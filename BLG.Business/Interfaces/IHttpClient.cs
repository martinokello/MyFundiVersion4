using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;

namespace BLG.Business.Interfaces
{
    //HttpClient to call other Apis from anywhere.
    public interface IHttpClient
    {
        HttpClient HttpRequestClient { get; set; }
    }
}
