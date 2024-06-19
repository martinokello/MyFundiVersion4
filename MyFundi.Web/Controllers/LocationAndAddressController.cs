using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.UnitOfWork.Interfaces;
using MyFundi.Web.ViewModels;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using MyFundi.Web.IdentityServices;
using MyFundiProfile.ServiceEndPoint.GeneralSevices;

namespace MyFundi.Web.Controllers
{
    [AuthorizeIdentity]
    [EnableCors(PolicyName = "CorsPolicy")]
    public class LocationAndAddressController : Controller
    {
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private Mapper _Mapper;

        public LocationAndAddressController(IMailService emailService, MyFundiUnitOfWork unitOfWork, Mapper mapper)
        {
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _Mapper = mapper;

        }

        [Route("~/{Controller}/{Action}/{addressId}")]
        [HttpGet]
        public async Task<IActionResult> GetAddressById(int addressId)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                Address res = await _serviceEndPoint.GetAddressById(addressId);
                AddressViewModel results = _Mapper.Map<AddressViewModel>(res);
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
        [AuthorizeIdentity]
        public async Task<IActionResult> PostOrCreateAddress([FromBody] AddressViewModel addressViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var address = _Mapper.Map<Address>(addressViewModel);
                bool result = await _serviceEndPoint.PostCreateAddress(address);
                if (!result)
                {
                    return NotFound(addressViewModel);
                }
                return Ok(new { message = "Succesfully Created!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [HttpPost]
        [AuthorizeIdentity]
        public async Task<IActionResult> UpdateAddress([FromBody] AddressViewModel addressViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var address = _Mapper.Map<Address>(addressViewModel);
                bool result = await _serviceEndPoint.UpdateAddress(address);
                if (!result)
                {
                    return NotFound(addressViewModel);
                }
                return Ok(new { message = "Succesfully Updated!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [HttpPost]
        public async Task<IActionResult> SelectAddress([FromBody] AddressViewModel addressViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var address = _Mapper.Map<Address>(addressViewModel);
                var result = await _serviceEndPoint.SelectAddress(address);
                if (result == null)
                {
                    return NotFound(addressViewModel);
                }
                return Ok(new { message = "Succesfully Selected!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [HttpPost]
        [AuthorizeIdentity]
        public async Task<IActionResult> DeleteAddress([FromBody] AddressViewModel addressViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var address = _Mapper.Map<Address>(addressViewModel);
                bool result = await _serviceEndPoint.DeleteAddress(address);
                if (!result)
                {
                    return NotFound(new { message = "Failed To Delete Address:" + address.AddressLine1 });
                }
                return Ok(new { message = "Succesfully Deleted!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllAddresses()
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                Address[] addresses = await _serviceEndPoint.GetAllAddresses();
                AddressViewModel[] results = _Mapper.Map<AddressViewModel[]>(addresses);
                if (!results.Any())
                {
                    return NotFound(results);
                }
                return Ok(results);
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message, StackTrace = ex.StackTrace });
            }

        }

        //Location CRUD:
        [Route("~/{Controller}/{Action}/{locationId}")]
        [HttpGet]
        public async Task<IActionResult> GetLocationById(int locationId)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                Location res = await _serviceEndPoint.GetLocationById(locationId);
                LocationViewModel results = _Mapper.Map<LocationViewModel>(res);
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
        [AuthorizeIdentity]
        public async Task<IActionResult> PostOrCreateLocation([FromBody] LocationViewModel locationViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var location = _Mapper.Map<Location>(locationViewModel);
                bool result = await _serviceEndPoint.PostCreateLocation(location);
                if (!result)
                {
                    return NotFound(locationViewModel);
                }
                return Ok(new { message = "Succesfully Created!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [HttpPost]
        [AuthorizeIdentity]
        public async Task<IActionResult> UpdateLocation([FromBody] LocationViewModel locationViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var location = _Mapper.Map<Location>(locationViewModel);
                bool result = await _serviceEndPoint.UpdateLocation(location);
                if (!result)
                {
                    return NotFound(locationViewModel);
                }
                return Ok(new { message = "Succesfully Updated!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [HttpPost]
        public async Task<IActionResult> SelectLocation([FromBody] LocationViewModel locationViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var location = _Mapper.Map<Location>(locationViewModel);
                var result = await _serviceEndPoint.SelectLocation(location);
                if (result == null)
                {
                    return NotFound(locationViewModel);
                }
                return Ok(new { message = "Succesfully Selected!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [HttpPost]
        public async Task<IActionResult> DeleteLocation([FromBody] LocationViewModel locationViewModel)
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                var location = _Mapper.Map<Location>(locationViewModel);
                bool result = await _serviceEndPoint.DeleteLocation(location);
                if (!result)
                {
                    return NotFound(locationViewModel);
                }
                return Ok(new { message = "Succesfully Deleted!", result = result });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetAllLocations()
        {
            try
            {
                var _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
                Location[] farmers = await _serviceEndPoint.GetAllLocations();
                LocationViewModel[] results = _Mapper.Map<LocationViewModel[]>(farmers);
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
