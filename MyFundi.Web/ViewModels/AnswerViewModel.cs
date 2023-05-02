using System.ComponentModel.DataAnnotations.Schema;

namespace MyFundi.Web.ViewModels
{
    public class AnswerViewModel
    {
        public int AnswerId { get; set; }
        public int QuestionId { get; set; }
        public string AnswerContent { get; set; }
        public int FundiProfileId { get; set; }
    }
}
