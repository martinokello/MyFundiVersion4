using AutoMapper;
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
using PaymentGateway;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
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
            var clientJobs = _unitOfWork._jobRepository.GetAll().Where(q => q.ClientProfileId == clientProfileId);

            if (clientJobs.Any())
            {
                return await Task.FromResult(Ok(_mapper.Map<JobViewModel[]>(clientJobs)));
            }
            return await Task.FromResult(NotFound(new { Message = "Jobs not found" }));
        }

        [AuthorizeIdentity]
        [HttpGet]
        [Route("~/ClientProfile/GetClientProfile/{username}")]
        public async Task<IActionResult> GetClientProfile(string username)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(username);
            var clientProfile = _unitOfWork._clientProfileRepository.GetAll().FirstOrDefault(q => q.UserId.ToString().ToLower().Equals(user.UserId.ToString().ToLower()));

            if (user == null || clientProfile == null)
            {
                return await Task.FromResult(NotFound(new { Message = "User not found" }));
            }
            return await Task.FromResult(Ok(_mapper.Map<ClientProfileViewModel>(clientProfile)));
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
        [Route("~/ClientProfile/GetJobWorkCategoriesByJobId/{jobId}")]
        public async Task<IActionResult> GetJobWorkCategoriesByJobId(int jobId)
        {

            var result = _unitOfWork._jobRepository.GetById(jobId);

            try
            {
                var jbWorkCatsList = new List<string>();
                var jbWokCats = _unitOfWork._jobWorkCategoryRepository.GetAll().Where(q => q.JobId == jobId).Include(ch=> ch.WorkCategory);
                foreach (var cat in jbWokCats)
                {
                    jbWorkCatsList.Add(cat.WorkCategory.WorkCategoryType);
                }
            return await Task.FromResult(Ok(jbWorkCatsList.ToArray()));
        }
            catch (Exception e)
            {
                return await Task.FromResult(BadRequest(new string[]{ }));
            }
        }

        [AuthorizeIdentity]
[HttpPost]
[Route("~/ClientProfile/CreateOrUpdateFundiJob")]
public async Task<IActionResult> CreateOrUpdateFundiJob([FromBody] JobViewModel jobViewModel)
{

    var workCats = GetWorkCategoriesForIds(jobViewModel.JobWorkCategoryIds);
    jobViewModel.JobWorkCategoryIds = null;
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
                    _unitOfWork._jobWorkCategoryRepository.Insert(new JobWorkCategory { JobId = job.JobId, WorkCategoryId = wc.WorkCategoryId });
                }
            }
            _unitOfWork.SaveChanges();
            return await Task.FromResult(Ok(new { Message = "Succefully Inserted Job" }));
        }
        else
        {
            if (workCats.Any())
            {
                var jbWokCats = _unitOfWork._jobWorkCategoryRepository.GetAll().Where(q => q.JobId == job.JobId);
                foreach (var cat in jbWokCats)
                {
                    _unitOfWork._jobWorkCategoryRepository.Delete(cat);
                }
                _unitOfWork.SaveChanges();

                foreach (var wc in workCats)
                {
                    _unitOfWork._jobWorkCategoryRepository.Insert(new JobWorkCategory { JobId = job.JobId, WorkCategoryId = wc.WorkCategoryId });
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

[AuthorizeIdentity]
[HttpPost]
public async Task<IActionResult> UpdateJob([FromBody] JobViewModel jobViewModel)
{
    if (ModelState.IsValid)
    {
        var job = _mapper.Map<Job>(jobViewModel);
        var workCategories = jobViewModel.JobWorkCategoryIds;

        var result = _unitOfWork._jobRepository.GetById(job.JobId);

        if (result == null)
        {
            return await Task.FromResult(Ok(new { Message = "Failed to Update Job. Job does not Exist!" }));
        }
        else
        {
            var workCats = GetWorkCategoriesForIds(workCategories);

            if (workCats.Any())
            {
                var jbWokCats = _unitOfWork._jobWorkCategoryRepository.GetAll().Where(q => q.JobId == job.JobId);
                foreach (var cat in jbWokCats)
                {
                    _unitOfWork._jobWorkCategoryRepository.Delete(cat);
                }
                foreach (var wc in workCats)
                {
                    var jbWokCat2 = _unitOfWork._jobWorkCategoryRepository.GetAll().FirstOrDefault(q => q.JobId == job.JobId);
                    jbWokCat2.JobId = job.JobId;
                    jbWokCat2.WorkCategoryId = wc.WorkCategoryId;
                }
            }
            _unitOfWork._jobRepository.Update(job);
            _unitOfWork.SaveChanges();
            return await Task.FromResult(Ok(new { Message = "Succefully Updated Job" }));
        }
    }
    return await Task.FromResult(BadRequest(new { Message = "Job Details are bad, therefore operation failed!" }));
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
