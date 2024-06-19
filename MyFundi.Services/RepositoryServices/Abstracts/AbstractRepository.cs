using MyFundi.DataAccess;
using MyFundi.Services.RepositoryServices.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyFundi.Services.RepositoryServices.Abstracts
{
    public abstract class AbstractRepository<T> : IRepository<T> where T : class
    {
        public MyFundiDBContext MyFundiDBContext { get; set; }
        public abstract bool Delete(T toDelete);

        public IQueryable<T> GetAll()
        {
            return MyFundiDBContext.Set<T>().AsQueryable<T>();
        }

        public abstract T GetById(int id);

        public abstract T GetByGuid(Guid id);
        public bool Insert(T toInsert)
        {
            try{

                MyFundiDBContext.Add<T>(toInsert);
                return true;
            }
            catch(Exception e){
                return false;
            }
        }

        public abstract bool Update(T toUpdate);
    }
}
