using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.UnitOfWork.Interfaces;
using MyFundi.AppConfigurations;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using QRCoder;
using MyFundi.Web.ViewModels;
using PaymentGateway;
using PaypalFacility;
using AutoMapper;
using Microsoft.AspNetCore.Http;
using MyFundi.Services.EmailServices;
using MyFundi.Web.IdentityServices;
using System.Text;
using Microsoft.EntityFrameworkCore;
using MyFundiProfile.ServiceEndPoint.GeneralSevices;
using System.Transactions;

namespace MyFundi.Web.Controllers
{
    [EnableCors(PolicyName = "CorsPolicy")]
    public class HomeController : Controller
    {
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private ServicesEndPoint _serviceEndPoint;
        private IConfigurationSection _applicationConstants;
        private IConfigurationSection _businessSmtpDetails;
        private IConfigurationSection _twitterProfileFiguration;
        private PaymentsManager PaymentsManager;
        private Mapper _mapper;
        public HomeController(IMailService emailService, MyFundiUnitOfWork unitOfWork, AppSettingsConfigurations appSettings, PaymentsManager paymentsManager, Mapper mapper)
        {
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _applicationConstants = appSettings.AppSettings.GetSection("ApplicationConstants");
            _twitterProfileFiguration = appSettings.AppSettings.GetSection("TwitterProfileFiguration");
            _businessSmtpDetails = appSettings.AppSettings.GetSection("BusinessSmtpDetails");
            _serviceEndPoint = new ServicesEndPoint(_unitOfWork, _emailService);
            PaymentsManager = paymentsManager;
            _mapper = mapper;
        }
        public IActionResult Index()
        {
            return View();
        }

        [AuthorizeIdentity]
        [HttpPost]
        [Consumes("multipart/form-data")]
        public IActionResult SendEmail()
        {
            try
            {
                _emailService.BusinessEmailDetails = _businessSmtpDetails;
                //Send Email:
                _emailService.SendEmail(new EmailDao { Attachment = Request.Form.Files.Any() ? Request.Form.Files[0] : null, EmailBody = Request.Form["emailBody"], EmailFrom = Request.Form["emailFrom"], EmailSubject = Request.Form["emailSubject"], EmailTo = Request.Form["emailTo"] });
                return View("Index");
            }
            catch (Exception e)
            {
                return Json(new { Result = false });
            }
        }

        [HttpGet]
        [AuthorizeIdentity]
        public async Task<ActionResult> GetUserInvoicedItems(string username)
        {
            var curUser = this._unitOfWork.MyFundiDBContext.Users.FirstOrDefault(u => u.Email.ToLower().Equals(username.ToLower()));
            if (curUser != null)
            {
                return await Task.FromResult(Ok(this._unitOfWork.MyFundiDBContext.Invoices.Where(q => /*q.HasFullyPaid &&*/ q.UserId.Equals(curUser.UserId)).
                    Select(q => new InvoiceViewModel { InvoiceId = q.InvoiceId, HasFullyPaid = q.HasFullyPaid, InvoiceName = q.InvoiceName, DateUpdated = q.DateUpdated }).ToArray()));
            }
            return NotFound("User has no invoices for transport scheduling");
        }


        [AuthorizeIdentity]
        public async Task<JsonResult> CheckAndValidatePaypalPayments(FormCollection formsCollection)
        {
            decimal amountPaid = Decimal.Parse(formsCollection["amount"]);
            int clientId = Int32.Parse(formsCollection["clientId"]);
            var userInvoice = _unitOfWork._monthlySubscriptionRepository.GetAll().FirstOrDefault(q => q.User.Username.ToLower().Equals(formsCollection["buyer_id"]));
            var fundiSubsc = _unitOfWork._fundiSubscriptionRepository.GetAll().FirstOrDefault(q => q.MonthlySubscriptionId == userInvoice.MonthlySubscriptionId);

            try
            {
                if (userInvoice.User.Username.ToLower().Equals(formsCollection["buyer_email"].First().ToLower()) && amountPaid == fundiSubsc.SubscriptionFee)
                {

                    userInvoice.HasPaid = true;
                    _unitOfWork.SaveChanges();
                    _emailService.SendEmail(new EmailDao
                    {
                        EmailTo = userInvoice.User.Username,
                        EmailSubject = "Confirmation Of Invoice Payment.",
                        DateCreated = DateTime.Now,
                        DateUpdated = DateTime.Now,
                        EmailBody = new EmailTemplating().GetEmailTemplate(EmailTemplate.SuccessBuyCommodityMessage).Replace("[[FirstName]]", userInvoice.User.FirstName).
                        Replace("[[TransactionCommoditesList]]", fundiSubsc.SubscriptionName + ", Net Price:" + fundiSubsc.SubscriptionFee + ", Gross Total Payable: " + fundiSubsc.SubscriptionFee)
                    });

                    _emailService.SendEmail(new EmailDao
                    {
                        EmailTo = userInvoice.User.Username,
                        EmailSubject = "Please Schedule Transportation of your bought Commodities.",
                        DateCreated = DateTime.Now,
                        DateUpdated = DateTime.Now,
                        EmailBody = new EmailTemplating().GetEmailTemplate(EmailTemplate.ArrangeTransportScheduleMessage).Replace("[[FirstName]]", userInvoice.User.FirstName).
                        Replace("[[CommodiyName]]", fundiSubsc.SubscriptionName)
                    });
                    return await Task.FromResult(Json(new { Result = "Success" }));
                }
            }
            catch (Exception e)
            {
                _emailService.SendEmail(new EmailDao
                {
                    EmailTo = userInvoice.User.Username,
                    EmailSubject = "Transaction for: " + userInvoice.User.FirstName + ", failed Processing By Paypal.",
                    DateCreated = DateTime.Now,
                    DateUpdated = DateTime.Now,
                    EmailBody = new EmailTemplating().GetEmailTemplate(EmailTemplate.TransactionFailureMessage).Replace("[[FirstName]]", userInvoice.User.FirstName).
                    Replace("[[TransactionCommoditesList]]", fundiSubsc.SubscriptionName + ", Net Price:" + fundiSubsc.SubscriptionFee + ", Gross Total Payable: " + fundiSubsc.SubscriptionFee)
                });
                //email exception to admin email
                _emailService.SendEmail(new EmailDao
                {
                    EmailTo = userInvoice.User.Username,
                    EmailSubject = "Transaction for: " + userInvoice.User.FirstName + ", failed Processing By Paypal.",
                    DateCreated = DateTime.Now,
                    DateUpdated = DateTime.Now,
                    EmailBody = new EmailTemplating().GetEmailTemplate(EmailTemplate.TransactionFailureMessage).Replace("[[FirstName]]", userInvoice.User.FirstName).
                    Replace("[[TransactionCommoditesList]]", fundiSubsc.SubscriptionName + ", Net Price:" + fundiSubsc.SubscriptionFee + ", Gross Total Payable: " + fundiSubsc.SubscriptionFee)
                });
                return Json(new { Result = "Bad Input" });
            }
            return Json(new { Result = "Failed" });
        }
        [HttpPost]
        [AuthorizeIdentity]
        public IActionResult GetClientEmailAndMobilePhoneNumber([FromBody] MyFundi.Web.Models.UserDetails userDetail)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(userDetail.emailAddress);

            if (user != null)
            {
                //Validate: mobile number
                if (user.MobileNumber.Equals(userDetail.mobileNumber))
                {
                    return Json(new { message = "Verified", statusCode = 200 });
                }
            }
            return Json(new { message = "Failed Validation. User not Found!", statusCode = 400 });
        }
        [HttpGet]
        public FileContentResult GetUserGeneratedQrCode(string username)
        {
            User user = _serviceEndPoint.GetUserByEmailAddress(username);

            //Generate QR Code:

            QRCodeGenerator qrGenerator = new QRCodeGenerator();
            QRCodeData qrCodeData = qrGenerator.CreateQrCode($"{user.MobileNumber}_{user.Email}",
            QRCodeGenerator.ECCLevel.Q);
            QRCode qrCode = new QRCode(qrCodeData);
            Bitmap qrCodeImage = qrCode.GetGraphic(20);
            return File(BitmapToBytes(qrCodeImage), "image/png");
        }
        [HttpGet]
        [AuthorizeIdentity]
        public async Task<IActionResult> GetAllJobs()
        {
            var results = _mapper.Map<JobViewModel[]>(this._unitOfWork._jobRepository.GetAll().Include(q => q.Location).ToArray());

            if (results.Any())
            {
                return await Task.FromResult(Ok(results));
            }
            return await Task.FromResult(NotFound(new JobViewModel[] { }));
        }

        private Byte[] BitmapToBytes(Bitmap img)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                img.Save(stream, System.Drawing.Imaging.ImageFormat.Png);
                return stream.ToArray();
            }
        }

        private readonly static object _locker = new object();
    }

}
