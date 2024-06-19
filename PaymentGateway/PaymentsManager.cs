using MyFundi.Domain;
using Newtonsoft.Json;
using PaymentsGateway.Interfaces;
using PaypalFacility;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;

namespace PaymentGateway
{
    public class PaymentsManager : IPayments
    {

        private PayPalHandler _PayPalHandler;
        private MtnAirTelHandler _MtnAirTelHandler;
        public MonthlySubscription[] MonthlySubscription { get; set; }

        public PaymentsManager(PayPalHandler paypalHandler, MtnAirTelHandler mtnAirTelHandler)
        {
            _PayPalHandler = paypalHandler;
            _MtnAirTelHandler = mtnAirTelHandler;
        }
        public async Task<HttpResponseMessage> MakePaymentsPaypal(string username,List<Product> products)
        {
            _PayPalHandler.BuyerEmail = username;
            
            var requestUrl = _PayPalHandler.RedirectToPayPal(products);
            HttpClient httpClient = new HttpClient();
            //Send request to Paypal: Response is handled by IPN Notification class later on.
            var response = await httpClient.SendAsync(new HttpRequestMessage { RequestUri = new Uri(requestUrl)});
            //Client will make a non cors request with returned requestUrl
            return await Task.FromResult(response);
        }
        public async Task<HttpResponseMessage> MakePaymentsMtnAirTel(string username, List<Product> products, PaypalFacility.Invoice invoice)
        {
            _MtnAirTelHandler.BuyerEmail = username;

            var requestObject = _MtnAirTelHandler.RedirectToMtnAirTel(products,invoice);
            var jsonTxtContent = JsonConvert.SerializeObject(requestObject);

            HttpClient httpClient = new HttpClient();

            //Send request to Paypal: Response is handled by IPN Notification class later on.
            var resp = await httpClient.PostAsync(requestObject.MtnAirtelBaseUrl,new StringContent(jsonTxtContent));
            //Client will make a non cors request with returned requestUrl
            return await Task.FromResult(resp);
        }
        
        public Task<string> MakePaymentByCreditFacilities(string username, List<Product> products, PaypalFacility.Invoice invoice)
        {
            throw new NotImplementedException("Currently not supported!");
        }
    }
}
