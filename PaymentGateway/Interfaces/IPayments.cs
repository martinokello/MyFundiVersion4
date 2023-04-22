using MyFundi.Domain;
using PaypalFacility;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PaymentsGateway.Interfaces
{
    public interface IPayments
    {
        Task<string> MakePaymentsPaypal(string username, List<Product> products);
        Task<MtnAirTelModel> MakePaymentsMtnAirTel(string username, List<Product> products,PaypalFacility.Invoice invoice);
        Task<string> MakePaymentByCreditFacilities(string username, List<Product> products, PaypalFacility.Invoice invoice);
    }
}
