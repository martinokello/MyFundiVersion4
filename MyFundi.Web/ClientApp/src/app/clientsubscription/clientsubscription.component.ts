import { Component, OnInit, Inject, AfterViewInit} from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IMtnAirTelModel, IWorkSubCategory, IWorkAndSubWorkCategory, ISubscription, IClientSubscription, IClientProfile, ISubscriptionFee } from '../../services/myFundiService';
import { Observable } from 'rxjs';
import { Router } from '@angular/router';
import { AfterViewChecked } from '@angular/core';
import { Pipe, PipeTransform } from '@angular/core';

import { ToFixedPipe } from '../../pipes/roundpipe';

declare var jQuery: any;

@Component({
    selector: 'clientsubscription',
    templateUrl: './clientsubscription.component.html'
})
export class ClientSubscriptionComponent implements OnInit,AfterViewInit {
    userDetails: any;
    userRoles: string[];
    subscriptionFee: number;
    subscription: IClientSubscription;
    subscriptionDescription: string;
    subscriptionName: string;
    clientLoginDetails: any = {};
    subscriptions: IClientSubscription[];
    setTo: NodeJS.Timeout;
    hasPopulatedPage: boolean = false;
    easyPayUrl: string = 'https://www.easypay.co.ug';

    constructor(private myFundiService: MyFundiService, private router: Router) {
        this.userDetails = {};
    }
    ngAfterViewInit(): void {

    }

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }

    initializeForm(): void {
        this.clientLoginDetails = JSON.parse(localStorage.getItem("ClientLoginDetails"));

        let clientSubs: Observable<IClientSubscription[]> = this.myFundiService.GetClientMonthlySubscriptions(this.clientLoginDetails.username);

        clientSubs.map((q: IClientSubscription[]) => {
            this.subscriptions = q;
            jQuery("select#clientSubscriptionId").append("<option value='0'>Select A Subscription</option>");


            for (let n = 0; n < this.subscriptions.length; n++) {
                jQuery("select#clientSubscriptionId").append("<option value='" + this.subscriptions[n].subscriptionId.toString() + "'>" + this.subscriptions[n].subscriptionName + "-" + this.formatDate(this.subscriptions[n].dateUpdated) + "</option>");
            }
            this.subscription = this.subscriptions[0];
            //let selector: HTMLSelectElement = document.querySelector('select#subscriptionId');

            //this.subscriptions.forEach((sub, index) => {
            //    selector.options.add(new Option(sub.subscriptionName, sub.subscriptionId.toString()));
            //});



            debugger;
            if (!this.subscription) {
                this.subscription = {
                    subscriptionId: 0,
                    clientProfileId: 0,
                    startDate: new Date(),
                    dateCreated: new Date(),
                    dateUpdated: new Date(),
                    username: this.clientLoginDetails.username,
                    hasPaid: false,
                    subscriptionName: this.clientLoginDetails.username + " 2 Weekly Client Subscription",
                    subscriptionDescription: this.clientLoginDetails.username + " 2 Weekly Client Subscription",
                    subscriptionFee: this.subscriptionFee
                }
            }
            let clientSubFee: Observable<any> = this.myFundiService.GetClientSubscriptionFee();
            clientSubFee.map(qn => {
                this.subscriptionFee = this.subscription.subscriptionFee = qn.clientSubscriptionFee;

            }).subscribe();
        }).subscribe();
    }
    ngOnInit(): void {

        this.initializeForm();
        let curthis = this;

        this.setTo = setInterval(this.runAutoCompleteOnSelects, 1000, curthis);
    }
    public paySubscriptionMonthlyFeeWithPaypal($event) {

        let subscriptionFeeExpenseToBePaid: IClientSubscription = this.subscription == null ?
        {
            subscriptionId: 0,
            clientProfileId: 0,
            startDate: new Date(),
            dateCreated: new Date(),
            dateUpdated: new Date(),
            username: this.clientLoginDetails.username,
            hasPaid: false,
            subscriptionName: this.clientLoginDetails.username + " 1 Weekly Client Subscription",
            subscriptionDescription: this.clientLoginDetails.username + " 1 Weekly Client Subscription",
            subscriptionFee: this.subscriptionFee
        } : this.subscription;
            
        let resultObs: Observable<any> = this.myFundiService.PayClientSubscriptionFeeWithPaypal(subscriptionFeeExpenseToBePaid);

        resultObs.map((q: any) => {
            if (q.payPalRedirectUrl.requestMessage.requestUri) {

                window.open(q.payPalRedirectUrl.requestMessage.requestUri);
                console.log('Response received');
                console.log(q.paypalUrl);
                alert("Payment made. Currently being processed by paypal service!\nYou will be informed once all is set up by email.");
            }
            else {
                alert("Paypal error happened. We are sorry something went bad. Please contact Admin");
            }
        }).subscribe();
        $event.preventDefault();
    }
    payClientSubscriptionFeeWithAirTel($event) {


        let subscriptionFeeExpenseToBePaid: IClientSubscription = this.subscription == null ?
            {
                subscriptionId: 0,
                clientProfileId: 0,
                startDate: new Date(),
                dateCreated: new Date(),
                dateUpdated: new Date(),
                username: this.clientLoginDetails.username,
                hasPaid: false,
                subscriptionName: this.clientLoginDetails.username + " 1 Weekly Client Subscription",
                subscriptionDescription: this.clientLoginDetails.username + " 1 Weekly Client Subscription",
                subscriptionFee: this.subscriptionFee
            } : this.subscription;

        let resultObs: Observable<any> = this.myFundiService.PayClientSubscriptionFeeWithAirTel(subscriptionFeeExpenseToBePaid);

        let easyPayWindow: HTMLIFrameElement = document.getElementById('clientEasyPayFrame') as HTMLIFrameElement;

        resultObs.map((q: any) => {

            if (q)
            {

                console.log('Response received');
                console.log(q);
                if (q.reasonPhrase) {
                    alert(q.reasonPhrase);
                }
                if (q.statusCode == "200") {
                    alert("Successfully Paid Subscription");
                }

                //var newMtnAirtelObject: any = {
                //    action: q.action,
                //    reason: q.reason,
                //    currency: q.currency,
                //    amount: q.amount,
                //    username: q.username,
                //    password: q.password,
                //    reference: q.reference,
                //    phone: q.phone
                //}

                //console.log('Response received: ' + q.mtnAirtelBaseUrl + `${q}`);

                //try {
                //    let easypayApiEndPoint = this.easyPayUrl + "/api";
                //    easyPayWindow.contentWindow.addEventListener('message', (event) => {
                //        console.log(JSON.stringify(event.data));
                //        debugger;
                //        alert(event.data);
                //    });
                //    easyPayWindow.contentWindow.postMessage(JSON.stringify(newMtnAirtelObject), easypayApiEndPoint);
                //    //jQuery(easyPayWindow.document.body).children().remove();
                //    alert("AirTel Payment made. Currently being processed by AirTel service!\nYou will be informed once all is set up by email.");
                //    //jQuery(easyPayWindow.document.body).html('<div class="container-fluid">' + "AirTel Payment made. Currently being processed by paypal service!\nYou will be informed once all is set up by email.</div>")
                //}
                //catch (ex) {
                //    console.log(ex);
                //    debugger;
                //    //jQuery(easyPayWindow.document.body).children().remove();
                //    alert(ex);
                //    //jQuery(easyPayWindow.document.body).html(ex);

                //}
                //finally {
                //    //easyPayWindow.close();
                //}
            }
            else {
                alert("AirTel error happened. We are sorry something went bad. Please contact Admin");
            }
        }).subscribe();
        $event.preventDefault();
    }
    payClientSubscriptionFeeWithMtn($event) {


        let subscriptionFeeExpenseToBePaid: IClientSubscription = this.subscription == null ?
            {
                subscriptionId: 0,
                clientProfileId: 0,
                startDate: new Date(),
                dateCreated: new Date(),
                dateUpdated: new Date(),
                username: this.clientLoginDetails.username,
                hasPaid: false,
                subscriptionName: this.clientLoginDetails.username + " 1 Weekly Client Subscription",
                subscriptionDescription: this.clientLoginDetails.username + " 1 Weekly Client Subscription",
                subscriptionFee: this.subscriptionFee
            } : this.subscription;

        let resultObs: Observable<any> = this.myFundiService.PayClientSubscriptionFeeWithAirTel(subscriptionFeeExpenseToBePaid);

        let easyPayWindow: HTMLIFrameElement = document.getElementById('clientEasyPayFrame') as HTMLIFrameElement;

        resultObs.map((q: any) => {

            if (q) {
                console.log('Response received');
                console.log(q);
                if (q.reasonPhrase) {
                    alert(q.reasonPhrase);
                }
                if (q.statusCode == "200") {
                    alert("Successfully Paid Subscription");
                }
        //let easyPayWindow: HTMLIFrameElement = document.getElementById('clientEasyPayFrame') as HTMLIFrameElement;

        //resultObs.map((q: IMtnAirTelModel) => {

        //    debugger;
        //    if (q.mtnAirtelBaseUrl) {

        //        var newMtnAirtelObject: any = {
        //            action: q.action,
        //            reason: q.reason,
        //            currency: q.currency,
        //            amount: q.amount,
        //            username: q.username,
        //            password: q.password,
        //            reference: q.reference,
        //            phone: q.phone
        //        }

        //        console.log('Response received: ' + q.mtnAirtelBaseUrl + `${q}`);

        //        try {
        //            let easypayApiEndPoint = this.easyPayUrl + "/api";
        //            easyPayWindow.contentWindow.addEventListener('message', (event) => {
        //                console.log(JSON.stringify(event.data));
        //                debugger;
        //                alert(event.data);
        //            });
        //            easyPayWindow.contentWindow.postMessage(JSON.stringify(newMtnAirtelObject), easypayApiEndPoint);
        //            //jQuery(easyPayWindow.document.body).children().remove();
        //            alert("MTN Payment made. Currently being processed by AirTel service!\nYou will be informed once all is set up by email.");
        //            //jQuery(easyPayWindow.document.body).html('<div class="container-fluid">' + "AirTel Payment made. Currently being processed by paypal service!\nYou will be informed once all is set up by email.</div>")
        //        }
        //        catch (ex) {
        //            console.log(ex);
        //            debugger;
        //            //jQuery(easyPayWindow.document.body).children().remove();
        //            alert(ex);
        //            //jQuery(easyPayWindow.document.body).html(ex);

        //        }
        //        finally {
        //            //easyPayWindow.close();
        //        }
            }
            else {
                alert("MTN error happened. We are sorry something went bad. Please contact Admin");
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
    subscriptionChange($event) {

        let clientSubs: Observable<IClientSubscription> = this.myFundiService.GetClientMonthlySubscriptionsById(this.clientLoginDetails.username,this.subscription.subscriptionId);

        clientSubs.map((q: IClientSubscription) => {
            this.subscription = q;
        }).subscribe();

    }
}

