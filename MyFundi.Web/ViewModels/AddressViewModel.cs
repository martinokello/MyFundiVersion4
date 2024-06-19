namespace MyFundi.Web.ViewModels
{
    public class AddressViewModel
    {
        public int AddressId { get; set; }
        public string AddressLine1 { get; set; }
        public string AddressLine2 { get; set; }
        public string Country { get; set; }
        public string Town { get; set; }
        public string PostCode { get; set; }
    }
}