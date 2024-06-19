using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class FundiLocation
    {
        [Key]
        public int FundiLocationId { get; set; }
        [ForeignKey("FundiProfile")]
        public int FundiProfileId { get; set; }
        public FundiProfile FundiProfile { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime DateUpdated { get; set; }
    }
}
