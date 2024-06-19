import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IMtnAirTelModel, IWorkSubCategory, IWorkAndSubWorkCategory, ISubscription, IClientFundiContract } from '../../services/myFundiService';
import { Observable } from 'rxjs';
declare var jQuery: any;

@Component({
    selector: 'fundi-contract',
    templateUrl: './fundicontract.component.html'
})
export class FundiContractComponent implements OnInit {
    userDetails: IUserDetail;
    userRoles: string[];
    clientFundiContract: IClientFundiContract;
    clientContracts: IClientFundiContract[];

    fundi: any = {};
    client: any = {}
    setTo: NodeJS.Timeout;
    unitMaterialCost: number = 0;
    unitMaterialQuantity: number=0;
    unitLabourCost: number=0;
    unitLabourQuantity: number = 0;
    unitPermitInspectionCost: number=0;
    unitPermitInspectionQuantity: number = 0;

    constructor(private myFundiService: MyFundiService) {
    }

    updateClientAddress($event) {
        this.clientFundiContract.clientAddressId = $event;
    }
    updateFundiAddress($event) {
        this.clientFundiContract.fundiAddressId = $event;
    }
    selectContract($event) {
        let crtObs: Observable<any> = this.myFundiService.SelectContract(this.clientFundiContract.clientFundiContractId);
        crtObs.map((q: any) => {
            this.clientFundiContract = q;
        }).subscribe();
        $event.preventDefault();
    }
    calculateCost($event) {

        this.clientFundiContract.agreedCost = this.unitMaterialCost * this.unitMaterialQuantity +
            this.unitLabourCost * this.unitLabourQuantity +
            this.unitPermitInspectionCost * this.unitPermitInspectionQuantity;
        $event.preventDefault();
    }

    createContract($event) {
        let crtObs: Observable<any> = this.myFundiService.CreateContract(this.clientFundiContract);
        crtObs.map((q: any) => {
            alert(q.message);
        }).subscribe();
        $event.preventDefault();
    }
    updateContract($event) {
        let crtObs: Observable<any> = this.myFundiService.UpdateContract(this.clientFundiContract);
        crtObs.map((q: any) => {
            alert(q.message);
        }).subscribe();
        $event.preventDefault();
    }
    deleteContract($event) {
        let crtObs: Observable<any> = this.myFundiService.DeleteContract(this.clientFundiContract.clientFundiContractId);
        crtObs.map((q: any) => {
            alert(q.message);
        }).subscribe();
        $event.preventDefault();
    }
    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {
        this.unitMaterialCost = 0;
        this. unitMaterialQuantity = 0;
        this.unitLabourCost = 0;
        this.unitLabourQuantity = 0;
        this.unitPermitInspectionCost = 0;
        this.unitPermitInspectionQuantity = 0;

        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));

        let curDate: Date = new Date();

        this.clientFundiContract = {
            clientFundiContractId: -1,
            clientProfileId: -1,
            fundiAddressId: 0,
            clientAddressId:0,
            clientUsername: "",
            clientFirstName: "",
            clientLastName: "",
            fundiProfileId: -1,
            fundiUsername: this.userDetails.username,
            fundiFirstName: "",
            fundiLastName: "",
            agreedStartDate: this.formatDate(curDate),
            agreedEndDate: this.formatDate(curDate),
            agreedCost: 0,
            jobId:0,
            contractualDescription: "",
            isSignedByClient: true,
            isSignedByFundi: false,
            isCompleted: false,
            isSignedOffByClient: false,
            notesForNotice: "",
            date1stPayment: this.formatDate(curDate),
            date2ndPayment: this.formatDate(curDate),
            date3rdPayment: this.formatDate(curDate),
            date4thPayment: this.formatDate(curDate),
            firstPaymentAmount: 0,
            secondPaymentAmount: 0,
            thirdPaymentAmount: 0,
            forthPaymentAmount: 0,
        };

        let resObs = this.myFundiService.GetFundiProfile(this.userDetails.username);

        resObs.map((fundiProf: IProfile) => {
            debugger;
            this.fundi = fundiProf;
            let clientContsObs: Observable<any[]> = this.myFundiService.GetFundiContractsByUsername(this.userDetails.username);
            clientContsObs.map((cts: any[])=> {
                this.clientContracts = cts;

                jQuery('div.fundiContract-wrapper select#clientFundiContractId option').remove();

                let optionElem = document.createElement('option');
                optionElem.selected = true;
                optionElem.value = (0).toString();
                optionElem.text = "Select Client Fundi Contract";
                document.querySelector('div.fundiContract-wrapper select#clientFundiContractId').append(optionElem);
;
                cts.forEach((c: any, index: number) => {
                    let optionElem: HTMLOptionElement = document.createElement('option');
                    optionElem.value = c.clientFundiContractId.toString();
                    optionElem.text = c.clientFirstName + " " + c.clientLastName + " : " + c.fundiFirstName + " " + c.fundiLastName + " , " + c.agreedStartDate + " , #" + c.clientFundiContractId;
                    document.querySelector('div.fundiContract-wrapper select#clientFundiContractId').append(optionElem);
                });
            }).subscribe();
        }).subscribe();
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

            let selects = jQuery('div.fundiContract-wrapper select');

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
            jQuery('div.fundiContract-wrapper select').each((ind, sel) => {
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

