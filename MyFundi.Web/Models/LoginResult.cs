using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.Models
{
    public class LoginResult
    {
        public bool IsLoggedIn { get; set; }
        public bool IsAdministrator { get; set; }
        public bool IsRegistered { get; set; }
        public string Message { get; set; }
        public string ErrorMessage { get; set; }
        public string AuthToken { get; set; }
        public bool IsFundi { get; set; }
        public bool IsClient { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public bool FundiDueToPaySubscription { get; set; } 
        public bool ClientDueToPaySubscription { get; internal set; }
    }
}
