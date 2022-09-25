using System;
using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFundi.Domain
{
    public class FundiProfile
    {
        [Key]
        public int FundiProfileId { get; set; }
        public Guid UserId { get; set; }
        public User User { get; set; }
        public string ProfileSummary { get; set; }
        public string ProfileImageUrl { get; set; }
        public string Skills { get; set; }
        public string UsedPowerTools { get; set; }
        [ForeignKey("Address")]
        public int AddressId { get; set; }
        public Address Address { get; set; }
        public string FundiProfileCvUrl { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
