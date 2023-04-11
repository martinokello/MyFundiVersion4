using Microsoft.EntityFrameworkCore;
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
            return MyFundiDBContext.ClientFundiContracts.Where(p => p.ClientFundiContractId == id).Include(q=> q.FundiProfile).Include(q=> q.ClientProfile).FirstOrDefault();
        }

        public override bool Update(ClientFundiContract toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.ClientFundiContractId);
                cert.ContractualDescription = toUpdate.ContractualDescription;
                cert.JobId = toUpdate.JobId;
                cert.ClientProfileId = toUpdate.ClientProfileId;
                cert.DateUpdated = toUpdate.DateUpdated;
                cert.FundiProfileId = toUpdate.FundiProfileId;
                cert.NotesForNotice = toUpdate.NotesForNotice;
                cert.IsSignedByClient = toUpdate.IsSignedByClient;
                cert.IsSignedByFundi = toUpdate.IsSignedByFundi;
                cert.IsCompleted = toUpdate.IsCompleted;
                cert.IsSignedOffByClient = toUpdate.IsSignedOffByClient;
                cert.NumberOfDaysToComplete = toUpdate.NumberOfDaysToComplete;
                cert.AgreedCost = toUpdate.AgreedCost;
                cert.AgreedStartDate = toUpdate.AgreedStartDate;
                cert.ClientAddressId = toUpdate.ClientAddressId;
                cert.FundiAddressId = toUpdate.FundiAddressId;
                cert.FirstPaymentAmount = toUpdate.FirstPaymentAmount;
                cert.SecondPaymentAmount = toUpdate.SecondPaymentAmount;
                cert.ThirdPaymentAmount = toUpdate.ThirdPaymentAmount;
                cert.ForthPaymentAmount = toUpdate.ForthPaymentAmount;
                cert.Date1stPayment = toUpdate.Date1stPayment;
                cert.Date2ndPayment = toUpdate.Date2ndPayment;
                cert.Date3rdPayment = toUpdate.Date3rdPayment;
                cert.Date4thPayment = toUpdate.Date4thPayment;
                cert.AgreedEndDate = toUpdate.AgreedEndDate;
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
