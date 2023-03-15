using MyFundi.DataAccess;
using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class MonthlySubscriptionQueueRepository:AbstractRepository<MonthlySubscriptionQueue>
    {
        public override bool Delete(MonthlySubscriptionQueue toDelete)
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

        public override MonthlySubscriptionQueue GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override MonthlySubscriptionQueue GetById(int id)
        {
            return MyFundiDBContext.MonthlySubscriptionQueues.SingleOrDefault(p => p.MonthlySubscriptionQueueId == id);
        }

        public override bool Update(MonthlySubscriptionQueue toUpdate)
        {
            try
            {
                var subs = GetById(toUpdate.MonthlySubscriptionQueueId);

                subs.DateUpdated = DateTime.Now;
                subs.HasPaid = toUpdate.HasPaid;
                subs.StartDate = toUpdate.StartDate;
                subs.EndDate = toUpdate.EndDate;
                subs.FundiProfileId = toUpdate.FundiProfileId;
                subs.HasExpired = toUpdate.HasExpired;
                subs.UserId = toUpdate.UserId;
                subs.SubscriptionDescription = toUpdate.SubscriptionDescription;
                subs.SubscriptionName = toUpdate.SubscriptionName;
                subs.SubscriptionFee = toUpdate.SubscriptionFee;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
