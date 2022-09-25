using MyFundi.Web.IdentityServices;
using MyFundi.AppConfigurations;
using BLG.Business;
using BLG.Business.Concretes;
using BLGWeather.Domain;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;

namespace BLGWeather.WebApi.Controllers
{
    namespace BLGWeather.WebApi.Controllers
    {
        /*[AuthorizeIdentity]*/
        public class LocationWeatherController : Controller
        {
            private readonly BLGLocationWeatherRequests _bLGLocationWeatherRequests;
            private AppSettingsConfigurations _appSettings;
            public LocationWeatherController(BLGLocationWeatherRequests bLGLocationWeatherRequests,AppSettingsConfigurations appSettings)
            {
                _bLGLocationWeatherRequests = bLGLocationWeatherRequests;
                _appSettings = appSettings;
            }
            [Microsoft.AspNetCore.Mvc.Route("~/api/LocationWeather/GetLocationWeather/{location}/{countryCode}")]
            [AuthorizeIdentity]
            public async Task<IActionResult> GetLocationWeather(string location, string countryCode)
            {
                var httpClient = new BGLHttpClient();
                httpClient.HttpRequestClient = new HttpClient();
                try
                {
                    var result = await _bLGLocationWeatherRequests.GetLocationWeather(_appSettings.GetConfigSetting("WeatherApiBaseUrl"), new Location { CityName = location, CountryCode = countryCode });

                    if (result == null)
                    {
                        return NotFound();
                    }
                    return Ok(result);
                }
                catch(Exception e)
                {
                    return BadRequest("Bad Result Set!");
                }
            }
        }
    }
}
