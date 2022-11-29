import { Component, OnInit, Injectable, AfterContentInit, AfterViewChecked, AfterViewInit } from '@angular/core';
import { IAddress, IWorkAndSubWorkCategory, IWorkCategory, MyFundiService } from '../../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
import * as EventEmitter from 'events';
declare var jQuery: any;

@Component({
    selector: 'workcategorycrud',
    templateUrl: './workcategorycrud.component.html',
    styleUrls: ['./workcategorycrud.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class WorkCategoryCrudComponent implements OnInit, AfterContentInit, AfterViewInit {
    private myFundiService: MyFundiService;
    private workCategories: IWorkCategory[];
    public hasPopulatedPage: boolean = false;
    count: number = 0;
    setTo: NodeJS.Timeout;

    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }
    ngOnInit(): void {
        this.workCategory = { workCategoryId: 0 };
        this.workCategories = [];
        let optionElem = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select WorkCategory";
        document.querySelector('select#workCategoryCrudId').append(optionElem);


        let workCategoriesObs: Observable<IWorkCategory[]> = this.myFundiService.GetWorkCategories();
        workCategoriesObs.map((wcs: IWorkCategory[]) => {
            this.workCategories = wcs;;
            wcs.forEach((c: IWorkCategory, index: number, wcs) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = c.workCategoryId.toString();
                optionElem.text = c.workCategoryType;
                document.querySelector('select#workCategoryCrudId').append(optionElem);
            });

        }).subscribe();
    }
    public workCategory: IWorkCategory | any;

    public addWorkCategory(): void {
        let form: HTMLFormElement = document.querySelector('form#f4') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.CreateWorkCategory(this.workCategory);
        actualResult.map((q: any) => {
            let p: any = q;
            alert('workCategory Added: ' + p.message);
            if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public updateworkCategory() {
        let form: HTMLFormElement = document.querySelector('form#f4') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.UpdateWorkCategory(this.workCategory);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('Address Updated: ' + p);
            if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public selectworkCategory(): void {
        let workCatValue: number = jQuery('div#workCategoriescrud-wrapper select#workCategoryCrudId').val();
        let actualResult: Observable<any> = this.myFundiService.GetworkCategoryById(workCatValue);
        actualResult.map((p: any) => {
            this.workCategory = p;
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public deleteworkCategory() {
        let form: HTMLFormElement = document.querySelector('form#f4') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.DeleteworkCategory(this.workCategory);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('workCategory Deleted: ' + p);
            if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
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

        if (curthis.workCategories && curthis.workCategories.length > 1 && !curthis.hasPopulatedPage) {

            let selects = jQuery('div#workCategoriescrud-wrapper select');

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
