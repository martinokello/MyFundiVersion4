using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class FundiWorkCategoryRepository : AbstractRepository<FundiWorkCategory>
    {
        public override bool Delete(FundiWorkCategory toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.FundiWorkCategories.SingleOrDefault(p => p.FundiWorkCategoryId == toDelete.FundiWorkCategoryId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override FundiWorkCategory GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override FundiWorkCategory GetById(int id)
        {
            return MyFundiDBContext.FundiWorkCategories.SingleOrDefault(p => p.FundiWorkCategoryId == id);
        }

        public override bool Update(FundiWorkCategory toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.FundiWorkCategoryId);
                cert.FundiProfileId = toUpdate.FundiProfileId;
                cert.WorkCategoryId = toUpdate.WorkCategoryId;
                cert.JobId = toUpdate.JobId;
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