using System;

namespace MyFundi.Web.ViewModels
{
    public class LocationViewModel
    {
        public int LocationId { get; set; }
        public string Country { get; set; }
        public float? Latitude { get; set; }
        public float? Longitude { get; set; }
        public virtual AddressViewModel Address { get; set; }
        public int AddressId { get; set; }
        public string LocationName { get; set; }
        public bool IsGeocoded { get; set; }
    }
}