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
using Microsoft.AspNetCore.Http;

namespace MyFundi.Services.EmailServices.Concretes
{
    public class EmailService : IMailService
    {
        public IConfigurationSection _businessSmtpDetails;
        public EmailService(IConfiguration configuration)
        {
            _businessSmtpDetails = configuration.GetSection("BusinessEmailDetails");
        }

        public IConfigurationSection BusinessEmailDetails {
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
                var fileStream = new FileInfo("/images/attachement");
                
                if (mail.Attachment != null)
                {
                    using (var memoryStream = new MemoryStream())
                    {
                        ReadFileAttachment(mail.Attachment, memoryStream);
                        memoryStream.Seek(0, SeekOrigin.Begin);
                        var attached = new Attachment(memoryStream, mail.Attachment.FileName);
                        mailMessage.Attachments.Add(attached);
                    }
                }
                if (mail.Attachments != null && mail.Attachments.Length > 0)
                { 
                    foreach(var attachment in mail.Attachments)
                    {
                        using (var memoryStream = new MemoryStream())
                        {
                            ReadFileAttachment(attachment, memoryStream);
                            memoryStream.Seek(0, SeekOrigin.Begin);
                            var attached = new Attachment(memoryStream, attachment.FileName);
                            mailMessage.Attachments.Add(attached);
                        }
                    }
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

        private MemoryStream ReadFileAttachment(IFormFile attacment, MemoryStream memoryStream)
        {
            var bytes = new byte[4096];
            var bytesRead = 0;
            while((bytesRead = attacment.OpenReadStream().Read(bytes,0,bytes.Length)) > 0)
            {
                memoryStream.Write(bytes, 0, bytesRead);
            }
            return memoryStream;
        }
    }
}
