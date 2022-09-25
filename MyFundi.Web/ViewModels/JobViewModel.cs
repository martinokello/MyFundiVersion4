using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class JobViewModel
    {
        public int JobId { get; set; }
        public string JobName { get; set; }
        public string JobDescription { get; set; }
        public int ClientProfileId { get; set; }
        public ClientProfileViewModel ClientProfile { get; set; }
        public Guid ClientUserId { get; set; }
        public UserViewModel ClientUser { get; set; }
        public int? AssignedFundiProfileId { get; set; }
        public FundiProfileViewModel AssignedFundiProfile { get; set; }
        public Guid? AssignedFundiUserId { get; set; }
        public UserViewModel AssignedFundiUser { get; set; }
        public bool HasBeenAssignedFundi { get; set; }
        public bool HasCompleted { get; set; }
        public int LocationId { get; set; }
        public LocationViewModel Location { get; set; }
        public int? ClientFundiContractId { get; set; }
        public decimal NumberOfDaysToComplete { get; set; }
        public int[] JobWorkCategoryIds { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
