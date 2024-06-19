import { Component, OnInit, ViewChild, ElementRef, Input, Output, Injectable, Inject, EventEmitter, AfterViewInit, AfterViewChecked } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ICompany, IAddress, ILocation, MyFundiService } from '../../../services/myFundiService';
import { Element } from '@angular/compiler';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { AfterContentInit } from '@angular/core';
declare var jQuery: any;

@Component({
    selector: 'company',
    templateUrl: './company.component.html',
    styleUrls: ['./company.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class CompanyComponent implements OnInit, AfterContentInit, AfterViewInit {
    private myFundiService: MyFundiService;
    public company: ICompany | any;
    private companies: ICompany[];
    private hasPopulatedPage: boolean = false;
    setTo: NodeJS.Timeout;
    count: number = 0;

    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }

    public addCompany(): void {
        let form: HTMLFormElement = document.querySelector('form#f2') as HTMLFormElement;
        if (!form.checkValidity()) return;

        this.company.location = null;
        let actualResult: Observable<any> = this.myFundiService.PostOrCreateCompany(this.company);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('Company Added: ' + p); if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public updateCompany() {
        let form: HTMLFormElement = document.querySelector('form#f2') as HTMLFormElement;
        if (!form.checkValidity()) return;

        let actualResult: Observable<any> = this.myFundiService.UpdateCompany(this.company);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('Company Updated: ' + p); if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public selectCompany(): void {
        let actualResult: Observable<any> = this.myFundiService.GetCompanyById(jQuery('div#companies-wrapper select#companyId').val());
        actualResult.map((p: any) => {
            this.company = p;
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public deleteCompany() {
        let form: HTMLFormElement = document.querySelector('form#f2') as HTMLFormElement;
        if (!form.checkValidity()) return;

        let actualResult: Observable<any> = this.myFundiService.DeleteCompany(this.company);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('Company Deleted: ' + p);
            if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public ngOnInit(): void {
        this.company = { companyId: 0 }
    }
    ngAfterContentInit(): void {

        let optionElem: HTMLOptionElement = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select Company";
        document.querySelector('select#companyId').append(optionElem);


        optionElem = document.createElement('option');
        optionElem.value = (0).toString();
        optionElem.text = "Select Location";
        document.querySelector('select#complocationId').append(optionElem);


        const companiesObs: Observable<ICompany[]> = this.myFundiService.GetAllCompanies();
        const locatObs: Observable<ILocation[]> = this.myFundiService.GetAllLocations();

        companiesObs.map((cmds: ICompany[]) => {
            this.companies = cmds;
            cmds.forEach((cmd: ICompany, index: number, cmds) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = cmd.companyId.toString();
                optionElem.text = cmd.companyName;
                document.querySelector('select#companyId').append(optionElem);
            });
        }).subscribe();

        locatObs.map((cmdCats: ILocation[]) => {
            cmdCats.forEach((comCat: ILocation, index: number, cmdCats) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = comCat.locationId.toString();
                optionElem.text = comCat.locationName;
                document.querySelector('select#complocationId').append(optionElem);
            });

        }).subscribe();

    }
    ngAfterViewInit() {
        let curthis = this;

        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
    runAutoCompleteOnSelects(curthis: any) {
        debugger;
        let hasFoundSelectsOnPage = false;


        if (curthis.companies && curthis.companies.length > 1 && !curthis.hasPopulatedPage) {

            let selects = jQuery('div#companies-wrapper select');

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
