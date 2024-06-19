using MyFundi.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class ClientSubscriptionViewModel
    {
        public int SubscriptionId { get; set; }
        public string Username { get; set; }
        public string SubscriptionName { get; set; }
        public string SubscriptionDescription { get; set; }
        public int? ClientProfileId { get; set; }
		public bool HasPaid { get; set; }
        public decimal SubscriptionFee { get; set; }
        public DateTime StartDate { get; set; } = DateTime.Now;
        public DateTime DateCreated = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
