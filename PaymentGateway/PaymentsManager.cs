using MyFundi.Domain;
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
        public MonthlySubscription[] MonthlySubscription { get; set; }

        public PaymentsManager(PayPalHandler paypalHandler)
        {
            _PayPalHandler = paypalHandler;
            //_monthlySubscription = monthlySubscription;
        }
        public async Task<string> MakePayments(string username,List<Product> products)
        {
            _PayPalHandler.BuyerEmail = username;

            var requestUrl = _PayPalHandler.RedirectToPayPal(products);
            //HttpClient httpClient = new HttpClient();
            //Send request to Paypal: Response is handled by IPN Notification class later on.
            //await httpClient.SendAsync(new HttpRequestMessage { RequestUri = new Uri(requestUrl)});
            return await Task.FromResult(requestUrl);
        }
        public Task<string> MakePaymentByCreditFacilities(string username, List<Product> products)
        {
            throw new NotImplementedException("Currently not supported!");
        }
    }
}
