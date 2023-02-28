using System;
using System.Collections.Generic;
using System.Text;

namespace PaymentCalculater
{
    public class DiscountCalculator
    {
        public enum DealPricing { NoDealPrice, Buy3Get1HalfPrice, Buy4Get1Free};
        private decimal _unitPrice;
        public DiscountCalculator(decimal unitPrice)
        {
            _unitPrice = unitPrice;
        }
        public int TotalBought { get; set; }
        public decimal ApplyNoDealPrice()
        {
            return _unitPrice * TotalBought;
        }
        public decimal ApplyBuy3Get1HalfPrice()
        {
            return _unitPrice * TotalBought - _unitPrice / 2;
        }
        public decimal ApplyBuy4Get1Free()
        {
            return _unitPrice * TotalBought - _unitPrice;
        }
    }
}
