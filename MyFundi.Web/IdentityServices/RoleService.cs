using MyFundi.UnitOfWork.Concretes;
using MyFundi.UnitOfWork.Interfaces;
using MyFundi.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AesCryptoSystemExtra.AESCryptoSystem.ExternalCryptoUnit;

namespace MyFundi.IdentityServices
{
    public interface IRoleService
    {
        Task<UserInteractionResults> CreateAsync(Role role);
        Task<Role> FindByNameAsync(string rolename);
        Task<UserInteractionResults> AddToRoleAsync(User user, string rolename);
        Task<IEnumerable<Role>> GetAllRoles();
        Task<UserInteractionResults> DeleteAsync(Role role);
        Task<Role[]> FindByUserNameAsync(string username);
        string[] GetAllUserRolesAsString(string username);
    }
    public class RoleService:IRoleService
    {
        private MyFundiUnitOfWork _unitOfWork;
        private AesExternalProcedures _passwordEncryptor;
        public RoleService(AesExternalProcedures passwordEncryptor, MyFundiUnitOfWork unitOfWork)
        {
            _passwordEncryptor = passwordEncryptor;
            _unitOfWork = unitOfWork;
        }
        public async Task<UserInteractionResults> CreateAsync(Role role)
        {
            try
            {
                var r = _unitOfWork._rolesRepository.GetAll().FirstOrDefault(q => q.RoleName.ToLower().Equals(role.RoleName.ToLower()));
                if(r == null)
                {
                    _unitOfWork._rolesRepository.Insert(role);
                    _unitOfWork.SaveChanges();
                    return await Task.FromResult(UserInteractionResults.Succeeded);
                }
                return await Task.FromResult(UserInteractionResults.Failed);
            }
            catch (Exception e)
            {
                return await Task.FromResult(UserInteractionResults.Failed);
            }
        }
        public Task<Role[]> FindByUserNameAsync(string username)
        {
            return Task.FromResult((from u in _unitOfWork._userRepository.GetAll()
                                   join uir in _unitOfWork._userInRolesRepository.GetAll()
                                   on u.UserId equals uir.UserId into usri
                                   from ri in usri
                                   join r in _unitOfWork._rolesRepository.GetAll()
                                   on ri.RoleId equals r.RoleId
                                   where ri.User.Username == username
                                   select r).ToArray());
        }
        public Task<Role> FindByNameAsync(string rolename)
        {
            return Task.FromResult(_unitOfWork._rolesRepository.GetAll().FirstOrDefault(q => q.RoleName.ToLower().Equals(rolename.ToLower())));
        }

        public Task<UserInteractionResults> AddToRoleAsync(User user, string rolename)
        {
            try
            {
                var userInRole = _unitOfWork._userInRolesRepository.GetAll().FirstOrDefault(q => q.Role.RoleName.ToLower().Equals(rolename.ToLower()) && q.User.UserId.Equals(user.UserId));
                if(userInRole == null)
                { 
                    var role =_unitOfWork._rolesRepository.GetAll().FirstOrDefault(q => q.RoleName.ToLower().Equals(rolename.ToLower()));
                    if(role != null)
                    {
                        userInRole = new UserRole { UserId = user.UserId, RoleId = role.RoleId };
                        _unitOfWork._userInRolesRepository.Insert(userInRole);
                        _unitOfWork.SaveChanges();
                        return Task.FromResult(UserInteractionResults.Succeeded);
                    }
                    return Task.FromResult(UserInteractionResults.Failed);
                }
                return Task.FromResult(UserInteractionResults.Failed);
            }
            catch(Exception e)
            {
               return Task.FromResult(UserInteractionResults.Failed);
            }
        }

        public async Task<IEnumerable<Role>> GetAllRoles()
        {
            return await Task.FromResult(_unitOfWork._rolesRepository.GetAll().ToList());
        }

        public async Task<UserInteractionResults> DeleteAsync(Role role)
        {
            try
            {
                var tmR = _unitOfWork._rolesRepository.GetByGuid(role.RoleId);
                _unitOfWork._rolesRepository.Delete(tmR);
                _unitOfWork.SaveChanges();
                return await Task.FromResult(UserInteractionResults.Succeeded);
            }
            catch (Exception e)
            {
                return await Task.FromResult(UserInteractionResults.Failed);
            }
        }

        public string[] GetAllUserRolesAsString(string username)
        {
            var user = _unitOfWork._userRepository.GetAll().FirstOrDefault(u => u.Username.ToLower().Equals(username.ToLower()));
            var userInroles = _unitOfWork._userInRolesRepository.GetAll().Where(u => u.UserId.Equals(user.UserId));
            if (userInroles.Any())
            {
                var roles = from r in _unitOfWork._rolesRepository.GetAll()
                            from ur in userInroles
                            where r.RoleId == ur.RoleId
                            select (r.RoleName);
                return roles.ToArray();
            }
            return new string[]{ };
        }
    }
}
