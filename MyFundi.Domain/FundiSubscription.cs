using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class FundiSubscription
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int FundiSubscriptionId { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime DateUpdated { get; set; }
        public DateTime StartDate { get; set; }
        public string SubscriptionName { get; set; }
        public decimal SubscriptionFee { get; set; }
        public string SubscriptionDescription { get; set; }
        public DateTime EndDate { get; set; }
        [ForeignKey("MonthlySubscription")]
        public int MonthlySubscriptionId { get; set; }
        public MonthlySubscription MonthlySubscription { get; set; }
        [ForeignKey("WorkCategory")]
        public int FundiWorkCategoryId { get; set; }
        [ForeignKey("WorkSubCategory")]
        public int FundiWorkSubCategoryId { get; set; }
        public WorkSubCategory WorkSubCategory { get; set; }
    }
}
