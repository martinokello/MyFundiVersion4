using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLGWeather.Domain
{
    public class Temperature
    {
        public decimal CurrentTemperature { get; set; }
        public decimal MaximumTemperature { get; set; }
        public decimal MinmumTemperature { get; set; }
    }
}
