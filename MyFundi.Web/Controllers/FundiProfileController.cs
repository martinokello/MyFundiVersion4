using AutoMapper;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MyFundi.AppConfigurations;
using MyFundi.Domain;
using MyFundiProfile.ServiceEndPoint.GeneralSevices;
using MyFundi.Services.EmailServices.Interfaces;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.Web.IdentityServices;
using MyFundi.Web.Infrastructure;
using MyFundi.Web.ViewModels;
using PaymentGateway;
using PaypalFacility;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using SimbaToursEastAfrica.Caching;
using SimbaToursEastAfrica.Caching.Interfaces;
using SimbaToursEastAfrica.Caching.Concretes;
using System.Linq.Expressions;
using Newtonsoft.Json;

namespace MyFundi.Web.Controllers
{
    [EnableCors(PolicyName = "CorsPolicy")]
    public class FundiProfileController : Controller
    {
        private AppSettingsConfigurations _appSettings;
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private ServicesEndPoint _serviceEndPoint;
        private IConfigurationSection _applicationConstants;
        private IConfigurationSection _businessSmtpDetails;
        private IConfigurationSection _twitterProfileFiguration;
        private PaymentsManager PaymentsManager;
        private Mapper _mapper;
        private IHostingEnvironment Environment;
        private SimbaToursEastAfricaCahing _caching;
        public FundiProfileController(IMailService emailService, MyFundiUnitOfWork unitOfWork, AppSettingsConfigurations appSettings, PaymentsManager paymentsManager, Mapper mapper, IHostingEnvironment _environment, ICaching caching)
        {
            _appSettings = appSettings;
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _applicationConstants = appSettings.AppSettings.GetSection("ApplicationConstants");
            _twitterProfileFiguration = appSettings.AppSettings.GetSection("TwitterProfileFiguration");
            _businessSmtpDetails = appSettings.AppSettings.GetSection("BusinessSmtpDetails");
            _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
            PaymentsManager = paymentsManager;
            _mapper = mapper;
            _caching = caching as SimbaToursEastAfricaCahing;
            Environment = _environment;
        }
        [Route("~/FundiProfile/GetFundiProfileRatingById/{fundiProfileId}")]
        public async Task<IActionResult> GetFundiProfileRatingById(int fundiProfileId)
        {
            Func<int, Tuple<int, int>> GetFundiProfileRating = new Func<int, Tuple<int, int>>(_serviceEndPoint.GetFundiProfileRatingById);

            var fundiRating = _caching.GetOrSaveToCacheWithId<int, Tuple<int, int>>($"ProfileRating-{fundiProfileId}", 12 * 60 * 60, GetFundiProfileRating, fundiProfileId);

            if (fundiRating.Item2 != 0)
            {
                return await Task.FromResult(Ok(new { FundiProfileId = fundiProfileId, FundiAverageRating = fundiRating.Item2 }));
            }
            return await Task.FromResult(NotFound(new { Message = "File Not Found!" }));
        }
        public async Task<IActionResult> GetFundiProfileImageByUsername(string username)
        {

            string contentPath = this.Environment.ContentRootPath;

            string fundiProfileImagePath = contentPath + "\\MyFundiProfile\\ProfileImage_" + username + ".jpg";

            var profInfo = new FileInfo(fundiProfileImagePath);

            if (profInfo.Exists)
            {
                Bitmap profileImage = new Bitmap(Bitmap.FromFile(fundiProfileImagePath));

                return await Task.FromResult(File(BitmapToBytes(profileImage), "image/jpg"));
            }
            return await Task.FromResult(NotFound(new { Message = "File Not Found!" }));
        }
        public async Task<IActionResult> GetFundiProfileImageByProfileId(int fundiProfileId)
        {

            string contentPath = this.Environment.ContentRootPath;
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetById(fundiProfileId);
            var username = _unitOfWork._userRepository.GetByGuid(fundiProfile.UserId).Username;

            string fundiProfileImagePath = contentPath + "\\MyFundiProfile\\ProfileImage_" + username + ".jpg";

            var profInfo = new FileInfo(fundiProfileImagePath);

            if (profInfo.Exists)
            {
                Bitmap profileImage = new Bitmap(Bitmap.FromFile(fundiProfileImagePath));

                return await Task.FromResult(File(BitmapToBytes(profileImage), "image/jpg"));
            }
            return await Task.FromResult(NotFound(new { Message = "File Not Found!" }));
        }
        [HttpGet]
        [Route("~/FundiProfile/GetFundiCVByProfileId/{fundiProfileId}")]
        public async Task<IActionResult> GetFundiCVByProfileId(int fundiProfileId)
        {

            string contentPath = this.Environment.ContentRootPath + "\\MyFundiProfile\\";
            var userId = _unitOfWork._fundiProfileRepository.GetById(fundiProfileId).UserId;
            string fundiCVImagePath = contentPath + "ProfileCV_" + _unitOfWork._userRepository.GetByGuid(userId).Username.ToLower();
            DirectoryInfo dir = new DirectoryInfo(contentPath);

            if (dir.Exists)
            {
                var profInfo = dir.GetFiles().FirstOrDefault(f => f.FullName.ToLower().Contains(fundiCVImagePath.ToLower()));

                if (profInfo != null)
                {
                    using (var stream = profInfo.OpenRead())
                    {
                        byte[] bytes = new byte[4096];
                        int bytesRead = 0;
                        Response.ContentType = $"application/{profInfo.Extension}";
                        Response.Headers.Add("Content-Disposition", $"attachment; filename=\"{profInfo.Name}\"");
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
                    return await Task.FromResult(Ok(new { Message = "Profile CV downloaded Successfully" }));
                }
            }
            return await Task.FromResult(NotFound(new { Message = "CV does not exist" }));

        }

        [HttpGet]
        public async Task<IActionResult> GetFundiCVByUsername(string username)
        {

            string contentPath = this.Environment.ContentRootPath + "\\MyFundiProfile\\";

            string fundiCVImagePath = contentPath + "ProfileCV_" + username;
            DirectoryInfo dir = new DirectoryInfo(contentPath);

            if (dir.Exists)
            {
                var profInfo = dir.GetFiles().FirstOrDefault(f => f.FullName.ToLower().Contains(fundiCVImagePath.ToLower()));

                if (profInfo != null)
                {
                    using (var stream = profInfo.OpenRead())
                    {
                        byte[] bytes = new byte[4096];
                        int bytesRead = 0;
                        Response.ContentType = $"application/{profInfo.Extension}";
                        Response.Headers.Add("Content-Disposition", $"attachment; filename=\"{profInfo.Name}\"");
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
                    return await Task.FromResult(Ok(new { Message = "Profile CV downloaded Successfully" }));
                }
            }
            return await Task.FromResult(NotFound(new { Message = "CV does not exist" }));

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
        [HttpPost]
        public async Task<IActionResult> AddFundiWorkCategory([FromBody] WorkCategoryUserTO fundiWorkCategoryTo)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(fundiWorkCategoryTo.Username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {fundiWorkCategoryTo.Username} profile not Found!" }));
            }
            var exEntity = _unitOfWork._fundiWorkCategoryRepository.GetAll().Where(q => q.WorkCategoryId == fundiWorkCategoryTo.WorkCategoryId && q.FundiProfileId == fundiProfile.FundiProfileId);

            if (!exEntity.Any())
            {
                _unitOfWork._fundiWorkCategoryRepository.Insert(new FundiWorkCategory { WorkCategoryId = fundiWorkCategoryTo.WorkCategoryId, WorkSubCategoryId = fundiWorkCategoryTo.WorkSubCategoryId, FundiProfileId = fundiProfile.FundiProfileId });
                _unitOfWork.SaveChanges();
            }
            return await Task.FromResult(Ok(new { Message = "Fundi work category updated" }));
        }
        [AuthorizeIdentity]
        [HttpPost]
        public async Task<IActionResult> RemoveFundiWorkCategory([FromBody] WorkCategoryUserTO fundiWorkCategoryTo)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(fundiWorkCategoryTo.Username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {fundiWorkCategoryTo.Username} profile not Found!" }));
            }
            var exEntity = _unitOfWork._fundiWorkCategoryRepository.GetAll().Where(q => q.WorkCategoryId == fundiWorkCategoryTo.WorkCategoryId && q.FundiProfileId == fundiProfile.FundiProfileId && q.WorkSubCategoryId == fundiWorkCategoryTo.WorkSubCategoryId).FirstOrDefault();

            if (exEntity != null)
            {
                _unitOfWork._fundiWorkCategoryRepository.Delete(exEntity);
                _unitOfWork.SaveChanges();
            }
            return await Task.FromResult(Ok(new { Message = "Fundi work category updated" }));
        }
        [AuthorizeIdentity]
        [HttpPost]
        public async Task<IActionResult> AddFundiWorkCategoryWithoutSubCategory([FromBody] WorkCategoryUserTO fundiWorkCategoryTo)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(fundiWorkCategoryTo.Username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {fundiWorkCategoryTo.Username} profile not Found!" }));
            }
            var exEntity = _unitOfWork._fundiWorkCategoryRepository.GetAll().Where(q => q.WorkCategoryId == fundiWorkCategoryTo.WorkCategoryId && q.FundiProfileId == fundiProfile.FundiProfileId);

            if (!exEntity.Any())
            {
                _unitOfWork._fundiWorkCategoryRepository.Insert(new FundiWorkCategory { WorkCategoryId = fundiWorkCategoryTo.WorkCategoryId, FundiProfileId = fundiProfile.FundiProfileId });
                _unitOfWork.SaveChanges();
            }
            return await Task.FromResult(Ok(new { Message = "Fundi work category updated" }));
        }


        [AuthorizeIdentity]
        public async Task<IActionResult> AddFundiCertificate([FromBody] CertificationUserTO certificationUserTO)
        {

            User user = _serviceEndPoint.GetUserByEmailAddress(certificationUserTO.Username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));
            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {certificationUserTO.Username} profile not Found!" }));
            }
            var exEntity = _unitOfWork._fundiProfileCertificationRepostiory.GetAll().Where(q => q.CertificationId == certificationUserTO.CertificationId && q.FundiProfileId == fundiProfile.FundiProfileId);
            if (!exEntity.Any())
            {
                _unitOfWork._fundiProfileCertificationRepostiory.Insert(new FundiProfileCertification { CertificationId = certificationUserTO.CertificationId, FundiProfileId = fundiProfile.FundiProfileId });
                _unitOfWork.SaveChanges();
            }

            return await Task.FromResult(Ok(new { Message = "Fundi certification updated" }));
        }
        [AuthorizeIdentity]
        [HttpPost]
        public async Task<IActionResult> AddFundiCourse([FromBody] CourseUserTO courseUserTO)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(courseUserTO.Username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {courseUserTO.Username} profile not Found!" }));
            }
            var exEntity = _unitOfWork._fundiProfileCourseTakenRepository.GetAll().Where(q => q.CourseId == courseUserTO.CourseId && q.FundiProfileId == fundiProfile.FundiProfileId);
            if (!exEntity.Any())
            {
                _unitOfWork._fundiProfileCourseTakenRepository.Insert(new FundiProfileCourseTaken { CourseId = courseUserTO.CourseId, FundiProfileId = fundiProfile.FundiProfileId });
                _unitOfWork.SaveChanges();
            }

            return await Task.FromResult(Ok(new { Message = "Fundi Courses updated" }));
        }
        
        [Route("~/FundiProfile/GetFundiProfileByProfileId/{profileId}")]
        public async Task<IActionResult> GetFundiProfileByProfileId(int profileId)
        {
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetById(profileId);

            if (fundiProfile != null)
            {
                return await Task.FromResult(Ok(_mapper.Map<FundiProfileViewModel>(fundiProfile)));
            }
            return await Task.FromResult(NotFound(new { Message = "Fundi not found" }));
        }
        [Route("~/FundiProfile/GetFundiLevelOfEngagementById/{fundiProfileId}")]
        public async Task<IActionResult> GetFundiLevelOfEngagementById(int fundiProfileId)
        {
            var results = _unitOfWork.MyFundiDBContext.GetFundiLevelOfEngagementById(fundiProfileId);

            if (results.Count > 0)
            {
                return await Task.FromResult(Ok(results.ToArray()));
            }
            return await Task.FromResult(NotFound(new { Message = "Fundi Has No Engagement found" }));
        }
        [Route("~/FundiProfile/GetFundiLocationByFundiProfileId/{profileId}")]
        public async Task<IActionResult> GetFundiLocationByFundiProfileId(int profileId)
        {
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetById(profileId);

            if (fundiProfile != null)
            {
                var location = _unitOfWork._locationRepository.GetAll().FirstOrDefault(q => q.LocationId == fundiProfile.LocationId);
                if (location != null)
                {
                    return await Task.FromResult(Ok(_mapper.Map<LocationViewModel>(location)));
                }
            }
            return await Task.FromResult(NotFound(new { Message = "Fundi not found" }));
        }
        public async Task<IActionResult> GetAllFundiProfiles()
        {
            var fundiProfiles = _unitOfWork._fundiProfileRepository.GetAll().Include(q => q.User).Include(q => q.Location).ToArray();

            if (fundiProfiles.Any())
            {
                return await Task.FromResult(Ok(fundiProfiles));
            }
            return await Task.FromResult(NotFound(new { Message = "User not found" }));
        }
        [Route("~/FundiProfile/GetFundiUserByProfileId/{profileId}")]
        public async Task<IActionResult> GetFundiUserByProfileId(int profileId)
        {
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetById(profileId);
            var user = _unitOfWork._userRepository.GetByGuid(fundiProfile.UserId);

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = "User not found" }));
            }
            return await Task.FromResult(Ok(_mapper.Map<UserViewModel>(user)));
        }
        public async Task<IActionResult> GetFundiProfile(string username)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = "User not found" }));
            }
            return await Task.FromResult(Ok(_mapper.Map<FundiProfileViewModel>(fundiProfile)));
        }


        [AuthorizeIdentity]
        public async Task<IActionResult> GetFundiSkillsByFundiProfileId(int fundiProfileId)
        {
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetById(fundiProfileId);

            if (fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = "profile not Found!" }));
            }

            return await Task.FromResult(Ok(new string[] { fundiProfile.Skills }));
        }


        [AuthorizeIdentity]

        public async Task<IActionResult> GetFundiWorkCategoriesByFundiProfileId(int fundiProfileId)
        {
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetById(fundiProfileId);

            if (fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = "Profile not Found!" }));
            }
            var workCategories = _unitOfWork._fundiWorkCategoryRepository.GetAll().Where(q => q.FundiProfileId == fundiProfileId);

            return await Task.FromResult(Ok(workCategories.Select(q => q.WorkCategory.WorkCategoryType).ToArray()));
        }

        [AuthorizeIdentity]
        public async Task<IActionResult> GetFundiRatings(string username)
        {
            var fundiUser = _serviceEndPoint.GetUserByEmailAddress(username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId == fundiUser.UserId);
            var fundiProfileRatings = _unitOfWork._fundiRatingsAndReviewRepository.GetAll().Where(q => q.FundiProfileId == fundiProfile.FundiProfileId);

            if (fundiUser == null || fundiProfile == null || !fundiProfileRatings.Any())
            {
                return await Task.FromResult(NotFound(new { Message = $"user {username} profile not Found!" }));
            }

            return await Task.FromResult(Ok(_mapper.Map<FundiRatingAndReviewViewModel[]>(fundiProfileRatings.ToArray())));
        }


        [AuthorizeIdentity]
        public async Task<IActionResult> RateFundiByProfileId([FromBody] FundiRatingAndReviewViewModel fundiRatingReview)
        {

            var fundiRated = _mapper.Map<FundiRatingAndReview>(fundiRatingReview);

            if (string.IsNullOrEmpty(fundiRatingReview.WorkCategoryType) || fundiRated == null || fundiRated.FundiProfileId < 1 || fundiRated.UserId == null || string.IsNullOrEmpty(fundiRated.Review))
            {
                return await Task.FromResult(Ok(new { Message = "Fundi Not Found!" }));
            }
            _unitOfWork._fundiRatingsAndReviewRepository.Insert(fundiRated);
            _unitOfWork.SaveChanges();

            return await Task.FromResult(Ok(new { Message = "Fundi Profile Rated!" }));
        }

        [AuthorizeIdentity]
        [HttpPost]
        [Route("~/FundiProfile/PayMonthlySubscriptionFeeWithPaypal")]
        public async Task<IActionResult> PayMonthlySubscriptionFeeWithPaypal([FromBody] MonthlySubscriptionViewModel subscriptionViewModel)
        {
            try
            {
                using (var transaction = _unitOfWork.MyFundiDBContext.Database.BeginTransaction())
                {
                    var subscription = _mapper.Map<MonthlySubscription>(subscriptionViewModel);
                    var paymentsManager = this.PaymentsManager;

                    var paypalRequestUrl = await paymentsManager.MakePaymentsPaypal(subscriptionViewModel.Username, new List<Product> {
                    new Product{
                        Amount = subscriptionViewModel.SubscriptionFee,
                        HasPaidInfull = true,
                        Quantity= 1,
                        VATAmmount=(decimal) 0,
                        ProductName = subscriptionViewModel.SubscriptionName,
                        ProductDescription = subscriptionViewModel.SubscriptionDescription
                    }

                });
                    _unitOfWork._monthlySubscriptionRepository.Insert(subscription);
                    _unitOfWork.SaveChanges();
                    var fundiSubscription = _mapper.Map<FundiSubscription>(subscriptionViewModel);
                    fundiSubscription.MonthlySubscriptionId = subscription.MonthlySubscriptionId;
                    foreach(var wcId in subscriptionViewModel.WorkCategoryAndSubCategoryIds)
                    {
                        foreach(var wscId in wcId.WorkSubCategoryIds)
                        {
                            fundiSubscription.FundiWorkCategoryId = wcId.WorkCategoryId;
                            fundiSubscription.FundiWorkSubCategoryId = wscId;
                            _unitOfWork._fundiSubscriptionRepository.Insert(fundiSubscription);
                            _unitOfWork.SaveChanges();
                        }
                    }
                    return await Task.FromResult(Ok(new { Message = "Inserted Subscription", PayPalRedirectUrl = paypalRequestUrl }));
                }
            }
            catch (Exception e)
            {
                return await Task.FromResult(Ok(new { Message = e.Message + " error: Failed To Pay. Please Contact Admin on Site" }));
            }
        }
        [AuthorizeIdentity]
        [HttpPost]
        [Route("~/FundiProfile/PayMonthlySubscriptionFeeWithAirTel")]
        public async Task<IActionResult> PayMonthlySubscriptionFeeWithAirTel([FromBody] MonthlySubscriptionViewModel subscriptionViewModel)
        {
            try
            {
                using (var transaction = _unitOfWork.MyFundiDBContext.Database.BeginTransaction())
                {

                    var subscription = _mapper.Map<MonthlySubscription>(subscriptionViewModel);
                    var paymentsManager = this.PaymentsManager;

                    var mtnAirtelObject = await paymentsManager.MakePaymentsMtnAirTel(subscriptionViewModel.Username, new List<Product>
                    {
                        new Product{
                            Amount = subscriptionViewModel.SubscriptionFee,
                            HasPaidInfull = true,
                            Quantity= 1,
                            VATAmmount=(decimal) 0,
                            ProductName = subscriptionViewModel.SubscriptionName,
                            ProductDescription = subscriptionViewModel.SubscriptionDescription
                    }

                    });
                    _unitOfWork._monthlySubscriptionRepository.Insert(subscription);
                    _unitOfWork.SaveChanges();
                    var fundiSubscription = _mapper.Map<FundiSubscription>(subscriptionViewModel);
                    fundiSubscription.MonthlySubscriptionId = subscription.MonthlySubscriptionId;
                    foreach (var wcId in subscriptionViewModel.WorkCategoryAndSubCategoryIds)
                    {
                        foreach (var wscId in wcId.WorkSubCategoryIds)
                        {
                            fundiSubscription.FundiWorkCategoryId = wcId.WorkCategoryId;
                            fundiSubscription.FundiWorkSubCategoryId = wscId;
                            _unitOfWork._fundiSubscriptionRepository.Insert(fundiSubscription);
                            _unitOfWork.SaveChanges();
                        }
                    }
                    return await Task.FromResult(Ok(mtnAirtelObject));
                }
            }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(new { Message = e.Message + " error: Failed To Pay. Please Contact Admin on Site" }));
            }
        }
        [AuthorizeIdentity]
        [HttpPost]
        [Route("~/FundiProfile/PayMonthlySubscriptionFeeWithMtn")]
        public async Task<IActionResult> PayMonthlySubscriptionFeeWithMtn([FromBody] MonthlySubscriptionViewModel subscriptionViewModel)
        {
            try
            {
                using (var transaction = _unitOfWork.MyFundiDBContext.Database.BeginTransaction())
                {

                    var subscription = _mapper.Map<MonthlySubscription>(subscriptionViewModel);
                    var paymentsManager = this.PaymentsManager;

                    var mtnAirtelObject = await paymentsManager.MakePaymentsMtnAirTel(subscriptionViewModel.Username, new List<Product> 
                    {
                        new Product{
                            Amount = subscriptionViewModel.SubscriptionFee,
                            HasPaidInfull = true,
                            Quantity= 1,
                            VATAmmount=(decimal) 0,
                            ProductName = subscriptionViewModel.SubscriptionName,
                            ProductDescription = subscriptionViewModel.SubscriptionDescription
                    }

                    });
                    _unitOfWork._monthlySubscriptionRepository.Insert(subscription);
                    _unitOfWork.SaveChanges();
                    var fundiSubscription = _mapper.Map<FundiSubscription>(subscriptionViewModel);
                    fundiSubscription.MonthlySubscriptionId = subscription.MonthlySubscriptionId;
                    foreach (var wcId in subscriptionViewModel.WorkCategoryAndSubCategoryIds)
                    {
                        foreach (var wscId in wcId.WorkSubCategoryIds)
                        {
                            fundiSubscription.FundiWorkCategoryId = wcId.WorkCategoryId;
                            fundiSubscription.FundiWorkSubCategoryId = wscId;
                            _unitOfWork._fundiSubscriptionRepository.Insert(fundiSubscription);
                            _unitOfWork.SaveChanges();
                        }
                    }
                    return await Task.FromResult(Ok(mtnAirtelObject));
                }
            }
            catch (Exception e)
            {
                return await Task.FromResult(Ok(new { Message = e.Message + " error: Failed To Pay. Please Contact Admin on Site" }));
            }
        }
        [AuthorizeIdentity]
        [HttpPost]
        [Route("~/FundiProfile/FundiSubscriptionValidByProfileId/{fundiProfileId}")]
        public async Task<IActionResult> FundiSubscriptionValidByProfileId(int fundiProfileId)
        {

            var result = _unitOfWork._monthlySubscriptionRepository.GetAll().First(q => q.FundiProfileId == fundiProfileId).EndDate < DateTime.Now;
            return await Task.FromResult(Ok(new { IsValid = result }));
        }
        [AuthorizeIdentity]
        [HttpPost]
        [Route("~/FundiProfile/JobsByCategoriesAndFundiUser/{fundiProfileId}/{distanceKmLimitApart}/{skip}/{take}")]
        public async Task<IActionResult> JobsByCategoriesAndFundiUser([FromBody] CategoriesViewModel[] categoriesViewModel, int fundiProfileId, float distanceKmLimitApart = 500000000, int skip = 0, int take = 5)
        {

            List<dynamic> resMerged = new List<dynamic>();

            try
            {
                var workCategories = new List<string>();
                var workSubCatagories = new List<string>();

                foreach (var item in categoriesViewModel)
                {
                    workCategories.AddRange(item.WorkCategories);
                    workSubCatagories.AddRange(item.WorkSubCategories);
                }

                var wkCatArry = workCategories.Union(new List<string> { "" }).ToArray();
                var wkSubCatArry = workSubCatagories.Union(new List<string> { "" }).ToArray();

                var reviewCateg = _unitOfWork.MyFundiDBContext.GetJobsByFundiWorkCategoriesWithinDistance(fundiProfileId, wkCatArry, wkSubCatArry, distanceKmLimitApart, skip, take);


                if (reviewCateg.Any())
                {
                    var results = reviewCateg.GroupBy(res => (res.FundiProfileId, res.FundiUserId, res.FundiUsername, res.FundiFirstName, res.FundiLastName, res.FundiLocationId,
                    res.FundiProfileSummary, res.FundiSkills, res.FundiUsedPowerTools, res.FundiLocationName, res.ClientUsername, res.JobId, res.JobLocationId,
                    res.JobName, res.JobDescription, res.ClientFirstName, res.ClientLastName, res.JobLocationName, res.DistanceApart)).
                    Select(g => new
                    {
                        FundiProfileId = g.Key.FundiProfileId,
                        FundiUserId = g.Key.FundiUserId,
                        FundiUsername = g.Key.FundiUsername,
                        FundiFirstName = g.Key.FundiFirstName,
                        FundiLastName = g.Key.FundiLastName,
                        FundiLocationId = g.Key.FundiLocationId,
                        FundiProfileSummary = g.Key.FundiProfileSummary,
                        FundiSkills = g.Key.FundiSkills,
                        FundiUsedPowerTools = g.Key.FundiUsedPowerTools,
                        FundiLocationName = g.Key.FundiLocationName,
                        ClientUserName = g.Key.ClientUsername,
                        ClientFirstName = g.Key.ClientFirstName,
                        ClientLastName = g.Key.ClientLastName,
                        JobId = g.Key.JobId,
                        JobLocationId = g.Key.JobLocationId,
                        JobName = g.Key.JobName,
                        JobDescription = g.Key.JobDescription,
                        JobLocationName = g.Key.JobLocationName,
                        DistanceApart = Math.Round(g.Key.DistanceApart, 3, MidpointRounding.AwayFromZero),
                        JobWorkCategoryDetails = _unitOfWork.MyFundiDBContext.GetWorkSubCategoriesForFundiByJobId(g.Key.JobId, g.Key.FundiProfileId).Where(q => wkSubCatArry.Contains((string)(q.WorkSubCategoryType))).ToArray(),
                    });
                    resMerged.AddRange(results);
                }
                if (resMerged.Count > 0)
                {
                    return await Task.FromResult(Ok(resMerged.ToArray()));
                }
                else
                {
                    return await Task.FromResult(NotFound(new string[] { }));
                }
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new string[] { }));
            }

        }

        [AuthorizeIdentity]
        [HttpPost]
        [Route("~/FundiProfile/PostAllFundiRatingsAndReviewsByCategories/{clientProfileId}/{jobId}/{distanceKmLimitApart}/{skip}/{take}")]
        public async Task<IActionResult> PostAllFundiRatingsAndReviewsByCategories([FromBody] CategoriesViewModel[] categoriesViewModel, int clientProfileId, int jobId, float distanceKmLimitApart = 500000000, int skip = 0, int take = 5)
        {
            List<dynamic> resMerged = new List<dynamic>();

            try
            {
                var workCategories = new List<string>();
                var workSubCatagories = new List<string>();


                foreach (var item in categoriesViewModel)
                {
                    workCategories.AddRange(item.WorkCategories);
                    workSubCatagories.AddRange(item.WorkSubCategories);
                }
                var wkCatArry = workCategories.Union(new List<string> { "" }).ToArray();
                var wkSubCatArry = workSubCatagories.Union(new List<string>{""}).ToArray();

                var reviewCateg = _unitOfWork.MyFundiDBContext.GetFundiAvgRatingsAndJobWithinDistance(clientProfileId, jobId, wkCatArry, wkSubCatArry, distanceKmLimitApart, skip, take);

                if (reviewCateg.Any())
                {
                    var results = reviewCateg.GroupBy(res => (res.FundiProfileId, res.FundiUserId, res.FundiUsername, res.FundiFirstName, res.FundiLastName, res.FundiLocationId,
                    res.FundiProfileSummary, res.FundiSkills, res.FundiUsedPowerTools, res.FundiLocationName, res.ClientUsername, res.JobId, res.JobLocationId,
                    res.JobName, res.JobDescription, res.ClientFirstName, res.ClientLastName, res.JobLocationName, res.DistanceApart)).
                    Select(g => new
                    {
                        FundiProfileId = g.Key.FundiProfileId,
                        FundiUserId = g.Key.FundiUserId,
                        FundiUsername = g.Key.FundiUsername,
                        FundiFirstName = g.Key.FundiFirstName,
                        FundiLastName = g.Key.FundiLastName,
                        FundiLocationId = g.Key.FundiLocationId,
                        FundiProfileSummary = g.Key.FundiProfileSummary,
                        FundiSkills = g.Key.FundiSkills,
                        FundiUsedPowerTools = g.Key.FundiUsedPowerTools,
                        FundiLocationName = g.Key.FundiLocationName,
                        ClientUserName = g.Key.ClientUsername,
                        ClientFirstName = g.Key.ClientFirstName,
                        ClientLastName = g.Key.ClientLastName,
                        JobId = g.Key.JobId,
                        JobLocationId = g.Key.JobLocationId,
                        JobName = g.Key.JobName,
                        JobDescription = g.Key.JobDescription,
                        JobLocationName = g.Key.JobLocationName,
                        DistanceApart = Math.Round(g.Key.DistanceApart, 3, MidpointRounding.AwayFromZero),
                        FundiRatingsAndReviews = _unitOfWork.MyFundiDBContext.GetAllFundiRatingByProfileId(g.Key.FundiProfileId).ToArray(),
                        JobWorkCategoryDetails = _unitOfWork.MyFundiDBContext.GetWorkSubCategoriesForFundiByJobId(g.Key.JobId, g.Key.FundiProfileId).Where(q => wkSubCatArry.Contains((string)(q.WorkSubCategoryType))).ToArray(),
                        AverageFundiRating = _unitOfWork.MyFundiDBContext.GetFundiProfileAvgRatingById(g.Key.FundiProfileId).ToValueTuple().Item2
                    });
                    resMerged.AddRange(results);
                }
                if (resMerged.Count > 0)
                {
                    return await Task.FromResult(Ok(resMerged.ToArray()));
                }
                else
                {
                    return await Task.FromResult(NotFound(new string[] { }));
                }
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new string[] { }));
            }
        }

        [AuthorizeIdentity]
        public async Task<IActionResult> GetFundiCertifications(string username)
        {

            User user = _serviceEndPoint.GetUserByEmailAddress(username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {username} profile not Found!" }));
            }
            var fundiCertifications = from fc in _unitOfWork._certificationRepository.GetAll()
                                      join fpc in _unitOfWork._fundiProfileCertificationRepostiory.GetAll()
                                      on fc.CertificationId equals fpc.CertificationId
                                      join fp in _unitOfWork._fundiProfileRepository.GetAll().Where(q => q.FundiProfileId == fundiProfile.FundiProfileId)
                                      on fpc.FundiProfileId equals fp.FundiProfileId
                                      select fc;
            return await Task.FromResult(Ok(_mapper.Map<CertificationViewModel[]>(fundiCertifications.ToArray())));
        }

        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllFundiCertificates()
        {
            var allCerts = _unitOfWork._certificationRepository.GetAll().ToArray();
            return await Task.FromResult(Ok(_mapper.Map<CertificationViewModel[]>(allCerts)));
        }

        [AuthorizeIdentity]
        public async Task<IActionResult> GetFundiCoursesTaken(string username)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {username} profile not Found!" }));
            }
            var fundiCoursesTaken = from c in _unitOfWork._courseRepository.GetAll()
                                    join fcr in _unitOfWork._fundiProfileCourseTakenRepository.GetAll()
                                    on c.CourseId equals fcr.CourseId
                                    join fp in _unitOfWork._fundiProfileRepository.GetAll().Where(q => q.FundiProfileId == fundiProfile.FundiProfileId)
                                    on fcr.FundiProfileId equals fp.FundiProfileId
                                    select c;
            return await Task.FromResult(Ok(_mapper.Map<CourseViewModel[]>(fundiCoursesTaken.ToArray())));
        }

        [AuthorizeIdentity]
        public async Task<IActionResult> GetWorkCategories()
        {
            var workCategories = _unitOfWork._workCategoryRepository.GetAll();


            if (workCategories.Any())
            {
                return await Task.FromResult(Ok(_mapper.Map<WorkCategoryViewModel[]>(workCategories.ToArray())));
            }
            return await Task.FromResult(NotFound(new { Message = "No Work Categories exist!" }));
        }


        [AuthorizeIdentity]
        public async Task<IActionResult> GetWorkSubCategories()
        {
            var workCategories = _unitOfWork._workSubCategoryRepository.GetAll();


            if (workCategories.Any())
            {
                return await Task.FromResult(Ok(_mapper.Map<WorkCategoryViewModel[]>(workCategories.ToArray())));
            }
            return await Task.FromResult(NotFound(new { Message = "No Work Categories exist!" }));
        }

        [AuthorizeIdentity]
        public async Task<IActionResult> GetFundiWorkCategories(string username)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {username} profile not Found!" }));
            }
            var fundiWorkCategories = from w in _unitOfWork._workCategoryRepository.GetAll()
                                      join fwc in _unitOfWork._fundiWorkCategoryRepository.GetAll()
                                      on w.WorkCategoryId equals fwc.WorkCategoryId
                                      join wsc in _unitOfWork._workSubCategoryRepository.GetAll()
                                      on w.WorkCategoryId equals wsc.WorkCategoryId
                                      join fp in _unitOfWork._fundiProfileRepository.GetAll().Where(q => q.FundiProfileId == fundiProfile.FundiProfileId)
                                      on fwc.FundiProfileId equals fp.FundiProfileId
                                      select new JobWorkCategoryViewModel { WorkCategoryId = w.WorkCategoryId, WorkSubCategoryId = wsc.WorkSubCategoryId, WorkCategory = w, WorkSubCategory = wsc };
            return await Task.FromResult(Ok(fundiWorkCategories.ToArray()));
        }
        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllFundiWorkCategories()
        {
            var wcs = _unitOfWork._jobWorkCategoryRepository.GetAll().Include(q => q.WorkCategory).Include(q => q.WorkSubCategory);

            if (wcs.Any())
            {
                return await Task.FromResult(Ok(_mapper.Map<JobWorkCategory[]>(wcs.ToArray())));
            }
            return await Task.FromResult(NotFound(new { Message = "No Work Categories Found!" }));
        }

        [AuthorizeIdentity]
        [Route("~/FundiProfile/GetAllFundiWorkSubCategoriesByWorkCategoryId/{workCategoryId}")]
        public async Task<IActionResult> GetAllFundiWorkSubCategoriesByWorkCategoryId(int workCategoryId)
        {
            var wcs = _unitOfWork._workSubCategoryRepository.GetAll().Where(q => q.WorkCategoryId == workCategoryId);

            if (wcs.Any())
            {
                return await Task.FromResult(Ok(_mapper.Map<WorkSubCategoryViewModel[]>(wcs.ToArray())));
            }
            return await Task.FromResult(NotFound(new { Message = "No Work Categories Found!" }));
        }

        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllFundiCourses()
        {
            var wcs = _unitOfWork._courseRepository.GetAll();

            if (wcs.Any())
            {
                return await Task.FromResult(Ok(_mapper.Map<CourseViewModel[]>(wcs.ToArray())));
            }
            return await Task.FromResult(NotFound(new { Message = "No Work Categories Found!" }));
        }
        [AuthorizeIdentity]
        public async Task<IActionResult> GetFundiContracts(string username)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(username);
            var fundiProfile = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.ToString().ToLower()));

            if (user == null || fundiProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = $"user {username} profile not Found!" }));
            }
            var fundiContracts = from c in _unitOfWork._clientFundiContractRepository.GetAll().Where(q => q.FundiUserId.ToString().ToLower() == user.UserId.ToString().ToLower())
                                 select c;
            return await Task.FromResult(Ok(_mapper.Map<ClientFundiContractViewModel[]>(fundiContracts.ToArray())));
        }

        [HttpPost]
        public async Task<IActionResult> SaveFundiProfileImage(string username, [FromForm] IFormFile profileImage)
        {
            try
            {
                if (profileImage.Length > 0 && !string.IsNullOrEmpty(username))
                {
                    string contentPath = this.Environment.ContentRootPath;
                    var profileDirPath = contentPath + "\\MyFundiProfile";
                    DirectoryInfo pfDir = new DirectoryInfo(profileDirPath);

                    var profileImgPath = pfDir.FullName + $"\\ProfileImage_{username}.jpg";
                    try
                    {
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
                return await Task.FromResult(BadRequest(new { Message = "Fundi Profile Image not Inserted, therefore operation failed!" }));
            }



        }
        [HttpPost]
        public async Task<IActionResult> SaveFundiCV(string username, [FromForm] IFormFile fundiProfileCv)
        {
            try
            {
                if (fundiProfileCv.Length > 0 && !string.IsNullOrEmpty(username))
                {
                    string contentPath = this.Environment.ContentRootPath;
                    var profileDirPath = contentPath + "\\MyFundiProfile";
                    DirectoryInfo pfDir = new DirectoryInfo(profileDirPath);

                    var cvPath = pfDir.FullName + $"\\ProfileCV_{username}{fundiProfileCv.FileName.Substring(fundiProfileCv.FileName.LastIndexOf("."))}";

                    try
                    {
                        var existImgInfo = new FileInfo(cvPath);
                        if (existImgInfo.Exists)
                        {
                            System.GC.Collect();
                            System.GC.WaitForPendingFinalizers();
                            System.IO.File.Delete(cvPath);
                        }
                    }
                    catch (Exception e)
                    {
                    }
                    using (var stream = new FileStream(cvPath, FileMode.Create, FileAccess.ReadWrite))
                    {
                        await fundiProfileCv.CopyToAsync(stream);
                        stream.Flush();
                        stream.Close();
                    }
                }

                return await Task.FromResult(Ok(new { Message = "Succefully Inserted Fundi Profile CV" }));
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = "Fundi Profile CV not Inserted, therefore operation failed!" });
            }
        }


        [HttpPost]
        [AuthorizeIdentity]
        public async Task<IActionResult> PostCreateWorkCategory([FromBody] WorkCategoryViewModel workCategoryViewModel)
        {
            if (ModelState.IsValid)
            {
                var workCategory = _mapper.Map<WorkCategory>(workCategoryViewModel);

                var result = _unitOfWork._workCategoryRepository.Insert(workCategory);
                _unitOfWork.SaveChanges();
                return await Task.FromResult(Ok(new { Message = "Succefully Inserted Work Ccategory" }));

            }

            return await Task.FromResult(BadRequest(new { Message = "Work Category not Inserted, therefore operation failed!" }));
        }

        [HttpPost]
        [AuthorizeIdentity]
        public async Task<IActionResult> DeleteWorkSubCategory([FromBody] WorkSubCategoryViewModel workSubCategoryViewModel)
        {
            if (ModelState.IsValid)
            {
                var workSubCategory = _mapper.Map<WorkSubCategory>(workSubCategoryViewModel);

                var result = _unitOfWork._workSubCategoryRepository.Delete(workSubCategory);
                _unitOfWork.SaveChanges();

                return await Task.FromResult(Ok(true));

            }

            return await Task.FromResult(BadRequest(false));
        }


        [HttpPost]
        [AuthorizeIdentity]
        public async Task<IActionResult> PostOrCreateWorkSubCategory([FromBody] WorkSubCategoryViewModel workSubCategoryViewModel)
        {
            if (ModelState.IsValid)
            {
                var workSubCategory = _mapper.Map<WorkSubCategory>(workSubCategoryViewModel);

                var result = _unitOfWork._workSubCategoryRepository.Insert(workSubCategory);
                _unitOfWork.SaveChanges();
                return await Task.FromResult(Ok(true));

            }

            return await Task.FromResult(BadRequest(false));
        }

        [HttpPost]
        [AuthorizeIdentity]
        public async Task<IActionResult> UpdateWorkSubCategory([FromBody] WorkSubCategoryViewModel workSubCategoryViewModel)
        {
            try
            {

                var workSubCategory = _mapper.Map<WorkSubCategory>(workSubCategoryViewModel);

                var result = _unitOfWork._workSubCategoryRepository.Update(workSubCategory);
                _unitOfWork.SaveChanges();
                return await Task.FromResult(Ok(true));

            }
            catch
            {

                return await Task.FromResult(BadRequest(false));
            }
        }

        [AuthorizeIdentity]
        [HttpPost]
        public async Task<IActionResult> CreateFundiProfile([FromBody] FundiProfileViewModel fundiProfileViewModel)
        {
            if (ModelState.IsValid)
            {
                var fundiProfile = _mapper.Map<FundiProfile>(fundiProfileViewModel);

                var result = _unitOfWork._fundiProfileRepository.Insert(fundiProfile);
                _unitOfWork.SaveChanges();
                return await Task.FromResult(Ok(new { Message = "Succefully Inserted Fundi Profile" }));

            }

            return await Task.FromResult(BadRequest(new { Message = "Fundi Profile not Inserted, therefore operation failed!" }));
        }

        [HttpPost]
        public async Task<IActionResult> UpdateFundiProfile([FromBody] FundiProfileViewModel fundiProfileViewModel)
        {
            if (ModelState.IsValid)
            {
                var fundiProfile = _mapper.Map<FundiProfile>(fundiProfileViewModel);

                var result = _unitOfWork._fundiProfileRepository.GetById(fundiProfile.FundiProfileId);

                if (result == null)
                {
                    _unitOfWork._fundiProfileRepository.Insert(fundiProfile);
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(Ok(new { Message = "Succefully Inserted Fundi Profile" }));
                }
                else
                {
                    _unitOfWork._fundiProfileRepository.Update(fundiProfile);
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(Ok(new { Message = "Succefully Updated Fundi Profile" }));
                }
            }
            return await Task.FromResult(BadRequest(new { Message = "Fundi Profile not Updated, therefore operation failed!" }));
        }
        [AuthorizeIdentity]
        [HttpPost]
        public async Task<IActionResult> DeleteFundiProfile([FromBody] FundiProfileViewModel fundiProfileViewModel)
        {
            if (ModelState.IsValid)
            {
                var fundiProfile = _mapper.Map<FundiProfile>(fundiProfileViewModel);

                var result = _unitOfWork._fundiProfileRepository.GetById(fundiProfile.FundiProfileId);

                if (result != null)
                {
                    _unitOfWork._fundiProfileRepository.Delete(result);
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(Ok(new { Message = "Succefully Deleted Fundi Profile" }));
                }
            }
            return await Task.FromResult(BadRequest(new { Message = "Fundi Profile not Deleted, therefore operation failed!" }));
        }

        [HttpGet]
        [Route("~/{Controller}/{Action}/{companyId}")]
        public async Task<IActionResult> GetAllFundisByCompanyId(int companyId)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                FundiProfile[] results = await _serviceEndPoint.GetAllFundiProfilesByCompanyId(companyId);
                if (!results.Any())
                {
                    return NotFound(results);
                }
                return Ok(results);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
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
            var filePathInfo = new FileInfo(currentDir.FullName + "\\AndroidPhoneLocationApp\\XamarinForms.locationservice.ipa");
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

        [HttpGet]
        [Route("~/{Controller}/{Action}/{companyId}")]
        public async Task<IActionResult> GetFundisByCompanyId(int companyId)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                FundiProfile[] result = await _serviceEndPoint.GetFundisByCompanyId(companyId);
                if (result == null)
                {
                    return NotFound(result);
                }
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

    }
}
