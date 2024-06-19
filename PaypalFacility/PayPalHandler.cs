using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.AspNetCore.Http;
using PaymentCalculater;

namespace PaypalFacility
{
    public class PayPalHandler
    {
        private bool hasBeenRedirected;
        private string baseUrl;
        private string notifyUrl;
        private string successUrl;
        private string cancelUrl;
        public Invoice invoice;
        private HttpResponse response = null;
        private string businessEmail = null;
        private string buyerEmail;
        private DiscountCalculator _discountCalculator;

        public HttpContext _HttpContext { get; set; }

        public PayPalHandler(string baseUrl, string businessEmail, string successUrl, string cancelUrl,string notifyUrl, string buyerEmail, DiscountCalculator discountCalculator)
        {
            this.baseUrl = baseUrl;
            this.hasBeenRedirected = false;
            this.businessEmail = businessEmail;
            this.successUrl = successUrl;
            this.cancelUrl = cancelUrl;
            this.notifyUrl = notifyUrl;
            this.buyerEmail = buyerEmail;
            _discountCalculator = discountCalculator;
        }

        public string RedirectToPayPal(List<Product> productArray)
        {
            //fill In invoice Details
            _discountCalculator.TotalBought = productArray[0].Quantity;

            StringBuilder prodNames = new StringBuilder();


            foreach (var prod in productArray)
            {
                prodNames.Append(prod.ProductName + ";");
            }

            if (productArray[0].Quantity < 3)
            {
                invoice = new Invoice(productArray, _discountCalculator.ApplyNoDealPrice(), buyerEmail);
            }
            else if (productArray[0].Quantity == 3)
            {
                invoice = new Invoice(productArray, _discountCalculator.ApplyBuy3Get1HalfPrice(), buyerEmail);
            }
            else if (productArray[0].Quantity > 3)
            {
                invoice = new Invoice(productArray, _discountCalculator.ApplyBuy4Get1Free(), buyerEmail);
            }


            hasBeenRedirected = true;
            URLBuilder urlBuilder = new URLBuilder(businessEmail, successUrl, cancelUrl, notifyUrl,buyerEmail,invoice);
            string requestUrl = baseUrl + urlBuilder.getFullCommandParameters();
            return requestUrl;
        }

        public bool HasBeenRequested
        {
            get { return hasBeenRedirected; }
            set { hasBeenRedirected = false; }
        }

        public string CancelUrl
        {
            get { return cancelUrl;  }
            set { cancelUrl=value; }
        }
        public string NotifyUrl
        {
            get { return notifyUrl; }
            set { notifyUrl = value; }
        }
        public string BuyerEmail
        {
            get { return buyerEmail; }
            set { buyerEmail = value; }
        }
    }
}
