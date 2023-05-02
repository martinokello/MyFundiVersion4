using MyFundi.DataAccess;
using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class AnswerRepository : AbstractRepository<Answer>
    {
        public override bool Delete(Answer toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.AnswerId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override Answer GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override Answer GetById(int id)
        {
            return MyFundiDBContext.Answers.SingleOrDefault(p => p.AnswerId == id);
        }

        public override bool Update(Answer toUpdate)
        {
            try
            {
                var item = GetById(toUpdate.AnswerId);

                item.AnswerContent = toUpdate.AnswerContent;
                item.DateUpdated = DateTime.Now;
                item.QuestionId = toUpdate.QuestionId;
                item.FundiProfileId = toUpdate.FundiProfileId;

                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
