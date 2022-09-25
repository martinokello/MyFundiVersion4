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
        Task<string> MakePayments(string username, List<Product> products);
        Task<string> MakePaymentByCreditFacilities(string username, List<Product> products);
    }
}
