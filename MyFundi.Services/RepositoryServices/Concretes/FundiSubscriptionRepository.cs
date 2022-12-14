using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class FundiSubscriptionRepository : AbstractRepository<FundiSubscription>
    {
        public override bool Delete(FundiSubscription toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.FundiSubscriptionId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override FundiSubscription GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override FundiSubscription GetById(int id)
        {
            return MyFundiDBContext.FundiSubscriptions.SingleOrDefault(p => p.FundiSubscriptionId == id);
        }

        public override bool Update(FundiSubscription toUpdate)
        {
            try
            {
                var subs = GetById(toUpdate.FundiSubscriptionId);
                subs.DateUpdated = DateTime.Now;
                subs.StartDate = toUpdate.StartDate;
                subs.EndDate = toUpdate.EndDate;
                subs.SubscriptionDescription = toUpdate.SubscriptionDescription;
                subs.SubscriptionName = toUpdate.SubscriptionName;
                subs.SubscriptionFee = toUpdate.SubscriptionFee;
                subs.MonthlySubscriptionId = toUpdate.MonthlySubscriptionId;
                subs.FundiWorkCategoryId = toUpdate.FundiWorkCategoryId;
                subs.FundiWorkSubCategoryId = toUpdate.FundiWorkSubCategoryId;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

    }
}
