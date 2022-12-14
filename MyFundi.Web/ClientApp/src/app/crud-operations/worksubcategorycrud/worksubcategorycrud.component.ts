import { Component, OnInit, Injectable, AfterContentInit, AfterViewChecked, AfterViewInit } from '@angular/core';
import { IAddress, IWorkAndSubWorkCategory, IWorkCategory, IWorkSubCategory, MyFundiService } from '../../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
import * as EventEmitter from 'events';
declare var jQuery: any;

@Component({
    selector: 'worksubcategorycrud',
    templateUrl: './worksubcategorycrud.component.html',
    styleUrls: ['./worksubcategorycrud.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class WorkSubCategoryCrudComponent implements OnInit, AfterContentInit, AfterViewInit {
    private myFundiService: MyFundiService;
    public workCategories: IWorkCategory[];
    public workCategory: IWorkCategory | any;
    public workSubCategory: IWorkSubCategory | any;
    public workSubCategories: IWorkSubCategory[];
    public workCategoryId: number;
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
        document.querySelector('select#workCategoryCrudForSubCatId').append(optionElem);


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
        document.querySelector('select#workSubCategoryCrudId').append(optionElem);

        let workCategoriesObs: Observable<IWorkCategory[]> = this.myFundiService.GetWorkCategories();
        workCategoriesObs.map((wcs: IWorkCategory[]) => {
            this.workCategories = wcs;
            wcs.forEach((c: IWorkCategory, index: number, wcs) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = c.workCategoryId.toString();
                optionElem.text = c.workCategoryType;
                document.querySelector('select#workCategoryCrudForSubCatId').append(optionElem);
            });


            let workSubCategoriesObs = this.myFundiService.GetWorkSubCategories();

            workSubCategoriesObs.map((wcs: IWorkSubCategory[]) => {
                this.workSubCategories = wcs;;
                wcs.forEach((c: IWorkSubCategory, index: number, wcs) => {
                    let optionElem: HTMLOptionElement = document.createElement('option');
                    optionElem.value = c.workSubCategoryId.toString();
                    optionElem.text = c.workSubCategoryType;
                    document.querySelector('select#workSubCategoryCrudId').append(optionElem);
                });
            }).subscribe();
        }).subscribe();
    }
    getWorkSubCategoriesByWorkCategoryId() {
        let workSubCategoriesObs = this.myFundiService.GetAllFundiWorkSubCategoriesByWorkCategoryId(this.workSubCategory.workCategoryId);
        
        workSubCategoriesObs.map((wcs: IWorkSubCategory[]) => {
            //clear the workCategory options menu and add new options:
            jQuery('select#workSubCategoryCrudId option').remove();

            this.workSubCategories = [];
            let optionElem = document.createElement('option');
            optionElem.selected = true;
            optionElem.value = (0).toString();
            optionElem.text = "Select WorkSubCategory";
            document.querySelector('select#workSubCategoryCrudId').append(optionElem);

            this.workSubCategories = wcs;
            wcs.forEach((c: IWorkSubCategory, index: number, wcs) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = c.workSubCategoryId.toString();
                optionElem.text = c.workSubCategoryType;
                document.querySelector('select#workSubCategoryCrudId').append(optionElem);
            });
        }).subscribe();
    }

    public addWorkSubCategory($event): void {
        let form: HTMLFormElement = document.querySelector('form#f') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.CreateWorkSubCategory(this.workSubCategory);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('workSubCategory Added: ' + p.toString());
            if (p == true) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
        $event.preventDefault();
    }

    public updateworkSubCategory($event) {
        let form: HTMLFormElement = document.querySelector('form#f') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.UpdateWorkSubCategory(this.workSubCategory);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('WorkSubCategory Updated: ' + p.toString());
            if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
        $event.preventDefault();
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
    public deleteworkSubCategory($event) {
        let form: HTMLFormElement = document.querySelector('form#f') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.DeleteworkSubCategory(this.workSubCategory);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('workSubCategory Deleted: ' + p);
            if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
        $event.preventDefault();
    }
    ngAfterContentInit() {

    }


    ngAfterViewInit() {
        let curthis = this;

        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
    runAutoCompleteOnSelects(curthis: any) {
        
        let hasFoundSelectsOnPage = false;

        if (curthis.workCategories && curthis.workCategories.length > 1 && !curthis.hasPopulatedPage) {

            let selects = jQuery('div#workSubCategoriescrud-wrapper select');

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
