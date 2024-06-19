using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace MyFundi.Domain
{
    public class Blog
    {
        [Key]
        public int BlogId { get; set; }
        public string BlogName { get; set; }
        public string BlogContent { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
