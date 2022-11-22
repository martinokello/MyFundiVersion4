using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class FundiLocationViewModel
    {
        public UserViewModel fundiUserDetails { get; set; }
        public bool UpdatePhoneNumber { get; set; }
        public string PhoneNumber { get; set; }
        public string EmailAddress { get; set; }
        public float Lattitude { get; set; }
        public float Longitude { get; set; }
        public override bool Equals(object obj)
        {
            return this.PhoneNumber.Equals((obj as FundiLocationViewModel).PhoneNumber) && this.EmailAddress.Equals((obj as FundiLocationViewModel).EmailAddress);
        }
        public override int GetHashCode()
        {
            return (int)(Double.Parse(this.PhoneNumber) * 8);
        }
    }
}
