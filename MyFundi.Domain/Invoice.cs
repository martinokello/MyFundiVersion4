using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyFundi.Domain
{
    public class Invoice
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int InvoiceId { get; set; } = 0;
        public string InvoiceName { get; set; }
        public virtual List<Item> InvoicedItems { get; set; } = new List<Item>();
        public decimal NetCost { get; set; }
        [ForeignKey("User")]
        public Guid UserId { get; set; }
        public User User { get; set; }
        public decimal PercentTaxAppliable { get; set; }
        public bool HasFullyPaid { get; set; }
        public decimal GrossCost { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
