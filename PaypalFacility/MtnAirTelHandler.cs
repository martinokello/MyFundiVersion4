using Microsoft.AspNetCore.Http;
using MyFundi.Domain;
using PaymentCalculater;
using System;
using System.Collections.Generic;
using System.Text;

namespace PaypalFacility
{
    public class MtnAirTelHandler
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
        private string phoneNumber;
        private string username;
        private string password;
        private DiscountCalculator _discountCalculator;
        private string currency;
        private string action;
        public HttpContext _HttpContext { get; set; }

        public MtnAirTelHandler(string baseUrl, string businessEmail, string successUrl, string cancelUrl, string notifyUrl, string buyerEmail,
            string phoneNumber, string username, string password, string currency, string action, DiscountCalculator discountCalculator)
        {
            this.baseUrl = baseUrl;
            this.hasBeenRedirected = false;
            this.businessEmail = businessEmail;
            this.successUrl = successUrl;
            this.cancelUrl = cancelUrl;
            this.notifyUrl = notifyUrl;
            this.buyerEmail = buyerEmail;
            this.phoneNumber = phoneNumber;
            this.currency = currency;
            this.action = action;
            this.username = username;
            this.password = password;
            _discountCalculator = discountCalculator;
        }

        public MtnAirTelModel RedirectToMtnAirTel(List<Product> productArray,Invoice invoice)
        {
            //fill In invoice Details

            _discountCalculator.TotalBought = productArray[0].Quantity;
            StringBuilder prodNames = new StringBuilder();

            foreach (var prod in productArray)
            {
                prodNames.Append(prod.ProductName + ";");
            }

            hasBeenRedirected = true;
            URLBuilder urlBuilder = new URLBuilder(businessEmail, successUrl, cancelUrl, notifyUrl, buyerEmail,invoice);
            string requestUrl = baseUrl;
            var mtnAirtelModel = new MtnAirTelModel
            {
                Action = this.action,
                Reason = "Payment For MyFundi Site Monthly Subscription",
                Currency = this.currency,
                Amount = invoice.Amount.ToString(),
                Username = username,
                Password = password,
                Reference = buyerEmail+": "+invoice.InvoiceNo,
                Phone= this.phoneNumber,
                MtnAirtelBaseUrl = this.baseUrl,
                NotifyUrl = this.NotifyUrl,
                CancelUrl = this.CancelUrl,
                SuccessUrl = this.successUrl
            };
            // urlBuilder.getFullCommandParameters();
            return mtnAirtelModel;
        }

        public bool HasBeenRequested
        {
            get { return hasBeenRedirected; }
            set { hasBeenRedirected = false; }
        }

        public string CancelUrl
        {
            get { return cancelUrl; }
            set { cancelUrl = value; }
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

