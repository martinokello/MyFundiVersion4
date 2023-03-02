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
using Microsoft.AspNetCore.Http;

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
        public AdhocReportingController(IMailService emailService, MyFundiUnitOfWork unitOfWork, Mapper mapper, IConfiguration appSettings, MartinLayooIncChat martinLayooIncChat, List<FundiLocationViewModel> currentFundiLocations)
        {
            ChatResource = martinLayooIncChat;
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
            _currentFundilocations = currentFundiLocations;
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
        public async Task<IActionResult> SaveFundiGeoLocation([FromBody] FundiLocationViewModel fundiLocationViewModel)
        {
            try
            {
                var fundiLocation = _mapper.Map<FundiLocation>(fundiLocationViewModel);
                _unitOfWork._fundiLocationRepository.Insert(fundiLocation);
                _unitOfWork.SaveChanges();
               return await Task.FromResult(Ok( new { Message = "Geolocation Saved", Result=true }));
            }
            catch (Exception e)
            {

                return await Task.FromResult(BadRequest(new { Message = "Failed To Save Geolocation", Result = false }));
            }
        }
        
        [HttpPost]
        public async Task<IActionResult> RemoveFundiFromMonitor([FromBody] FundiLocationViewModel fundiLocationViewModel)
        {
            try
            {
                if (_currentFundilocations.Contains(fundiLocationViewModel))
                {
                    _currentFundilocations.Remove(fundiLocationViewModel);
                    await SaveFundiGeoLocation(fundiLocationViewModel);
                    return await Task.FromResult(Ok(new { Message = $"Removed Fundi: {fundiLocationViewModel.Username} from Map", Success = true })); ;
                }
                else
                {
                    return await Task.FromResult(BadRequest(new { Message = $" Fundi: {fundiLocationViewModel.Username} Is not being tracked at the moment!!", Success = false }));
                }
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(new { Message = "An Error Occured While Removing Fundi!!", Success = false }));
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
                else if(userDetail.replaceMobileNumber)
                {
                    var currentUser = _unitOfWork._userRepository.GetAll().FirstOrDefault(q => q.Username.ToLower().Equals(userDetail.username.ToLower()));
                    currentUser.MobileNumber = userDetail.mobileNumber;
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(Ok(new { message = "Verified, and Mobile Number Updated, to "+currentUser.MobileNumber, statusCode = 200 }));
                }
            }
            return await Task.FromResult(NotFound(new { message = "Failed Validation. User not Found!", statusCode = 400 }));
        }
        [HttpGet]
        [Route("~/AdhocReporting/GetFundiLiveLocationsByUsername/{username}")]
        public async Task<IActionResult> GetFundiLiveLocationsByUsername(string username)
        {
            try
            {
                return await Task.FromResult(Ok(_currentFundilocations.FirstOrDefault(q => q.Username.ToLower().Equals(username.ToLower()))));
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new { result = false, message = "Failed To Get Fundi Location" }));
            }
        }
        
       [HttpGet]
        public async Task<IActionResult> GetFundiLiveLocations()
        {
            try
            {
                return await Task.FromResult(Ok(_currentFundilocations));
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new { result = false, message = "Failed To Get Fundi Location" }));
            }
        }
        [AuthorizeIdentity]
        [HttpPost]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> SendEmail([FromForm(Name="attachment")] IFormFile attachment)
        {
            try
            {
                //Send Email:
                _emailService.SendEmail(new EmailDao { Attachment = attachment, EmailBody = Request.Form["emailBody"], EmailFrom = Request.Form["emailFrom"], EmailSubject = Request.Form["emailSubject"], EmailTo = Request.Form["emailTo"] });
                return await Task.FromResult(Ok(new { Succeded = true, Message = "Succesfully Sent Your Email!" }));
            }
            catch (Exception e)
            {
                return await Task.FromResult(Ok(new { Succeded = false, Message = "Failed to Send Your Email!\n"+e.Message+"\n"+e.StackTrace }));
            }
        }
        [HttpPost]
        public async Task<IActionResult> MonitorAndPlotVehicleOnMap([FromBody] FundiLocationViewModel fundiLocationViewModel)
        {
            try
            {
                User fundiUser = _unitOfWork._userRepository.GetAll().FirstOrDefault(u => u.Email.ToLower().Equals(fundiLocationViewModel.Username.ToLower()));

                if (fundiUser != null)
                {

                    if (_currentFundilocations.Count == 0 || !_currentFundilocations.Contains(fundiLocationViewModel))
                    {
                        _currentFundilocations.Add(fundiLocationViewModel);
                    }
                    else
                    {
                        var actLocations = _currentFundilocations.FirstOrDefault(q => q.Username.ToLower().Equals(fundiLocationViewModel.Username.ToLower()));
                        actLocations.Latitude = fundiLocationViewModel.Latitude;
                        actLocations.Longitude = fundiLocationViewModel.Longitude;
                        actLocations.MobileNumber = fundiLocationViewModel.MobileNumber;
                    }
                    if (fundiLocationViewModel.replaceMobileNumber)
                    {
                        fundiUser.MobileNumber = fundiLocationViewModel.MobileNumber;
                        _unitOfWork.SaveChanges();
                        return await Task.FromResult(Ok(new { Message = "Verified, and Mobile Number Updated, to " + fundiLocationViewModel.MobileNumber, statusCode = 200, Result=true }));
                    }
                    return await Task.FromResult(Ok(new { Result = true, Message = "Added Fundi Tracking" }));
                }
                return await Task.FromResult(NotFound(new { Result = false, Message = "Fundi Not Found!!" }));
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new { result = false, message = "Failed To Add Tracking"+Environment.NewLine+ex.Message+Environment.NewLine+ex.StackTrace }));
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
            Client client = new Client {CurrentMessage=clt.CurrentMessage+ $" [[{clt.RoomNumber}-Invite]]",Username = clt.Username, Messages = new Queue<Message>(), RoomNumber = clt.RoomNumber, TimeStarted = DateTime.Now };
            ChatResource.AddClientToChatRoom(client);
            MartinLayooIncChat.GlobalMessageQueue.Enqueue(new Message { ClientMessage = client.CurrentMessage, MessageWasSent = false, MessageFrom=clt.Username });
             
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
                ChatResource.Rooms[clt.RoomNumber].First().Enqueue(actualClient);
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
                MartinLayooIncChat.GlobalMessageQueue.Enqueue(new Message { ClientMessage = client.CurrentMessage, MessageFrom=clt.Username });
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
