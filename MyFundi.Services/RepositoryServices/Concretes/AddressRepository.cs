using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class AddressRepository : AbstractRepository<Address>
    {
        public override bool Delete(Address toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.Addresses.SingleOrDefault(p => p.AddressId == toDelete.AddressId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch(Exception e)
            {
                return false;
            }
        }

        public override Address GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override Address GetById(int id)
        {
            return MyFundiDBContext.Addresses.SingleOrDefault(p => p.AddressId == id);
        }

        public override bool Update(Address toUpdate)
        {
            try
            {
                var address = GetById(toUpdate.AddressId);
                address.AddressLine1 = toUpdate.AddressLine1;
                address.AddressLine2 = toUpdate.AddressLine2;
                address.Country = toUpdate.Country;
                address.PhoneNumber = toUpdate.PhoneNumber;
                address.PostCode = toUpdate.PostCode;
                address.Town = toUpdate.Town;
                address.DateUpdated = DateTime.Now;
                return true;
            }
            catch(Exception e)
            {
                return false;
            }
        }
    }
}
