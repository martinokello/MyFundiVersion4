using System;
using System.Collections.Generic;
using System.Text;

namespace MyFundi.Domain
{
    public class WorkCategoryTypesTO
    {
        public int WorkCategoryId { get; set; }
        public int WorkSubCategoryId { get; set; }
        public string WorkCategoryType { get; set; }
        public string WorkSubCategoryType { get; set; }
    }
}
