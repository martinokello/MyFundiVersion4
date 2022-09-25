using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class WorkCategory
    {
        [Key]
        public int WorkCategoryId { get; set; }
        public string WorkCategoryType { get; set; }
        public string WorkCategoryDescription { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
