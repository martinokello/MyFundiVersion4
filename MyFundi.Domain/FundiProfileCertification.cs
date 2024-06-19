using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class FundiProfileCertification
    {
        [Key]
        public int FundiProfileCertificationId { get; set; }
        [ForeignKey("FundiProfile")]
        public int FundiProfileId { get; set; }
        public FundiProfile FundiProfile { get; set; }
        [ForeignKey("Certification")]
        public int CertificationId { get; set; }
        public Certification Certification { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
