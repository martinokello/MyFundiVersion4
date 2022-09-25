using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class ClientProfileRepository : AbstractRepository<ClientProfile>
    {
        public override bool Delete(ClientProfile toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.ClientProfiles.SingleOrDefault(p => p.ClientProfileId == toDelete.ClientProfileId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override ClientProfile GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override ClientProfile GetById(int id)
        {
            return MyFundiDBContext.ClientProfiles.SingleOrDefault(p => p.ClientProfileId == id);
        }

        public override bool Update(ClientProfile toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.ClientProfileId);
                cert.ProfileImageUrl = toUpdate.ProfileImageUrl;
                cert.DateUpdated = toUpdate.DateUpdated;
                cert.ProfileSummary = toUpdate.ProfileSummary;
                cert.UserId = toUpdate.UserId;
                cert.AddressId = toUpdate.AddressId;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
