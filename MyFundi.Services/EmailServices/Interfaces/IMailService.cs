using Microsoft.Extensions.Options;
using MyFundi.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

namespace MyFundi.Services.EmailServices.Interfaces
{
    public enum EmailTemplate 
    { 
        InvoiceMessage, 
        WelcomeMessage, 
        SuccessBuyCommodityMessage, 
        TransactionFailureMessage, 
        ArrangeTransportScheduleMessage, 
        PasswordResetMessage
    }
    public interface IMailService
    {
        public IConfiguration BusinessEmailDetails { get; set; }

        void SendEmail(EmailDao mail);
        string GetTemplate(EmailTemplate template);
    }
}
