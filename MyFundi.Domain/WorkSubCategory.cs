using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class WorkSubCategory
    {

        [Key]
        public int WorkSubCategoryId { get; set; }
        public string WorkSubCategoryType{ get; set; }
        public string WorkSubCategoryDescription { get; set; }
        [ForeignKey("WorkCategory")]
        public int WorkCategoryId { get; set; }
        public WorkCategory WorkCategory { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
