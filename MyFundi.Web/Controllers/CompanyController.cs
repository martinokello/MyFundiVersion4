using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.Web.ViewModels;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using MyFundi.Web.IdentityServices;
using MyFundiProfile.ServiceEndPoint.GeneralSevices;

namespace MyFundi.Web.Controllers
{
    [AuthorizeIdentity]
    [EnableCors(PolicyName = "CorsPolicy")]
    public class CompanyController : Controller
    {
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private Mapper _Mapper;

        public CompanyController(IMailService emailService, MyFundiUnitOfWork unitOfWork, Mapper mapper)
        {
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _Mapper = mapper;
        }
        [HttpGet]
        [Route("~/{Controller}/{Action}/{companyId}")]
        public async Task<IActionResult> GetCompanyById(int companyId)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                Company res = await _serviceEndPoint.GetCompanyById(companyId);
                CompanyViewModel results = _Mapper.Map<CompanyViewModel>(res);
                if (results == null)
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
        [HttpPost]
        public async Task<IActionResult> PostOrCreateCompany([FromBody] CompanyViewModel companyViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var company = _Mapper.Map<Company>(companyViewModel);
                bool result = await _serviceEndPoint.PostCreateCompany(company);
                if (!result)
                {
                    return NotFound(companyViewModel);
                }
                return Ok(new { message = "Succesfully Created!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [HttpPost]
        public async Task<IActionResult> UpdateCompany([FromBody] CompanyViewModel companyViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var farmer = _Mapper.Map<Company>(companyViewModel);
                bool result = await _serviceEndPoint.UpdateCompany(farmer);
                if (!result)
                {
                    return NotFound(companyViewModel);
                }
                return Ok(new { message = "Succesfully Updated!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
 
        [HttpPost]
        public async Task<IActionResult> DeleteCompany([FromBody] CompanyViewModel companyViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var company = _Mapper.Map<Company>(companyViewModel);
                bool result = await _serviceEndPoint.DeleteCompany(company);
                if (!result)
                {
                    return NotFound(companyViewModel);
                }
                return Ok(new { message = "Succesfully Deleted!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetAllCompanies()
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                Company[] companies = await _serviceEndPoint.GetAllCompanies();
                CompanyViewModel[] results = _Mapper.Map<CompanyViewModel[]>(companies);
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
    }
}
