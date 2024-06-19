using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyFundi.Services.RepositoryServices.Interfaces
{
    public interface IRepository<T>
    {
        T GetById(int id);
        IQueryable<T> GetAll();
        bool Update(T toUpdate);
        bool Delete(T toDelete);
        bool Insert(T toInsert);
    }
}
