using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class FundiProfileCertificationRepository : AbstractRepository<FundiProfileCertification>
    {
        public override bool Delete(FundiProfileCertification toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.FundiProfileCertifications.SingleOrDefault(p => p.FundiProfileCertificationId == toDelete.FundiProfileCertificationId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override FundiProfileCertification GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override FundiProfileCertification GetById(int id)
        {
            return MyFundiDBContext.FundiProfileCertifications.SingleOrDefault(p => p.FundiProfileCertificationId == id);
        }

        public override bool Update(FundiProfileCertification toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.FundiProfileCertificationId);
                cert.CertificationId = toUpdate.CertificationId;
                cert.FundiProfileId = toUpdate.FundiProfileId;
                cert.DateUpdated = toUpdate.DateUpdated;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
