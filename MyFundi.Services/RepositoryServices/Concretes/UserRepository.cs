using MyFundi.DataAccess;
using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class UserRepository : AbstractRepository<User>
    {
        public override bool Delete(User toDelete)
        {
            try
            {
                toDelete = GetByGuid(toDelete.UserId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override User GetByGuid(Guid id)
        {
            return MyFundiDBContext.Users.SingleOrDefault(p => p.UserId == id);
        }

        public override User GetById(int id)
        {
            throw new NotImplementedException();
        }

        public override bool Update(User toUpdate)
        {
            try
            {
                var user = GetByGuid(toUpdate.UserId);
                user.FirstName = toUpdate.FirstName;
                user.LastName = toUpdate.LastName; 
                user.Token = toUpdate.Token;
                user.CompanyId = toUpdate.CompanyId;
                user.IsLockedOut = toUpdate.IsLockedOut;
                user.IsActive = toUpdate.IsActive;
                user.LastLogInTime = toUpdate.LastLogInTime;
                user.MobileNumber = toUpdate.MobileNumber;
                user.Email = toUpdate.Email;
                user.Password = toUpdate.Password;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
