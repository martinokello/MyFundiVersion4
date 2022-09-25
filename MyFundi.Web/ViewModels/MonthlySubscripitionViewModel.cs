using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class MonthlySubscriptionViewModel
    {
        public int MonthlySubscriptionId { get; set; }
        public Guid? UserId { get; set; }
        public UserViewModel User { get; set; }
        public string Username { get; set; }
        public int? FundiProfileId { get; set; }
        public FundiProfileViewModel FundiProfile { get; set; }
        public bool HasPaid { get; set; }
        public string SubscriptionName { get; set; }
        public decimal SubscriptionFee { get; set; }
        public string SubscriptionDescription { get; set; }
        public DateTime DescriptionDate { get; set; }
        public DateTime StartDate { get; set; } = DateTime.Now;
        public DateTime EndDate { get; set; } = DateTime.Now.AddDays(31);
        public DateTime DateCreated = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
