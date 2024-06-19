using Microsoft.Extensions.Options;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using MyFundi.AppConfigurations;
using Microsoft.AspNetCore.Http;
using MailKit.Net.Smtp;
using MimeKit;
using MimeKit.Text;

namespace MyFundi.Services.EmailServices.Concretes
{
    public class EmailService : IMailService
    {
        public IConfigurationSection _businessSmtpDetails;
        public EmailService(IConfiguration configuration)
        {
            _businessSmtpDetails = configuration.GetSection("BusinessEmailDetails");
        }

        public IConfigurationSection BusinessEmailDetails
        {
            set { _businessSmtpDetails = value; }
            get { return _businessSmtpDetails; }
        }
        public string GetTemplate(EmailTemplate template)
        {
            throw new NotImplementedException();
        }

        public void SendEmail(EmailDao mail)
        {
            MemoryStream memoryStream = null;
            List<MemoryStream> memoryStreams = new List<MemoryStream>();
            var smtpServer = new SmtpClient();
            try
            {
                //Send Email:
                smtpServer.Connect(_businessSmtpDetails.GetSection("SmtpServer").Value);
                var mailMessage = new MimeMessage();


                mailMessage.Subject = @"From " + mail.EmailFrom + " " + mail.EmailSubject;

                mailMessage.From.Add(MailboxAddress.Parse(_businessSmtpDetails.GetSection("BusinessEmail").Value));

                if (mail.Attachment != null)
                {
                    //memoryStream = ReadFileAttachment(mail.Attachment, new MemoryStream());

                    // create an image attachment for the file located at path


                    // now create the multipart/mixed container to hold the message text and the
                    // image attachment
                    var multipart = new Multipart("mixed");
                    multipart.Add(new TextPart(TextFormat.Html) { Text = mail.EmailBody });

                    var mimiPart = AddAttachment(mail.Attachment);

                    multipart.Add(mimiPart);

                    // now set the multipart/mixed as the message body
                    mailMessage.Body = multipart;
                }
                if (mail.Attachments != null && mail.Attachments.Count > 0)
                {
                    var multipart = new Multipart("mixed");
                    foreach (var attach in mail.Attachments)
                    {

                        //memoryStream = ReadFileAttachment(mail.Attachment, new MemoryStream());
                        //memoryStreams.Add(memoryStream);

                        // create an image attachment for the file located at path
                        var mimiPart = AddAttachment(attach);

                        multipart.Add(mimiPart);

                    }
                    multipart.Add(new TextPart(TextFormat.Html) { Text = mail.EmailBody });
                    // now set the multipart/mixed as the message body
                    mailMessage.Body = multipart;
                }
                mail.EmailTo += string.Format(";{0}", _businessSmtpDetails.GetSection("BusinessEmail").Value);
                Array.ForEach<string>(mail.EmailTo.Split(new char[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries), (p) =>
                {
                    mailMessage.To.Add(MailboxAddress.Parse(p));
                });
                
                smtpServer.Authenticate(_businessSmtpDetails.GetSection("NetworkUsername").Value, _businessSmtpDetails.GetSection("NetworkPassword").Value);
                smtpServer.Send(mailMessage);
            }
            catch
            {
                throw;
            }
            finally
            {
                smtpServer.Disconnect(true);
                if (memoryStream != null)
                {
                    memoryStream.Dispose();
                }
                if(memoryStreams.Count > 0)
                {
                    foreach(var memStrm in memoryStreams)
                    {
                        memStrm.Dispose();
                    }
                }
            }
        }

        private MimePart AddAttachment(IFormFile attach)
        {
            var attachment = new MimePart("octet", attach.FileName.Substring(attach.FileName.LastIndexOf(".") + 1))
            {
                Content = new MimeContent(attach.OpenReadStream()),
                ContentDisposition = new ContentDisposition(ContentDisposition.Attachment),
                ContentTransferEncoding = ContentEncoding.Default,
                FileName = attach.FileName
            };

            // now create the multipart/mixed container to hold the message text and the
            // image attachment
            return attachment;
        }

        private MemoryStream ReadFileAttachment(IFormFile attacment, MemoryStream memoryStream)
        {
            var bytes = new byte[4096];
            var bytesRead = 0;
            while ((bytesRead = attacment.OpenReadStream().Read(bytes, 0, bytes.Length)) > 0)
            {
                memoryStream.Write(bytes, 0, bytesRead);
                memoryStream.Flush();
            }
            memoryStream.Position = 0;
            return memoryStream;
        }
    }
}
