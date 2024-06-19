using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using MyFundi.IdentityServices;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.Web.Models;
using MyFundi.AppConfigurations;
using MyFundi.Domain;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using MyFundi.Web.IdentityServices;
using MyFundi.Services.EmailServices.Concretes;
using MyFundi.Services.EmailServices;
using MyFundi.Services.EmailServices.Interfaces;

namespace MyFundi.Web.Controllers
{

    [EnableCors(PolicyName = "CorsPolicy")]
    public class AccountController : Controller
    {
        private MyFundiUnitOfWork _unitOfWork;
        public readonly IUserService _userService;
        private readonly IRoleService _roleService;
        private readonly IMailService _emailService;
        private readonly AppSettingsConfigurations _appSettings;
        public AccountController(IUserService userService, IRoleService roleService, MyFundiUnitOfWork unitOfWork, AppSettingsConfigurations appSettings, IMailService emailService)
        {
            _unitOfWork = unitOfWork;
            _roleService = roleService;
            _userService = userService;
            _emailService = emailService;
            _appSettings = appSettings;
        }


        [HttpGet]
        public async Task<IActionResult> VerifyLoggedInUser()
        {

            var authToken = HttpContext.Request.Headers["authToken"];
            if (!string.IsNullOrEmpty(authToken))
            {
                var user = await _userService.Authenticate(authToken);
                if (!string.IsNullOrEmpty(user.Username))
                {
                    var result = await Authenticate(authToken, user.Username.ToLower());
                    result.IsLoggedIn = true;
                    return await Task.FromResult(Ok(result));
				}
            }
            return Ok(new { IsLoggedIn = false });
        }
        [HttpGet]
        public async Task<IActionResult> GetUserGuidId(string username)
        {
            var users = await _userService.GetAll();
            var user = users.FirstOrDefault(q => q.Username.ToLower().Equals(username.ToLower()));
            if (user != null) return Ok(user.UserId);
            return NotFound();
        }
        [HttpPost]
        public async Task<IActionResult> Register([FromBody] UserDetails userDetails)
        {
            if (userDetails.password != userDetails.repassword)
            {
                ModelState.AddModelError(string.Empty, "Password don't match");
                return BadRequest(new { Error = "Passwords don't match", IsRegistered = false });
            }
            if (string.IsNullOrEmpty(userDetails.mobileNumber))
            {
                ModelState.AddModelError(string.Empty, "Mobile Number Required");
                return BadRequest(new { Error = "Mobile Number Required", IsRegistered = false });
            }
            var newUser = new User
            {
                Username = userDetails.emailAddress,
                Email = userDetails.emailAddress,
                MobileNumber = userDetails.mobileNumber,
                FirstName = userDetails.firstName,
                LastName = userDetails.lastName,
                CreateTime = DateTime.Now,
                IsActive = false,
                IsLockedOut = false,
                LastLogInTime = DateTime.Now
            };
            try
            {
                UserInteractionResults userCreationResult = await _userService.CreateAsync(newUser, userDetails.password);

            if(userCreationResult == UserInteractionResults.Succeeded)
                {
                    //Add User to role Fundi or Client:
                    var roleInsertionResult = await _roleService.AddToRoleAsync(newUser, userDetails.fundi ? "Fundi" : "Client");
                    if (roleInsertionResult == UserInteractionResults.Succeeded)
                    {
                        var clientSubFee = decimal.Parse(_appSettings.AppSettings.GetSection("ApplicationConstants").GetSection("ClientSubscriptionFee").Value);


                        if (userDetails.client)
                        {
                            var result = _unitOfWork._clientSubscriptionRepository.Insert(
                                new ClientSubscription
                                {
                                    UserId = newUser.UserId,
                                    DateCreated = DateTime.Now,
                                    DateUpdated = DateTime.Now,
                                    SubscriptionFee = clientSubFee,
                                    HasPaid = false,
                                    Username = newUser.Username,
                                    ClientProfileId = null,
                                    StartDate = DateTime.Now,
                                    SubscriptionName = "Initial Registration",
                                    SubscriptionDescription = "Initial Registration"
                                });
                            _unitOfWork.SaveChanges();
                        }
                        if (userDetails.fundi)
                        {
                            await _roleService.AddToRoleAsync(newUser, "Guest");
                        }
                        _emailService.SendEmail(new EmailDao
                        {
                            EmailTo = userDetails.emailAddress,
                            EmailSubject = "Welcome to MyFundi Web App",
                            DateCreated = DateTime.Now,
                            DateUpdated = DateTime.Now,
                            EmailBody = new EmailTemplating().GetEmailTemplate(EmailTemplate.WelcomeMessage).Replace("[[FirstName]]", userDetails.firstName)
                        });

                    }
                }

                return Ok(new { IsRegistered = true, IsAdministrator = false, Message = UserInteractionResults.Succeeded.ToString() });

            }
            catch (Exception ex)
            {
                return Ok(new { IsRegistered = true, IsAdministrator = false, Message = ex.Message });
            }

        }

        [HttpGet]
        public async Task<LoginResult> Authenticate(string authToken, string email)
        {
            var expiryDueWithin7 = 7;
            var expiryDueWithin5 = 5;
            var expiryDueWithin2 = 2;
            var clientdurationInDaysDue = 7;

            if (!string.IsNullOrEmpty(authToken))
            {
                var user = await _userService.Authenticate(authToken);
                user = _unitOfWork._userRepository.GetAll().FirstOrDefault(q => q.Username.ToLower().Equals(user.Username.ToLower()));
                var fundi = _unitOfWork._fundiProfileRepository.GetAll().FirstOrDefault(q => q.UserId == user.UserId);

                if (fundi != null)
                {
                    var isInRoleGuest = await _userService.IsUserInRoleAsync(user.Username, "Guest");

                    var message = _unitOfWork.MyFundiDBContext.ValidateFundiSubscription(fundi.FundiProfileId);
                    var tmpTopMessage = message;
                    if (!message.ToLower().Equals("Subscription Is Still Valid".ToLower()) &&
                        !await _userService.IsUserInRoleAsync(user.Username, "administrator"))
                    {
                        await UserAddToRole(new Models.UserRole { role = "Guest", email = user.Email });
                        await UserRemoveFromRole(new Models.UserRole { role = "Fundi", email = user.Email });

                        return new LoginResult
                        {
                            ErrorMessage = message,
                            FirstName = user.FirstName,
                            LastName = user.LastName,
                            IsLoggedIn = true,
                            IsFundi = true,
                            IsAdministrator = await _userService.IsUserInRoleAsync(user.Username, "Administrator"),
                            IsClient = await _userService.IsUserInRoleAsync(user.Username, "Client"),
                            Message = message,
                            Username = user.Username,
                            AuthToken = authToken,
                            IsRegistered = true,
                            FundiDueToPaySubscription = true,
                            ClientDueToPaySubscription = (await(_userService.IsUserInRoleAsync(user.Username,"Client")) && _unitOfWork.MyFundiDBContext.IsClientToPaySubscriptionFee(user.Username, clientdurationInDaysDue))
						};
                    }
                    else if (await _userService.IsUserInRoleAsync(user.Username, "administrator"))
                    {
                        var isUserInRoleFundi1 = await _userService.IsUserInRoleAsync(user.Username, "Fundi");
                        if (!isUserInRoleFundi1)
                        {
                            await UserAddToRole(new Models.UserRole { role = "Fundi", email = user.Email });
                        }
                        var actualResult = new LoginResult
                        {
                            IsLoggedIn = true,
                            FirstName = user.FirstName,
                            LastName = user.LastName,
                            Username = user.Username,
                            IsAdministrator = true,
                            Message = string.Empty,
                            AuthToken = authToken,
                            IsClient = await _userService.IsUserInRoleAsync(user.Username, "Client"),
							IsFundi = true,
                            IsRegistered = true,
							FundiDueToPaySubscription = false,
							ClientDueToPaySubscription = false
						};
                        return actualResult;
                    }
                    else if (message.ToLower().Equals("Subscription Is Still Valid".ToLower()))
                    {
                        var isUserInRoleFundi1 = await _userService.IsUserInRoleAsync(user.Username, "Fundi");
                        if (!isUserInRoleFundi1)
                        {
                            await UserAddToRole(new Models.UserRole { role = "Fundi", email = user.Email });
                        }
                    }

                    message = _unitOfWork.MyFundiDBContext.ValidateFundiSubscriptionDaysToExpiry(fundi.FundiProfileId, expiryDueWithin2);
                    if (!message.ToLower().Equals("Subscription Is Still Valid".ToLower()))
                    {
                        var tmpResult = new LoginResult { ErrorMessage = "", FirstName = user.FirstName, LastName = user.LastName, IsLoggedIn = false, IsFundi = true, IsAdministrator = false, IsClient = false, Message = "", AuthToken = authToken };
                        var actualResult = new LoginResult
                        {
                            IsLoggedIn = true,
                            FirstName = user.FirstName,
                            LastName = user.LastName,
                            Username = user.Username,
                            IsAdministrator = await _userService.IsUserInRoleAsync(user.Username, "Administrator"),
                            Message = tmpResult.Message,
                            AuthToken = authToken,
                            IsClient = await _userService.IsUserInRoleAsync(user.Username, "Client"),
                            IsFundi = true,
                            IsRegistered = true,
							FundiDueToPaySubscription = false,
							ClientDueToPaySubscription = (await (_userService.IsUserInRoleAsync(user.Username, "Client")) && _unitOfWork.MyFundiDBContext.IsClientToPaySubscriptionFee(user.Username, clientdurationInDaysDue))
						};
                        return actualResult;
                    }
                    message = _unitOfWork.MyFundiDBContext.ValidateFundiSubscriptionDaysToExpiry(fundi.FundiProfileId, expiryDueWithin5);
                    if (!message.ToLower().Equals("Subscription Is Still Valid".ToLower()))
                    {
                        var tmpResult = new LoginResult { ErrorMessage = "", FirstName = user.FirstName, LastName = user.LastName, IsLoggedIn = false, IsFundi = true, IsAdministrator = false, IsClient = false, Message = message, AuthToken = authToken };
                        var actualResult = new LoginResult
                        {
                            IsLoggedIn = true,
                            FirstName = user.FirstName,
                            LastName = user.LastName,
                            Username = user.Username,
                            IsAdministrator = await _userService.IsUserInRoleAsync(user.Username, "administrator"),
                            Message = tmpResult.Message,
                            AuthToken = authToken,
                            IsClient = await _userService.IsUserInRoleAsync(user.Username, "Client"),
                            IsFundi = true,
                            IsRegistered = true,
							FundiDueToPaySubscription = false,
							ClientDueToPaySubscription = (await (_userService.IsUserInRoleAsync(user.Username, "Client")) && _unitOfWork.MyFundiDBContext.IsClientToPaySubscriptionFee(user.Username, clientdurationInDaysDue))
						};
                        return actualResult;
                    }
                    message = _unitOfWork.MyFundiDBContext.ValidateFundiSubscriptionDaysToExpiry(fundi.FundiProfileId, expiryDueWithin7);
                    if (!message.ToLower().Equals("Subscription Is Still Valid".ToLower()))
                    {
                        var tmpResult = new LoginResult { ErrorMessage = "", FirstName = user.FirstName, LastName = user.LastName, IsLoggedIn = false, IsFundi = true, IsAdministrator = false, IsClient = false, Message = message, AuthToken = authToken };
                        var actualResult = new LoginResult
                        {
                            IsLoggedIn = true,
                            FirstName = user.FirstName,
                            LastName = user.LastName,
                            Username = user.Username,
                            IsAdministrator = await _userService.IsUserInRoleAsync(user.Username, "administrator"),
                            Message = tmpResult.Message,
                            AuthToken = authToken,
                            IsClient = await _userService.IsUserInRoleAsync(user.Username, "Client"),
                            IsFundi = true,
                            IsRegistered = true,
							FundiDueToPaySubscription = false,
							ClientDueToPaySubscription = (await (_userService.IsUserInRoleAsync(user.Username, "Client")) && _unitOfWork.MyFundiDBContext.IsClientToPaySubscriptionFee(user.Username, clientdurationInDaysDue))
						};
                        return actualResult;
                    }
                    else if (tmpTopMessage.ToLower().Equals("Subscription Is Still Valid".ToLower()))
                    {
                        await UserAddToRole(new Models.UserRole { role = "Fundi", email = user.Email });
                        var actualResult = new LoginResult
                        {
                            IsLoggedIn = true,
                            FirstName = user.FirstName,
                            LastName = user.LastName,
                            Username = user.Username,
                            IsAdministrator = false,
                            Message = tmpTopMessage,
                            AuthToken = authToken,
                            IsClient = await _userService.IsUserInRoleAsync(user.Username, "Client"),
                            IsFundi = true,
                            IsRegistered = true,
							FundiDueToPaySubscription = false,
							ClientDueToPaySubscription = (await (_userService.IsUserInRoleAsync(user.Username, "Client")) && _unitOfWork.MyFundiDBContext.IsClientToPaySubscriptionFee(user.Username, clientdurationInDaysDue))
						};
                        return actualResult;
                    }
                }
                if (!await _userService.IsUserInRoleAsync(user.Username, "administrator") && await _userService.IsUserInRoleAsync(user.Username, "Fundi"))
                {
                    if (fundi != null)
                    {
                        await UserRemoveFromRole(new Models.UserRole { role = "Fundi", email = email });
                    }
                    await AddUserToRole(new Models.UserRole { role = "Guest", email = email });
                }
                if (await _userService.IsUserInRoleAsync(user.Username, "Client"))
                {
                    if (_unitOfWork.MyFundiDBContext.IsClientToPaySubscriptionFee(user.Username, clientdurationInDaysDue))
                    {
                        return new LoginResult
                        {
                            IsLoggedIn = false,
                            ClientDueToPaySubscription = true,
                            FirstName = user.FirstName,
                            LastName = user.LastName,
                            Username = user.Username,
                            IsAdministrator = await _userService.IsUserInRoleAsync(user.Username, "Administrator"),
                            Message = "Client Subscription Expired!",
                            AuthToken = authToken,
                            IsClient = true,
                            IsFundi = false,
                            IsRegistered = true,
							FundiDueToPaySubscription = false
						};
                    }
                }
                if (!string.IsNullOrEmpty(user.Username))
                {
                    return new LoginResult
                    {
                        IsLoggedIn = true,
                        FirstName = user.FirstName,
                        LastName = user.LastName,
                        Username = user.Username,
                        IsAdministrator = await _userService.IsUserInRoleAsync(user.Username, "Administrator"),
                        Message = "",
                        AuthToken = authToken,
                        IsClient = await _userService.IsUserInRoleAsync(user.Username, "Client"),
                        IsFundi = (fundi == null),
                        IsRegistered = true,
                        ClientDueToPaySubscription= true,
						FundiDueToPaySubscription = true
					};
                }
            }
            return new LoginResult
            {
                IsLoggedIn = false,
                IsAdministrator = false,
                Message = "Bad Request!!",
                AuthToken = "",
                ErrorMessage = "Bad Request",
                IsClient = false,
                IsFundi = false,
            };
        }
        [HttpPost]
        public async Task<IActionResult> Login([FromBody] UserDetails userDetails)
        {
            if (!string.IsNullOrEmpty(userDetails.authToken))
            {
                LoginResult res = await Authenticate(userDetails.authToken, userDetails.username);

                if (res.IsLoggedIn)
                {
                    await SignInUserWithClaims(userDetails);
                    return Ok(res);
                }
                return BadRequest(userDetails);
            }
            else
            {
                var signInResult = await CreateAuthoriseUsingLoginCredentials(userDetails);

                var result = await Authenticate(signInResult.AuthToken, userDetails.username);
                if (result.Message.ToLower().Equals("Subscription Is Still Valid".ToLower()))
                {
                    await SignInUserWithClaims(userDetails);
                    return Ok(signInResult);
                }
                else return Ok(result);
            }
        }
        private async Task SignInUserWithClaims(UserDetails userDetails)
        {
            try
            {
                if (userDetails != null && !string.IsNullOrEmpty(userDetails.username))
                {
                    var claims = new List<Claim>();

                    claims.Add(new Claim("email", userDetails.emailAddress));
                    var roleList = _roleService.GetAllUserRolesAsString(userDetails.emailAddress);
                    foreach (var role in roleList)
                    {
                        claims.Add(new Claim("role", role));
                    }
                    claims.Add(new Claim("firstname", userDetails.firstName));
                    claims.Add(new Claim("lastname", userDetails.lastName));
                    ClaimsIdentity userIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                    ClaimsPrincipal claimsPrincipal = new ClaimsPrincipal(userIdentity);

                    await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, claimsPrincipal, new AuthenticationProperties() { IsPersistent = userDetails.keepLoggedIn });
                }
                else
                {
                    throw new Exception("Username cannot be null!");
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        private async Task<LoginResult> CreateAuthoriseUsingLoginCredentials(UserDetails userDetails)
        {
            var user = await _userService.FindByEmailAsync(userDetails.emailAddress);
            if (user == null)
            {
                ModelState.AddModelError(string.Empty, "Invalid login");

                return new LoginResult { IsLoggedIn = false, ErrorMessage = "Invalid login" };
            }

            UserInteractionResults result = await _userService.PasswordSignInAsync(user, userDetails.password, isPersistent: userDetails.keepLoggedIn, lockoutOnFailure: false);
            if (result != UserInteractionResults.Succeeded)
            {
                ModelState.AddModelError(string.Empty, "Invalid login");
                return new LoginResult { IsLoggedIn = false, ErrorMessage = "Invalid Login" };
            }
            else if (result == UserInteractionResults.Succeeded)
            {
                // var tmpUser = await _userService.FindByNameAsync(user.Username);
                var userRoles = await _roleService.FindByUserNameAsync(user.Username);
                var authToken = string.Empty;
                if (userRoles == null)
                {
                    var roles = await _roleService.GetAllRoles();
                    userRoles = new Role[] { roles.FirstOrDefault(q => q.RoleName == "Guest") };
                }
                user.Token = await _userService.AddUserRolesClaimAsync(user.Username, userRoles, user);

                _unitOfWork.SaveChanges();

                return new LoginResult
                {
                    AuthToken = user.Token,
                    IsLoggedIn = true,
                    IsAdministrator = await _userService.IsUserInRoleAsync(user.Username.ToLower(), "administrator"),
                    IsClient = await _userService.IsUserInRoleAsync(user.Username.ToLower(), "Client"),
                    IsFundi = await _userService.IsUserInRoleAsync(user.Username.ToLower(), "Fundi"),
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    Username = user.Username
                };
            }

            return new LoginResult { IsLoggedIn = false, IsAdministrator = false, Message = "Failed to Login!" };
        }

        [HttpPost]
        public async Task<IActionResult> ForgotPassword([FromBody] UserDetails userDetails)
        {
            try
            {
                var emailAddress = userDetails.emailAddress;
                var user = await _userService.FindByEmailAsync(emailAddress);
                if (user == null)
                    return BadRequest(new { ErrorMessage = "User does not exist!!" });

                string passwordResetToken = await _userService.GeneratePasswordResetTokenAsync(user);
                var passwordResetUrl = Url.Action("ResetPassword", "Account", new ResetPassword { Id = user.UserId.ToString(), Token = passwordResetToken }, Request.Scheme);
                var emailDao = new EmailDao
                {
                    EmailTo = user.Email,
                    EmailSubject = "You Requested Password Reset for your My Fundi Site.",
                    DateCreated = DateTime.Now,
                    DateUpdated = DateTime.Now,
                    EmailBody = new EmailTemplating().GetEmailTemplate(EmailTemplate.PasswordResetMessage).Replace("[[FirstName]]", user.FirstName).Replace("[[PasswordResetLink]]", $"Click <a href=\"https://myfundiv2.martinlayooinc.com/reset-password\"> here</a> to reset your password").Replace("[[PasswordToken]]", passwordResetToken)
                };
                _emailService.SendEmail(emailDao);
                return await Task.FromResult(Ok(new { PasswordResetUrl = passwordResetUrl, passwordResetToken = passwordResetToken, Message = "Reset your password through email link sent!", UserId= user.UserId }));
            }
            catch(Exception ex)
            {
                return await Task.FromResult(Ok(new { ErrorMessage = ex.Message, Error = ex.StackTrace,  }));
            }
        }

        [HttpPost]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPassword resetPassword)
        {
            User user = await _userService.FindByIdAsync(resetPassword.Id);
            if (user == null)
                throw new InvalidOperationException();

            if (resetPassword.Password != resetPassword.Repassword)
            {
                ModelState.AddModelError(string.Empty, "Passwords do not match");

                return BadRequest(new { ErrorMessage = "Password and retyped Passwords don't match" });
            }

            User userResetPassword = await _userService.ResetPasswordAsync(user, resetPassword.Token, resetPassword.Password);

            if (userResetPassword.Username != null)
            {
                _emailService.SendEmail(new EmailDao
                {
                    EmailTo = user.Email,
                    EmailSubject = "Password for Myfundi Site Reset Successfully!",
                    DateCreated = DateTime.Now,
                    DateUpdated = DateTime.Now,
                    EmailBody = new EmailTemplating().GetEmailTemplate(EmailTemplate.PasswordResetMessage).Replace("[[FirstName]]", user.FirstName)
                });
                return Ok(new { Message = "Password reset successfully", ErrorMessage = "" });
            }
            else
            {

                return Ok(new { Message = "Failed to Reset Password.\nContact Site Administrator!", ErrorMessage = "" });
            }
        }

        [HttpGet]
        public async Task<IActionResult> Logout(string useremail)
        {
            _userService.SignOut(useremail);
            await this.HttpContext.SignOutAsync();
            HttpContext.Session.Clear();
            return Ok(new { isLoggedIn = false, Message = "Logged Out", isAdministrator = false });
        }

        [HttpPost]
        [CustomAuthorize(Roles = new string[] { "Administrator" })]
        public async Task<IActionResult> AddUserToRole([FromBody] Models.UserRole userRole)
        {
            var result = await UserAddToRole(userRole);

            return Json(new { Result = result.ToString() });
        }
        public async Task<UserInteractionResults> UserAddToRole(Models.UserRole userRole)
        {
            var isUserInrole = false;
            var user = await _userService.FindByEmailAsync(userRole.email);
            if (user != null)
            {
                isUserInrole = await _userService.IsUserInRoleAsync(user.Email.ToLower(), userRole.role);
            }
            if (!isUserInrole)
            {
                UserInteractionResults result = await _userService.AddToRoleAsync(user, userRole.role);
                return await Task.FromResult(result);
            }
            return await Task.FromResult(UserInteractionResults.Failed);
        }
        [HttpPost]
        [CustomAuthorize(Roles = new string[] { "Administrator" })]
        public async Task<IActionResult> RemoveUserFromRole([FromBody] Models.UserRole userRole)
        {
            var result = await UserRemoveFromRole(userRole);

            return Json(new { Result = result.ToString() });
        }

        public async Task<UserInteractionResults> UserRemoveFromRole(Models.UserRole userRole)
        {
            var userInRole = false;
            var user = await _userService.FindByEmailAsync(userRole.email);
            if (user != null)
            {
                userInRole = await _userService.IsUserInRoleAsync(user.Email.ToLower(), userRole.role.ToLower());
            }
            if (userInRole)
            {
                UserInteractionResults result = await _userService.RemoveFromRolesAsync(user, new string[] { userRole.role });
                return await Task.FromResult(result);
            }
            return await Task.FromResult(UserInteractionResults.Failed);
        }
        [HttpGet]
        [AuthorizeIdentity]
        public IActionResult GetAllRoles()
        {
            try
            {
                IEnumerable<Role> roles = _roleService.GetAllRoles().Result.Select(p => new Role { RoleName = p.RoleName });
                return Ok(roles.ToArray());
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        [HttpGet]
        [Route("~/Account/GetUserRolesByUsername/{username}")]
        public IActionResult GetUserRolesByUsername(string username)
        {
            try
            {
                if (string.IsNullOrEmpty(username))
                    return NotFound();
                var roles = _roleService.GetAllUserRolesAsString(username);
                return Ok(roles);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        [HttpGet]
        public IActionResult GetAllUserRoles(string username)
        {
            try
            {
                if (string.IsNullOrEmpty(username))
                    return NotFound();
                var roles = _roleService.GetAllUserRolesAsString(username);
                return Ok(roles);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        [HttpPost]
        [CustomAuthorize(Roles = new string[] { "Administrator" })]
        public async Task<IActionResult> CreateRole([FromBody] MyFundi.Web.Models.UserRole role)
        {
            try
            {
                var newRole = _roleService.GetAllRoles().Result.FirstOrDefault(p => p.RoleName.ToLower().Equals(role.role.ToLower().Trim()));

                if (newRole == null)
                {
                    UserInteractionResults result = await _roleService.CreateAsync(new MyFundi.Domain.Role { RoleName = role.role });
                    if (result == UserInteractionResults.Succeeded)
                    {
                        return Ok(new { Message = UserInteractionResults.Succeeded.ToString() });
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return BadRequest(new { ErrorMessage = UserInteractionResults.Failed.ToString() });
        }
        [HttpPost]
        [CustomAuthorize(Roles = new string[] { "Administrator" })]
        public async Task<IActionResult> DeleteRole([FromBody] MyFundi.Web.Models.UserRole role)
        {
            try
            {
                var toDeleteRole = _roleService.GetAllRoles().Result.FirstOrDefault(p => p.RoleName.ToLower().Equals(role.role.ToLower().Trim()));

                if (toDeleteRole != null)
                {
                    UserInteractionResults result = await _roleService.DeleteAsync(toDeleteRole);
                    if (result == UserInteractionResults.Succeeded)
                    {
                        return Ok(new { Message = UserInteractionResults.Succeeded.ToString() });
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return BadRequest(new { ErrorMessage = UserInteractionResults.Failed.ToString() });
        }
    }

}