using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class WorkSubCategoryRepository : AbstractRepository<WorkSubCategory>
    {
        public override bool Delete(WorkSubCategory toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.WorkSubCategories.SingleOrDefault(p => p.WorkSubCategoryId == toDelete.WorkSubCategoryId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override WorkSubCategory GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override WorkSubCategory GetById(int id)
        {
            return MyFundiDBContext.WorkSubCategories.SingleOrDefault(p => p.WorkSubCategoryId == id);
        }

        public override bool Update(WorkSubCategory toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.WorkSubCategoryId);
                cert.WorkSubCategoryDescription = toUpdate.WorkSubCategoryDescription;
                cert.WorkSubCategoryType = toUpdate.WorkSubCategoryType;
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
