using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class CertificationRepository: AbstractRepository<Certification>
    {
        public override bool Delete(Certification toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.Certifications.SingleOrDefault(p => p.CertificationId == toDelete.CertificationId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch(Exception e)
            {
                return false;
            }
        }

        public override Certification GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override Certification GetById(int id)
        {
            return MyFundiDBContext.Certifications.SingleOrDefault(p => p.CertificationId == id);
        }

        public override bool Update(Certification toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.CertificationId);
                cert.CertificationDescription = toUpdate.CertificationDescription;
                cert.CertificationName = toUpdate.CertificationName;
                cert.DateUpdated = toUpdate.DateUpdated;
                return true;
            }
            catch(Exception e)
            {
                return false;
            }
        }
    }
}
