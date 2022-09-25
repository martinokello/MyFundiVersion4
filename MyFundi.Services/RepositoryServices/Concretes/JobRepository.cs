using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class JobRepository : AbstractRepository<Job>
    {
        public override bool Delete(Job toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.JobId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override Job GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override Job GetById(int id)
        {
            return MyFundiDBContext.Jobs.SingleOrDefault(p => p.JobId == id);
        }

        public override bool Update(Job toUpdate)
        {
            try
            {
                var item = GetById(toUpdate.JobId);

                item.JobName = toUpdate.JobName;
                item.JobDescription = toUpdate.JobDescription;
                item.HasCompleted = toUpdate.HasCompleted;
                item.LocationId = toUpdate.LocationId;
                item.ClientProfileId = toUpdate.ClientProfileId;
                item.ClientUserId = toUpdate.ClientUserId;
                item.AssignedFundiProfileId = toUpdate.AssignedFundiProfileId;
                item.AssignedFundiUserId = toUpdate.AssignedFundiUserId;
                item.ClientFundiContractId = toUpdate.ClientFundiContractId;
                item.HasBeenAssignedFundi = toUpdate.HasBeenAssignedFundi;
                item.NumberOfDaysToComplete = toUpdate.NumberOfDaysToComplete;
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
