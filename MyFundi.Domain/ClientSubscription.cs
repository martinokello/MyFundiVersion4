using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class ClientSubscription
    {
        [Key]
        public int SubscriptionId { get; set; }
        [ForeignKey("User")]
        public Guid? UserId { get; set; }
        public string Username { get; set; }
        public string SubscriptionName { get; set; }
        public string SubscriptionDescription { get; set; }
        public User User { get; set; }
        [ForeignKey("ClientProfile")]
        public int? ClientProfileId { get; set; }
        public ClientProfile ClientProfile { get; set; }
        public bool HasPaid { get; set; }
        public decimal SubscriptionFee { get; set; }
        public DateTime StartDate { get; set; } = DateTime.Now;
        public DateTime DateCreated = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
