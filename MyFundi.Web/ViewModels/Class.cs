using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class FundiSubscriptionQueueViewModel
    {
        public int FundiSubscriptionQueueId { get; set; }
        public bool HasPaid { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime DateUpdated { get; set; }
        public DateTime StartDate { get; set; }
        public string SubscriptionName { get; set; }
        public decimal SubscriptionFee { get; set; }
        public string SubscriptionDescription { get; set; }
        public DateTime EndDate { get; set; }
        public int MonthlySubscriptionId { get; set; }
        public int FundiWorkCategoryId { get; set; }
        public int FundiWorkSubCategoryId { get; set; }
    }
}
