using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class FundiRatingAndReview   
    {
        [Key]
        public int FundiRatingAndReviewId { get; set; }
        [ForeignKey("User")]
        public Guid UserId { get; set; }
        public User User { get; set; }
        public int Rating { get; set; }
        public string Review { get; set; }
        [ForeignKey("FundiProfile")]
        public int FundiProfileId { get; set; }
        public FundiProfile FundiProfile { get; set; }
        public DateTime DateCreated { get; set; } = DateTime.Now;
        public DateTime DateUpdated { get; set; } = DateTime.Now;
        public string WorkCategoryType { get; set; }
    }
}
