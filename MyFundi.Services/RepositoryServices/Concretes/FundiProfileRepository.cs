using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class FundiProfileRepository : AbstractRepository<FundiProfile>
    {
        public override bool Delete(FundiProfile toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.FundiProfiles.SingleOrDefault(p => p.FundiProfileId == toDelete.FundiProfileId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override FundiProfile GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override FundiProfile GetById(int id)
        {
            return MyFundiDBContext.FundiProfiles.SingleOrDefault(p => p.FundiProfileId == id);
        }

        public override bool Update(FundiProfile toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.FundiProfileId);
                cert.FundiProfileCvUrl = toUpdate.FundiProfileCvUrl;
                cert.ProfileImageUrl = toUpdate.ProfileImageUrl;
                cert.DateUpdated = toUpdate.DateUpdated;
                cert.ProfileSummary = toUpdate.ProfileSummary;
                cert.Skills = toUpdate.Skills;
                cert.UsedPowerTools = toUpdate.UsedPowerTools;
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