using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class ClientSubscriptionRepository:AbstractRepository<ClientSubscription>
    {
        public override bool Delete(ClientSubscription toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.SubscriptionId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override ClientSubscription GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override ClientSubscription GetById(int id)
        {
            return MyFundiDBContext.ClientSubscriptions.SingleOrDefault(p => p.SubscriptionId == id);
        }

        public override bool Update(ClientSubscription toUpdate)
        {
            try
            {
                var subs = GetById(toUpdate.SubscriptionId);
                subs.DateUpdated = DateTime.Now;
                subs.StartDate = toUpdate.StartDate;
                subs.SubscriptionDescription = toUpdate.SubscriptionDescription;
                subs.SubscriptionName = toUpdate.SubscriptionName;
                subs.SubscriptionFee = toUpdate.SubscriptionFee;
                subs.ClientProfileId = toUpdate.ClientProfileId;
                subs.UserId = toUpdate.UserId;
                subs.Username = toUpdate.Username;

                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

    }
}
