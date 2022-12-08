using Microsoft.AspNetCore.Http;
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
        private string currency;
        private string action;
        public HttpContext _HttpContext { get; set; }

        public MtnAirTelHandler(string baseUrl, string businessEmail, string successUrl, string cancelUrl, string notifyUrl, string buyerEmail,
            string phoneNumber, string username, string password, string currency, string action)
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
        }

        public MtnAirTelModel RedirectToMtnAirTel(List<Product> productArray)
        {
            //fill In invoice Details

            StringBuilder prodNames = new StringBuilder();
            decimal amount = 0;
            foreach (var prod in productArray)
            {
                amount += prod.Amount;
                prodNames.Append(prod.ProductName + ";");
            }

            invoice = new Invoice(productArray, amount, buyerEmail);


            hasBeenRedirected = true;
            URLBuilder urlBuilder = new URLBuilder(businessEmail, successUrl, cancelUrl, notifyUrl, buyerEmail, invoice);
            string requestUrl = baseUrl;
            var mtnAirtelModel = new MtnAirTelModel
            {
                Action = this.action,
                Reason = "Payment For MyFundi Site Monthly Subscription",
                Currency = this.currency,
                Amount = invoice.Ammount.ToString(),
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

    public class MtnAirTelModel{

        public string Username { get; set; }
        public string Password { get; set; }
        public string Action { get; set; }
        public string Currency { get; set; }
        public string Amount { get; set; }
        public string Phone { get; set; }
        public string Reference { get; set; }
        public string Reason { get; set; }
        public string MtnAirtelBaseUrl { get; set; }
        public string CancelUrl { get; set; }
        public string SuccessUrl { get; set; }
        public string NotifyUrl { get; set; }
    }
}

