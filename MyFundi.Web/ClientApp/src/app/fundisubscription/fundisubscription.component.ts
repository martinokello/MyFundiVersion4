import { Component, OnInit, Inject, AfterViewChecked, AfterViewInit } from '@angular/core';
import { Pipe, PipeTransform } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IMtnAirTelModel, IWorkSubCategory, IWorkAndSubWorkCategory, ISubscription } from '../../services/myFundiService';
import { Observable } from 'rxjs';
import { Router } from '@angular/router';
declare var jQuery: any;

@Component({
    selector: 'fundisubscription',
    templateUrl: './fundisubscription.component.html'
})
export class FundiSubscriptionComponent implements OnInit, AfterViewInit, AfterViewChecked {
    userDetails: any;
    userRoles: string[];
    location: ILocation;
    subscriptionFee: number = 5;
    subscriptionDescription: string;
    subscriptionName: string;
    startDate: string;
    fundi: any = {};
    public workCategories: IWorkCategory[];
    public workCategory: IWorkCategory | any;
    public workSubCategory: IWorkSubCategory | any;
    public workSubCategories: IWorkSubCategory[];
    subscriptionFeeExpense: ISubscription;
    subscription: ISubscription;
    setTo: NodeJS.Timeout;
    easyPayUrl: string = 'https://www.easypay.co.ug';
    hasPopulatedPage: boolean = false;

    constructor(private myFundiService: MyFundiService, private router: Router) {
        this.userDetails = {};
    }
    ngAfterViewInit(): void {

    }

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {

        this.workCategory = { workCategoryId: 0 };
        this.workCategories = [];

        this.workSubCategory = {
            workSubCategoryId: 0,
            workCategoryId: 0,
            workSubCategoryType: "",
            workSubCategoryDescription: ""
        };


        this.workCategory = {
            workCategoryId: 0,
            workCategoryType: "",
            workCategoryDescription: ""
        };
        this.workSubCategories = [];

        let workCategoriesObs: Observable<IWorkCategory[]> = this.myFundiService.GetWorkCategories();
        workCategoriesObs.map((wcs: IWorkCategory[]) => {
            this.workCategories = wcs;
            wcs.forEach((c: IWorkCategory, index: number, wcs) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = c.workCategoryId.toString();
                optionElem.text = c.workCategoryType;
                document.querySelector('select#subcworkCategoryId').append(optionElem);
            });

            let selectedWorkCatId = parseInt(jQuery('select#subcworkCategoryId > option:selected').val());
            debugger;
            let workSubCategoriesObs = this.myFundiService.GetAllFundiWorkSubCategoriesByWorkCategoryId(selectedWorkCatId);

            workSubCategoriesObs.map((wcs: IWorkSubCategory[]) => {
                this.workSubCategories = wcs;;
                wcs.forEach((c: IWorkSubCategory, index: number, wcs) => {
                    let optionElem: HTMLOptionElement = document.createElement('option');
                    optionElem.value = c.workSubCategoryId.toString();
                    optionElem.text = c.workSubCategoryType;
                    document.querySelector('select#subcworkSubCategoryId').append(optionElem);
                });
            }).subscribe();
        }).subscribe();
        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        if (!this.userDetails) this.userDetails = {};
        if (!this.userDetails.username) {
            this.userDetails.username = MyFundiService.clientEmailAddress;
        }
        this.subscription = this.subscriptionFeeExpense = {
            monthlySubscriptionId: 0,
            userId: this.fundi.userId,
            fundiProfileId: this.fundi.fundiProfileId,
            startDate: new Date(),
            username: this.userDetails.username,
            subscriptionFee: this.fundi.subscriptionFee,
            hasPaid: false,
            subscriptionName: this.fundi.subscriptionName,
            subscriptionDescription: this.fundi.subscriptionDescription,
            workCategoryAndSubCategoryIds: []
        }
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        let resObs = this.myFundiService.GetFundiProfile(this.userDetails.username);

        resObs.map((fundiProf: IProfile) => {
            if (!fundiProf) {
                alert('Fundi need mandatory Profiles. \nPlease create and Save your Fundi Profile!!');
                this.router.navigateByUrl('/manage-profile');
                return;
            }
            else {

                this.fundi = fundiProf;
                this.fundi.subscriptionFee = this.subscriptionFee;
                this.fundi.subscriptionName = `Fundi User ${this.userDetails.firstName} ${this.userDetails.lastName} Subscription for 31 days`;
                this.fundi.subscriptionDescription = "Attempting Monthly Payment!";


                let userIdObs: Observable<string> = this.myFundiService.GetUserGuidId(this.userDetails.username);
                userIdObs.map((q: string) => {
                    this.fundi.userId = q;
                    let subscrObs: Observable<ISubscription[]> = this.myFundiService.GetAllFundiSubscriptions(this.fundi.fundiProfileId);
                    subscrObs.map((subs: ISubscription[]) => {
                        let opt: HTMLOptionElement = document.createElement('option');
                        opt.value = "0";
                        opt.text = "Select Month Subscription";
                        let subscrSelect = document.querySelector('div#fundiSubscription-wrapper select#subscriptionId');
                        subscrSelect.appendChild(opt);
                        if (subs.length > 0) {
                            this.subscriptionFeeExpense = this.subscription = subs[0];
                            this.fundi.subscriptionFee = this.subscription.subscriptionFee;
                            this.startDate = this.formatDate(subs[0].startDate);
                            this.appendCategoriesAndSubCategoriesToUi();
                        }
                        else {
                            let dateNow = new Date();
                            this.startDate = this.formatDate(dateNow);
                            this.subscription = this.subscriptionFeeExpense;
                            this.subscription.monthlySubscriptionId = 0;
                        }
                        subs.forEach((sub: ISubscription, ind: number) => {

                            let opt1: HTMLOptionElement = document.createElement('option');
                            opt1.value = sub.monthlySubscriptionId.toString();
                            opt1.text = sub.subscriptionName + "-#" + sub.subscriptionFee + "# " + this.formatDate(sub.startDate);
                            subscrSelect.appendChild(opt1);
                        });
                        if(subs.length > 0)
                            this.fundi.subscriptionFee = subs[subs.length - 1].subscriptionFee;
                        else
                            this.fundi.subscriptionFee = 0;
                    }).subscribe();
                }).subscribe();
            }
        }).subscribe();
    }
    public getWorkSubCategoriesByWorkCategoryId($event) {
        let workSubCategoriesObs = this.myFundiService.GetAllFundiWorkSubCategoriesByWorkCategoryId(this.workCategory.workCategoryId);

        workSubCategoriesObs.map((wcs: IWorkSubCategory[]) => {
            //clear the workCategory options menu and add new options:
            jQuery('select#subcworkSubCategoryId option').remove();

            this.workSubCategories = wcs;
            wcs.forEach((c: IWorkSubCategory, index: number, wcs) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = c.workSubCategoryId.toString();
                optionElem.text = c.workSubCategoryType;
                document.querySelector('select#subcworkSubCategoryId').append(optionElem);
            });
        }).subscribe();
    }
    public selectworkSubCategory($event): void {
        let workSubCatValue: number = this.workSubCategory.workSubCategoryId;
        let actualResult: Observable<any> = this.myFundiService.GetworkSubCategoryById(workSubCatValue);
        actualResult.map((p: any) => {

            this.workSubCategory = p;
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
        $event.preventDefault();
    }
    public addSubCategory($event) {
        let indexWorkCatToRemove: number;

        let selWorkCat = jQuery('select#subcworkCategoryId > option:selected').val();
        let selWorkSubCat = jQuery('select#subcworkSubCategoryId > option:selected').val();

        let chosenCategory = this.subscriptionFeeExpense.workCategoryAndSubCategoryIds.find((q, index) => {
            indexWorkCatToRemove = index;
            return q.workCategoryId == selWorkCat;
        })
        if (chosenCategory) {
            let indexWorkSubCatToRemove: number;
            let chosenWorkSubCatId = chosenCategory.workSubCategoryIds.find((q, index) => {
                indexWorkSubCatToRemove = index;
                return q == selWorkSubCat;
            });
            if (chosenWorkSubCatId) {
                return;
            }
            else {

                let selWorkCat = jQuery('select#subcworkCategoryId > option:selected').val();
                let selWorkSubCat = jQuery('select#subcworkSubCategoryId > option:selected').val();

                this.subscriptionFeeExpense.workCategoryAndSubCategoryIds[indexWorkCatToRemove].workSubCategoryIds.push(selWorkSubCat);

                let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
                let li = document.createElement("li");
                li.setAttribute('id', `${selWorkCat},${selWorkSubCat}`);

                li.textContent = jQuery('select#subcworkCategoryId > option:selected').text() + ` :[${jQuery('select#subcworkSubCategoryId > option:selected').text()}]`;
                ulSelectedCategories.appendChild(li);
            }
        }
        else {
            let workCategorySubCatIds: any[] = [];
            let selWorkCat = jQuery('select#subcworkCategoryId > option:selected').val();
            let selWorkSubCat = jQuery('select#subcworkSubCategoryId > option:selected').val();

            workCategorySubCatIds.push(selWorkSubCat);
            this.subscriptionFeeExpense.workCategoryAndSubCategoryIds.push({
                workCategoryId: selWorkCat, workSubCategoryIds: workCategorySubCatIds
            });
            let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
            let li = document.createElement("li");
            li.setAttribute('id', `${selWorkCat},${selWorkSubCat}`);

            li.textContent = jQuery('select#subcworkCategoryId > option:selected').text() + ` :[${jQuery('select#subcworkSubCategoryId > option:selected').text()}]`;
            ulSelectedCategories.appendChild(li);
        }
        $event.preventDefault();
    }
    appendCategoriesAndSubCategoriesToUi() {
        let curThis = this;
        let ulSelectedCategories = document.querySelector('div#fundiSubscription-wrapper ul#ulistWorkCategories');

        jQuery('div#fundiSubscription-wrapper ul#ulistWorkCategories').children('li').remove();

        for (let n = 0; n < this.subscriptionFeeExpense.workCategoryAndSubCategoryIds.length; n++) {
            jQuery('select#subcworkCategoryId').val(curThis.subscriptionFeeExpense.workCategoryAndSubCategoryIds[n].workCategoryId.toString()).trigger('change');

            for (let s = 0; s < curThis.subscriptionFeeExpense.workCategoryAndSubCategoryIds[n].workSubCategoryIds.length; s++) {

                var res = this.myFundiService.GetworkSubCategoryById(parseInt(this.subscriptionFeeExpense.workCategoryAndSubCategoryIds[n].workSubCategoryIds[s])).toPromise()
                    .then((q: IWorkSubCategory) => {

                        let li = document.createElement("li");
                        li.setAttribute('id', `${this.subscriptionFeeExpense.workCategoryAndSubCategoryIds[n].workCategoryId.toString()},${this.subscriptionFeeExpense.workCategoryAndSubCategoryIds[n].workSubCategoryIds[s].toString()}`);

                        li.textContent = jQuery('select#subcworkCategoryId > option[value="' + this.subscriptionFeeExpense.workCategoryAndSubCategoryIds[n].workCategoryId + '"]').text() +
                            ` [${q.workSubCategoryType}]`;
                        ulSelectedCategories.appendChild(li);
                    });

            }
        }
    }
    removeWorkSubCategory($event) {

        let indexWorkCatToRemove: number;

        let selWorkCat = jQuery('select#subcworkCategoryId > option:selected').val();
        let selWorkSubCat = jQuery('select#subcworkSubCategoryId > option:selected').val();

        let chosenCategory = this.subscriptionFeeExpense.workCategoryAndSubCategoryIds.find((q, index) => {
            indexWorkCatToRemove = index;
            return q.workCategoryId == selWorkCat;
        })
        if (chosenCategory) {
            let indexWorkSubCatToRemove: number;
            let chosenWorkSubCatId = chosenCategory.workSubCategoryIds.find((q, index) => {
                indexWorkSubCatToRemove = index;
                return q == selWorkSubCat;
            });
            if (chosenWorkSubCatId) {
                let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
                let li = document.querySelector('ul#ulistWorkCategories > li[id="' + `${selWorkCat},${selWorkSubCat}` + '"]');

                ulSelectedCategories.removeChild(li);

                this.subscriptionFeeExpense.workCategoryAndSubCategoryIds[indexWorkCatToRemove].workSubCategoryIds.splice(indexWorkSubCatToRemove, 1);
                if (this.subscriptionFeeExpense.workCategoryAndSubCategoryIds[indexWorkCatToRemove].workSubCategoryIds.length == 0) {
                    this.subscriptionFeeExpense.workCategoryAndSubCategoryIds.splice(indexWorkCatToRemove, 1);
                }
            }
        }

        $event.preventDefault();
    }
    public selectSubscription($event) {

        let subObs: Observable<ISubscription> = this.myFundiService.GetFundiSubscription(this.subscription.monthlySubscriptionId);
        subObs.map((q: ISubscription) => {
            this.subscription = this.subscriptionFeeExpense = q;
            this.fundi.subscriptionFee = this.subscription.subscriptionFee;
            this.startDate = this.formatDate(q.startDate);
            this.appendCategoriesAndSubCategoriesToUi();
        }).subscribe();
        $event.preventDefault();
    }
    public updateSubscription($event) {
        let subObs: Observable<any> = this.myFundiService.UpdateFundiSubscription(this.subscription);
        subObs.map((q: any) => {
            if (q && q.result) {
                alert(q.message);
            }
        }).subscribe();
        $event.preventDefault();
    }
    public deleteSubscription($event) {

        let subObs: Observable<any> = this.myFundiService.DeleteFundiSubscription(this.subscription.monthlySubscriptionId);
        subObs.map((q: any) => {
            if (q && q.result) {
                alert(q.message);
            }
        }).subscribe();
        $event.preventDefault();
    }
    public checkFundiProfileExists(): boolean {
        if (!this.fundi.fundiProfileId) {
            alert('Fundi need mandatory Profiles. \nPlease create and Save your Fundi Profile!!');
            return false;
        }
        return true;
    }
    public paySubscriptionMonthlyFeeWithPaypal($event) {
        if (!this.checkFundiProfileExists()) {
            this.router.navigateByUrl('/manage-profile');
            return;
        }
        let subscriptionFeeExpenseToBePaid: ISubscription = {
            monthlySubscriptionId: 0,
            userId: this.fundi.userId,
            fundiProfileId: this.fundi.fundiProfileId,
            startDate: new Date(),
            username: this.userDetails.username,
            subscriptionFee: this.fundi.subscriptionFee,
            hasPaid: false,
            subscriptionName: this.userDetails.username + "-" + this.fundi.subscriptionName,
            subscriptionDescription: this.fundi.subscriptionDescription,
            workCategoryAndSubCategoryIds: this.subscriptionFeeExpense.workCategoryAndSubCategoryIds
        };

        let resultObs: Observable<any> = this.myFundiService.PayMonthlySubscriptionFeeWithPaypal(subscriptionFeeExpenseToBePaid);

        resultObs.map((q: any) => {
            debugger;
            if (q) {
                window.open(q.payPalRedirectUrl.requestMessage.requestUri);
                console.log('Response received');
                console.log(q);
                alert("Payment made. Currently being processed by paypal service!\nYou will be informed once all is set up by email.");
            }
            else {
                alert("Paypal error happened. We are sorry something went bad. Please contact Admin");
            }
        }).subscribe();
        $event.preventDefault();
    }

    public paySubscriptionMonthlyFeeWithAirTel($event) {

        if (!this.checkFundiProfileExists()) {
            this.router.navigateByUrl('/manage-profile');
            return;
        }

        let subscriptionFeeExpenseToBePaid: any = {
            monthlySubscriptionId: 0,
            userId: this.fundi.userId,
            fundiProfileId: this.fundi.fundiProfileId,
            startDate: new Date(),
            username: this.userDetails.username,
            subscriptionFee: this.fundi.subscriptionFee,
            hasPaid: false,
            subscriptionName: this.fundi.subscriptionName,
            subscriptionDescription: this.fundi.subscriptionDescription,
            workCategoryAndSubCategoryIds: this.subscriptionFeeExpense.workCategoryAndSubCategoryIds
        };
        let easyPayWindow: HTMLIFrameElement = document.getElementById('fundiEasyPayFrame') as HTMLIFrameElement;
        let easypayApiEndPoint = this.easyPayUrl + "/api";

        let resultObs: Observable<any> = this.myFundiService.PayMonthlySubscriptionFeeWithMtn(subscriptionFeeExpenseToBePaid);

        resultObs.map((q: any) => {

            debugger;
            if (q) {

                console.log('Response received');
                console.log(q);


                if (q.reasonPhrase) {
                    alert(q.reasonPhrase);
                }
                if (q.statusCode == "200") {
                    alert("Successfully Paid Subscription");
                }
                //    var newMtnAirtelObject: any = {
                //        action: q.action,
                //        reason: q.reason,
                //        currency: q.currency,
                //        amount: q.amount,
                //        username: q.username,
                //        password: q.password,
                //        reference: q.reference,
                //        phone: q.phone
                //    }

                //    console.log('Response received: ' + q.mtnAirtelBaseUrl + `${q}`);

                //    try {

                //        easyPayWindow.contentWindow.postMessage(JSON.stringify(newMtnAirtelObject), easypayApiEndPoint);
                //        //jQuery(easyPayWindow.document.body).children().remove();
                //        alert("AirTel Payment made. Currently being processed by AirTel service!\nYou will be informed once all is set up by email.");
                //        //jQuery(easyPayWindow.document.body).html('<div class="container-fluid">' + "AirTel Payment made. Currently being processed by paypal service!\nYou will be informed once all is set up by email.</div>")
                //    }
                //    catch (ex) {
                //        console.log(ex);
                //        debugger;
                //        //jQuery(easyPayWindow.document.body).children().remove();
                //        alert(ex);
                //        //jQuery(easyPayWindow.document.body).html(ex);

                //    }
                //    finally {
                //        //easyPayWindow.close();
                //    }
            }
            else {
                alert("AirTel error happened. We are sorry something went bad. Please contact Admin");
            }
        }).subscribe();
        $event.preventDefault();
    }
    public paySubscriptionMonthlyFeeWithMtn($event) {

        if (!this.checkFundiProfileExists()) {
            this.router.navigateByUrl('/manage-profile');
            return;
        }

        let subscriptionFeeExpenseToBePaid: any = {
            monthlySubscriptionId: 0,
            userId: this.fundi.userId,
            fundiProfileId: this.fundi.fundiProfileId,
            startDate: new Date(),
            username: this.userDetails.username,
            subscriptionFee: this.fundi.subscriptionFee,
            hasPaid: false,
            subscriptionName: this.fundi.subscriptionName,
            subscriptionDescription: this.fundi.subscriptionDescription,
            workCategoryAndSubCategoryIds: this.subscriptionFeeExpense.workCategoryAndSubCategoryIds
        };
        let easyPayWindow: HTMLIFrameElement = document.getElementById('fundiEasyPayFrame') as HTMLIFrameElement;

        let resultObs: Observable<any> = this.myFundiService.PayMonthlySubscriptionFeeWithMtn(subscriptionFeeExpenseToBePaid);

        resultObs.map((q: any) => {

            debugger;
            if (q) {

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

                //try {
                //    let easypayApiEndPoint = this.easyPayUrl + "/api";
                //    easyPayWindow.contentWindow.addEventListener('message', (event) => {
                //        console.log(JSON.stringify(event.data));
                //        debugger;
                //        alert(event.data);
                //    });
                //    easyPayWindow.contentWindow.postMessage(JSON.stringify(newMtnAirtelObject), easypayApiEndPoint);
                //    //jQuery(easyPayWindow.document.body).children().remove();
                //    alert("MTN Payment made. Currently being processed by AirTel service!\nYou will be informed once all is set up by email.");
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

    ngAfterViewChecked() {
        let curthis = this;

        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
    runAutoCompleteOnSelects(curthis: any) {
        let hasFoundSelectsOnPage = false;

        if (!curthis.hasPopulatedPage) {

            let selects = jQuery('div#fundiSubscription-wrapper select');

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
            jQuery('div#fundiSubscription-wrapper select').each((ind, sel) => {
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
}

