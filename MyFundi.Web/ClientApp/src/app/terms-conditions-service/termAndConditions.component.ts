import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IMtnAirTelModel, IWorkSubCategory, IWorkAndSubWorkCategory, ISubscription } from '../../services/myFundiService';
import { Observable } from 'rxjs';
import { Router } from '@angular/router';
declare var jQuery: any;

@Component({
    selector: 'terms-and-conditions',
    templateUrl: './termAndConditions.component.html'
})
export class TermsAndConditionsComponent implements OnInit {
    userDetails: any;
    userRoles: string[];
    liabilityNotesHtml: string = "";
    termsAndConditionsOfServiceHtml: string = "";
    currentDate: string;
    termsAndConditionOfService: boolean = false;

    constructor(private myFundiService: MyFundiService,private router:Router) {
        this.userDetails = {};
        let date = new Date();
        this.currentDate = this.formatDate(date);
    }
    acceptTermsAndConditions($event) {
        if (!this.termsAndConditionOfService) {
            alert('You should accept the terms and conditions\nof service before registering!');
            localStorage.setItem('HasAcceptedTermsOfService', "false");
            return;
        }
        debugger;
        localStorage.setItem('HasAcceptedTermsOfService', "true");
        this.router.navigateByUrl('/register')
        //$event.preventDefault();
    }
    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {


    }
   formatDate(date):string {
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

