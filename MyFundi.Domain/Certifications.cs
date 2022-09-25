using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace MyFundi.Domain
{
    public class Certification
    {
        [Key]
        public int CertificationId { get; set; }
        public string CertificationName { get; set; }
        public string CertificationDescription { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
