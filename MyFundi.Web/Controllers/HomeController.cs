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
using MyFundi.IdentityServices;

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
        public readonly IUserService _userService;
        private readonly IRoleService _roleService;
        private Mapper _mapper;
        public HomeController(IUserService userService, IRoleService roleService, IMailService emailService, MyFundiUnitOfWork unitOfWork, AppSettingsConfigurations appSettings, PaymentsManager paymentsManager, Mapper mapper)
        {
            _roleService = roleService;
            _userService = userService;
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
        [HttpGet]
        public async Task<IActionResult> GetAllBlogs()
        {
            try
            {
                return await Task.FromResult(Ok(_unitOfWork._blogsRepository.GetAll().OrderByDescending(q=> q.DateCreated).ToArray()));
            }
            catch (Exception ex) {
                return await Task.FromResult(BadRequest(null));
            }
        }

        [HttpPost]
        public async Task<IActionResult> SearchBlogs([FromBody] string[] query)
        {
            try
            {
                var allBlogs = _unitOfWork._blogsRepository.GetAll().ToArray();
                var results = (from res in allBlogs
                               where res.BlogName.ToLower().Split(new char[] { ' ', '.', ',', '!', '?' }, StringSplitOptions.RemoveEmptyEntries).Intersect(query).Any() || res.BlogContent.ToLower().Split(new char[] { ' ', '.',',','!','?' }, StringSplitOptions.RemoveEmptyEntries).Intersect(query).Any()
                               orderby res.DateCreated descending
                               select res);
                if (results.Any())
                {
                    return await Task.FromResult(Ok(results.ToArray()));
                }
                else { 
                    return await Task.FromResult(Ok(new string[] { }));
                }
            }
            catch (Exception ex)
            {
                return await Task.FromResult(BadRequest(new { Message=ex.Message, StackTrace = ex.StackTrace}));
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


        public async Task<JsonResult> CheckAndValidatePaypalPayments(FormCollection formsCollection)
        {
            decimal amountPaid = Decimal.Parse(formsCollection["amount"]);
            var userName = formsCollection["buyer_email"].First();
            var userInvoice = _unitOfWork._monthlySubscriptionQueueRepository.GetAll().FirstOrDefault(q => q.User.Username.ToLower().Equals(formsCollection["buyer_id"]));
            var fundiSubsc = _unitOfWork._fundiSubscriptionQueueRepository.GetAll().FirstOrDefault(q => q.MonthlySubscriptionQueueId == userInvoice.MonthlySubscriptionQueueId);

            try
            {

                if (await _userService.IsUserInRoleAsync(userName, "Fundi"))
                {
                    if (userInvoice.User.Username.ToLower().Equals(userName.ToLower()) /*&& amountPaid == fundiSubsc.SubscriptionFee*/)
                    {
                        var fundiSubsQueueItems = _unitOfWork._fundiSubscriptionQueueRepository.GetAll().Where(q => q.MonthlySubscriptionQueueId == userInvoice.MonthlySubscriptionQueueId);

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
                        //Copy from Queue to MonthlySubscription:
                        var monthlyFundiSubcription = new MonthlySubscription
                        {
                            SubscriptionName = userInvoice.SubscriptionName,
                            HasPaid = true,
                            HasExpired = false,
                            DateCreated = DateTime.Now,
                            DateUpdated = DateTime.Now,
                            EndDate = DateTime.Now.AddDays(30),
                            FundiProfileId = userInvoice.FundiProfileId,
                            StartDate = DateTime.Now,
                            SubscriptionDescription = userInvoice.SubscriptionDescription,
                            SubscriptionFee = userInvoice.SubscriptionFee,
                            UserId = userInvoice.UserId,
                            Username = userInvoice.Username
                        };
                        _unitOfWork._monthlySubscriptionRepository.Insert(monthlyFundiSubcription);
                        _unitOfWork.SaveChanges();

                        foreach (var funSubQueItem in fundiSubsQueueItems)
                        {
                            var fundiSubs = new FundiSubscription
                            {
                                DateCreated = DateTime.Now,
                                DateUpdated = DateTime.Now,
                                EndDate = DateTime.Now.AddDays(30),
                                FundiWorkCategoryId = funSubQueItem.FundiWorkCategoryId,
                                FundiWorkSubCategoryId = funSubQueItem.FundiWorkSubCategoryId,
                                MonthlySubscriptionId = monthlyFundiSubcription.MonthlySubscriptionId,
                                StartDate = DateTime.Now,
                                SubscriptionDescription = funSubQueItem.SubscriptionDescription,
                                SubscriptionFee = funSubQueItem.SubscriptionFee,
                                SubscriptionName = funSubQueItem.SubscriptionName
                            };
                            _unitOfWork._fundiSubscriptionRepository.Insert(fundiSubs);
                            _unitOfWork.SaveChanges();

                            //Delete monthlySubscriptionQueue And FundiSubsciptionQueue items:

                            _unitOfWork._fundiSubscriptionQueueRepository.Delete(funSubQueItem);
                            _unitOfWork.SaveChanges();
                        }
                        _unitOfWork._monthlySubscriptionQueueRepository.Delete(userInvoice);
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

                        return await Task.FromResult(Json(new { Result = "Success" }));

                    }
                    else
                    {
                        var clientSubs = _unitOfWork._clientSubscriptionRepository.GetAll().Where(q => !q.HasPaid && q.Username.ToLower().Equals(userName.ToLower())).FirstOrDefault();

                        if (userInvoice.User.Username.ToLower().Equals(userName.ToLower()) && amountPaid == clientSubs.SubscriptionFee)
                        {
                            clientSubs.HasPaid = true;
                            _unitOfWork.SaveChanges();
                        }

                        return await Task.FromResult(Json(new { Result = "Success" }));
                    }
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
                return Json(new { Result = "Bad Input" });
            }
            return Json(new { Result = "Failed" });
        }

        public async Task<JsonResult> CheckAndValidateMTNandAirtelPayments([FromBody] IPNotificationViewModel ipnNotificationViewModel)
        {
            decimal amountPaid = ipnNotificationViewModel.Amount;
            string clientId = ipnNotificationViewModel.Reference.Split(new char[] {':',' '}, StringSplitOptions.RemoveEmptyEntries)[0];
            string transactionId = ipnNotificationViewModel.TransactionId;
            string reason = ipnNotificationViewModel.Reason;

            
            var userInvoice = _unitOfWork._monthlySubscriptionQueueRepository.GetAll().FirstOrDefault(q => q.User.Username.ToLower().Equals(clientId));
            var fundiSubsc = _unitOfWork._fundiSubscriptionQueueRepository.GetAll().FirstOrDefault(q => q.MonthlySubscriptionQueueId == userInvoice.MonthlySubscriptionQueueId);

            try
            {
                var fundiSubsQueueItems = _unitOfWork._fundiSubscriptionQueueRepository.GetAll().Where(q => q.MonthlySubscriptionQueueId == userInvoice.MonthlySubscriptionQueueId);
                if (await _userService.IsUserInRoleAsync(clientId, "Fundi"))
                {
                    if (userInvoice.User.Username.ToLower().Equals(clientId.ToLower()) && amountPaid == fundiSubsc.SubscriptionFee)
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
                        //Copy from Queue to MonthlySubscription:
                        var monthlyFundiSubcription = new MonthlySubscription
                        {
                            SubscriptionName = userInvoice.SubscriptionName,
                            HasPaid = true,
                            HasExpired = false,
                            DateCreated = DateTime.Now,
                            DateUpdated = DateTime.Now,
                            EndDate = DateTime.Now.AddDays(30),
                            FundiProfileId = userInvoice.FundiProfileId,
                            StartDate = DateTime.Now,
                            SubscriptionDescription = userInvoice.SubscriptionDescription,
                            SubscriptionFee = userInvoice.SubscriptionFee,
                            UserId = userInvoice.UserId,
                            Username = userInvoice.Username
                        };
                        _unitOfWork._monthlySubscriptionRepository.Insert(monthlyFundiSubcription);
                        _unitOfWork.SaveChanges();

                        foreach (var funSubQueItem in fundiSubsQueueItems)
                        {
                            var fundiSubs = new FundiSubscription
                            {
                                DateCreated = DateTime.Now,
                                DateUpdated = DateTime.Now,
                                EndDate = DateTime.Now.AddDays(30),
                                FundiWorkCategoryId = funSubQueItem.FundiWorkCategoryId,
                                FundiWorkSubCategoryId = funSubQueItem.FundiWorkSubCategoryId,
                                MonthlySubscriptionId = monthlyFundiSubcription.MonthlySubscriptionId,
                                StartDate = DateTime.Now,
                                SubscriptionDescription = funSubQueItem.SubscriptionDescription,
                                SubscriptionFee = funSubQueItem.SubscriptionFee,
                                SubscriptionName = funSubQueItem.SubscriptionName
                            };
                            _unitOfWork._fundiSubscriptionRepository.Insert(fundiSubs);
                            _unitOfWork.SaveChanges();

                            //Delete monthlySubscriptionQueue And FundiSubsciptionQueue items:

                            _unitOfWork._fundiSubscriptionQueueRepository.Delete(funSubQueItem);
                            _unitOfWork.SaveChanges();
                        }
                        _unitOfWork._monthlySubscriptionQueueRepository.Delete(userInvoice);
                        _unitOfWork.SaveChanges();
                        return await Task.FromResult(Json(new { Result = "Success" }));
                    }
                    else
                    {
                        foreach (var funSubQueItem in fundiSubsQueueItems)
                        {
                            //Delete monthlySubscriptionQueue And FundiSubsciptionQueue items:

                            _unitOfWork._fundiSubscriptionQueueRepository.Delete(funSubQueItem);
                            _unitOfWork.SaveChanges();
                        }
                        _unitOfWork._monthlySubscriptionQueueRepository.Delete(userInvoice);
                        _unitOfWork.SaveChanges();
                        _emailService.SendEmail(new EmailDao
                        {
                            EmailTo = userInvoice.User.Username,
                            EmailSubject = "TransactioniD " + transactionId + " for: " + userInvoice.User.FirstName + ", failed Processing By MTN and Airtel.",
                            DateCreated = DateTime.Now,
                            DateUpdated = DateTime.Now,
                            EmailBody = new EmailTemplating().GetEmailTemplate(EmailTemplate.TransactionFailureMessage).Replace("[[FirstName]]", userInvoice.User.FirstName).
                            Replace("[[TransactionCommoditesList]]", fundiSubsc.SubscriptionName + ", Net Price:" + fundiSubsc.SubscriptionFee + ", Gross Total Payable: " + fundiSubsc.SubscriptionFee)
                        });
                    }
                }
                else
                {
                    var clientSubs = _unitOfWork._clientSubscriptionRepository.GetAll().Where(q => !q.HasPaid && q.Username.ToLower().Equals(clientId.ToLower())).FirstOrDefault();

                    if (userInvoice.User.Username.ToLower().Equals(clientId.ToLower()) && amountPaid == clientSubs.SubscriptionFee)
                    {
                        clientSubs.HasPaid = true;
                        _unitOfWork.SaveChanges();
                    }

                    return await Task.FromResult(Json(new { Result = "Success" }));
                }
            }
            catch (Exception e)
            {

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
