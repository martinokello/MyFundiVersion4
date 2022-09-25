using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class FundiWorkCategory
    {
        [Key]
        public int FundiWorkCategoryId { get; set; }
        [ForeignKey("FundiProfile")]
        public int FundiProfileId { get; set; }
        public FundiProfile FundiProfile { get; set; }
        [ForeignKey("WorkCategory")]
        public int WorkCategoryId { get; set; }
        public WorkCategory WorkCategory { get; set; }
        [ForeignKey("Job")]
        public int? JobId { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
