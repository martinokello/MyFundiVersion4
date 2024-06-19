using SimbaToursEastAfrica.Caching.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Caching.Memory;
using System.Reflection;

namespace SimbaToursEastAfrica.Caching.Concretes
{
    public class SimbaToursEastAfricaCahing: ICaching
    {
        public MemoryCache CacheObject { get; set; } = new MemoryCache(new MemoryCacheOptions());


        public async Task<T> GetOrSaveToCache<T>(string key, int timeInMinutes, Func<Task<T>> ResolveCache)
        {
            T result = (T) CacheObject.Get(key);
            if (object.Equals(result, default(T)))
            {
                T fromCache = await ResolveCache.Invoke();
                CacheObject.Set(key, fromCache, DateTime.Now.AddMinutes(timeInMinutes));
                return fromCache;
            }
            return result;
        }

        public  T GetOrSaveToCacheWithId<K,T>(string key, int timeInMinutes, Func<K,T> ResolveCache, int id)
        { 
            T result = (T)CacheObject.Get(key);
            if (object.Equals(result, default(T)))
            {
                T fromCache = (T)ResolveCache.Method.Invoke(ResolveCache.Target,new object[]{ id});
                CacheObject.Set(key, fromCache, DateTime.Now.AddMinutes(timeInMinutes));
                return fromCache;
            }
            return result;
        }
    }
}
