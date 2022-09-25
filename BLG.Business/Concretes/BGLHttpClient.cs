using BLG.Business.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace BLG.Business.Concretes
{
    public class BGLHttpClient : IHttpClient
    {
        public HttpClient HttpRequestClient { get; set; }
    }
}
