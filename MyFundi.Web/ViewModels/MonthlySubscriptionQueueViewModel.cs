using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class MonthlySubscriptionQueueViewModel
    {
        public int MonthlySubscriptionQueueId { get; set; }
        public Guid? UserId { get; set; }
        public string Username { get; set; }
        public string SubscriptionName { get; set; }
        public string SubscriptionDescription { get; set; }
        public int? FundiProfileId { get; set; }
        public bool HasPaid { get; set; }
        public bool HasExpired { get; set; }
        public decimal SubscriptionFee { get; set; }
        public DateTime StartDate { get; set; } = DateTime.Now;
        public DateTime EndDate { get; set; }
        public DateTime DateCreated = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
