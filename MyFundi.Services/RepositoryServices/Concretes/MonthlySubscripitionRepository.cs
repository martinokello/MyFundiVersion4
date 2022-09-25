using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class MonthlySubscriptionRepository : AbstractRepository<MonthlySubscription>
    {
        public override bool Delete(MonthlySubscription toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.MonthlySubscriptionId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override MonthlySubscription GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override MonthlySubscription GetById(int id)
        {
            return MyFundiDBContext.MonthlySubscriptions.SingleOrDefault(p => p.MonthlySubscriptionId == id);
        }

        public override bool Update(MonthlySubscription toUpdate)
        {
            try
            {
                var subs = GetById(toUpdate.MonthlySubscriptionId);
                subs.SubscriptionDescription = toUpdate.SubscriptionDescription;
                subs.DateUpdated = DateTime.Now;
                subs.SubscriptionName = toUpdate.SubscriptionName;
                subs.SubscriptionFee = toUpdate.SubscriptionFee;
                subs.HasPaid = toUpdate.HasPaid;
                subs.StartDate = toUpdate.StartDate;
                subs.EndDate = toUpdate.EndDate;
                subs.FundiProfileId = toUpdate.FundiProfileId;
                subs.UserId = toUpdate.UserId;
                subs.SubscriptionDescription = toUpdate.SubscriptionDescription;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}
