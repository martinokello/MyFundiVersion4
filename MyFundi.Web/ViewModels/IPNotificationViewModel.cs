using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class IPNotificationViewModel
    {
        public string Phone { get; set; }
        public string Reference { get; set; }
        public string TransactionId { get; set; }
        public decimal Amount { get; set; }
        public string Reason { get; set; }
    }
}
