using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class CompanyRepository:AbstractRepository<Company>
    {
        public override bool Delete(Company toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.CompanyId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override Company GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override Company GetById(int id)
        {
            return MyFundiDBContext.Companies.SingleOrDefault(p => p.CompanyId == id);
        }

        public override bool Update(Company toUpdate)
        {
            try
            {
                var company = GetById(toUpdate.CompanyId);
                company.CompanyName= toUpdate.CompanyName;
                company.DateUpdated = DateTime.Now;
                company.CompanyPhoneNUmber = toUpdate.CompanyPhoneNUmber;
                company.LocationId = toUpdate.LocationId;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
