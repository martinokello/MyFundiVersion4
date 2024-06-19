using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class Answer
    {
        public int AnswerId { get; set; }
        [ForeignKey("Question")]
        public int QuestionId { get; set; }
        public string AnswerContent { get; set; }
        [ForeignKey("FundiProfile")]
        public int FundiProfileId { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
}
