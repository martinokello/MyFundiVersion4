using MyFundi.Domain;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFundi.Domain
{
    public class User
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public Guid UserId { get; set; } 
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public string Email { get; set; }
        public string MobileNumber { get; set; }
        public string Token { get; set; }
        [ForeignKey("Company")]
        public int? CompanyId { get; set; }
        public Company Company { get; set; }
        public DateTime CreateTime { get; set; } = DateTime.Now;
        public DateTime LastLogInTime { get; set; } = DateTime.Now;
        public bool IsActive { get; set; }
        public bool IsLockedOut { get; set; }
    }
}
