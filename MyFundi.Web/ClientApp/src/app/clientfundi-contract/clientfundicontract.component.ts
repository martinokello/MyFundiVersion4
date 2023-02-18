import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IMtnAirTelModel, IWorkSubCategory, IWorkAndSubWorkCategory, ISubscription, IClientFundiContract } from '../../services/myFundiService';
import { Observable } from 'rxjs';
declare var jQuery: any;

@Component({
    selector: 'client-fundi-contract',
    templateUrl: './clientfundicontract.component.html'
})
export class ClientFundiContractComponent implements OnInit {
    userDetails: IUserDetail;
    userRoles: string[];
    clientFundiContract: IClientFundiContract;
    clientContracts: IClientFundiContract[];
    fundi: any = {};
    client: any = {}

    constructor(private myFundiService: MyFundiService) {
    }
    selectContract($event) {
        let crtObs: Observable<any> = this.myFundiService.SelectContract(this.clientFundiContract.clientFundiContractId);
        crtObs.map((q: any) => {
            this.clientFundiContract = q;
        }).subscribe();
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
        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));

        let curDate: Date = new Date();
        let draftContractData: any =JSON.parse(localStorage.getItem("DraftContractData"));

        this.clientFundiContract = {
            clientFundiContractId: draftContractData.clientFundiContractId,
            clientProfileId: draftContractData.clientProfileId,
            clientUsername: draftContractData.clientUsername,
            clientFirstName: draftContractData.clientFirstName,
            clientLastName: draftContractData.clientLastName,
            fundiProfileId: draftContractData.fundiProfileId,
            fundiUsername: draftContractData.fundiUsername,
            fundiFirstName: draftContractData.fundiFirstName,
            fundiLastName: draftContractData.fundiLastName,
            agreedStartDate: this.formatDate(curDate),
            agreedEndDate: this.formatDate(curDate),
            agreedCost: draftContractData.agreedFees,
            contractualDescription: draftContractData.contractualDescription,
            isSignedByClient: true,
            isSignedByFundi: false,
            isCompleted: false,
            isSignedOffByClient: false,
            notesForNotice: draftContractData.notesForNotice
        };

        let resObs = this.myFundiService.GetFundiProfile(this.clientFundiContract.fundiUsername);

        resObs.map((fundiProf: IProfile) => {
            debugger;
            this.fundi = fundiProf;
            let clientContsObs: Observable<any[]> = this.myFundiService.GetClientContractsByUsername(this.clientFundiContract.clientUsername);
            clientContsObs.map((cts: any[])=> {
                this.clientContracts = cts;

                jQuery('select#clientFundiContractId option').remove();

                let optionElem = document.createElement('option');
                optionElem.selected = true;
                optionElem.value = (0).toString();
                optionElem.text = "Select Client Fundi Contract";
                document.querySelector('select#clientFundiContractId').append(optionElem);
;
                cts.forEach((c: any, index: number) => {
                    let optionElem: HTMLOptionElement = document.createElement('option');
                    optionElem.value = c.clientFundiContractId.toString();
                    optionElem.text = c.clientFirstName + " " + c.clientLastName + " : " + c.fundiFirstName + " " + c.fundiLastName + " , " + c.agreedStartDate + " , #" + c.clientFundiContractId;
                    document.querySelector('select#clientFundiContractId').append(optionElem);
                });
            }).subscribe();
        }).subscribe();
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

}

