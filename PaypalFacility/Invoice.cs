using System;
using System.Collections.Generic;

namespace PaypalFacility
{
    public class Invoice
    {
        private int invoiceNo;
        private List<Product> products;
        private string buyerEmail;
        private decimal amount;
        private decimal amountVAT;
        private const int beginGenerate = 1003;
        static private Random randomGenerator = new Random(DateTime.Now.Millisecond);

        public Invoice(List<Product> products, decimal amount, string buyerEmail)
        {
            this.products = products;
            this.amount = amount;
            this.buyerEmail = buyerEmail;
        }

        public long GenerateUniqueInvoiceNo()
        {
            invoiceNo = randomGenerator.Next(beginGenerate);
            return (long)invoiceNo;
        }

        public int InvoiceNo
        {
            get { return invoiceNo; }
            set { invoiceNo = value; }
        }

        public string BuyerEmail
        {
            get { return buyerEmail; }
            set { buyerEmail = value; }
        }


        public List<Product> Products
        {
            get { return products; }
            set { products = value; }
        }

        public decimal Ammount
        {
            get {
                decimal amount = 0.00M;
                foreach(var prod in Products)
                {
                    amount += prod.Amount;
                }
                return amount;
            }
            set { amount = value; }
        }

        public decimal AmountVAT
        {
            get { return amountVAT; }
            set { amountVAT = value; }
        }
        
        public IEnumerator<dynamic> GetEnumerator()
        {
            return products.GetEnumerator();
        }
    }
}
