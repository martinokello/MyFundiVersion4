using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace MyFundi.Domain
{
    public class UserRole
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public Guid UserRoleId { get; set; }
        [ForeignKey("User")]
        public Guid UserId { get; set; }
        public User User { get; set; }
        [ForeignKey("Role")]
        public Guid RoleId { get; set; }
        public Role Role { get; set; }
    }
}
