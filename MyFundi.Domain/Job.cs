using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class Job
    {
       /* public Job()
        {
            this.WorkCategories = new HashSet<WorkCategory>();
        }*/
        [Key]
        public int JobId { get; set; }
        public string JobName { get; set; }
        public string JobDescription { get; set; }
        [ForeignKey("Location")]
        public int LocationId { get; set; }
        public Location Location { get; set; }
        [ForeignKey("ClientProfile")]
        public int ClientProfileId { get; set; }
        public ClientProfile ClientProfile { get; set; }
        [ForeignKey("ClientUser")]
        public Guid ClientUserId { get; set; }
        public User ClientUser { get; set; }
        [ForeignKey("AssignedFundiUser")]
        public Guid? AssignedFundiUserId { get; set; }
        public User AssignedFundiUser { get; set; }
        [ForeignKey("AssignedFundiProfile")]
        public int? AssignedFundiProfileId { get; set; }
        public FundiProfile AssignedFundiProfile { get; set; }
        public bool HasBeenAssignedFundi { get; set; }
        public bool HasCompleted { get; set; }
        public int? ClientFundiContractId { get; set; }
        public int NumberOfDaysToComplete { get; set; }
        //public ICollection<WorkCategory> WorkCategories { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
