using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using MyFundi.Web.IdentityServices;
using MyFundi.Services.EmailServices;
using MyFundi.Services.RepositoryServices;
using System.Reflection;
using System.IO;
using MyFundi.Services.EmailServices.Interfaces;
using MyFundi.UnitOfWork.Concretes;
using MyFundiProfile.ServiceEndPoint.GeneralSevices;
using MyFundi.Domain;

namespace MyFundi.Web.Controllers
{
    [EnableCors(PolicyName = "CorsPolicy")]
    public class TransportController : Controller
    {
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private Mapper _Mapper;

        public TransportController(IMailService emailService, MyFundiUnitOfWork unitOfWork, Mapper mapper)
        {
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _Mapper = mapper;

        }

}
}

