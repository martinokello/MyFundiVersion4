using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class FundiLocationRepository:AbstractRepository<FundiLocation>
    {
        public override bool Delete(FundiLocation toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.FundiLocations.SingleOrDefault(p => p.FundiLocationId == toDelete.FundiLocationId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override FundiLocation GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override FundiLocation GetById(int id)
        {
            return MyFundiDBContext.FundiLocations.SingleOrDefault(p => p.FundiLocationId == id);
        }

        public override bool Update(FundiLocation toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.FundiLocationId);
                cert.FundiProfileId = toUpdate.FundiProfileId;
                cert.Latitude = toUpdate.Latitude;
                cert.DateUpdated = toUpdate.DateUpdated;
                cert.Longitude = toUpdate.Longitude;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
