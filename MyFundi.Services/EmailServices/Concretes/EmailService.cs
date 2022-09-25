using Microsoft.Extensions.Options;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using Microsoft.Extensions.Configuration;
using MyFundi.AppConfigurations;

namespace MyFundi.Services.EmailServices.Concretes
{
    public class EmailService : IMailService
    {
        public IConfiguration _businessSmtpDetails;
        public EmailService(AppSettingsConfigurations businessSmtpDetails)
        {
            _businessSmtpDetails = businessSmtpDetails.AppSettings.GetSection("BusinessEmailDetails");
        }

        public IConfiguration BusinessEmailDetails {
            set { _businessSmtpDetails = value; }
            get { return _businessSmtpDetails; }
        }
        public string GetTemplate(EmailTemplate template)
        {
            throw new NotImplementedException();
        }

        public void SendEmail(EmailDao mail)
        {
            try
            {
                //Send Email:
                var networkCredentials = new NetworkCredential { UserName = _businessSmtpDetails.GetSection("NetworkUsername").Value, Password = _businessSmtpDetails.GetSection("NetworkPassword").Value };
                var smtpServer = new SmtpClient(_businessSmtpDetails.GetSection("SmtpServer").Value);
                smtpServer.Credentials = networkCredentials;

                var mailMessage = new MailMessage();
                mailMessage.From = new MailAddress(_businessSmtpDetails.GetSection("BusinessEmail").Value);
                mailMessage.Body = mail.EmailBody;
                mailMessage.Subject = @"From " + mail.EmailFrom + " " + mail.EmailSubject;
                var memoryStream = new MemoryStream();
                var fileStream = new FileInfo("/images/attachement");

                if (mail.Attachment != null)
                {
                    var attachment = new Attachment(mail.Attachment.OpenReadStream(), mail.Attachment.FileName);
                    mailMessage.Attachments.Add(attachment);
                }
                mail.EmailTo += string.Format(";{0}", _businessSmtpDetails.GetSection("BusinessEmail").Value);
                Array.ForEach<string>(mail.EmailTo.Split(new char[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries), (p) =>
                {
                    mailMessage.To.Add(p);
                });
                smtpServer.Send(mailMessage);
                
            }
            catch (Exception e)
            {
                throw e;
            }
        }
    }
}
