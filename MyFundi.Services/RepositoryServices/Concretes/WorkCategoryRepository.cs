using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class WorkCategoryRepository : AbstractRepository<WorkCategory>
    {
        public override bool Delete(WorkCategory toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.WorkCategories.SingleOrDefault(p => p.WorkCategoryId == toDelete.WorkCategoryId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override WorkCategory GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override WorkCategory GetById(int id)
        {
            return MyFundiDBContext.WorkCategories.SingleOrDefault(p => p.WorkCategoryId == id);
        }

        public override bool Update(WorkCategory toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.WorkCategoryId);
                cert.WorkCategoryDescription = toUpdate.WorkCategoryDescription;
                cert.WorkCategoryType = toUpdate.WorkCategoryType;
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