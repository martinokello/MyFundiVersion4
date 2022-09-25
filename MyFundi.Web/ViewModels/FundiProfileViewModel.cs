using System;
using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFundi.Web.ViewModels
{
    public class FundiProfileViewModel
    {
        public int FundiProfileId { get; set; }
        public Guid UserId { get; set; }
        public string ProfileSummary { get; set; }
        public string ProfileImageUrl { get; set; }
        public string Skills { get; set; }
        public string UsedPowerTools { get; set; }
        public string FundiProfileCvUrl { get; set; }
        public int AddressId { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
