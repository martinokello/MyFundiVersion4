using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class JobWorkCategory
    {
        [Key]
        public int JobWorkCategoryId { get; set; }
        [ForeignKey("Job")]
        public int? JobId { get; set; }
        public Job Job { get; set; }
        [ForeignKey("WorkCategory")]
        public int? WorkCategoryId { get; set; }
        public WorkCategory WorkCategory { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
