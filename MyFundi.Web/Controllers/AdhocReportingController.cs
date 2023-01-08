using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.UnitOfWork.Interfaces;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using MyFundi.Web.IdentityServices;
using MyFundi.Web.ViewModels;
using System.Net.Http;
using System.Text.Json;
using MyFundi.Web.Models;
using AutoMapper;
using System.IO;
using Microsoft.Extensions.Configuration;
using MyFundi.AppConfigurations;
using MyFundiProfile.ServiceEndPoint.GeneralSevices;
using MyFundi.Web.Infrastructure;
using MartinLayooInc.Web.Infrastructure;
using System.Text;
using System.Threading;

namespace MyFundi.Web.Controllers
{
    [EnableCors(PolicyName = "CorsPolicy")]
    public class AdhocReportingController : Controller
    {
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private List<FundiLocationViewModel> _currentFundilocations;
        private ServicesEndPoint _serviceEndPoint;
        private IConfigurationSection _businessSmtpDetails;

        private MartinLayooIncChat ChatResource = null;
        private Mapper _mapper;
        public AdhocReportingController(IMailService emailService, MyFundiUnitOfWork unitOfWork, Mapper mapper, AppSettingsConfigurations appSettings, MartinLayooIncChat martinLayooIncChat)
        {
            ChatResource = martinLayooIncChat;
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _currentFundilocations = new List<FundiLocationViewModel>();
            _mapper = mapper;
            _businessSmtpDetails = appSettings.AppSettings.GetSection("BusinessSmtpDetails");
            _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
        }
        [HttpGet]
        [Route("~/{Controller}/{Action}/{appType}")]
        public async Task<IActionResult> GetLocationEmitterApp(string appType)
        {
            try
            {
                switch (appType)
                {
                    case "android":
                        return await GetFileAndroid();
                    case "ios":
                        return await GetFileIos();
                    default:
                        return await GetFileAndroid();
                }
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }


        private async Task<FileContentResult> GetFileAndroid()
        {
            DirectoryInfo currentDir = new DirectoryInfo(Directory.GetCurrentDirectory());
            var filePathInfo = new FileInfo(currentDir.FullName + "\\AndroidPhoneLocationApp\\xamarinforms.locationservice.apk");
            Response.ContentType = "multipart/form-data";
            Response.Headers.Add("Content-Disposition", "attachment; filename=\"MartinLayooIncLocationEmitter.apk\"");

            if (filePathInfo.Exists)
            {
                using (var strReader = filePathInfo.OpenRead())
                {

                    var bytes = new byte[strReader.Length];

                    strReader.Read(bytes, 0, bytes.Length);

                    strReader.Flush();
                    strReader.Close();
                    var result = await Task.FromResult(File(bytes, "multipart/form-data", "XamarinForms.locationservice.apk"));

                    return result;
                    /*
                    var maxBytesRead = 4096;
                    var bytesRead = 0;
                    var bytes = new byte[maxBytesRead];

                    while(( bytesRead = strReader.Read(bytes,0,maxBytesRead)) > 0){
                       await contentBodyStream.WriteAsync(bytes, 0, bytesRead);
                    }
                    contentBodyStream.Flush();
                    contentBodyStream.Close();
                    
                    return Ok(new {Message="Downloaded Android App Successfully"});
                    */
                }
            }
            return await Task.FromResult(File(System.Text.Encoding.UTF8.GetBytes("Failed to Download Android App"), "text/plain"));
        }

        private async Task<FileContentResult> GetFileIos()
        {
            DirectoryInfo currentDir = new DirectoryInfo(Directory.GetCurrentDirectory());
            var filePathInfo = new FileInfo(currentDir.FullName + "\\IosPhoneLocationApp\\XamarinForms.locationservice.ipa");
            Response.ContentType = "multipart/form-data";
            Response.Headers.Add("Content-Disposition", "attachment; filename=\"XamarinForms.locationservice.ipa\"");

            if (filePathInfo.Exists)
            {
                using (var strReader = filePathInfo.OpenRead())
                {
                    var bytes = new byte[strReader.Length];

                    strReader.Read(bytes, 0, bytes.Length);

                    strReader.Flush();
                    strReader.Close();
                    var result = await Task.FromResult(File(bytes, "multipart/form-data", "XamarinForms.locationservice.ipa"));

                    return result;
                    /*
                    var maxBytesRead = 4096;
                    var bytesRead = 0;
                    var bytes = new byte[maxBytesRead];

                    while ((bytesRead = strReader.Read(bytes, 0, maxBytesRead)) > 0)
                    {
                        await contentBody.WriteAsync(bytes, 0, bytesRead);
                    }
                    contentBody.Flush();

                    return Ok(new { Message = "Downloaded IOS App Successfully" });
                    */
                }
            }
            return await Task.FromResult(File(System.Text.Encoding.UTF8.GetBytes("Failed to Download IOS App"), "text/plain"));
        }

        [HttpPost]
        public async Task<IActionResult> RemoveFundiFromMonitor([FromBody] FundiLocationViewModel fundiLocationViewModel)
        {
            try
            {
                if (_currentFundilocations.Contains(fundiLocationViewModel))
                {
                    _currentFundilocations.Remove(fundiLocationViewModel);
                    return await Task.FromResult(Ok(new { Message = $"Removed Fundi: {fundiLocationViewModel.fundiUserDetails.Username} from Map" }));
                }
                else
                {
                    return await Task.FromResult(BadRequest(new { Message = $" Fundi: {fundiLocationViewModel.fundiUserDetails.Username} Is not being tracked at the moment!!" }));
                }
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(new { Message = "An Error Occured While Removing Fundi!!" }));
            }
        }
        [HttpPost]
        public async Task<IActionResult> GetClientEmailAndMobilePhoneNumber([FromBody] UserDetails userDetail)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(userDetail.emailAddress);

            if (user != null)
            {
                //Validate: mobile number
                if (user.MobileNumber.Equals(userDetail.mobileNumber))
                {
                    return await Task.FromResult(Ok(new { message = "Verified", statusCode = 200 }));
                }
            }
            return await Task.FromResult(Ok(new { message = "Failed Validation. User not Found!", statusCode = 400 }));
        }

        [AuthorizeIdentity]
        [HttpPost]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> SendEmail()
        {
            try
            {
                _emailService.BusinessEmailDetails = _businessSmtpDetails;
                //Send Email:
                _emailService.SendEmail(new EmailDao { Attachment = Request.Form.Files.Any() ? Request.Form.Files[0] : null, EmailBody = Request.Form["emailBody"], EmailFrom = Request.Form["emailFrom"], EmailSubject = Request.Form["emailSubject"], EmailTo = Request.Form["emailTo"] });
                return await Task.FromResult(Ok(new { Succeded = true, Message = "Succesfully Sent Your Email!" }));
            }
            catch (Exception e)
            {
                return await Task.FromResult(Ok(new { Succeded = false, Message = "Failed to Send Your Email!" }));
            }
        }
        [HttpPost]
        public async Task<IActionResult> MonitorAndPlotVehicleOnMap([FromBody] FundiLocationViewModel fundiLocationViewModel)
        {
            try
            {
                User fundiUser = null;
                var httpClient = new HttpClient();
                var content = new { authToken = Request.Headers["authToken"], emailAddress = string.Empty, username = string.Empty };

                var jsonString = JsonSerializer.Serialize(content);

                //Request.Headers.Add("Content-Type", "application/json");
                var httpContent = new StringContent(jsonString);

                HttpResponseMessage respContent = await httpClient.PostAsync("https://myfundiv2/Account/UserCredentialsAuthenticate", httpContent);

                var jsonStr = await respContent.Content.ReadAsStringAsync();

                var userCredential = JsonSerializer.Deserialize<LoginResult>(jsonStr);
                fundiUser = _unitOfWork._userRepository.GetAll().FirstOrDefault(u => u.Email.ToLower().Equals(userCredential.Username.ToLower()));

                fundiLocationViewModel.fundiUserDetails = _mapper.Map<UserViewModel>(fundiUser);

                if (fundiLocationViewModel.UpdatePhoneNumber)
                {

                    if (userCredential != null && !string.IsNullOrEmpty(userCredential.Username))
                    {
                        if (fundiUser != null)
                        {
                            fundiUser.MobileNumber = fundiLocationViewModel.PhoneNumber;
                            _unitOfWork.SaveChanges();
                        }
                    }
                }
                if (!_currentFundilocations.Contains(fundiLocationViewModel))
                {
                    _currentFundilocations.Add(fundiLocationViewModel);
                }
                else
                {
                    var actLocations = _currentFundilocations.FirstOrDefault(q => q.EmailAddress.ToLower().Equals(fundiLocationViewModel.EmailAddress.ToLower()));
                    actLocations.Lattitude = fundiLocationViewModel.Lattitude;
                    actLocations.Longitude = fundiLocationViewModel.Longitude;
                    actLocations.fundiUserDetails = fundiLocationViewModel.fundiUserDetails;
                    actLocations.PhoneNumber = fundiLocationViewModel.PhoneNumber;
                }
                return await Task.FromResult(Ok(new { Result = true, Message = "Added Fundi Tracking" }));
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new { result = false, message = "Failed To Add Tracking" }));
            }
        }

        //Chat Functions.............................//////


        [HttpPost]
        [Route("~/Adhoc/IsInPrivateRoom")]
        public bool IsInPrivateRoom([FromBody] Client clt)
        {
            if (ChatResource.Rooms[clt.RoomNumber].First().FirstOrDefault(q => q.Username.ToLower().Equals(clt.Username.ToLower())) != null) return true;
            return false;
        }

        [HttpPost]
        [Route("~/Adhoc/InviteClient")]
        public Client InviteClient([FromBody] Client clt)
        {
            Client client = new Client { Username = clt.Username, Messages = new Queue<Message>(), RoomNumber = clt.RoomNumber, TimeStarted = DateTime.Now };
            ChatResource.AddClientToChatRoom(client);
            MartinLayooIncChat.GlobalMessageQueue.Enqueue(new Message { ClientMessage = clt.CurrentMessage, MessageWasSent = false });
            client.CurrentMessage += $" [[{clt.RoomNumber}]]-Invite";
            ChatResource.Rooms[clt.RoomNumber].First().Enqueue(client);
            return client;
        }

        [HttpPost]
        [Route("~/Adhoc/ExitPrivateRoom")]
        public void ExitPrivateRoom([FromBody] Client clt)
        {
            Client client = new Client { Username = clt.Username, CurrentMessage = clt.CurrentMessage };
            var clientToRemove = ChatResource.Rooms[clt.RoomNumber].First().FirstOrDefault(q => q.Username.ToLower().Equals(clt.Username.ToLower()));

            if (clientToRemove != null)
            {
                clientToRemove.RemoveFromRoom = true;
                AddExitMessagePrivateRoom(clt);
            }
        }
        [Route("~/Adhoc/ClearPrivateRoom/{roomNumber}")]
        public void ClearPrivateRoom(int roomNumber)
        {
            ChatResource.Rooms.Remove(roomNumber);
            ChatResource.CleanRoom();
        }
        [Route("~/Adhoc/ClearAllRooms")]
        public void ClearAllRooms()
        {
            ChatResource.CleanRoom();
        }

        [HttpPost]
        [Route("~/Adhoc/AddExitMessagePrivateRoom")]
        public void AddExitMessagePrivateRoom([FromBody] Client clt)
        {
            Client client = new Client { Username = clt.Username, CurrentMessage = clt.CurrentMessage, RemoveFromRoom = true };
            var actualClient = ChatResource.Rooms[clt.RoomNumber].First().FirstOrDefault(q => q.Username.ToLower().Equals(clt.Username.ToLower()));
            if (actualClient != null)
                actualClient.Messages.Enqueue(new Message { ClientMessage = clt.CurrentMessage, TimeSent = DateTime.Now });
        }

        [HttpPost]
        [Route("~/Adhoc/AddMessagePrivateRoom")]
        public bool AddMessagePrivateRoom([FromBody] Client clt)
        {
            Client client = new Client { Username = clt.Username };
            var actualClient = ChatResource.Rooms[clt.RoomNumber].First().FirstOrDefault(q => q.Username.ToLower().Equals(clt.Username.ToLower()));
            if (actualClient != null && !string.IsNullOrEmpty(clt.CurrentMessage))
            {
                actualClient.Messages.Enqueue(new Message { ClientMessage = clt.CurrentMessage, TimeSent = DateTime.Now });
                return true;
            }
            return false;
        }

        [HttpPost]
        [Route("~/Adhoc/AddMessageAllRooms")]
        public Client AddMessageAllRooms([FromBody] Client clt)
        {
            if (!string.IsNullOrEmpty(clt.CurrentMessage))
            {
                Client client = new Client { Username = clt.Username, CurrentMessage = clt.CurrentMessage };
                MartinLayooIncChat.GlobalMessageQueue.Enqueue(new Message { ClientMessage = client.CurrentMessage });
                return client;
            }
            return null;
        }

        [Route("~/Adhoc/GetMessage/{roomNumber}")]
        public Message GetMessage(int roomNumber)
        {
            if (ChatResource.Rooms[roomNumber].FirstOrDefault() != null)
            {

                var queue = ChatResource.Rooms[roomNumber].First();
                var clt = queue.LastOrDefault();
                Thread.Sleep(1500);
                if (clt != null)
                {
                    var msg = clt.Messages.LastOrDefault();

                    if (msg != null && !string.IsNullOrEmpty(msg.ClientMessage))
                    {

                        return new Message
                        {
                            ClientMessage = $"<span style=\"color:red !important;\">{clt.Username}: </span>{msg.ClientMessage}<br>",
                            MessageWasSent = true,
                            TimeSent = DateTime.Now
                        };
                    }
                    else
                    {
                        if (clt.Messages.Count > 0)
                            clt.Messages.Dequeue();
                        return null;
                    }
                }
            }
            return null;
        }
        [Route("~/Adhoc/GetBroadcastMessages")]
        public dynamic GetBroadcastMessages()
        {

            var currentGlobalMessage = MartinLayooIncChat.GlobalMessageQueue.LastOrDefault();

            Thread.Sleep(5000);
            if (currentGlobalMessage != null)
            {
                currentGlobalMessage.TimeSent = DateTime.Now;
                currentGlobalMessage.MessageWasSent = true;
                return new { Message = currentGlobalMessage.ClientMessage, MessageWasSent = currentGlobalMessage.MessageWasSent, TimeSent = currentGlobalMessage.TimeSent };
            }
            return null;
        }

        [Route("~/Adhoc/GetUserList/{roomNumber}")]
        public Client[] GetUserList(int roomNumber)
        {
            Thread.Sleep(2500);
            var list = new List<Client>();
            if (ChatResource.Rooms[roomNumber].FirstOrDefault() == null) return list.ToArray();

            foreach (var clt in ChatResource.Rooms[roomNumber].First())
            {
                list.Add(clt);
            }

            return list.ToArray();
        }
        [HttpPost]
        [Route("~/Adhoc/CheckRegisterUserAvailability")]
        public dynamic CheckRegisterUserAvailability([FromBody] Client availableClient)
        {
            try
            {
                var client = MartinLayooIncChat.AllUsersList.FirstOrDefault(q => q.Username.ToLower().Equals(availableClient.Username.ToLower()));
                if (client != null)
                {
                    return new { IsRegistered = true, registration="Client already Registered" };
                }
                else
                {
                    MartinLayooIncChat.AllUsersList.Add(availableClient);
                    return new { IsRegistered = true, registration="New Client Registration!" };
                }
            }
            catch(Exception e)
            {
                return new { IsRegistered = false};
            }

        }
        [HttpPost]
        [Route("~/Adhoc/RemoveUserAvailability")]
        public dynamic RemoveUserAvailability([FromBody] Client availableClient)
        {
            try
            {
                var isRemovable = false;
                var n = 0;
                for (n = 0; n < MartinLayooIncChat.AllUsersList.Count; n++)
                {
                    if (MartinLayooIncChat.AllUsersList[n].Username.ToLower().Equals(availableClient.Username.ToLower()))
                    {
                        isRemovable = true;
                        break;
                    }
                }
                if(isRemovable)
                MartinLayooIncChat.AllUsersList.RemoveAt(n);

                return new { isRemoved = true };
            }
            catch (Exception e)
            {
                return new { isRemoved = false };
            }

        }
        [Route("~/Adhoc/GetAllUsers")]
        public Client[] GetAllUsers()
        {
            return MartinLayooIncChat.AllUsersList.ToArray();
        }

        [HttpPost]
        [Route("~/Adhoc/BookPrivateRoom")]
        public Client BookPrivateRoom([FromBody] Client clt)
        {
            if (String.IsNullOrEmpty(clt.Username))
            {
                return null;
            }
            Client client = new Client { Username = clt.Username, Messages = clt.Messages = new Queue<Message>(), CurrentMessage = clt.CurrentMessage };
            client.ClientBooker = clt.Username;
            client.TimeStarted = DateTime.Now;

            if (ChatResource.AddClientToChatRoom(clt))
            {
                return clt;
            }
            else
            {
                return null;
            }
        }
        [Route("~/Adhoc/GetBookerClient/{roomNumber}")]
        public string GetBookerClient(int roomNumber)
        {
            Client bclient = null;
            bclient = ChatResource.Rooms[roomNumber].First().FirstOrDefault(q => !string.IsNullOrEmpty(q.ClientBooker));
            if (bclient != null) return bclient.ClientBooker;
            else return null;
        }

    }
}
