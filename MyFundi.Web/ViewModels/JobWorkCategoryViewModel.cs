using MyFundi.Domain;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class JobWorkCategoryViewModel
    {
        public int JobWorkCategoryId { get; set; }
        public int JobId { get; set; }
        public JobViewModel Job { get; set; }
        public int WorkCategoryId { get; set; }
        public WorkCategory WorkCategory { get; set; }
        public int WorkSubCategoryId { get; set; }
        public WorkSubCategory WorkSubCategory { get; set; }

    }
}
