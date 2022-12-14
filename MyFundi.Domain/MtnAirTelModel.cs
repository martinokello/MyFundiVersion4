using System;
using System.Collections.Generic;
using System.Text;

namespace MyFundi.Domain
{

    public class MtnAirTelModel
    {

        public string Username { get; set; }
        public string Password { get; set; }
        public string Action { get; set; }
        public string Currency { get; set; }
        public string Amount { get; set; }
        public string Phone { get; set; }
        public string Reference { get; set; }
        public string Reason { get; set; }
        public string MtnAirtelBaseUrl { get; set; }
        public string CancelUrl { get; set; }
        public string SuccessUrl { get; set; }
        public string NotifyUrl { get; set; }
    }
}
