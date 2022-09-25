using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class ClientFundiContract
    {
        [Key]
        public int ClientFundiContractId { get; set; }
        [ForeignKey("ClientUser")]
        public Guid ClientUserId { get; set; }
        public User ClientUser { get; set; }
        [ForeignKey("FundiUser")]
        public Guid FundiUserId { get; set; }
        public User FundiUser { get; set; }
        public decimal NumberOfDaysToComplete { get; set; }
        public string ContractualDescription { get; set; }
        public bool IsCompleted { get; set; }
        public bool IsSignedOffByClient { get; set; }
        public string NotesForNotice { get; set; }
        public Decimal AgreedCost { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
