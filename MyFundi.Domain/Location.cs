using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyFundi.Domain
{
    public class Location
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int LocationId { get; set; } = 0;
        public string Country { get; set; }
        [ForeignKey("AddressId")]
        public virtual Address Address { get; set; }
        public int AddressId { get; set; }
        public string LocationName { get; set; }
        public float? Latitude { get; set; }
        public float? Longitude { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
        public bool IsGeocoded { get; set; } = false;
    }

}
