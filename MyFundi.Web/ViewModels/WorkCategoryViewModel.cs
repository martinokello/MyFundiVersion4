using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace MyFundi.Web.ViewModels
{
    public class WorkCategoryViewModel
    {
        public int WorkCategoryId { get; set; }
        public string WorkCategoryType { get; set; }
        public string WorkCategoryDescription { get; set; }
        public int WorkSubCategoryId { get; set; }
        public string WorkSubCategoryType { get; set; }
        public string WorkSubCategoryDescription { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;


        public override bool Equals(object obj)
        {
            if (obj != null)
            {
                return (this.WorkCategoryId == ((WorkCategoryViewModel)obj).WorkCategoryId &&
                    this.WorkSubCategoryId == ((WorkCategoryViewModel)obj).WorkSubCategoryId);
            }
            return false;
        }
        public override int GetHashCode()
        {

            return 3;
        }
    }
}
