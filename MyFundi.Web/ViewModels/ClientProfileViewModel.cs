using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class ClientProfileViewModel
    {
        public int ClientProfileId { get; set; }
        public Guid UserId { get; set; }
        public UserViewModel User { get; set; }
        public int AddressId { get; set; }
        public AddressViewModel Address { get; set; }
        public string ProfileSummary { get; set; }
        public string ProfileImageUrl { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
