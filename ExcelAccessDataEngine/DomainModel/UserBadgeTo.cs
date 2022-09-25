using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExcelAccessDataEngine.DomainModel
{
    public class UserBadgeTo
    {
        public string CandidateFullName { get; set; }
        public string CellPhoneNumber { get; set; }
        public string ProvinceDelimitedByComma { get; set; }
        public string BadgeType { get; set; }
        public string EmailAddress { get; set; }
    }
}
