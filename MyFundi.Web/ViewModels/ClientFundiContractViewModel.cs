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
        public int ClientProfileId { get; set; }
        public string ClientUsername { get; set; }
        public string ClientFirstName { get; set; }
        public string ClientLastName { get; set; }
        public string FundiUsername { get; set; }
        public string FundiFirstName { get; set; }
        public string FundiLastName { get; set; }
        public int FundiProfileId { get; set; }
        public string ContractualDescription { get; set; }
        public bool IsSignedByClient { get; set; }
        public Decimal AgreedCost { get; set; }
        public bool IsSignedByFundi { get; set; }
        public bool IsCompleted { get; set; }
        public bool IsSignedOffByClient { get; set; }
        public string NotesForNotice { get; set; }
        public DateTime AgreedStartDate { get; set; }
        public DateTime AgreedEndDate { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
