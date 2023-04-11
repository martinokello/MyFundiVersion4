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
        [ForeignKey("ClientProfile")]
        public int ClientProfileId { get; set; }
        public ClientProfile ClientProfile { get; set; }
        [ForeignKey("FundiProfile")]
        public int FundiProfileId { get; set; }
        public FundiProfile FundiProfile { get; set; }
        [ForeignKey("Job")]
        public int? JobId { get; set; }
        public Job Job { get; set; }
        [ForeignKey("FundiAddress")]
        public int? FundiAddressId { get; set; }
        public Address FundiAddress { get; set; }
        [ForeignKey("ClientAddress")]
        public int? ClientAddressId { get; set; }
        public Address ClientAddress { get; set; }
        public string ClientUsername { get; set; }
        public string ClientFirstName { get; set; }
        public string ClientLastName { get; set; }
        public string FundiUsername { get; set; }
        public string FundiFirstName { get; set; }
        public string FundiLastName { get; set; }
        public decimal NumberOfDaysToComplete { get; set; }
        public string ContractualDescription { get; set; }
        public DateTime AgreedStartDate { get; set; }
        public DateTime AgreedEndDate { get; set; }
        public bool IsCompleted { get; set; }
        public bool IsSignedByClient { get; set; }
        public bool IsSignedByFundi { get; set; }
        public bool IsSignedOffByClient { get; set; }
        public string NotesForNotice { get; set; }
        public Decimal AgreedCost { get; set; }
        public DateTime Date1stPayment { get; set; } = DateTime.Now;
        public decimal FirstPaymentAmount { get; set; }
        public DateTime Date2ndPayment { get; set; } = DateTime.Now;
        public decimal SecondPaymentAmount { get; set; }
        public DateTime Date3rdPayment { get; set; } = DateTime.Now;
        public decimal ThirdPaymentAmount { get; set; }
        public DateTime Date4thPayment { get; set; } = DateTime.Now;
        public decimal ForthPaymentAmount { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;

    }
}
