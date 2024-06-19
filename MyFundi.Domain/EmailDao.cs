using Microsoft.AspNetCore.Http;
using System;
using System.IO;

namespace MyFundi.Domain
{
    public class EmailDao { 
        public string EmailBody { get; set; }
        public string EmailSubject { get; set; }
        public string EmailTo { get; set; }
        public string EmailFrom { get; set; }
        public IFormFile Attachment { get; set; }
        public IFormFileCollection Attachments { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
