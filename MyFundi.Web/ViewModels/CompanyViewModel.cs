using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class CompanyViewModel
    {
        public int CompanyId { get; set; }
        public string CompanyName { get; set; }
        public string CompanyPhoneNUmber { get; set; }
        public LocationViewModel Location { get; set; }
        public int LocationId { get; set; }
    }
}
