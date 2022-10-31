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

namespace MyFundi.Web.Controllers
{
    [EnableCors(PolicyName = "CorsPolicy")]
    public class FundiProfileController : Controller
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
        private SimbaToursEastAfricaCahing _caching;
        public FundiProfileController(IMailService emailService, MyFundiUnitOfWork unitOfWork, AppSettingsConfigurations appSettings, PaymentsManager paymentsManager, Mapper mapper, IHostingEnvironment _environment, ICaching caching)
        {
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
        [Route("~/FundiProfile/PayMonthlySubscriptionFee")]
        public async Task<IActionResult> PayMonthlySubscriptionFee([FromBody] MonthlySubscriptionViewModel subscriptionViewModel)
        {
            try
            {
                var subscription = _mapper.Map<MonthlySubscription>(subscriptionViewModel);
                var paymentsManager = new PaymentsManager(new PayPalHandler(_applicationConstants.GetSection("PaypalBaseUrl").Value,
                    _applicationConstants.GetSection("BusinessEmail").Value,
                     _applicationConstants.GetSection("SuccessUrl").Value,
                    _applicationConstants.GetSection("CancelUrl").Value,
                     _applicationConstants.GetSection("NotifyUrl").Value,
                     subscriptionViewModel.Username));

                var paypalRequestUrl = await paymentsManager.MakePayments(subscriptionViewModel.Username, new List<Product> {
                    new Product{
                        Amount = subscription.SubscriptionFee,
                        HasPaidInfull = true,
                        ProductDescription =subscription.SubscriptionDescription,
                        ProductName = subscription.SubscriptionName,
                        Quantity= 1,
                        VATAmmount=(decimal) 0
                    }

                });

                _unitOfWork._monthlySubscriptionRepository.Insert(subscription);
                _unitOfWork.SaveChanges();
                return await Task.FromResult(Ok(new { Message = "Inserted Subscription", PayPalRedirectUrl = paypalRequestUrl }));
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
        public async Task<IActionResult> JobsByCategoriesAndFundiUser([FromBody] CategoriesViewModel categories)
        {
            float km = 5;

            var jobResults = (from jb in _unitOfWork._jobRepository.GetAll().Include(l => l.ClientProfile).Include(l => l.ClientUser).Include(l => l.Location)
                               from fp in _unitOfWork._fundiProfileRepository.GetAll().Include(q => q.Location)
                               join clp in _unitOfWork._clientProfileRepository.GetAll()
                               on jb.ClientUserId equals clp.UserId
                               join fwcat in _unitOfWork._fundiWorkCategoryRepository.GetAll()
                               on fp.FundiProfileId equals fwcat.FundiProfileId
                               join fu in _unitOfWork._userRepository.GetAll()
                               on fp.UserId equals fu.UserId
                               where fu.Username == categories.Username && categories.Categories.Contains(fwcat.WorkCategory.WorkCategoryType)
                               && jb.HasCompleted == false
                               select new
                               {
                                   JobId = jb.JobId,
                                   JobName = jb.JobName,
                                   JobDescription = jb.JobDescription,
                                   HasBeenAssignedFundi = jb.HasBeenAssignedFundi,
                                   ClientFundiContractId = jb.ClientFundiContractId,
                                   LocationId = jb.Location.LocationId,
                                   Location = _mapper.Map<LocationViewModel>(jb.Location),
                                   ClientProfile = _mapper.Map<ClientProfileViewModel>(jb.ClientProfile),
                                   ClientUser = _mapper.Map<UserViewModel>(jb.ClientUser),
                                   ClientUserId = jb.ClientUser.UserId,
                                   NumberOfDaysToComplete = jb.NumberOfDaysToComplete,
                                   ClientProfileId = jb.ClientProfileId,
                                   AssignedFundiProfileId = jb.AssignedFundiProfileId,
                                   AssignedFundiUserId = jb.AssignedFundiProfile.UserId,
                                   FundiLocation = fp.Location
                               }).ToList().GroupBy(q => new { q.JobId, q.FundiLocation.AddressId, q.Location.LocationId, q.ClientProfileId})
                                       .Select(q => q.FirstOrDefault());


            var reviewCateg = (from jobRes in jobResults
                              select new ClientJobDistanceViewModel
                               {
                                   Job = new JobViewModel
                                   {
                                       JobId = jobRes.JobId,
                                       JobName = jobRes.JobName,
                                       JobDescription = jobRes.JobDescription,
                                       HasBeenAssignedFundi = jobRes.HasBeenAssignedFundi,
                                       ClientFundiContractId = jobRes.ClientFundiContractId,
                                       LocationId = jobRes.LocationId,
                                       Location = _mapper.Map<LocationViewModel>(jobRes.Location),
                                       ClientProfile = _mapper.Map<ClientProfileViewModel>(jobRes.ClientProfile),
                                       ClientUser = _mapper.Map<UserViewModel>(jobRes.ClientUser),
                                       ClientUserId = jobRes.ClientUserId,
                                       NumberOfDaysToComplete = jobRes.NumberOfDaysToComplete,
                                       ClientProfileId = jobRes.ClientProfileId,
                                       AssignedFundiProfileId = jobRes.AssignedFundiProfileId,
                                       AssignedFundiUserId = jobRes.AssignedFundiUserId,
                                       FundiLocation = _mapper.Map<LocationViewModel>(jobRes.FundiLocation),
                                       JobWorkCategoryIds = _unitOfWork._jobWorkCategoryRepository.GetAll().Where(q => q.JobId == jobRes.JobId).Select(s => (int)s.WorkCategoryId).ToArray()
                                   },
                                   Client = _mapper.Map<ClientProfileViewModel>(jobRes.ClientProfile),
                                   DistanceApart =
                                   CoordinateHelper.ArePointsNearEnough(
                                       new CoordinateViewModel { Latitude = (float)jobRes.Location.Latitude, Longitude = (float)jobRes.Location.Longitude },
                                   new CoordinateViewModel
                                   {
                                       Latitude = (float)_unitOfWork._locationRepository.GetAll().First(q => jobRes.FundiLocation.LocationId == q.LocationId).Latitude,
                                       Longitude = (float)_unitOfWork._locationRepository.GetAll().First(q => jobRes.FundiLocation.LocationId == q.LocationId).Longitude
                                   }, km)
                               }).ToArray();

            if (reviewCateg.Any())
            {
                return await Task.FromResult(Ok(reviewCateg.Where(n => n.DistanceApart.IsWithinDistance).OrderBy(q => (int)(Math.Round(q.DistanceApart.DistanceApart, 3, MidpointRounding.AwayFromZero) * 1000)).Skip(0).Take(5).ToList()));

            }
            return await Task.FromResult(NotFound(new string[]{ }));
        }

        [AuthorizeIdentity]
        [HttpPost]
        public async Task<IActionResult> PostAllFundiRatingsAndReviewsByCategories([FromBody] CategoriesViewModel categoriesViewModel)
        {
            float km = 5;

            var reviewCateg = from fwcat in _unitOfWork._fundiWorkCategoryRepository.GetAll()
                              join fp in _unitOfWork._fundiProfileRepository.GetAll().Include(q => q.Location)
                              on fwcat.FundiProfileId equals fp.FundiProfileId
                              join us in _unitOfWork._userRepository.GetAll()
                              on fp.UserId equals us.UserId
                              join frR in _unitOfWork._fundiRatingsAndReviewRepository.GetAll()
                              on fp.FundiProfileId equals frR.FundiProfileId into catFp
                              from j in catFp.DefaultIfEmpty()
                              where categoriesViewModel.Categories.Contains(fwcat.WorkCategory.WorkCategoryType)
                              && fp.FundiProfileId > 0
                              select new FundiRatingAndReviewViewModel
                              {
                                  FundiRatingAndReviewId = j.FundiRatingAndReviewId,
                                  FundiProfileId = fp.FundiProfileId,
                                  Rating = j.Rating,
                                  Review = j.Review,
                                  FundiProfile = _mapper.Map<FundiProfileViewModel>(fp),
                                  UserId = us.UserId,
                                  User = _mapper.Map<UserViewModel>(us),
                                  DateUpdated = j.DateUpdated,
                                  WorkCategoryType = fwcat.WorkCategory.WorkCategoryType,
                                  RatedByUser = _mapper.Map<UserViewModel>(j.User),
                                  RatingByUserId = j.UserId,
                                  FundiLocation = _mapper.Map<LocationViewModel>(fp.Location),
                                  DistanceApart = CoordinateHelper.ArePointsNearEnough(
                                  new CoordinateViewModel
                                  {
                                      Latitude = _unitOfWork._locationRepository.GetAll().First(q => q.LocationId == fp.LocationId).Latitude ?? 5000000,
                                      Longitude = _unitOfWork._locationRepository.GetAll().First(q => q.LocationId == fp.LocationId).Longitude ?? 50000000
                                  }, categoriesViewModel.Coordinate, km)
                              };
            if (reviewCateg.Any())
            {
                var fundiGroupedRatings = new Dictionary<string, List<FundiRatingAndReviewViewModel>>();

                var results = reviewCateg.ToArray().Where(n => n.DistanceApart.IsWithinDistance).OrderBy(q => (int)(Math.Round(q.DistanceApart.DistanceApart, 3, MidpointRounding.AwayFromZero) * 1000)).Skip(0).Take(5).ToList();
                foreach (var rat in results)
                {
                    if (!fundiGroupedRatings.Keys.Contains(rat.FundiProfileId.ToString().ToLower()))
                    {
                        var list = new List<FundiRatingAndReviewViewModel>();
                        list.Add(rat);

                        fundiGroupedRatings.Add(rat.FundiProfileId.ToString().ToLower(), list);
                    }
                    else
                    {
                        var list = fundiGroupedRatings[rat.FundiProfileId.ToString().ToLower()];
                        list.Add(rat);
                    }

                }
                return await Task.FromResult(Ok(fundiGroupedRatings));

            }
            return await Task.FromResult(NotFound(new { Message = "No Reviews & Ratings for Fundi" }));
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
                                      join fp in _unitOfWork._fundiProfileRepository.GetAll().Where(q => q.FundiProfileId == fundiProfile.FundiProfileId)
                                      on fwc.FundiProfileId equals fp.FundiProfileId
                                      select w;
            return await Task.FromResult(Ok(_mapper.Map<WorkCategoryViewModel[]>(fundiWorkCategories.ToArray())));
        }
        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllFundiWorkCategories()
        {
            var wcs = _unitOfWork._workCategoryRepository.GetAll();

            if (wcs.Any())
            {
                return await Task.FromResult(Ok(_mapper.Map<WorkCategoryViewModel[]>(wcs.ToArray())));
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
                return await Task.FromResult(Ok(new { Message = "Succefully Inserted Fundi Profile" }));

            }

            return await Task.FromResult(BadRequest(new { Message = "Fundi Profile not Inserted, therefore operation failed!" }));
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
