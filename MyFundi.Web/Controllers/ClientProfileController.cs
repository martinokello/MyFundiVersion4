using AutoMapper;
using BLG.Business.Interfaces;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MyFundi.AppConfigurations;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.Web.IdentityServices;
using MyFundi.Web.ViewModels;
using MyFundiProfile.ServiceEndPoint.GeneralSevices;
using Newtonsoft.Json;
using PaymentGateway;
using PaypalFacility;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace MyFundi.Web.Controllers
{
    [EnableCors(PolicyName = "CorsPolicy")]
    public class ClientProfileController : Controller
    {
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private ServicesEndPoint _serviceEndPoint;
        private IConfigurationSection _applicationConstants;
        private IConfigurationSection _businessSmtpDetails;
        private IConfigurationSection _twitterProfileFiguration;
        private PaymentsManager PaymentsManager;
        private Mapper _mapper;
        private IHostingEnvironment Environment;
        private decimal _clientSubscriptionFee;
        private dynamic _payMtnAirTelRedirectUrl;
        private HttpClient _httpClient;

        public ClientProfileController(IMailService emailService, MyFundiUnitOfWork unitOfWork, AppSettingsConfigurations appSettings, PaymentsManager paymentsManager, Mapper mapper, IHostingEnvironment _environment)
        {
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _applicationConstants = appSettings.AppSettings.GetSection("ApplicationConstants");
            _twitterProfileFiguration = appSettings.AppSettings.GetSection("TwitterProfileFiguration");
            _businessSmtpDetails = appSettings.AppSettings.GetSection("BusinessSmtpDetails");
            _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
            PaymentsManager = paymentsManager;
            _mapper = mapper;
            Environment = _environment;
            var mtnSection = appSettings.AppSettings.GetSection("MTNApiConfig");
            _clientSubscriptionFee = mtnSection.GetValue<decimal>("ClientSubscriptionFee");
            _payMtnAirTelRedirectUrl = mtnSection.GetValue<string>("MTNBaseUrl");
            _httpClient = new HttpClient();
        }
        public async Task<IActionResult> GetClientProfileImageByUsername(string username)
        {

            string contentPath = this.Environment.ContentRootPath;

            string clientProfileImagePath = contentPath + "\\ClientProfile\\ProfileImage_" + username + ".jpg";

            var profInfo = new FileInfo(clientProfileImagePath);
            using (var stream = profInfo.OpenRead())
            {
                byte[] bytes = new byte[4096];
                int bytesRead = 0;
                Response.ContentType = "image/jpg";
                using (var wstr = Response.BodyWriter.AsStream())
                {
                    while ((bytesRead = stream.Read(bytes, 0, bytes.Length)) > 0)
                    {
                        wstr.Write(bytes, 0, bytesRead);
                    }
                    wstr.Flush();
                    wstr.Close();
                }
            }
            return await Task.FromResult(Ok(new { Message = "Profile Image downloaded Successfully" }));
        }
        public async Task<IActionResult> GetClientProfileImageByProfileId(int clientProfileId)
        {

            string contentPath = this.Environment.ContentRootPath;
            var clientProfile = _unitOfWork._clientProfileRepository.GetById(clientProfileId);
            var username = _unitOfWork._userRepository.GetByGuid(clientProfile.UserId).Username;

            string fundiProfileImagePath = contentPath + "\\ClientProfile\\ProfileImage_" + username + ".jpg";

            var profInfo = new FileInfo(fundiProfileImagePath);
            using (var stream = profInfo.OpenRead())
            {
                byte[] bytes = new byte[4096];
                int bytesRead = 0;
                Response.ContentType = "image/jpg";
                using (var wstr = Response.BodyWriter.AsStream())
                {
                    while ((bytesRead = stream.Read(bytes, 0, bytes.Length)) > 0)
                    {
                        wstr.Write(bytes, 0, bytesRead);
                    }
                    wstr.Flush();
                    wstr.Close();
                }
            }
            return await Task.FromResult(Ok(new { Message = "Profile Image downloaded Successfully" }));

        }

        private Byte[] BitmapToBytes(Bitmap img)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                img.Save(stream, System.Drawing.Imaging.ImageFormat.Png);
                return stream.ToArray();
            }
        }

        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetClientUserByProfileId/{profileId}")]
        public async Task<IActionResult> GetClientUserByProfileId(int profileId)
        {
            var clientProfile = _unitOfWork._clientProfileRepository.GetById(profileId);
            var user = _unitOfWork._userRepository.GetByGuid(clientProfile.UserId);

            if (user == null || clientProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = "User not found" }));
            }
            return await Task.FromResult(Ok(_mapper.Map<UserViewModel>(user)));
        }

        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetAllClientJobByClientProfileId/{clientProfileId}")]
        public async Task<IActionResult> GetAllClientJobByClientProfileId(int clientProfileId)
        {
            var clientJobs = _unitOfWork._jobRepository.GetAll().Where(q => q.ClientProfileId == clientProfileId).Include(q => q.AssignedFundiProfile);

            if (clientJobs.Any())
            {
                return await Task.FromResult(Ok(_mapper.Map<JobViewModel[]>(clientJobs)));
            }
            return await Task.FromResult(NotFound(new { Message = "Jobs not found" }));
        }
        [AuthorizeIdentity]
        [Route("~/ClientProfile/DeleteJob/{jobId}")]
        public async Task<IActionResult> DeleteJob(int jobId)
        {
            var job = _unitOfWork._jobRepository.GetById(jobId);
            if (job != null)
            {
                job.AssignedFundiProfileId = null;
                job.AssignedFundiUserId = null;

                var hasDeleted = _unitOfWork._jobRepository.Delete(job);
                return await Task.FromResult(Ok(new { Message = "Job Deleted", Result = hasDeleted }));
            }
            else return await Task.FromResult(NotFound(new { Message = "Job Not Found", Result = false }));

        }
		[HttpGet]
        [Route("~/ClientProfile/GetClientProfile/{username}")]
        public async Task<IActionResult> GetClientProfile(string username)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(username);
            var clientProfile = _unitOfWork._clientProfileRepository.GetAll().Where(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || !clientProfile.Any())
            {
                return await Task.FromResult(NotFound(new { Message = "User not found Or ClientProfile doesn't exist!" }));
            }
            return await Task.FromResult(Ok(_mapper.Map<ClientProfileViewModel>(clientProfile.ToArray()[0])));
        }

        [AuthorizeIdentity]
        [HttpPost]
        public async Task<IActionResult> SaveClientProfileImage(string username, [FromForm] IFormFile profileImage)
        {
            try
            {
                if (profileImage.Length > 0 && !string.IsNullOrEmpty(username))
                {
                    string contentPath = this.Environment.ContentRootPath;
                    var profileDirPath = contentPath + "\\ClientProfile";
                    DirectoryInfo pfDir = new DirectoryInfo(profileDirPath);

                    var profileImgPath = pfDir.FullName + $"\\ProfileImage_{username}.jpg";
                    try
                    {
                        if (!pfDir.Exists)
                        {
                            throw new Exception("ClientProfile Directory Does not Exist!");
                        }
                        var existImgInfo = new FileInfo(profileImgPath);
                        if (existImgInfo.Exists)
                        {
                            System.GC.Collect();
                            System.GC.WaitForPendingFinalizers();
                            System.IO.File.Delete(profileImgPath);
                        }
                    }
                    catch (Exception e)
                    {
                        throw new Exception("ProfileImage Failed Deletion! Perhaps does not exist");
                    }
                    using (var stream = new FileStream(profileImgPath, FileMode.Create, FileAccess.ReadWrite))
                    {
                        await profileImage.CopyToAsync(stream);
                        stream.Flush();
                        stream.Close();
                    }
                }

                return await Task.FromResult(Ok(new { Message = "Succefully Inserted Fundi Profile Image" }));
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new { Message = "Profile Image not Inserted, therefore operation failed!" }));
            }



        }
        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllClientProfiles()
        {
            return await Task.FromResult(Ok(_unitOfWork._clientProfileRepository.GetAll().ToArray()));
        }

        [HttpGet]
        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetResultsRemoveWorkCategoryFromJobId/{jobId}/{workCategoryId}/{workSubCategoryId}")]
        public async Task<IActionResult> GetResultsRemoveWorkCategoryFromJobId(int jobId, int workCategoryId, int workSubCategoryId)
        {

            var result = _unitOfWork._jobRepository.GetAll().Where(j => j.JobId == jobId).Include(j => j.Location);
            var hasDeleted = false;
            try
            {
                var jbWorkCatsList = new List<object>();
                var jbWokCats = _unitOfWork._jobWorkCategoryRepository.GetAll().Where(q => q.JobId == jobId && q.WorkCategoryId == workCategoryId && q.WorkSubCategoryId == workSubCategoryId).ToList();

                foreach (var cat in jbWokCats)
                {
                    hasDeleted = _unitOfWork._jobWorkCategoryRepository.Delete(cat);
                }
                _unitOfWork.SaveChanges();
                return await Task.FromResult(Ok(hasDeleted));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(hasDeleted));
            }
        }
        [HttpGet]
        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetWorkSubCategoriesBySubCategoryId/{workSubCategoryId}")]
        public async Task<IActionResult> GetWorkSubCategoriesBySubCategoryId(int workSubCategoryId)
        {

            var result = _unitOfWork._workSubCategoryRepository.GetById(workSubCategoryId);
            try
            {
                if (result != null)
                {
                    var workSubCatViewModel = _mapper.Map<WorkSubCategoryViewModel>(result);
                    return await Task.FromResult(Ok(workSubCatViewModel));
                }
                return await Task.FromResult(NotFound(null));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(null));
            }
        }

        [HttpGet]
        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetClientProfileById/{clientProfileId}")]
        public async Task<IActionResult> GetClientProfileById(int clientProfileId)
        {

            var result = _unitOfWork._clientProfileRepository.GetById(clientProfileId);
            if (result != null)
            {
                return await Task.FromResult(Ok(result));
            }
            else
            {
                return null;
            }
        }
        [HttpGet]
        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetClientUserById/{clientUserId}")]
        public async Task<IActionResult> GetClientUserById(Guid clientUserId)
        {

            var result = _unitOfWork._userRepository.GetByGuid(clientUserId);
            if (result != null)
            {
                return await Task.FromResult(Ok(result));
            }
            else
            {
                return null;
            }
        }
        [HttpGet]
        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetJobByJobId/{jobId}")]
        public async Task<IActionResult> GetJobByJobId(int jobId)
        {
            var result = _unitOfWork._jobRepository.GetAll().Where(q => q.JobId == jobId).Include(q => q.Location);
            if (result.Count() > 0)
            {
                return await Task.FromResult(Ok(result.ToArray()[0]));
            }
            else
            {
                return null;
            }
        }
        [HttpGet]
        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetWorkCategoriesAndSubCategories")]
        public async Task<IActionResult> GetWorkCategoriesAndSubCategories()
        {

            var jbWokCats = (from wc in _unitOfWork._workCategoryRepository.GetAll()
                             join wsc in _unitOfWork._workSubCategoryRepository.GetAll()
                             on wc.WorkCategoryId equals wsc.WorkCategoryId
                             select new JobWorkCategoryViewModel
                             {
                                 WorkCategoryId = wc.WorkCategoryId,
                                 WorkSubCategoryId = wsc.WorkSubCategoryId,
                                 WorkCategory = wc,
                                 WorkSubCategory = wsc
                             }).ToArray();

            try
            {
                return await Task.FromResult(Ok(jbWokCats));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(new string[] { }));
            }
        }
        [HttpGet]
        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetJobWorkCategoriesByJobId/{jobId}")]
        public async Task<IActionResult> GetJobWorkCategoriesByJobId(int jobId)
        {

            var result = _unitOfWork._jobRepository.GetById(jobId);

            try
            {
                var jbWokCats = _unitOfWork._jobWorkCategoryRepository.GetAll().Where(q => q.JobId == jobId).Include(ch => ch.WorkCategory).Include(q => q.WorkSubCategory).ToArray();

                var jbWorkCatsList = _mapper.Map<JobWorkCategoryViewModel[]>(jbWokCats);
                return await Task.FromResult(Ok(jbWorkCatsList.ToArray()));
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(new string[] { }));
            }
        }

        [AuthorizeIdentity]
        [HttpPost]
        [Route("~/ClientProfile/CreateOrUpdateClientJob")]
        public async Task<IActionResult> CreateOrUpdateClientJob([FromBody] JobViewModel jobViewModel)
        {

            var workCats = jobViewModel.JobWorkCategoryIds.ToList();
            var job = _mapper.Map<Job>(jobViewModel);

            var result = _unitOfWork._jobRepository.GetById(job.JobId);

            try
            {

                if (result == null)
                {
                    _unitOfWork._jobRepository.Insert(job);
                    _unitOfWork.SaveChanges();
                    if (workCats.Any())
                    {
                        foreach (var wc in workCats)
                        {
                            _unitOfWork._jobWorkCategoryRepository.Insert(new JobWorkCategory { JobId = job.JobId, WorkCategoryId = wc.WorkCategoryId, WorkSubCategoryId = wc.WorkSubCategoryId });
                        }
                    }
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(Ok(new { Message = "Succefully Inserted Job" }));
                }
                else
                {
                    if (workCats.Any())
                    {
                        var jbWokCats = _unitOfWork._jobWorkCategoryRepository.GetAll().Where(q => q.JobId == job.JobId).ToList();
                        foreach (var cat in jbWokCats)
                        {
                            _unitOfWork._jobWorkCategoryRepository.Delete(cat);
                        }
                        _unitOfWork.SaveChanges();

                        foreach (var wc in workCats)
                        {
                            _unitOfWork._jobWorkCategoryRepository.Insert(new JobWorkCategory { JobId = job.JobId, WorkCategoryId = wc.WorkCategoryId, WorkSubCategoryId = wc.WorkSubCategoryId });
                        }
                    }
                    _unitOfWork._jobRepository.Update(job);
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(Ok(new { Message = "Succefully Updated Job" }));
                }
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(new { Message = $"Error: {e.Message}. Job and Client Profile to Update Fundi Profile!" }));
            }
        }

        [AuthorizeIdentity]
        [HttpPost]
        [Route("~/ClientProfile/CreateOrUpdateClientProfile")]
        public async Task<IActionResult> CreateOrUpdateClientProfile([FromBody] ClientProfileViewModel clientProfileViewModel)
        {
            if (ModelState.IsValid)
            {
                var clientProfile = _mapper.Map<ClientProfile>(clientProfileViewModel);

                var result = _unitOfWork._clientProfileRepository.GetById(clientProfile.ClientProfileId);

                if (result == null)
                {
                    _unitOfWork._clientProfileRepository.Insert(clientProfile);
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(Ok(new { Message = "Succefully Inserted Client Profile" }));
                }
                else
                {
                    _unitOfWork._clientProfileRepository.Update(clientProfile);
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(Ok(new { Message = "Succefully Updated Client Profile" }));
                }
            }
            return await Task.FromResult(BadRequest(new { Message = "Client Profile not Updated, therefore operation failed!" }));
        }
		[HttpGet]
		[Route("~/ClientProfile/GetClientMonthlySubscriptionsById/{username}/{clientSubscriptionId}")]
		public async Task<IActionResult> GetClientMonthlySubscriptionsById(string username, int clientSubscriptionId)
		{

			var subscriptions = _unitOfWork._clientSubscriptionRepository.GetAll().
				Where(q => q.Username.ToLower().Equals(username.ToLower()) && q.SubscriptionId == clientSubscriptionId).FirstOrDefault();
			var clientSubsViewModel = _mapper.Map<ClientSubscriptionViewModel>(subscriptions);
			return await Task.FromResult(Ok(clientSubsViewModel));
		}
        [HttpGet]
        [Route("~/ClientProfile/GetClientMonthlySubscriptionFee")]
        public async Task<IActionResult> GetClientMonthlySubscriptionFee(string username)
        {
            return await Task.FromResult(Ok(new { ClientSubscriptionFee = _clientSubscriptionFee }));
		}
		[HttpGet]
		[Route("~/ClientProfile/GetClientMonthlySubscriptions/{username}")]
		public async Task<IActionResult> GetClientMonthlySubscriptions(string username)
		{

			var subscriptions = _unitOfWork._clientSubscriptionRepository.GetAll().Where(q =>
			q.Username.ToLower().Equals(username.ToLower())).ToArray();
			var clientSubsViewModel = _mapper.Map<ClientSubscriptionViewModel[]>(subscriptions);
			return await Task.FromResult(Ok(clientSubsViewModel));
		}

		[HttpPost]
        [Route("~/ClientProfile/PayClientSubscriptionFeeWithPaypal")]
        public async Task<IActionResult> PayClientSubscriptionFeeWithPaypal([FromBody] ClientSubscriptionViewModel subscriptionViewModel)
        {
            try
            {
                var subscription = _mapper.Map<ClientSubscription>(subscriptionViewModel);
                var registrationSubscription = _unitOfWork._clientSubscriptionRepository.GetAll().FirstOrDefault(q => q.Username.ToLower().Equals(subscriptionViewModel.Username.ToLower()) && q.SubscriptionId == subscription.SubscriptionId);


				subscription.ClientProfileId = _unitOfWork._clientProfileRepository.GetAll().Include(q=> q.User).Where(q=> q.User.Username.ToLower().Equals(subscriptionViewModel.Username.ToLower())).FirstOrDefault().ClientProfileId;

				if (registrationSubscription != null)
                {
                    subscription = registrationSubscription;
                }
                var paymentsManager = this.PaymentsManager;

                var subCatQuantity = 1;
                var paypalRequestUrl = await paymentsManager.MakePaymentsPaypal(subscriptionViewModel.Username, new List<Product>
                    {
                        new Product{
                            Amount = _clientSubscriptionFee,
                            HasPaidInfull = true,
                            Quantity= subCatQuantity,
                            VATAmmount=(decimal) 0,
                            ProductName = subscriptionViewModel.SubscriptionName,
                            ProductDescription = subscriptionViewModel.SubscriptionDescription
                        }

                    });
                if(registrationSubscription == null)
                {
                    subscription.SubscriptionDescription = "Paid 7 day Subscription";
                    subscription.SubscriptionName = "Paid 7 day Subscription";
                    _unitOfWork._clientSubscriptionRepository.Insert(subscription);
                    _unitOfWork.SaveChanges();

				}
                else
                {
                    subscription.SubscriptionDescription = "Paid 7 day Subscription";
                    subscription.SubscriptionName = "Paid 7 day Subscription";
                    _unitOfWork._clientSubscriptionRepository.Update(subscription);
					_unitOfWork.SaveChanges();
				}
                return await Task.FromResult(Ok(new { Message = "Updated Subscription", PayPalRedirectUrl = paypalRequestUrl, Success = true }));

            }
            catch (Exception e)
            {
                return await Task.FromResult(Ok(new { Message = e.Message + " error: Failed To Pay. Please Contact Admin on Site" }));
            }
        }

        [HttpPost]
        [Route("~/ClientProfile/PayClientSubscriptionFeeWithMtn")]
        public async Task<IActionResult> PayClientSubscriptionFeeWithMtn([FromBody] ClientSubscriptionViewModel subscriptionViewModel)
        {
            try
            {
                var subCatQuantity = 1;

				var subscription = _mapper.Map<ClientSubscription>(subscriptionViewModel);
				var registrationSubscription = _unitOfWork._clientSubscriptionRepository.GetAll().FirstOrDefault(q => q.Username.ToLower().Equals(subscriptionViewModel.Username.ToLower()) && q.SubscriptionId == subscription.SubscriptionId);

				subscription.ClientProfileId = _unitOfWork._clientProfileRepository.GetAll().Include(q => q.User).Where(q => q.User.Username.ToLower().Equals(subscriptionViewModel.Username.ToLower())).FirstOrDefault().ClientProfileId;

				if (registrationSubscription != null)
                {
                    subscription = registrationSubscription;
                }
                var paymentsManager = this.PaymentsManager;
                var products = new List<Product>
                    {
                        new Product{
                            Amount = _clientSubscriptionFee,
                            HasPaidInfull = true,
                            Quantity= subCatQuantity,
                            VATAmmount=(decimal) 0,
                            ProductName = subscriptionViewModel.SubscriptionName,
                            ProductDescription = subscriptionViewModel.SubscriptionDescription
                        }

                    };
                if (registrationSubscription == null)
                {
                    subscription.DateUpdated = DateTime.Now;
                    subscription.StartDate = DateTime.Now;
                    subscription.SubscriptionDescription = "Paid 7 day Subscription";
                    subscription.SubscriptionName = "Paid 7 day Subscription";
                    _unitOfWork._clientSubscriptionRepository.Insert(subscription);
					_unitOfWork.SaveChanges();
				}
                else
                {
                    subscription.DateUpdated = DateTime.Now;
                    subscription.StartDate = DateTime.Now;
                    subscription.SubscriptionDescription = "Paid 7 day Subscription";
                    subscription.SubscriptionName = "Paid 7 day Subscription";
                    _unitOfWork._clientSubscriptionRepository.Update(subscription);
					_unitOfWork.SaveChanges();
				}

                var mtnAirtelObject = await paymentsManager.MakePaymentsMtnAirTel(subscriptionViewModel.Username, products, new PaypalFacility.Invoice(products, _clientSubscriptionFee, subscriptionViewModel.Username));

                return await Task.FromResult(Ok(mtnAirtelObject));
				/*var mtnAirtelObject = _payMtnAirTelRedirectUrl;

                var newMtnAirtelObject = new
                {
                    action = mtnAirtelObject.Action,
                    reason = mtnAirtelObject.Reason,
                    currency = mtnAirtelObject.Currency,
                    amount = mtnAirtelObject.Amount,
                    username = mtnAirtelObject.Username,
                    password = mtnAirtelObject.Password,
                    reference = mtnAirtelObject.Reference,
                    phone = mtnAirtelObject.Phone
                };
                
                var httpContent = new StringContent(JsonConvert.SerializeObject(newMtnAirtelObject));
                var resp = await _httpClient.PostAsync(mtnAirtelObject.MtnAirtelBaseUrl + "/api", httpContent);
                var respString = await resp.Content.ReadAsStringAsync();
                return await Task.FromResult(Ok(JsonConvert.DeserializeObject(respString)));
                */
			}
			catch (Exception e)
            {
                return await Task.FromResult(Ok(new { Message = e.Message + " error: Failed To Pay. Please Contact Admin on Site" }));
            }
        }
        [HttpGet]
        [AuthorizeIdentity]
        [Route("~/ClientProfile/GetClientContracts/{username}")]
        public async Task<IActionResult> GetClientContracts(string username)
        {
            try { 
            User user = _serviceEndPoint.GetUserByEmailAddress(username);
            var clientProfile = _unitOfWork._clientProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || clientProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {username} profile not Found!" }));
            }
            var fundiContracts = from c in _unitOfWork._clientFundiContractRepository.GetAll().Where(q => q.ClientProfileId == clientProfile.ClientProfileId || q.ClientUsername.ToLower().Equals(username.ToLower())).Include(q => q.ClientProfile).Include(q => q.FundiProfile)
                                 select c;
            return await Task.FromResult(Ok(_mapper.Map<ClientFundiContractViewModel[]>(fundiContracts.ToArray())));
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new { Message = ex.Message, StackTrace = ex.StackTrace }));
            }
		}

		[HttpPost]
        [Route("~/ClientProfile/PayClientSubscriptionFeeWithAirTel")]
        public async Task<IActionResult> PayClientSubscriptionFeeWithAirTel([FromBody] ClientSubscriptionViewModel subscriptionViewModel)
        {
             try
                {
                    var subCatQuantity = 1;
				var subscription = _mapper.Map<ClientSubscription>(subscriptionViewModel);
				var registrationSubscription = _unitOfWork._clientSubscriptionRepository.GetAll().FirstOrDefault(q => q.Username.ToLower().Equals(subscriptionViewModel.Username.ToLower()) && q.SubscriptionId == subscription.SubscriptionId);

				subscription.ClientProfileId = _unitOfWork._clientProfileRepository.GetAll().Include(q => q.User).Where(q => q.User.Username.ToLower().Equals(subscriptionViewModel.Username.ToLower())).FirstOrDefault().ClientProfileId;

				if (registrationSubscription != null)
                    {
                        subscription = registrationSubscription;
                    }
                    var paymentsManager = this.PaymentsManager;

                    if (registrationSubscription == null)
                    {
                        subscription.DateUpdated = DateTime.Now;
                        subscription.StartDate = DateTime.Now;
                        subscription.SubscriptionDescription = "Paid 7 day Subscription";
                        subscription.SubscriptionName = "Paid 7 day Subscription";
                        _unitOfWork._clientSubscriptionRepository.Insert(subscription);
					    _unitOfWork.SaveChanges();
				    }
                    else
                    {
                        subscription.DateUpdated = DateTime.Now;
                        subscription.StartDate = DateTime.Now;
                        subscription.SubscriptionDescription = "Paid 7 day Subscription";
                        subscription.SubscriptionName = "Paid 7 day Subscription";
                        _unitOfWork._clientSubscriptionRepository.Update(subscription);
					    _unitOfWork.SaveChanges();
				    }
                    var products = new List<Product>
                    {
                        new Product{
                            Amount = subscriptionViewModel.SubscriptionFee,
                            HasPaidInfull = true,
                            Quantity= subCatQuantity,
                            VATAmmount=(decimal) 0,
                            ProductName = subscriptionViewModel.SubscriptionName,
                            ProductDescription = subscriptionViewModel.SubscriptionDescription
                    } 
                };
                var mtnAirtelObject = await paymentsManager.MakePaymentsMtnAirTel(subscriptionViewModel.Username, products, new PaypalFacility.Invoice(products, subscriptionViewModel.SubscriptionFee, subscriptionViewModel.Username));
				return await Task.FromResult(Ok(mtnAirtelObject));
				/*
				//mtnAirtelObject.MtnAirtelBaseUrl = _payMtnAirTelRedirectUrl;
				var newMtnAirtelObject = new
				{
					action = mtnAirtelObject.Action,
					reason = mtnAirtelObject.Reason,
					currency = mtnAirtelObject.Currency,
					amount = mtnAirtelObject.Amount,
					username = mtnAirtelObject.Username,
					password = mtnAirtelObject.Password,
					reference = mtnAirtelObject.Reference,
					phone = mtnAirtelObject.Phone
				};
				var httpContent = new StringContent(JsonConvert.SerializeObject(newMtnAirtelObject));
				var resp = await _httpClient.PostAsync(mtnAirtelObject.MtnAirtelBaseUrl + "/api", httpContent);
				var respString = await resp.Content.ReadAsStringAsync();
				return await Task.FromResult(Ok(JsonConvert.DeserializeObject(respString)));
                */
               
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(new { Message = e.Message + " error: Failed To Pay. Please Contact Admin on Site" }));
            }
        }
        [AuthorizeIdentity]
        [HttpPost]
        public async Task<IActionResult> UpdateJob([FromBody] JobViewModel jobViewModel)
        {

            try
            {
                var job = _mapper.Map<Job>(jobViewModel);

                var result = _unitOfWork._jobRepository.GetById(job.JobId);
                var workCategories = jobViewModel.JobWorkCategoryIds;
                var jobDetailsUpdated = false;
                try
                {
                    if (result == null)
                    {
                        return await Task.FromResult(Ok(new { Message = "Failed to Update Job. Job does not Exist!" }));
                    }
                    result.AssignedFundiProfileId = job.AssignedFundiProfileId;
                    result.AssignedFundiUserId = job.AssignedFundiUserId;
                    result.ClientProfileId = job.ClientProfileId;
                    result.ClientUserId = job.ClientUserId;
                    result.DateUpdated = job.DateUpdated;
                    result.HasBeenAssignedFundi = job.HasBeenAssignedFundi;
                    result.HasCompleted = job.HasCompleted;
                    result.JobName = job.JobName;
                    result.LocationId = job.LocationId;
                    result.NumberOfDaysToComplete = job.NumberOfDaysToComplete;
                    result.JobDescription = job.JobDescription;

                    jobDetailsUpdated = _unitOfWork._jobRepository.Update(job);
                    _unitOfWork.SaveChanges();
                }
                catch (Exception ex)
                {

                }
                var workCats = jobViewModel.JobWorkCategoryIds;

                if (workCats.Any())
                {

                    var jbWokCats = _unitOfWork._jobWorkCategoryRepository.GetAll().Where(q => q.JobId == job.JobId).ToList();
                    foreach (var cat in jbWokCats)
                    {
                        _unitOfWork._jobWorkCategoryRepository.Delete(cat);
                    }
                    _unitOfWork.SaveChanges();

                    foreach (var wc in workCats)
                    {
                        _unitOfWork._jobWorkCategoryRepository.Insert(new JobWorkCategory { JobId = job.JobId, WorkCategoryId = wc.WorkCategoryId, WorkSubCategoryId = wc.WorkSubCategoryId });
                    }
                }
                _unitOfWork._jobRepository.Update(job);
                _unitOfWork.SaveChanges();
                return await Task.FromResult(Ok(new { Message = $"Succefully Updated Job: {jobDetailsUpdated.ToString()}" }));

            }
            catch
            {
                return await Task.FromResult(BadRequest(new { Message = "Exception: Job Details are bad, therefore operation failed!" }));
            }
        }
        [AuthorizeIdentity]
        [HttpPost]
        public async Task<IActionResult> DeleteClientProfile([FromBody] ClientProfileViewModel clientProfileViewModel)
        {
            if (ModelState.IsValid)
            {
                var clientProfile = _mapper.Map<ClientProfile>(clientProfileViewModel);

                var result = _unitOfWork._clientProfileRepository.GetById(clientProfile.ClientProfileId);

                if (result != null)
                {
                    _unitOfWork._clientProfileRepository.Delete(result);
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(Ok(new { Message = "Succefully Deleted Fundi Profile" }));
                }
            }
            return await Task.FromResult(BadRequest(new { Message = "Fundi Profile not Deleted, therefore operation failed!" }));
        }

        public WorkCategory[] GetWorkCategoriesForIds(int[] workCategoryIds)
        {
            var workCategories = _unitOfWork._workCategoryRepository.GetAll().Where(q => workCategoryIds.Contains(q.WorkCategoryId));
            return workCategories.ToArray();
        }
    }
}
