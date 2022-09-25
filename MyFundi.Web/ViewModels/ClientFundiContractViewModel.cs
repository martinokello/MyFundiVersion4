using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Web.ViewModels
{
    public class ClientFundiContractViewModel
    {
        public int ClientFundiContractId { get; set; }
        public Guid ClientUserId { get; set; }
        public Guid FundiUserId { get; set; }
        public string ContractualDescription { get; set; }
        public bool IsCompleted { get; set; }
        public bool IsSignedOffByClient { get; set; }
        public string NotesForNotice { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
