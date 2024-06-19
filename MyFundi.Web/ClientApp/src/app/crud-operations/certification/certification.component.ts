import { Component, OnInit, Inject, AfterViewChecked } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../../services/myFundiService';
import { AfterViewInit } from '@angular/core';
import { AfterContentInit } from '@angular/core';
declare var jQuery: any;

@Component({
    selector: 'certification',
    templateUrl: './certification.component.html'
})
export class CertificationComponent implements OnInit, AfterViewInit, AfterContentInit {
    userDetails: any;
    userRoles: string[];
    certifications: ICertification[];
    selectCertificate: HTMLSelectElement;
    hasPopulatedPage: boolean = false;
    count: number = 0;
    setTo: NodeJS.Timeout;
    ngOnInit(): void {
        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        if (!this.userDetails) this.userDetails = {};
        if (!this.userDetails.username) {
            this.userDetails.username = MyFundiService.clientEmailAddress;
        }
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        let certificationsObs = this.myFundiService.GetAllFundiCertificates();

        this.selectCertificate = document.querySelector('select#slcertificationId');

        certificationsObs.map((res: ICertification[]) => {
            this.certifications = res;
            let opts = document.querySelector('select#slcertificationId').querySelector("option");
            if (opts) {
                document.querySelector('select#slcertificationId').querySelector("option").remove();
            }

            let opt = document.createElement("option");
            opt.text = "Select Certification";
            opt.value = "0";

            document.querySelector('select#slcertificationId').append('opt');

            for (let n = 0; n < res.length; n++) {
                let option = document.createElement("option");
                option.value = res[n].certificationId.toString();
                option.text = res[n].certificationName;
                document.querySelector('select#slcertificationId').append(option);
            }
        }).subscribe();

    }
    constructor(private myFundiService: MyFundiService) {
        this.userDetails = {};
    }
    addCertification() {

        let certificateValue: HTMLSelectElement = document.querySelector('select#slcertificationId');
        let certsaddedObs = this.myFundiService.AddFundiCertificate(parseInt(certificateValue.value), this.userDetails.username);
        certsaddedObs.map((q: any) => {
            alert(q.message);
        }).subscribe();
    }

    ngAfterContentInit() {

    }

    ngAfterViewInit() {
        let curthis = this;

        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
    runAutoCompleteOnSelects(curthis: any) {
        debugger;
        let hasFoundSelectsOnPage = false;

        if (curthis.certifications && curthis.certifications.length > 1 && !curthis.hasPopulatedPage) {
            let selects = jQuery('div#certificates-wrapper select');

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
