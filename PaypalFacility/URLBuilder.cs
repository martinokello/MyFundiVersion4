using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using System.Configuration;


namespace PaypalFacility
{
    public class URLBuilder
    {
        private System.Web.HttpUtility URLUtility = null;
        private string businessEmail;
        private string successUrl;
        private string cancelUrl;
        private string notifyUrl;
        private string clientEmail;
        private int invoiceNo;
        private Invoice invoice;

        public URLBuilder(string businessEmail, string successUrl, string cancelUrl, string notifyUrl, string clientEmail, Invoice invoice)
        {
            URLUtility = new HttpUtility();
            this.businessEmail = businessEmail;
            this.clientEmail = clientEmail;
            this.cancelUrl = cancelUrl;
            this.successUrl = successUrl;
            this.notifyUrl = notifyUrl;
            this.invoiceNo = invoice.InvoiceNo;
            this.invoice = invoice;
        }

        public string getFullCommandParameters()
        {
            StringBuilder sbUrl = new StringBuilder();
            sbUrl.Append("cmd=_cart&upload=1");
            sbUrl.AppendFormat("&business={0}",HttpUtility.UrlEncode(businessEmail));
            var index = 1;
            foreach (var prod in invoice.Products)
            {
                sbUrl.AppendFormat("&item_name_{0}={1}",index, HttpUtility.UrlEncode(prod.ProductName));
                sbUrl.AppendFormat("&quantity_{0}={1}", index, HttpUtility.UrlEncode(index.ToString()));
                sbUrl.AppendFormat("&amount_{0}={1}", index, HttpUtility.UrlEncode(invoice.Ammount.ToString()));
                sbUrl.AppendFormat("&invoice={0}", HttpUtility.UrlEncode(index.ToString()));
                index++;
            }

            sbUrl.AppendFormat("&amount={0}", index, HttpUtility.UrlEncode(invoice.Ammount.ToString()));
            sbUrl.AppendFormat("&return={0}&username={1}", HttpUtility.UrlEncode(successUrl), HttpUtility.UrlEncode(clientEmail));
            sbUrl.AppendFormat("&cancel_return={0}&username={1}", HttpUtility.UrlEncode(cancelUrl), HttpUtility.UrlEncode((string)clientEmail));
            sbUrl.AppendFormat("&notify_url={0}", HttpUtility.UrlEncode(notifyUrl));
            sbUrl.AppendFormat("&buyer_email={0}", HttpUtility.UrlEncode(clientEmail));
            return sbUrl.ToString();
        }
    }
}
