using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class ItemRepository : AbstractRepository<Item>
    {
        public override bool Delete(Item toDelete)
        {
            try
            {
                toDelete = GetById(toDelete.ItemId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override Item GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override Item GetById(int id)
        {
            return MyFundiDBContext.Items.SingleOrDefault(p => p.ItemId == id);
        }

        public override bool Update(Item toUpdate)
        {
            try
            {
                var item = GetById(toUpdate.ItemId);
                item.ItemName = toUpdate.ItemName;
                item.ItemCost= toUpdate.ItemCost;
                item.Quantity = toUpdate.Quantity;
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
