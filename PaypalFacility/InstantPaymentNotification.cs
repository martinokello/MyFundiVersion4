using System;
using System.Configuration;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Text;
using System.Web;
using System.Net;
using System.IO;
using System.Net.Mail;
using System.Data;
using System.Data.SqlClient;
using Microsoft.AspNetCore.Http;

namespace PaypalFacility
{
    public class InstantPaymentNotification
    {
        private HttpWebRequest httpWebRequest;
        private string accountEmail;
        private string clientEmail;
        private DateTime orderDate;
        private NameValueCollection form;

        public InstantPaymentNotification(string accountEmail, NameValueCollection form)
        {
            this.accountEmail = accountEmail;
            this.form = form;
        }

        public string ClientEmail
        {
            get { return clientEmail; }
            set { clientEmail = value; }
        }
        public DateTime OrderDate
        {
            get { return orderDate; }
            set { orderDate = value; }
        }
        public bool ProcessIPNResults(StreamWriter IPNWriter)
        {
            bool result = false;
            // *** Reload our invoice and try to match it

            // *** a real invoice

            int InvoiceNo = Int32.Parse(form["invoice"]);
            decimal amount = Convert.ToDecimal(form["mc_gross"]);
            clientEmail = null;
            int orderId = -1;
            var orderAmmount = new decimal();
            var Username = string.Empty;
            var Password = string.Empty;

            SqlDataReader reader = null;

            //Get Client Order from DB:
            using (var con = new SqlConnection(ConfigurationManager.ConnectionStrings["TeachersAssistant"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand("select * from [Order] where status = 'UnPaid' and orderId = " + InvoiceNo + " order by order_date desc", con);
                cmd.Connection = con;
                con.Open();
                reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    result = true;
                    orderId = (int)reader["orderId"];
                    OrderDate = (DateTime)reader["order_date"];
                    orderAmmount = (decimal)reader["order_gross"];
                    Username = (string)reader["username"];

                    break;
                }

                con.Close();
            }

            clientEmail = form["payer_email"];

            if (!form["business"].Equals(ConfigurationManager.AppSettings["BusinessEmail"])) result = false;

            if (orderId != InvoiceNo) result = false;

            if (orderAmmount != amount) result = false;

            // *** Send the response data back to PayPal for confirmation

            StringBuilder sbUrl = new StringBuilder();
            sbUrl.Append("cmd=_notify-validate");

            StringBuilder prodBuffer = new StringBuilder();
            string username = null;
            string buyerEmail = null;

            foreach (string postKey in form)
            {
                sbUrl.Append("&" + postKey + "=" + form[postKey]);
                if (postKey.StartsWith("item_")) prodBuffer.Append(form[postKey] + "_");
                if (postKey.StartsWith("buyer_email")) buyerEmail = form[postKey];
                if (postKey.StartsWith("username")) username = form[postKey];
            }

            string requestUriString = System.Configuration.ConfigurationManager.AppSettings["PaypalBaseUrl"];

            this.httpWebRequest = (HttpWebRequest)HttpWebRequest.Create(requestUriString);
            // Set values for the request back
            httpWebRequest.Method = "POST";
            httpWebRequest.ContentType = "application/x-www-form-urlencoded";
            httpWebRequest.Timeout = 10000;
            // *** Set properties



            //retrieve post string:

            byte[] lbPostBuffer = System.Text.Encoding.GetEncoding(1252).GetBytes(sbUrl.ToString());
            httpWebRequest.ContentLength = lbPostBuffer.Length;

            Stream loPostData = httpWebRequest.GetRequestStream();
            loPostData.Write(lbPostBuffer, 0, lbPostBuffer.Length);

            loPostData.Close();

            HttpWebResponse loWebResponse = (HttpWebResponse)httpWebRequest.GetResponse();

            Encoding enc = System.Text.Encoding.GetEncoding(1252);

            StreamReader loResponseStream = new StreamReader(loWebResponse.GetResponseStream(), enc);
            string verify = loResponseStream.ReadToEnd();

            loWebResponse.Close();
            loResponseStream.Close();

            IPNWriter.WriteLine(DateTime.Now.ToString("dd/MM/yyyy HH:mm") + ":  " + verify);
            IPNWriter.Flush();
            IPNWriter.Close();

            if (result)
            {
                //Send Confirmation Mail

                var emailPassword = System.Configuration.ConfigurationManager.AppSettings["emailPassword"];
                var smtpUsername = System.Configuration.ConfigurationManager.AppSettings["BusinessEmail"];
                var smtpClient = new SmtpClient(System.Configuration.ConfigurationManager.AppSettings["smtpServer"]);
                smtpClient.Credentials = new NetworkCredential { Password = emailPassword, UserName = smtpUsername };

                string downloadInstructions = String.Format("http://www.martinlayooinc.com/Home/DownloadPage?username={0}&status=Download&product={1}", System.Web.HttpUtility.UrlEncode(Username), System.Web.HttpUtility.UrlEncode(Encoding.GetEncoding(1252).GetBytes(prodBuffer.ToString()))); ;
                MailMessage message = new MailMessage(System.Configuration.ConfigurationManager.AppSettings["BusinessEmail"], clientEmail,
                    "Download Instructions!! Transaction Verification Passed", "Dear " + Username + ",\n\nIt has been confirmed that you have fully paid for the mentioned transaction. Your downloads have been enabled as a result.\n\nBelow is a link that will direct you to the download page.\n\n" + downloadInstructions + "\n\nHave fun and don't forget to check out products being realesed at http://www.martinlayooinc.com \n\nKindest regards\nMartin Okello.\nAka The Medallion");
                message.To.Add("martin.okello@martinlayooinc.com");
                message.To.Add("martinokello@martinlayooinc.com");
                message.To.Add(clientEmail);

                smtpClient.Send(message);
                //Get Client Order from DB:
                using (var con2 = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["TeachersAssistant"].ConnectionString))
                {
                    SqlCommand cmd = new SqlCommand(String.Format("Update [Order] set status = 'Paid' where status = 'UnPaid' and username = '{0}' and orderid= {2}", Username, Password, InvoiceNo), con2);
                    con2.Open();
                    cmd.ExecuteNonQuery();
                    con2.Close();
                }
            }
            return result;
        }


    }
}
