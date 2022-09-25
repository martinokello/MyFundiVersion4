using BLGWeather.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLG.Business.Interfaces
{
    public interface IWeatherRequests
    {
        Task<LocationWeatherElements> GetLocationWeather(string reqUrl, Location location);
    }
}
