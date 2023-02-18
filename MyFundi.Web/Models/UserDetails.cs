namespace MyFundi.Web.Models
{
    public class UserDetails
    {
        public string username { get; set; }
        public string firstName { get; set; }
        public string lastName { get; set; }
        public string emailAddress { get; set; }
        public string mobileNumber { get; set; }
        public string password { get; set; }
        public string repassword { get; set; }
        public bool keepLoggedIn { get; set; }
        public string authToken { get; set; }
        public bool client { get; set; }
        public bool fundi { get; set; }
        public bool replaceMobileNumber { get; set; }
    }

    public class UserRole
    {
        public string role { get; set; }
        public string email { get; set; }

        public override bool Equals(object obj)
        {
            return this.role.ToLower().Equals(((UserRole)obj).role.ToLower());
        }
        public override int GetHashCode()
        {
            return this.role.Length;
        }
    }
    public class ResetPassword
    {
        public string Id { get; set; }
        public string Token { get; set; }
        public string Password { get; set; }
        public string Repassword { get; set; }
    }
}