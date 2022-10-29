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

namespace MyFundi.Web.ControllersControllers
{
    [EnableCors(PolicyName = "CorsPolicy")]
    public class AdministrationController : Controller
    {
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private ServicesEndPoint _serviceEndPoint;
        private Mapper _mapper;

        public AdministrationController(IMailService emailService, MyFundiUnitOfWork unitOfWork, Mapper mapper)
        {
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        [HttpPost]
        [Authorize(Roles = ("Administrator"))]
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
