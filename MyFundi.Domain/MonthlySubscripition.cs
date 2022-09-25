using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class MonthlySubscription
    {
        [Key]
        public int MonthlySubscriptionId { get; set; }
        [ForeignKey("User")]
        public Guid? UserId { get; set; }
        public string Username { get; set; }
        public User User { get; set; }
        [ForeignKey("FundiProfile")]
        public int? FundiProfileId { get; set; }
        public FundiProfile FundiProfile { get; set; }
        public bool HasPaid { get; set; }
        public string SubscriptionName { get; set; }
        public decimal SubscriptionFee { get; set; }
        public string SubscriptionDescription { get; set; }
        public DateTime StartDate { get; set; } = DateTime.Now;
        public DateTime EndDate { get; set; }
        public DateTime DateCreated = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
