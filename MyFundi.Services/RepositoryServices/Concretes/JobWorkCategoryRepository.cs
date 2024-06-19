using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class JobWorkCategoryRepository : AbstractRepository<JobWorkCategory>
    {
        public override bool Delete(JobWorkCategory toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.JobWorkCategories.SingleOrDefault(p => p.JobWorkCategoryId == toDelete.JobWorkCategoryId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override JobWorkCategory GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override JobWorkCategory GetById(int id)
        {
            return MyFundiDBContext.JobWorkCategories.SingleOrDefault(p => p.JobWorkCategoryId == id);
        }

        public override bool Update(JobWorkCategory toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.JobWorkCategoryId);
                cert.JobId = toUpdate.JobId;
                cert.WorkCategoryId = toUpdate.WorkCategoryId;
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
