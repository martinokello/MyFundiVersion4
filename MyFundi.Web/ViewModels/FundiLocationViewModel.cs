using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class FundiLocationViewModel
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string MobileNumber { get; set; }
        public bool UpdatePhoneNumber { get; set; }
        public float Latitude { get; set; }
        public float Longitude { get; set; }
        public string DriverName { get; set; }
        public int FundiProfileId { get; set; }
        public bool replaceMobileNumber { get; set; }
        public override bool Equals(object obj)
        {
            return this.MobileNumber.Equals((obj as FundiLocationViewModel).MobileNumber) && this.Email.Equals((obj as FundiLocationViewModel).Email);
        }
        public override int GetHashCode()
        {
            return (int)(Double.Parse(this.MobileNumber) * 8 + this.Email.Length);
        }
    }
}
