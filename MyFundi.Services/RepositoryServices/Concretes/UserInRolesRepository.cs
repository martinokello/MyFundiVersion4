using MyFundi.DataAccess;
using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class UserInRolesRepository : AbstractRepository<UserRole>
    {
        public override bool Delete(UserRole toDelete)
        {
            try
            {
                toDelete = GetByGuid(toDelete.UserRoleId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override UserRole GetByGuid(Guid id)
        {
            return MyFundiDBContext.UserRoles.SingleOrDefault(p => p.UserRoleId == id);
        }

        public override UserRole GetById(int id)
        {
            throw new NotImplementedException();
        }

        public override bool Update(UserRole toUpdate)
        {
            try
            {
                var userrole = GetByGuid(toUpdate.UserRoleId);
                userrole.RoleId = toUpdate.RoleId;
                userrole.UserId = toUpdate.UserId;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
