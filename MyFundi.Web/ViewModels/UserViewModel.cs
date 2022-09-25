using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class UserViewModel
    {
        public Guid UserId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string MobileNumber { get; set; }
        public int CompanyId { get; set; }
        public DateTime CreateTime { get; set; } = DateTime.Now;
        public DateTime LastLogInTime { get; set; } = DateTime.Now;
        public bool IsActive { get; set; }
        public bool IsLockedOut { get; set; }

    }
}
