using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class FundiSubscriptionQueueRepository:AbstractRepository<FundiSubscriptionQueue>
    {
        public override bool Delete(FundiSubscriptionQueue toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.MonthlySubscriptionQueueId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override FundiSubscriptionQueue GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override FundiSubscriptionQueue GetById(int id)
        {
            return MyFundiDBContext.FundiSubscriptionQueues.SingleOrDefault(p => p.FundiSubscriptionQueueId == id);
        }

        public override bool Update(FundiSubscriptionQueue toUpdate)
        {
            try
            {
                var subs = GetById(toUpdate.FundiSubscriptionQueueId);
                subs.DateUpdated = DateTime.Now;
                subs.StartDate = toUpdate.StartDate;
                subs.EndDate = toUpdate.EndDate;
                subs.SubscriptionDescription = toUpdate.SubscriptionDescription;
                subs.SubscriptionName = toUpdate.SubscriptionName;
                subs.SubscriptionFee = toUpdate.SubscriptionFee;
                subs.MonthlySubscriptionQueueId = toUpdate.MonthlySubscriptionQueueId;
                subs.FundiWorkCategoryId = toUpdate.FundiWorkCategoryId;
                subs.FundiWorkSubCategoryId = toUpdate.FundiWorkSubCategoryId;
                subs.HasPaid = toUpdate.HasPaid;

                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

    }
}
