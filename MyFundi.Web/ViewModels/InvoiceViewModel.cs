using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class InvoiceViewModel
    {
        public int InvoiceId { get; set; } = 0;
        public string InvoiceName { get; set; }
        public bool HasFullyPaid { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
