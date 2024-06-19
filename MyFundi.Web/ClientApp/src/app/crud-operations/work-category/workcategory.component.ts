import { Component, OnInit, Inject, AfterViewInit, AfterContentInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IWorkSubCategory, IWorkAndSubWorkCategory } from '../../../services/myFundiService';
import { Observable } from 'rxjs';

declare var jQuery: any;

@Component({
    selector: 'workcategory',
    templateUrl: './workcategory.component.html'
})
export class WorkCategoryComponent implements OnInit, AfterViewInit, AfterContentInit {
    userDetails: any;
    userRoles: string[];
    workCategory: IWorkAndSubWorkCategory;
    workCategoryId: number;
    workSubCategoryId: number;
    workCategories: IWorkCategory[];
    selectCategory: HTMLSelectElement;
    hasPopulatedPage: boolean;
    setTo: NodeJS.Timeout;
    coount: number = 0;
    workSubCategories: IWorkSubCategory[];

    ngOnInit(): void {
        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        let workCategoriesObs = this.myFundiService.GetWorkCategories();

        this.selectCategory = document.querySelector('select#slworkCategoryId');

        workCategoriesObs.map((res: IWorkCategory[]) => {
            this.workCategories = res;
            let opts = document.querySelector('select#slworkCategoryId').querySelector("option");
            if (opts) {
                document.querySelector('select#slworkCategoryId').querySelector("option").remove();
            }

            let opt = document.createElement("option");
            opt.text = "Select Work Category";
            opt.value = "0";
            document.querySelector('select#slworkCategoryId').append('opt');

            for (let n = 0; n < res.length; n++) {
                let option = document.createElement("option");
                option.value = res[n].workCategoryId.toString();
                option.text = res[n].workCategoryType;
                document.querySelector('select#slworkCategoryId').append(option);
            }

        }).subscribe();

        let workSubCategoriesObs = this.myFundiService.GetWorkSubCategories();

        workSubCategoriesObs.map((wcs: IWorkSubCategory[]) => {
            let opts = document.querySelector('select#slworkSubCategoryId').querySelector("option");
            if (opts) {
                document.querySelector('select#slworkSubCategoryId').querySelector("option").remove();
            }

            let opt = document.createElement("option");
            opt.text = "Select Sub Work Category";
            opt.value = "0";
            document.querySelector('select#slworkSubCategoryId').append('opt');
            this.workSubCategories = wcs;;
            wcs.forEach((c: IWorkSubCategory, index: number, wcs) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = c.workSubCategoryId.toString();
                optionElem.text = c.workSubCategoryType;
                document.querySelector('select#slworkSubCategoryId').append(optionElem);
            });
        }).subscribe();
    }
    constructor(private myFundiService: MyFundiService) {
        this.userDetails = {};
    }
    workCategoryChanged($event) {
        let workSubCategoriesObs: Observable<IWorkSubCategory[]> = this.myFundiService.GetAllFundiWorkSubCategoriesByWorkCategoryId(this.workCategoryId);

        workSubCategoriesObs.map((wcs: IWorkSubCategory[]) => {
            let opts = document.querySelector('select#slworkSubCategoryId').querySelector("option");
            if (opts) {
                document.querySelector('select#slworkSubCategoryId').querySelector("option").remove();
            }

            let opt = document.createElement("option");
            opt.text = "Select Sub Work Category";
            opt.value = "0";
            document.querySelector('select#slworkSubCategoryId').append('opt');
            this.workSubCategories = wcs;;
            wcs.forEach((c: IWorkSubCategory, index: number, wcs) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = c.workSubCategoryId.toString();
                optionElem.text = c.workSubCategoryType;
                document.querySelector('select#slworkSubCategoryId').append(optionElem);
            });
        }).subscribe();
    }
    addCategory($event) {

        let workCatAddedObs = this.myFundiService.AddFundiWorkCategory(this.workCategoryId, this.workSubCategoryId, this.userDetails.username);

        workCatAddedObs.map((q: any) => {
            alert(q.message);
        }).subscribe();
        $event.preventDefault();
    }

    removeCategory($event) {

        let workCatValue: number = jQuery('div#workCategories-wrapper select#slworkCategoryId').val();
        let workSubCatValue: number = jQuery('div#workCategories-wrapper select#slworkSubCategoryId').val();
        let workCatAddedObs = this.myFundiService.RemoveFundiWorkCategory(this.workCategoryId, this.workSubCategoryId, this.userDetails.username);

        workCatAddedObs.map((q: any) => {
            alert(q.message);
        }).subscribe();
        $event.preventDefault();
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
            let selects = jQuery('div#workCategories-wrapper  select');

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
