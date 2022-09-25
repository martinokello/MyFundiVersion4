using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Web.ViewModels
{
    public class FundiProfileCertificationViewModel
    {
        public int FundiProfileCertificationId { get; set; }
        public int FundiProfileId { get; set; }
        public int CertificationId { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }

    public class CertificationUserTO
    {
        public int CertificationId { get; set; }
        public string Username { get; set; }
    }
}
