import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IMtnAirTelModel, IWorkSubCategory, IWorkAndSubWorkCategory, ISubscription, IClientSubscription, IClientProfile } from '../../services/myFundiService';
import { Observable } from 'rxjs';
import { Router } from '@angular/router';
import { AfterViewChecked } from '@angular/core';
declare var jQuery: any;

@Component({
    selector: 'clientsubscription',
    templateUrl: './clientsubscription.component.html'
})
export class ClientSubscriptionComponent implements OnInit, AfterViewChecked {
    userDetails: any;
    userRoles: string[];
    subscriptionFee: number = 2000;
    subscriptionDescription: string;
    subscriptionName: string;
    clientLoginDetails: any = {};
    subscription: any;
    setTo: NodeJS.Timeout;
    hasPopulatedPage: boolean = false;

    constructor(private myFundiService: MyFundiService, private router:Router) {
        this.userDetails = {};
    }

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {
        this.clientLoginDetails = JSON.parse(localStorage.getItem("ClientLoginDetails"));
        debugger;
        
        this.subscription = {
            userId: "",
            firstName: this.clientLoginDetails.firstName,
            lastName: this.clientLoginDetails.lastName,
            startDate: this.formatDate(new Date()),
            username: this.clientLoginDetails.username,
            subscriptionFee: this.subscriptionFee,
            hasPaid: false,
            subscriptionName: this.clientLoginDetails.username+": Client Subscription",
            subscriptionDescription: this.clientLoginDetails.firstName + " " + this.clientLoginDetails.lastName  + ": Client Subscription"
        }

        let userIdObs: Observable<string> = this.myFundiService.GetUserGuidId(this.subscription.username);
        userIdObs.map((q: string) => {
            this.subscription.userId = q;
        }).subscribe();
    }
    public paySubscriptionMonthlyFeeWithPaypal($event) {

        let subscriptionFeeExpenseToBePaid: any = this.subscription;

        let resultObs: Observable<any> = this.myFundiService.PayClientSubscriptionFeeWithPaypal(subscriptionFeeExpenseToBePaid);

        resultObs.map((q: any) => {
            if (q.success) {
                console.log('Response received');
                alert("Payment made. Currently being processed by paypal service!\nOnce payment is confirmed you can login. You will be\ninformed once all is set up by email.");
                this.router.navigateByUrl('/login');
            }
            else {
                alert("Paypal error happened. We are sorry something went bad. Please contact Admin");
            }
            localStorage.removeItem("ClientLoginDetails");
        }).subscribe();
        $event.preventDefault();
    }
    payClientSubscriptionFeeWithAirTel($event) {

        let subscriptionFeeExpenseToBePaid: any = this.subscription;

        let resultObs: Observable<IMtnAirTelModel> = this.myFundiService.PayClientSubscriptionFeeWithAirTel(subscriptionFeeExpenseToBePaid);

        resultObs.map((q: IMtnAirTelModel) => {
            if (q.mtnAirtelBaseUrl) {
                //Requires POST Verb.
                //window.open(q.mtnAirTelBaseUrl);
                var newMtnAirtelObject: any = {
                    action: q.action,
                    reason: q.reason,
                    currency: q.currency,
                    amount: q.amount,
                    username: q.username,
                    password: q.password,
                    reference: q.reference,
                    phone: q.phone
                }

                console.log('Response received: ' + q.mtnAirtelBaseUrl);
                let resObs: Observable<any> = this.myFundiService.postToMtnAirtelApi(q.mtnAirtelBaseUrl, newMtnAirtelObject);

                resObs.map((q: any) => {
                    console.log("Was Successful: " + q.success);
                    console.log("Result Data: " + q.data);

                    if (q.success) {
                        alert("Payment made. Currently being processed by Airtel service!\nOnce payment is confirmed you can login. You will be\ninformed once all is set up by email.");

                        this.router.navigateByUrl("/login");
                    }
                    else {
                        alert("Payment Failed!!")
                    }
                }).subscribe();
            }
            else {
                alert("MTN or AirTel error happened. We are sorry something went bad. Please contact Admin");
            }
        }).subscribe();
        $event.preventDefault();
    }
    payClientSubscriptionFeeWithMtn($event) {

        let subscriptionFeeExpenseToBePaid: any = this.subscription;

        let resultObs: Observable<IMtnAirTelModel> = this.myFundiService.PayClientSubscriptionFeeWithAirTel(subscriptionFeeExpenseToBePaid);

        resultObs.map((q: IMtnAirTelModel) => {

            if (q.mtnAirtelBaseUrl) {
                //Requires POST Verb.
                //window.open(q.mtnAirTelBaseUrl);
                var newMtnAirtelObject: any = {
                    action: q.action,
                    reason: q.reason,
                    currency: q.currency,
                    amount: q.amount,
                    username: q.username,
                    password: q.password,
                    reference: q.reference,
                    phone: q.phone
                }

                console.log('Response received: ' + q.mtnAirtelBaseUrl);
                let resObs: Observable<any> = this.myFundiService.postToMtnAirtelApi(q.mtnAirtelBaseUrl, newMtnAirtelObject);

                resObs.map((q: any) => {
                    console.log("Was Successful: " + q.success);
                    console.log("Result Data: " + q.data);

                    if (q.success) {
                        alert("Payment made. Currently being processed by MTN service!\nOnce payment is confirmed you can login. You will be\ninformed once all is set up by email.");

                        this.router.navigateByUrl("/login");
                    }
                    else {
                        alert("Payment Failed!!")
                    }                }).subscribe();
            }
            else {
                alert("MTN or AirTel error happened. We are sorry something went bad. Please contact Admin");
            }
        }).subscribe();
        $event.preventDefault();
    }
    formatDate(date): string {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;

        return [year, month, day].join('-');
    }

    runAutoCompleteOnSelects(curthis: any) {
        debugger;
        let hasFoundSelectsOnPage = false;

        if (!curthis.hasPopulatedPage) {

            let selects = jQuery('div#clientSubscription-wrapper select');

            if (selects && selects.length > 0) {
                hasFoundSelectsOnPage = true;
            }

            if (hasFoundSelectsOnPage) {

                jQuery(selects.each((ind, elem) => {
                    jQuery(elem).parent('ul').css('background', 'white');
                    jQuery(elem).parent('ul').css('z-index', '100');
                    let id = 'autoComplete' + jQuery(elem).attr('id');
                    jQuery(elem).parent('div').prepend("<input type='text' placeholder='Search dropdown' id=" + `${id}` + " /><br/>");

                }));
                hasFoundSelectsOnPage = false;
            }

            //Check For Dom Change and Add auto complete to select elements
            debugger;
            jQuery('div#clientSubscription-wrapper select').each((ind, sel) => {
                let options = jQuery(sel).children('option');

                let vals = [];
                jQuery(options).each((id, el) => {
                    let optionText = jQuery(el).html();
                    vals.push(optionText);
                });
                //options is source of auto complete:
                let jQueryinpId = jQuery('input#autoComplete' + jQuery(sel).attr('id'));
                jQueryinpId.autocomplete({ source: vals });
                jQuery(document).on('click', '.ui-menu .ui-menu-item-wrapper', function (event) {
                    jQuery('select#' + jQuery(sel).attr('id')).find("option").filter(function () {
                        return jQuery(event.target).text() == jQuery(this).html();
                    }).attr("selected", true);
                });
            });

            curthis.hasPopulatedPage = true;
            clearTimeout(curthis.setTo);
        }
    }
    ngAfterViewChecked() {
        let curthis = this;

        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
}

