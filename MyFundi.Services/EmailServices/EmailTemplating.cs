using MyFundi.Services.EmailServices.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;

namespace MyFundi.Services.EmailServices
{
    public class EmailTemplating
    {
        
        public string GetEmailTemplate(EmailTemplate emailTemplate)
        {
            switch (emailTemplate)
            {
                case EmailTemplate.ArrangeTransportScheduleMessage:
                    return @"Dear [[FirstName]],
                    
Our systems show you have made a recent purchase of commodities:
[[CommodiyName]]. It is good practice to set up a transport schedule for delivery of your products ordered.

Normally Transport schedules are carried out from within our site, however there is a choice for you to arrange your own transport means. However, you should  note that transport out of our ecosystems aren't monitored.

If you intend to use our own transport systems then please visit the schedule tab of our main navigation systems to generate a scheduling scheme.

Many thanks
MartinLayooInc Team.";
                case EmailTemplate.WelcomeMessage:
                    return @"Dear [[FirstName]],
                    
We would like to welcome you to the African Farmers Commodities site. The site offers ways to systematically buy or trade with very high secure means.

After registration you will be able to start using the site straight away.

Let's know your feedback, and if anything is not clear, contact us at our contacts page. We nomarly respond within 48 hours.

Many thanks
MartinLayooInc Team.";
                case EmailTemplate.InvoiceMessage:
                    return @"Dear [[FirstName]],
                    
We would like to let you know that the following transactions were created by yourself, within the African Farmers Commodities site.

[[TransactionCommoditesList]]

We take security concerns very highly. If you didn't make this transaction, then do please contact us immediately.

Otherwise, please note that payments take around 3 business days to clear on your accounts. Once payment is processed you will get an email to schedule transport for your commodities.

Many thanks
MartinLayooInc Team.";
                case EmailTemplate.TransactionFailureMessage:
                    return @"Dear [[FirstName]],
                    
We would like to let you know that the following transactions which were created by yourselves have failed. The products have not been cleared due to faiure of payments,


[[TransactionCommoditesList]]

We take security concerns very highly. If you didn't make this transaction, then do please contact us immediately.

Otherwise, please note that payments take around 3 business days to show up on your accounts. Once payment is processed you will get an email to schedule transport for your commodities.

Many thanks
MartinLayooInc Team.";
                case EmailTemplate.SuccessBuyCommodityMessage: 
                    return @"Dear [[FirstName]],
                    
We would like to let you know that the following transactions was successfully cleared successfully.


[[TransactionCommoditesList]]

We take security concerns very highly. If you didn't make this transaction, then do please contact us immediately.

Otherwise, please note that payments take around 3 business days to show up on your accounts. Once payment is processed you will get an email to schedule transport for your commodities.

Many thanks
MartinLayooInc Team.";
                case EmailTemplate.PasswordResetMessage:
                    return @"Dear [[FirstName]],
                    
We would like to let you know that you have requested your password to be reset.

Use this link to reset your password [[PasswordResetLink]].

Please not that you will get an email to reset password. Follow the instructions and reset your password.

We take security concerns very highly. If you didn't request password reset, then do please contact us immediately.

Otherwise,  please ignore this message

Many thanks
MartinLayooInc Team.";
            }
            return "";
        }
    }
}
