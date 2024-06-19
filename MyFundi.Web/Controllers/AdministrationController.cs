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

        public async Task<IActionResult> GetAdvertLinks()
        {
            try
            {
                var absoluteAdvertLinkUrl1 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl1").Value;
                var absoluteAdvertLinkUrl2 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl2").Value;
                var absoluteAdvertLinkUrl3 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl3").Value;
                return await Task.FromResult(Ok(new { AdvertLinkUrl1 = absoluteAdvertLinkUrl1, AdvertLinkUrl2 = absoluteAdvertLinkUrl2, AdvertLinkUrl3 = absoluteAdvertLinkUrl3 }));
            }
            catch
            {
                return await Task.FromResult(BadRequest(null));
            }
        }
        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UploadBlogSingleImages([FromForm] IFormFile blogFile)
        {
            try
            {
                if (blogFile != null)
                {
                    var blogDirectory = new DirectoryInfo($"{this.Environment.ContentRootPath}\\wwwroot\\images");
                    if (!blogDirectory.Exists)
                    {
                        blogDirectory.Create();
                    }
                    var fileInfo = new FileInfo($"{this.Environment.ContentRootPath}\\wwwroot\\images\\{blogFile.FileName}");
                    using (var fileStream = (fileInfo.Exists ? fileInfo.OpenWrite() : fileInfo.Create()))
                    {
                        await blogFile.CopyToAsync(fileStream);

                        return Ok(new { result = true, Message = "Successfully Uploaded Blog!" });
                    }
                }
                else
                {
                    return Ok(new { AbsoluteAdvertUrl = "", Result = false, Message = "Flie Does not Exist." });
                }
            }
            catch (Exception ex)
            {

                return await Task.FromResult(Ok(new { Message = ex.Message + "\n" + ex.StackTrace, Result = false, AbsoluteAdvertUrl = string.Empty }));
            }
        }
        [HttpGet]
        [Route("~/Administration/GetBlog/{blogId}")]
        public async Task<IActionResult> GetBlog(int blogId)
        {
            var editBlog = _unitOfWork._blogsRepository.GetById(blogId);

            if (editBlog != null)
            {
                return await Task.FromResult(Ok(new { Blog = _mapper.Map<BlogViewModel>(editBlog), Success = true }));
            }
            else
            {
                return await Task.FromResult(Ok(new { Blog = "", Success = false }));
            }
        }
        
        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UpdateBlog([FromForm] IFormFile blogFile)
        {
            try
            {
                //_unitOfWork._blogsRepository.Insert(new Blog { BlogContent = HttpContext.Request.Form["blogContent"], BlogName = HttpContext.Request.Form["blogName"] });
                var blogToUpdate = _unitOfWork._blogsRepository.GetById(Int32.Parse(HttpContext.Request.Form["blogId"]));
                if (blogToUpdate != null)
                {
                    blogToUpdate.BlogContent = HttpContext.Request.Form["blogContent"];
                    blogToUpdate.BlogName = HttpContext.Request.Form["blogName"];
                    blogToUpdate.DateUpdated = DateTime.Now;
                    _unitOfWork.SaveChanges();
                    var blogDirectory = new DirectoryInfo($"{this.Environment.ContentRootPath}\\images");
                    if (!blogDirectory.Exists)
                    {
                        blogDirectory.Create();
                    }
                    var fileInfo = new FileInfo($"{this.Environment.ContentRootPath}\\images\\{HttpContext.Request.Form["blogName"]}.jpg");
                    if (blogFile != null)
                    {
                        using (var fileStream = (fileInfo.Exists ? fileInfo.OpenWrite() : fileInfo.Create()))
                        {
                            await blogFile.CopyToAsync(fileStream);

                        }
                    }

                    return Ok(new { result = true, Message = "Successfully Updated Blog!" });
                }
                else
                {
                    return Ok(new { AbsoluteAdvertUrl = "", Result = false, Message = "Flie Does not Exist." });
                }
            }
            catch (Exception ex)
            {

                return await Task.FromResult(Ok(new { Message = ex.Message + "\n" + ex.StackTrace, Result = false, AbsoluteAdvertUrl = string.Empty }));
            }
        }
		
		[CustomAuthorize("Administrator")]
        [Route("~/Administration/DeleteBlog/{blogId}")]
		public async Task<IActionResult> DeleteBlog(int blogId)
		{
			try
			{
				var blog = _unitOfWork._blogsRepository.GetById(blogId);
                _unitOfWork._blogsRepository.Delete(blog);
				_unitOfWork.SaveChanges();
                return await Task.FromResult(Ok(new { hasDeleted = true, Message = $"Deleted Blog {blogId.ToString()}" }));
			}
			catch (Exception ex)
			{
				return await Task.FromResult(Ok(new { hasDeleted = false, Message = $"Failed To Delete Blog {blogId.ToString()}" }));

			}
		}
		[HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UploadBlog([FromForm] IFormFile blogFile)
        {
            try
            {
                _unitOfWork._blogsRepository.Insert(new Blog { BlogContent = HttpContext.Request.Form["blogContent"], BlogName = HttpContext.Request.Form["blogName"] });
                _unitOfWork.SaveChanges();
                if (blogFile != null)
                {
                    var blogDirectory = new DirectoryInfo($"{this.Environment.ContentRootPath}\\images");
                    if (!blogDirectory.Exists)
                    {
                        blogDirectory.Create();
                    }
                    var fileInfo = new FileInfo($"{this.Environment.ContentRootPath}\\images\\{HttpContext.Request.Form["blogName"]}.jpg");
                    using (var fileStream = (fileInfo.Exists ? fileInfo.OpenWrite() : fileInfo.Create()))
                    {
                        await blogFile.CopyToAsync(fileStream);

                        return Ok(new { result = true, Message = "Successfully Uploaded Blog!" });
                    }
                }
                else
                {
                    return Ok(new { AbsoluteAdvertUrl = "", Result = false, Message = "Flie Does not Exist." });
                }
            }
            catch (Exception ex)
            {

                return await Task.FromResult(Ok(new { Message = ex.Message + "\n" + ex.StackTrace, Result = false, AbsoluteAdvertUrl = string.Empty }));
            }
        }
        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UploadAdvertGifImage1([FromForm] IFormFile advertGifFiles)
        {
            try
            {
                if (advertGifFiles != null)
                {
                    var absoluteAdvertLinkUrl1 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl1").Value;
                    var absoluteAdvertLinkUrl2 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl2").Value;
                    var absoluteAdvertLinkUrl3 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl3").Value;
                    var dirAdvertImg = new DirectoryInfo($"{this.Environment.ContentRootPath}\\images");
                    if (!dirAdvertImg.Exists)
                    {
                        dirAdvertImg.Create();
                    }
                    var fileInfo1 = new FileInfo($"{this.Environment.ContentRootPath}\\images\\currentAdvert1.gif");
                    using (var fileStream = (fileInfo1.Exists ? fileInfo1.OpenWrite() : fileInfo1.Create()))
                    {
                        await advertGifFiles.CopyToAsync(fileStream);
                    }
                    return Ok(new { AbsoluteAdvertLinkUrl1 = absoluteAdvertLinkUrl1, AbsoluteAdvertLinkUrl2 = absoluteAdvertLinkUrl2, AbsoluteAdvertLinkUrl3 = absoluteAdvertLinkUrl3, Result = true, Message = "Successfully Uploaded Advert Gif Image." });

                }
                else
                {
                    return Ok(new { AbsoluteAdvertUrl1 = "", AbsoluteAdvertLinkUrl2 = "", AbsoluteAdvertLinkUrl3 = "", Result = false, Message = "Flie Does not Exist." });
                }
            }
            catch (Exception ex)
            {

                return await Task.FromResult(BadRequest(new { Message = ex.Message + "\n" + ex.StackTrace, Result = false, AbsoluteAdvertUrl = string.Empty }));
            }
        }


        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UploadAdvertGifImage2([FromForm] IFormFile advertGifFiles)
        {
            try
            {
                if (advertGifFiles != null)
                {
                    var absoluteAdvertLinkUrl1 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl1").Value;
                    var absoluteAdvertLinkUrl2 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl2").Value;
                    var absoluteAdvertLinkUrl3 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl3").Value;
                    var dirAdvertImg = new DirectoryInfo($"{this.Environment.ContentRootPath}\\wwwroot\\images");
                    if (!dirAdvertImg.Exists)
                    {
                        dirAdvertImg.Create();
                    }
                    var fileInfo1 = new FileInfo($"{this.Environment.ContentRootPath}\\wwwroot\\images\\currentAdvert2.gif");
                    using (var fileStream = (fileInfo1.Exists ? fileInfo1.OpenWrite() : fileInfo1.Create()))
                    {
                        await advertGifFiles.CopyToAsync(fileStream);
                    }
                    return Ok(new { AbsoluteAdvertLinkUrl1 = absoluteAdvertLinkUrl1, AbsoluteAdvertLinkUrl2 = absoluteAdvertLinkUrl2, AbsoluteAdvertLinkUrl3 = absoluteAdvertLinkUrl3, Result = true, Message = "Successfully Uploaded Advert Gif Image." });

                }
                else
                {
                    return Ok(new { AbsoluteAdvertUrl1 = "", AbsoluteAdvertLinkUrl2 = "", AbsoluteAdvertLinkUrl3 = "", Result = false, Message = "Flie Does not Exist." });
                }
            }
            catch (Exception ex)
            {

                return await Task.FromResult(BadRequest(new { Message = ex.Message + "\n" + ex.StackTrace, Result = false, AbsoluteAdvertUrl = string.Empty }));
            }
        }

        [HttpPost]
        [CustomAuthorize("Administrator")]
        public async Task<IActionResult> UploadAdvertGifImage3([FromForm] IFormFile advertGifFiles)
        {
            try
            {
                if (advertGifFiles != null)
                {
                    var absoluteAdvertLinkUrl1 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl1").Value;
                    var absoluteAdvertLinkUrl2 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl2").Value;
                    var absoluteAdvertLinkUrl3 = this._appSettings.AppSettings.GetSection("AdvertisingAbsoluteLinkUrl3").Value;
                    var dirAdvertImg = new DirectoryInfo($"{this.Environment.ContentRootPath}\\wwwroot\\images");
                    if (!dirAdvertImg.Exists)
                    {
                        dirAdvertImg.Create();
                    }
                    var fileInfo1 = new FileInfo($"{this.Environment.ContentRootPath}\\wwwroot\\images\\currentAdvert3.gif");
                    using (var fileStream = (fileInfo1.Exists ? fileInfo1.OpenWrite() : fileInfo1.Create()))
                    {
                        await advertGifFiles.CopyToAsync(fileStream);
                    }
                    return Ok(new { AbsoluteAdvertLinkUrl1 = absoluteAdvertLinkUrl1, AbsoluteAdvertLinkUrl2 = absoluteAdvertLinkUrl2, AbsoluteAdvertLinkUrl3 = absoluteAdvertLinkUrl3, Result = true, Message = "Successfully Uploaded Advert Gif Image." });

                }
                else
                {
                    return Ok(new { AbsoluteAdvertUrl1 = "", AbsoluteAdvertLinkUrl2 = "", AbsoluteAdvertLinkUrl3 = "", Result = false, Message = "Flie Does not Exist." });
                }
            }
            catch (Exception ex)
            {

                return await Task.FromResult(BadRequest(new { Message = ex.Message + "\n" + ex.StackTrace, Result = false, AbsoluteAdvertUrl = string.Empty }));
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
