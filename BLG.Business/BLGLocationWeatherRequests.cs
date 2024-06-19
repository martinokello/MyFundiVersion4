using BLG.Business.Interfaces;
using BLGWeather.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using System.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace BLG.Business
{
    public class BLGLocationWeatherRequests : IWeatherRequests
    {
        private IHttpClient _httpClient;
        private string _openWeatherMapAPIKey;
        public BLGLocationWeatherRequests(IHttpClient httpClient, string openWeatherMapAPIKey)
        {
            _httpClient = httpClient;
            _openWeatherMapAPIKey = openWeatherMapAPIKey;
        }
        public virtual async Task<LocationWeatherElements> GetLocationWeather(string reqUrl, Location location)
        {
            var fullUrl = $"{reqUrl}{location.CityName},{location.CountryCode}&appid={_openWeatherMapAPIKey}";
            var reqResult = await _httpClient.HttpRequestClient.GetAsync(fullUrl);
            var result = await reqResult.Content.ReadAsStringAsync();
            JObject dynObj = JsonConvert.DeserializeObject<JObject>(result);

            return new LocationWeatherElements
            {
                Humidity = int.Parse(dynObj.GetValue("main").ToObject<JObject>().GetValue("humidity").ToString()),
                Pressure = int.Parse(dynObj.GetValue("main").ToObject<JObject>().GetValue("pressure").ToString()),
                Sunrise = new DateTime(long.Parse(dynObj.GetValue("sys").ToObject<JObject>().GetValue("sunrise").ToString())),
                Sunset = new DateTime(long.Parse(dynObj.GetValue("sys").ToObject<JObject>().GetValue("sunset").ToString())),
                Temperature = new Temperature
                {
                    CurrentTemperature = decimal.Parse(dynObj.GetValue("main").ToObject<JObject>().GetValue("temp").ToString()),
                    MaximumTemperature = decimal.Parse(dynObj.GetValue("main").ToObject<JObject>().GetValue("temp_max").ToString()),
                    MinmumTemperature = decimal.Parse(dynObj.GetValue("main").ToObject<JObject>().GetValue("temp_min").ToString())
                },
                Location = new Location { CityName = dynObj.GetValue("name").ToString(),
                CountryCode = dynObj.GetValue("sys").ToObject<JObject>().GetValue("country").ToString(), StateCode = string.Empty }
            };
        }
    }
}
