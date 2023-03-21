using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class BlogsRepository : AbstractRepository<Blog>
    {
        public override bool Delete(Blog toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.BlogId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override Blog GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override Blog GetById(int id)
        {
            return MyFundiDBContext.Blogs.SingleOrDefault(p => p.BlogId == id);
        }

        public override bool Update(Blog toUpdate)
        {
            try
            {
                var item = GetById(toUpdate.BlogId);

                item.BlogName = toUpdate.BlogName;
                item.BlogContent = toUpdate.BlogContent;
                item.DateUpdated = DateTime.Now;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
