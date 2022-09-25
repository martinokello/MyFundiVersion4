using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using MyFundi.AppConfigurations;
using MyFundi.Domain;
using MyFundi.Services;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.UnitOfWork.Interfaces;
using MyFundi.IdentityServices;
using System.Reflection;
using Newtonsoft.Json;
using AesCryptoSystemExtra.AESCryptoSystem.ExternalCryptoUnit;

namespace MyFundi.IdentityServices
{
    public interface IUserService
    {
        Task<User> Authenticate(string authToken);
        Task<IEnumerable<User>> GetAll();
        Task<User> GetById(Guid id);
        Task<User> FindByNameAsync(string username);
        Task<UserInteractionResults> CreateAsync(User user, string userPWD);
        Task<UserInteractionResults> AddToRoleAsync(User user, string vrole);
        Task<User> FindByEmailAsync(string email);
        Task<bool> IsUserInRoleAsync(string user, string role);
        Task<UserInteractionResults> UpdateUserAsync(User user);
        Task<string> AddUserRolesClaimAsync(string username, Role[] roles, User user);
        Task<string> GenerateEmailConfirmationTokenAsync(User newUser);
        Task<string> WriteToken(string username, Role[] roles, User user);
        Task<UserInteractionResults> PasswordSignInAsync(User user, string password, bool isPersistent, bool lockoutOnFailure);
        Task<string> GeneratePasswordResetTokenAsync(User user);
        Task<User> ResetPasswordAsync(User user, string token, string password);
        Task<User> FindByIdAsync(string id);
        void SignOut(string username);
        IDictionary<string, object> GetUserClaimsFromToken(string authToken);
        Task<UserInteractionResults> RemoveFromRolesAsync(User user, string[] roles);
    }

    public class UserService : IUserService
    {
        private MyFundiUnitOfWork _unitOfWork;
        private AesExternalProcedures _passwordEncryptor;
        private IRoleService _roleService;
        public UserService(AppSettingsConfigurations appSettings, IRoleService roleService, AesExternalProcedures passwordEncryptor, MyFundiUnitOfWork unitOfWork)
        {
            _appSettings = appSettings;
            _roleService = roleService;
            _passwordEncryptor = passwordEncryptor;
            _unitOfWork = unitOfWork;
        }

        public  Task<User> FindByNameAsync(string username)
        {
            var user = _unitOfWork._userRepository.GetAll().FirstOrDefault(q => q.Username.ToLower().Equals(username.ToLower()));
            return Task.FromResult(user);
        }

        public Task<UserInteractionResults> CreateAsync(User user, string userPWD)
        {
            try
            {
                var passwordEncrypted = Convert.ToBase64String(_passwordEncryptor.EncryptPassword(userPWD, _passwordEncryptor.KeyBytes));
                user.Password = passwordEncrypted;

                _unitOfWork._userRepository.Insert(user);
                _unitOfWork.SaveChanges();

                return Task.FromResult(UserInteractionResults.Succeeded);
            }
            catch(Exception e)
            {
                return Task.FromResult(UserInteractionResults.Failed);
            }
        }

        public async Task<UserInteractionResults> AddToRoleAsync(User user, string role)
        {
            var us = _unitOfWork._userRepository.GetAll().FirstOrDefault(u => u.Username.ToLower().Equals(user.Email.ToLower()));
            if(us != null)
            {
                var isUserInRole = await IsUserInRoleAsync(us.Username, role);
                if (!isUserInRole)
                {
                    var tmp = await _roleService.FindByNameAsync(role);
                    if (tmp != null)
                    {
                        var userRole = new UserRole { UserId = us.UserId, RoleId = tmp.RoleId };

                        _unitOfWork._userInRolesRepository.Insert(userRole);
                        _unitOfWork.SaveChanges();
                        return await Task.FromResult(UserInteractionResults.Succeeded);
                    }
                }

            }

            return await Task.FromResult(UserInteractionResults.Failed);
        }

        public async Task<bool> IsUserInRoleAsync(string user, string role)
        {
            var roles = await _roleService.FindByUserNameAsync(user.ToLower());
            if (roles.Any())
            {
                var res = roles.FirstOrDefault(r => r.RoleName.ToLower().Equals(role.ToLower()));
                if (res != null)
                {
                    return await Task.FromResult(true);
                }
            }
            return await Task.FromResult(false);
        }
        public async Task<User> FindByEmailAsync(string email)
        {
            var user = _unitOfWork._userRepository.GetAll().FirstOrDefault(q => q.Email.ToLower().Equals(email.ToLower()));
            if (user != null)
            {
                return await Task.FromResult(user);
            }
            return null;
        }

        private readonly AppSettingsConfigurations _appSettings;

        public async Task<User> Authenticate(string authToken)
        {
            // authentication successful so generate jwt token
            //var tokenHandler = new JwtSecurityTokenHandler();
            //var key = Encoding.ASCII.GetBytes(_appSettings.GetConfigSetting("ClaimsKeyBytes"));

            SecurityTokenDescriptor token = ReadToken(authToken);

            var emailClaim = token.Claims.Where(c => c.Key == "email");
            var roleClaims = token.Claims.Where(c => c.Key == "role");
            var fnameClaims = token.Claims.Where(c => c.Key == "firstname");
            var lnameClaims = token.Claims.Where(c => c.Key == "lastname");

            if (!emailClaim.Any()) return await Task.FromResult(new User());

            if(token.Expires > DateTime.Now)
            {
                return await Task.FromResult(new User { Username = emailClaim.First().Value as string, FirstName=fnameClaims.First().Value as string, LastName = lnameClaims.First().Value as string});
            }
            return await Task.FromResult(new User());
        }

        public SecurityTokenDescriptor ReadToken(string authToken)
        {
            var securityTokenDescription  = JsonConvert.DeserializeObject<SecurityTokenDescriptor>(Encoding.UTF8.GetString(_passwordEncryptor.DecryptPassword(authToken, _passwordEncryptor.KeyBytes)));

            return securityTokenDescription;
        }

        public async Task<IEnumerable<User>> GetAll()
        {
            return await Task.FromResult(_unitOfWork._userRepository.GetAll().ToArray());
        }

        public async Task<User> GetById(Guid id)
        {
            return await Task.FromResult(_unitOfWork._userRepository.GetByGuid(id));
        }

        public async Task<string> GenerateEmailConfirmationTokenAsync(User newUser)
        {
            throw new NotImplementedException();
        }

        public async Task<string> AddUserRolesClaimAsync(string username,Role[] roles, User user)
        {
            return await WriteToken(username, roles,user);
        }
        public async Task<string> WriteToken(string username, Role[] roles, User user)
        {
            //var key = Encoding.ASCII.GetBytes(_appSettings.GetConfigSetting("ClaimsKeyBytes"));
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(),
                Expires = DateTime.UtcNow.AddDays(7),
                //SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
                Claims = new Dictionary<string, object>()
            };
            tokenDescriptor.Claims.Add("email", username);
            tokenDescriptor.Claims.Add("role", roles);
            tokenDescriptor.Claims.Add("firstname", user.FirstName);
            tokenDescriptor.Claims.Add("lastname", user.LastName);
            //var token = tokenHandler.CreateToken(tokenDescriptor);
            var tokenDescString = JsonConvert.SerializeObject(tokenDescriptor);
            var token = Convert.ToBase64String(_passwordEncryptor.EncryptPassword(tokenDescString, _passwordEncryptor.KeyBytes));
            return await Task.FromResult<string>(token);
        }
        public async Task<UserInteractionResults> PasswordSignInAsync(User user, string password, bool isPersistent, bool lockoutOnFailure)
        {
            var encryptedPassword = Convert.ToBase64String(_passwordEncryptor.EncryptPassword(password, _passwordEncryptor.KeyBytes));

            var tmpUser =_unitOfWork._userRepository.GetAll().FirstOrDefault(q => q.Username.ToLower().Equals(user.Username.ToLower()) && q.Password.Equals(encryptedPassword));
            if (tmpUser != null) {
                tmpUser.LastLogInTime = DateTime.Now;
                tmpUser.IsActive = true;
                _unitOfWork.SaveChanges();
                return await Task.FromResult(UserInteractionResults.Succeeded);
            }
            return await Task.FromResult(UserInteractionResults.Failed);
        }
        public async Task<UserInteractionResults> UpdateUserAsync(User user)
        {
            user.Password = Convert.ToBase64String(_passwordEncryptor.EncryptPassword(user.Password, _passwordEncryptor.KeyBytes));

            var hasUpdated = _unitOfWork._userRepository.Update(user);
            _unitOfWork.SaveChanges();
            if (hasUpdated) return await Task.FromResult(UserInteractionResults.Succeeded);
            return await Task.FromResult(UserInteractionResults.Failed);
        }
        public async Task<string> GeneratePasswordResetTokenAsync(User user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_appSettings.GetConfigSetting("ClaimsResetPasswordKeyBytes"));
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(),
                Expires = DateTime.UtcNow.AddDays(7),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            tokenDescriptor.Claims.Add(ClaimTypes.Email, user.Username);
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return await Task.FromResult<string>(tokenHandler.WriteToken(token));
        }
        public async Task<User> ResetPasswordAsync(User user, string authToken, string password)
        {
            // authentication successful so generate jwt token
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_appSettings.GetConfigSetting("ClaimsResetPasswordKeyBytes"));

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(),
                Expires = DateTime.UtcNow.AddDays(7),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.ReadJwtToken(authToken);

            var emailClaim = token.Claims.FirstOrDefault(q => q.Type=="email");

            if (emailClaim == null) return await Task.FromResult(new User());

            if (token.ValidTo > DateTime.Now && token.ValidFrom < DateTime.Now)
            {
                if (emailClaim.Value.ToLower().Equals(user.Username.ToLower()))
                {
                    //Reset User Password:
                    var encryptedPassword = Convert.ToBase64String(_passwordEncryptor.EncryptPassword(password, _passwordEncryptor.KeyBytes));
                    var userPasswordChange = _unitOfWork._userRepository.GetAll().FirstOrDefault(q => q.Username.ToLower().Equals(user.Username));
                    userPasswordChange.Password = encryptedPassword;
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(new User { Username = emailClaim.Value });
                }
            }
            return await Task.FromResult(new User());
        }


        public async Task<User> FindByIdAsync(string id)
        {
            return await Task.FromResult(_unitOfWork._userRepository.GetByGuid(Guid.Parse(id)));
        }

        public void SignOut(string username)
        {
            var user =_unitOfWork._userRepository.GetAll().FirstOrDefault(q => q.Username.ToLower().Equals(username.ToLower()));

            if(user != null)
            {
                user.IsActive = false;
                user.LastLogInTime = DateTime.Now;
                user.Token = null;
                _unitOfWork._userRepository.Update(user);
                _unitOfWork.SaveChanges();
            }
        }

        public async Task<UserInteractionResults> RemoveFromRolesAsync(User user, string[] roles)
        {
            try
            {
                foreach (var role in roles)
                {
                    if (await IsUserInRoleAsync(user.Username, role))
                    {
                        var tmpRole = await _roleService.FindByNameAsync(role);

                        if (tmpRole != null)
                        {
                            var userRole = _unitOfWork._userInRolesRepository.GetAll().FirstOrDefault(q => q.UserId == user.UserId && q.RoleId == tmpRole.RoleId);
                            _unitOfWork._userInRolesRepository.Delete(userRole);
                            _unitOfWork.SaveChanges();
                        }
                    }
                }
                return await Task.FromResult(UserInteractionResults.Succeeded);
            }
            catch(Exception e)
            {
                return await Task.FromResult(UserInteractionResults.Failed);
            }

        }
        public IDictionary<string,object> GetUserClaimsFromToken(string authToken)
        {
            // authentication successful so generate jwt token
           // var tokenHandler = new JwtSecurityTokenHandler();
            //var key = Encoding.ASCII.GetBytes(_appSettings.GetConfigSetting("ClaimsKeyBytes"));

            SecurityTokenDescriptor token = ReadToken(authToken);

            //var nameClaims = token.Claims.FirstOrDefault(q => q.Type.Equals(ClaimTypes.Name));
            //var roleClaims = token.Claims.Select(c => c.Type.Equals(ClaimTypes.Role.ToString()));

            return token.Claims;
        }
    }
}
