using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Web.ViewModels
{
    public class FundiProfileCourseTakenViewModel
    {
        public int FundiProfileCourseTakenId { get; set; }
        public int CourseId { get; set; }
        public int FundiProfileId { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
    }
    public class CourseUserTO
    {
        public int CourseId { get; set; }
        public string Username { get; set; }
    }
}
