using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class ClientFundiContractRepository : AbstractRepository<ClientFundiContract>
    {
        public override bool Delete(ClientFundiContract toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.ClientFundiContracts.SingleOrDefault(p => p.ClientFundiContractId == toDelete.ClientFundiContractId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override ClientFundiContract GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override ClientFundiContract GetById(int id)
        {
            return MyFundiDBContext.ClientFundiContracts.SingleOrDefault(p => p.ClientFundiContractId == id);
        }

        public override bool Update(ClientFundiContract toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.ClientFundiContractId);
                cert.ContractualDescription = toUpdate.ContractualDescription;
                cert.ClientUserId = toUpdate.ClientUserId;
                cert.DateUpdated = toUpdate.DateUpdated;
                cert.FundiUserId = toUpdate.FundiUserId;
                cert.NotesForNotice = toUpdate.NotesForNotice;
                cert.IsCompleted = toUpdate.IsCompleted;
                cert.IsSignedOffByClient = toUpdate.IsSignedOffByClient;
                cert.NumberOfDaysToComplete = toUpdate.NumberOfDaysToComplete;
                cert.AgreedCost = toUpdate.AgreedCost;
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
