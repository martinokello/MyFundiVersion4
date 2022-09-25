using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLGWeather.Domain
{
    public class LocationWeatherElements
    {
        public Location Location { get; set; }
        public Temperature Temperature { get; set; }
        public int Pressure { get; set; }
        public int Humidity { get; set; }
        public DateTime Sunrise { get; set; }
        public DateTime Sunset { get; set; }
    }
}
