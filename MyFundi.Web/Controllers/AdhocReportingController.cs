using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.UnitOfWork.Interfaces;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using Microsoft.AspNetCore.Authorization;
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

        private Mapper _mapper;
        public AdhocReportingController(IMailService emailService, MyFundiUnitOfWork unitOfWork,Mapper mapper, AppSettingsConfigurations appSettings)
        {
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
            var filePathInfo = new FileInfo(currentDir.FullName + "\\AndroidPhoneLocationApp\\XamarinForms.locationservice.apk");
            Response.ContentType = "multipart/form-data";
            Response.Headers.Add("Content-Disposition", "attachment; filename=\"XamarinForms.locationservice.apk\"");

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
            try {
                if (_currentFundilocations.Contains(fundiLocationViewModel))
                {
                    _currentFundilocations.Remove(fundiLocationViewModel);
                    return await Task.FromResult(Ok(new { Message = $"Removed Fundi: {fundiLocationViewModel.fundiUserDetails.Username} from Map" }));
                }
                else{
                    return await Task.FromResult(BadRequest(new { Message = $" Fundi: {fundiLocationViewModel.fundiUserDetails.Username} Is not being tracked at the moment!!" }));
                }
            }
            catch(Exception e)
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
                return await Task.FromResult(Ok(new {Succeded = true, Message = "Succesfully Sent Your Email!"}));
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
                    var actLocations = _currentFundilocations.FirstOrDefault(q => q.PhoneNumber.Equals(fundiLocationViewModel.PhoneNumber));
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

        [HttpGet]
        public async Task<IActionResult> GetFundiLiveLocations()
        {
            try
            {
                return await Task.FromResult(Ok(_currentFundilocations.ToArray()));
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new { result = false, message = "Failed To Get Vehicles" }));
            }
        }
        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllUnScheduledVehiclesByStorageCapacityLowestPrice()
        {
            try
            {
                var allUnscheduledVehiclesAvailable = _unitOfWork.MyFundiDBContext.GetAllUnScheduledVehiclesByStorageCapacityLowestPrice();
                return Ok(await Task.FromResult(allUnscheduledVehiclesAvailable));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }

        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllScheduledVehiclesByStorageCapacityLowestPrice()
        {
            try
            {
                var vehiclesAvailableLowestPriceByStorageCapacity = _unitOfWork.MyFundiDBContext.GetAllScheduledVehiclesByStorageCapacityLowestPrice();
                return await Task.FromResult(Ok(vehiclesAvailableLowestPriceByStorageCapacity));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }
        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetFoodHubCommoditiesStockStorageUsage()
        {
            try
            {
                var foodHubCommoditiesStorageUsageByFoodHubId = _unitOfWork.MyFundiDBContext.GetFoodHubCommoditiesStockStorageUsage();
                return await Task.FromResult(Ok(foodHubCommoditiesStorageUsageByFoodHubId));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }

        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllFoodHubCommoditiesStockStorageUsage()
        {
            try
            {
                var allFoodHubCommoditiesStorage = _unitOfWork.MyFundiDBContext.GetFoodHubCommoditiesStockStorageUsage();
                return await Task.FromResult(Ok(allFoodHubCommoditiesStorage));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }
        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetTop5DryCommoditiesInDemandRatingAccordingToStorageFacilities()
        {
            try
            {
                var result = _unitOfWork.MyFundiDBContext.GetTop5DryCommoditiesInDemandRatingAccordingToStorageFacilities();
                return await Task.FromResult(Ok(result));
            }
            catch (Exception e)
            {
                return BadRequest("You have used some bad arguments. Check and Try Again");
            }
        }

        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetTop5RefreigeratedCommoditiesInDemandRatingAccordingToStorageFacilities()
        {
            try
            {
                var top5RefreigeratedCommoditiesInDemandAccordingToStorageRating = _unitOfWork.MyFundiDBContext.GetTop5RefreigeratedCommoditiesInDemandRatingAccordingToStorageFacilities();
                return await Task.FromResult(Ok(top5RefreigeratedCommoditiesInDemandAccordingToStorageRating));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }


        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetFoodHubDateAnalysisCommoditiesStockStorageUsage()
        {
            try
            {
                var foodHubCommoditiesStorageUsage = _unitOfWork.MyFundiDBContext.GetFoodHubDateAnalysisCommoditiesStockStorageUsage(DateTime.Now.AddYears(-1), DateTime.Now);
                return await Task.FromResult(Ok(foodHubCommoditiesStorageUsage));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }

        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllFoodHubDateAnalysisCommoditiesStockStorageUsage()
        {
            try
            {
                var allFoodHubCommoditiesStorageUsage = _unitOfWork.MyFundiDBContext.GetAllFoodHubDateAnalysisCommoditiesStockStorageUsage(DateTime.Now.AddYears(-1), DateTime.Now);
                return await Task.FromResult(Ok(allFoodHubCommoditiesStorageUsage));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }

        [AuthorizeIdentity]
        public async Task<IActionResult> GetTop5DryCommoditiesDateAnalysisInDemandRatingAccordingToStorageFacilities()
        {
            try
            {
                var top5DryStorageCommoditisInDemand = _unitOfWork.MyFundiDBContext.GetTop5DryCommoditiesDateAnalysisInDemandRatingAccordingToStorageFacilities(DateTime.Now.AddYears(-1), DateTime.Now);
                return await Task.FromResult(Ok(top5DryStorageCommoditisInDemand));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }

        public async Task<IActionResult> GetTop5RefreigeratedCommoditiesDateAnalysisInDemandRatingAccordingToStorageFacilitiess()
        {
            try
            {
                var top5RefreigeratedCommoditisInDemand = _unitOfWork.MyFundiDBContext.GetTop5RefreigeratedCommoditiesDateAnalysisInDemandRatingAccordingToStorageFacilitiess(DateTime.Now.AddYears(-1), DateTime.Now);
                return await Task.FromResult(Ok(top5RefreigeratedCommoditisInDemand));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }

        public async Task<IActionResult> GetTop5FarmerCommoditiesDateAnalysisInUnitPricingOverDate()
        {
            try
            {
                var top5FarmersCommoditiesByUnitPrice = _unitOfWork.MyFundiDBContext.GetTop5FarmerCommoditiesDateAnalysisInUnitPricingOverDate(DateTime.Now.AddYears(-1), DateTime.Now);
                return await Task.FromResult(Ok(top5FarmersCommoditiesByUnitPrice));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }
        public async Task<IActionResult> GetTop5FarmerCommoditiesDateAnalysisInUnitPricing()
        {
            try
            {
                var top5FarmersCommoditiesByUnitPrice = _unitOfWork.MyFundiDBContext.GetTop5FarmerCommoditiesInUnitPricings();
                return await Task.FromResult(Ok(top5FarmersCommoditiesByUnitPrice));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }
        public async Task<IActionResult> GetTop5PricingAllUnScheduledVehiclesByStorageCapacityLowestPrice()
        {
            try
            {
                var top5PricingsUncheduledVehicles = _unitOfWork.MyFundiDBContext.GetTop5PricingAllUnScheduledVehiclesByStorageCapacityLowestPrice();
                return await Task.FromResult(Ok(top5PricingsUncheduledVehicles));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest("You have used some bad arguments. Check and Try Again"));
            }
        }
    }
}
