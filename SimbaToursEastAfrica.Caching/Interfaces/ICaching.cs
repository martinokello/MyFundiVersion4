using Microsoft.Extensions.Caching.Memory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SimbaToursEastAfrica.Caching.Interfaces
{
    public interface ICaching
    {
        MemoryCache CacheObject { set; get; }
        Task<T> GetOrSaveToCache<T>(string key, int timeInMinutes, Func<Task<T>> ResolveCache);
    }
}
