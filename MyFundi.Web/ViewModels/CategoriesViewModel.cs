using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class CategoriesViewModel
    {
        public string[] WorkCategories { get; set; }
        public string[] WorkSubCategories { get; set; }
        public string Username { get; set; }
        public int FundiProfileId { get; set; }
        public CoordinateViewModel Coordinate { get; set; }
    }
}
