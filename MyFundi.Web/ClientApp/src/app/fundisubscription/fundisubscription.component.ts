import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IMtnAirTelModel, IWorkSubCategory } from '../../services/myFundiService';
import { Observable } from 'rxjs';
declare var jQuery: any;

@Component({
    selector: 'fundisubscription',
    templateUrl: './fundisubscription.component.html'
})
export class FundiSubscriptionComponent implements OnInit {
    userDetails: any;
    userRoles: string[];
    location: ILocation;
    subscriptionFee: number = 2500;
    subscriptionDescription: string;
    subscriptionName: string;
    fundi: any = {};
    public workCategories: IWorkCategory[];
    public workCategory: IWorkCategory | any;
    public workSubCategory: IWorkSubCategory | any;
    public workSubCategories: IWorkSubCategory[];
    subscriptionFeeExpense: any;

    constructor(private myFundiService: MyFundiService) {
        this.userDetails = {};
    }

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {
        this.subscriptionFeeExpense = {
            monthlySubscriptionId: 0,
            userId: this.fundi.userId,
            fundiProfileId: this.fundi.fundiProfileId,
            startDate: new Date(),
            username: this.userDetails.username,
            subscriptionFee: this.fundi.subscriptionFee,
            hasPaid: false,
            subscriptionName: this.fundi.subscriptionName,
            subscriptionDescription: this.fundi.subscriptionDescription,
            fundiWorkCategoryIds: []
}
        this.workCategory = { workCategoryId: 0 };
        this.workCategories = [];
        let optionElem = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select WorkCategory";
        document.querySelector('select#subcworkCategoryId').append(optionElem);


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
        optionElem = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select WorkSubCategory";
        document.querySelector('select#subcworkSubCategoryId').append(optionElem);

        let workCategoriesObs: Observable<IWorkCategory[]> = this.myFundiService.GetWorkCategories();
        workCategoriesObs.map((wcs: IWorkCategory[]) => {
            this.workCategories = wcs;
            wcs.forEach((c: IWorkCategory, index: number, wcs) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = c.workCategoryId.toString();
                optionElem.text = c.workCategoryType;
                document.querySelector('select#subcworkCategoryId').append(optionElem);
            });


            let workSubCategoriesObs = this.myFundiService.GetWorkSubCategories();

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
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        let resObs = this.myFundiService.GetFundiProfile(this.userDetails.username);

        resObs.map((fundiProf: IProfile) => {
            this.fundi = fundiProf;
            this.fundi.subscriptionFee = this.subscriptionFee;
            this.fundi.subscriptionName = `Fundi User ${this.userDetails.firstName} ${this.userDetails.lastName} Subscription for 31 days`;
            this.fundi.subscriptionDescription = "Attempting Monthly Payment!";

            let userIdObs: Observable<string> = this.myFundiService.GetUserGuidId(this.userDetails.username);
            userIdObs.map((q: string) => {
                this.fundi.userId = q;
            }).subscribe();
        }).subscribe();
    }
    public getWorkSubCategoriesByWorkCategoryId() {
        let workSubCategoriesObs = this.myFundiService.GetAllFundiWorkSubCategoriesByWorkCategoryId(this.workCategory.workCategoryId);

        workSubCategoriesObs.map((wcs: IWorkSubCategory[]) => {
            //clear the workCategory options menu and add new options:
            jQuery('select#subcworkSubCategoryId option').remove();
            
            this.workSubCategories = [];
            let optionElem = document.createElement('option');
            optionElem.selected = true;
            optionElem.value = (0).toString();
            optionElem.text = "Select WorkSubCategory";
            document.querySelector('select#subcworkSubCategoryId').append(optionElem);

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

        let chosenCategory = this.subscriptionFeeExpense.fundiWorkCategoryIds.find((q, index) => {
            indexWorkCatToRemove = index;
           return q.workCategoryId == this.workCategory.workCategoryId;
        })
        if (chosenCategory) {
            let indexWorkSubCatToRemove: number;
            let chosenWorkSubCatId = chosenCategory.workSubCategoryIds.find((q, index) => {
                indexWorkSubCatToRemove = index;
                return q == this.workSubCategory.workSubCategoryId;
            });
            if (chosenWorkSubCatId) {
                return;
            }
            else {

                this.subscriptionFeeExpense.fundiWorkCategoryIds[indexWorkCatToRemove].workSubCategoryIds.push(this.workSubCategory.workSubCategoryId);
               
                let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
                let li = document.createElement("li");

                li.textContent = jQuery('select#subcworkCategoryId > option:selected').text() + ` :[${jQuery('select#subcworkSubCategoryId > option:selected').text()}]`;
                ulSelectedCategories.appendChild(li);
            }
        }
        else {
            let workCategorySubCatIds: any[] = [];
            workCategorySubCatIds.push(this.workSubCategory.workSubCategoryId);
            this.subscriptionFeeExpense.fundiWorkCategoryIds.push({
                workCategoryId: this.workCategory.workCategoryId, workSubCategoryIds: workCategorySubCatIds
            });
            let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
            let li = document.createElement("li");

            li.textContent = jQuery('select#subcworkCategoryId > option:selected').text() + ` :[${jQuery('select#subcworkSubCategoryId > option:selected').text() }]`;
            ulSelectedCategories.appendChild(li);
        }
        $event.preventDefault();
    }
    public paySubscriptionMonthlyFeeWithPaypal($event) {

        let subscriptionFeeExpenseToBePaid:any = {
            monthlySubscriptionId: 0,
            userId: this.fundi.userId,
            fundiProfileId: this.fundi.fundiProfileId,
            startDate: new Date(),
            username: this.userDetails.username,
            subscriptionFee: this.fundi.subscriptionFee,
            hasPaid: false,
            subscriptionName: this.fundi.subscriptionName,
            subscriptionDescription: this.fundi.subscriptionDescription,
            workCategoryAndSubCategoryIds: this.subscriptionFeeExpense.fundiWorkCategoryIds
        };

        let resultObs: Observable<any> = this.myFundiService.PayMonthlySubscriptionFeeWithPaypal(subscriptionFeeExpenseToBePaid);

        resultObs.map((q: any) => {
            if (q.payPalRedirectUrl) {
                window.open(q.payPalRedirectUrl);
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
    paySubscriptionMonthlyFeeWithAirTel($event) {

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
            workCategoryAndSubCategoryIds: this.subscriptionFeeExpense.fundiWorkCategoryIds
        };

        let resultObs: Observable<IMtnAirTelModel> = this.myFundiService.PayMonthlySubscriptionFeeWithAirTel(subscriptionFeeExpenseToBePaid);

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
                    alert("MTN or AirTel Payment made. Currently being processed by paypal service!\nYou will be informed once all is set up by email.");
                }).subscribe();
            }
            else {
                alert("MTN or AirTel error happened. We are sorry something went bad. Please contact Admin");
            }
        }).subscribe();
        $event.preventDefault();
    }
    paySubscriptionMonthlyFeeWithMtn($event) {

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
            workCategoryAndSubCategoryIds: this.subscriptionFeeExpense.fundiWorkCategoryIds
        };
        let resultObs: Observable<IMtnAirTelModel> = this.myFundiService.PayMonthlySubscriptionFeeWithAirTel(subscriptionFeeExpenseToBePaid);

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
                    alert("MTN or AirTel Payment made. Currently being processed by paypal service!\nYou will be informed once all is set up by email.");
                }).subscribe();
            }
            else {
                alert("MTN or AirTel error happened. We are sorry something went bad. Please contact Admin");
            }
        }).subscribe();
        $event.preventDefault();
    }


    runAutoCompleteOnSelects(curthis: any) {
        debugger;
        let hasFoundSelectsOnPage = false;

        if (curthis.workCategories && curthis.workCategories.length > 1 && !curthis.hasPopulatedPage) {

            let selects = jQuery('div#subcworkSubCategories-wrapper select');

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
            jQuery('select').each((ind, sel) => {
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

