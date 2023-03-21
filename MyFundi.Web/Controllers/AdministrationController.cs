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
using AutoMapper;
using MyFundiProfile.ServiceEndPoint.GeneralSevices;
using Microsoft.AspNetCore.Http;
using System.IO;
using Microsoft.Extensions.Hosting;
using MyFundi.AppConfigurations;

namespace MyFundi.Web.ControllersControllers
{
    [EnableCors(PolicyName = "CorsPolicy")]
    public class AdministrationController : Controller
    {
        private AppSettingsConfigurations _appSettings;
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private ServicesEndPoint _serviceEndPoint;
        private Mapper _mapper;
        private IHostEnvironment Environment;

        public AdministrationController(IMailService emailService, MyFundiUnitOfWork unitOfWork, Mapper mapper, IHostEnvironment environment, AppSettingsConfigurations appSettings)
        {
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            this.Environment = environment;
            this._appSettings = appSettings;
        }

        public async Task<IActionResult> GetAdvertLink()
        {
            try
            {
                var absoluteAdvertLinkUrl = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl").Value;
                return await Task.FromResult(Ok(new { AdvertLinkUrl= absoluteAdvertLinkUrl}));
            }
            catch
            {
                return await Task.FromResult(BadRequest(null));
            }
        }
        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UploadBlog([FromForm] IFormFile blogFile,FormCollection formCollection)
        {
            try
            {
                _unitOfWork._blogsRepository.Insert(new Blog { BlogContent = formCollection["blogContent"], BlogName = formCollection["blogName"] });
                _unitOfWork.SaveChanges();
                if (blogFile != null)
                {
                    var dirAdvertImg = new DirectoryInfo($"{this.Environment.ContentRootPath}\\wwwwroot\\images");
                    if (!dirAdvertImg.Exists)
                    {
                        dirAdvertImg.Create();
                    }
                    var fileInfo = new FileInfo($"{this.Environment.ContentRootPath}\\wwwwroot\\images\\{formCollection["blogName"]}.jpg");
                    using (var fileStream = (fileInfo.Exists ? fileInfo.OpenWrite() : fileInfo.Create()))
                    {
                        await blogFile.CopyToAsync(fileStream);

                        return Ok(new { result = true, Message = "Successfully Blog." });
                    }
                }
                else
                {
                    return Ok(new { AbsoluteAdvertUrl = "", Result = false, Message = "Flie Does not Exist." });
                }
            }
            catch (Exception ex)
            {

                return await Task.FromResult(BadRequest(new { Message = ex.Message, Result = false, AbsoluteAdvertUrl = string.Empty }));
            }
        }
        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UploadAdvertGifImage([FromForm] IFormFile advertGifFile)
        {
            try
            {
                if (advertGifFile != null)
                {
                    var absoluteAdvertLinkUrl = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl").Value;
                    var dirAdvertImg = new DirectoryInfo($"{this.Environment.ContentRootPath}\\wwwwroot\\images");
                    if (!dirAdvertImg.Exists)
                    {
                        dirAdvertImg.Create();
                    }
                    var fileInfo = new FileInfo($"{this.Environment.ContentRootPath}\\wwwwroot\\images\\currentAdvert.gif");
                    using (var fileStream = (fileInfo.Exists ? fileInfo.OpenWrite() : fileInfo.Create()))
                    {
                        await advertGifFile.CopyToAsync(fileStream);
                        return Ok(new { AbsoluteAdverSrctUrl = "/adverts/images/currentAdvert.gif", AbsoluteAdvertLinkUrl= absoluteAdvertLinkUrl, Result = true, Message = "Successfully Uploaded Advert Gif Image." });
                    }
                }
                else
                {
                    return Ok(new { AbsoluteAdvertUrl = "", Result = false, Message = "Flie Does not Exist." });
                }
            }
            catch(Exception ex)
            {

                return await Task.FromResult(BadRequest(new { Message = ex.Message, Result = false, AbsoluteAdvertUrl=string.Empty }));
            }
        }
        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> PostLocation([FromBody] Location location)
        {
            _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
            bool result = await _serviceEndPoint.PostLocation(location);
            if (result) return Ok(result);
            return await Task.FromResult(BadRequest(false));
        }
        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> PostOrCreateCourse([FromBody] CourseViewModel course)
        {
            if (ModelState.IsValid)
            {
                var cs = _mapper.Map<Course>(course);
                bool result = _unitOfWork._courseRepository.Insert(cs);
                _unitOfWork.SaveChanges();
                if (result) return await Task.FromResult(Ok(result));
            }
            return await Task.FromResult(BadRequest(false)); 
        }

        
        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UpdateCourse([FromBody] CourseViewModel cvw)
        {
            if (ModelState.IsValid)
            {
                var cs = _mapper.Map<Course>(cvw);
                bool result = _unitOfWork._courseRepository.Update(cs);
                _unitOfWork.SaveChanges();
                if (result) return await Task.FromResult(Ok(result));
            }
            return await Task.FromResult(BadRequest(false));
        }

        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UpdateCertification([FromBody] CertificationViewModel certification)
        {
            if (ModelState.IsValid)
            {
                _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var cert = _mapper.Map<Certification>(certification);
                bool result = _unitOfWork._certificationRepository.Update(cert);
                _unitOfWork.SaveChanges();
                if (result) return await Task.FromResult(Ok(result));
            }
            return await Task.FromResult(BadRequest(false));
        }
        
        [HttpPost]
        [Route("DeleteworkCategory")]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> DeleteworkCategory([FromBody] WorkCategoryViewModel wc)
        {
            if (ModelState.IsValid)
            {
                _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var res = _mapper.Map<WorkCategory>(wc);
                bool result = _unitOfWork._workCategoryRepository.Delete(res);
                _unitOfWork.SaveChanges();
                if (result) return await Task.FromResult(Ok(result));
            }
            return await Task.FromResult(BadRequest(false));
        }
        
        [HttpPost]
        [Route("DeleteCourse")]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> DeleteCourse([FromBody] CourseViewModel c)
        {
            if (ModelState.IsValid)
            {
                var res = _mapper.Map<Course>(c);
                bool result = _unitOfWork._courseRepository.Delete(res);
                _unitOfWork.SaveChanges();
                if (result) return await Task.FromResult(Ok(result));
            }
            return await Task.FromResult(BadRequest(false));
        }
        [HttpPost]
        [Route("DeleteCertification")]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> DeleteCertification([FromBody] CertificationViewModel certification)
        {
            if (ModelState.IsValid)
            {
                _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var cert = _mapper.Map<Certification>(certification);
                bool result = _unitOfWork._certificationRepository.Delete(cert);
                _unitOfWork.SaveChanges();
                if (result) return await Task.FromResult(Ok(result));
            }
            return await Task.FromResult(BadRequest(false));
        }
        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> PostOrCreateCertification([FromBody] CertificationViewModel certification)
        {
            if (ModelState.IsValid)
            {
                _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var cert = _mapper.Map<Certification>(certification);
                bool result = _unitOfWork._certificationRepository.Insert(cert);
                _unitOfWork.SaveChanges();
                if (result) return await Task.FromResult(Ok(result));
            }
            return await Task.FromResult(BadRequest(false));
        }
        
       [HttpGet]
        public async Task<IActionResult> GetCourseById(int courseId)
        {
            var result = _unitOfWork._courseRepository.GetById(courseId);

            if (result != null)
            {
                var resView = _mapper.Map<CourseViewModel>(result);
                return await Task.FromResult(Ok(resView));
            }
            return await Task.FromResult(NotFound());
        }
        [HttpGet]
        public async Task<IActionResult> GetworkCategoryById(int workCategoryId)
        {
            var result = _unitOfWork._workCategoryRepository.GetById(workCategoryId);

            if (result != null)
            {
                var resView = _mapper.Map<WorkCategoryViewModel>(result);
                return await Task.FromResult(Ok(resView));
            }
            return await Task.FromResult(NotFound());
        }
        [HttpGet]
        public async Task<IActionResult> GetCertificationById(int certificationId)
        {
            var result = _unitOfWork._certificationRepository.GetById(certificationId);

            if (result != null)
            {
                var resView = _mapper.Map<CertificationViewModel>(result);
                return await Task.FromResult(Ok(resView));
            }
            return await Task.FromResult(NotFound());
        }

        [HttpGet]
        public async Task<IActionResult> GetAllCertification()
        {
            if (ModelState.IsValid)
            {
                var results = _unitOfWork._certificationRepository.GetAll();
                var resView = _mapper.Map<CertificationViewModel[]>(results.ToArray());
                if (results.Any()) return await Task.FromResult(Ok(resView));
            }
            return await Task.FromResult(BadRequest(false));
        }
        [HttpPost]
        [Authorize(Roles = ("Administrator"))]
        public async Task<IActionResult> UpdateLocation([FromBody] Location location)
        {
            _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
            bool result = await _serviceEndPoint.UpdateLocation(location);
            if (result) return Ok(result);
            return await Task.FromResult(BadRequest(false));
        }
        // POST: api/Administration
        [HttpPost]
        public void PostEmail(IMailService emailService, MyFundiUnitOfWork unitOfWork)
        {
            _emailService = emailService;
            _unitOfWork = unitOfWork;
        }

    }
}
