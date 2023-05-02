using MyFundi.DataAccess;
using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class QuestionRepository : AbstractRepository<Question>
    {
        public override bool Delete(Question toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.QuestionId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override Question GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override Question GetById(int id)
        {
            return MyFundiDBContext.Questions.SingleOrDefault(p => p.QuestionId == id);
        }

        public override bool Update(Question toUpdate)
        {
            try
            {
                var item = GetById(toUpdate.QuestionId);

                item.QuestionContent = toUpdate.QuestionContent;
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
