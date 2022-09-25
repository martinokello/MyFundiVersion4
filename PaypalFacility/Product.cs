using System;

namespace PaypalFacility
{
    public class Product
    {
        private decimal ammount;
        private decimal ammountVAT;
        private string prodName;
        private string prodDescription;
        private int quantity;


        public Product()
        {
            
        }
        public bool HasPaidInfull { get; set; }
        public int Quantity
        {
            get { return quantity; }
            set { quantity = value; }
        }
        public decimal Amount
        {
            get { return ammount; }
            set { ammount = value; }
        }
        public decimal VATAmmount
        {
            get { return ammountVAT; }
            set { ammountVAT = value; }
        }

        public string ProductName
        {
            get { return prodName; }
            set { prodName = value; }
        }

        public string ProductDescription
        {
            get { return prodDescription; }
            set { prodDescription = value; }
        }
    }
}
