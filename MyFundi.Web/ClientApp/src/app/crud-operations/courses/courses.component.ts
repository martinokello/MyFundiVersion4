import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../../services/myFundiService';
import { AfterViewInit } from '@angular/core';
import { AfterViewChecked } from '@angular/core';
import { AfterContentInit } from '@angular/core';
declare var jQuery: any;

@Component({
    selector: 'courses',
    templateUrl: './courses.component.html'
})
export class CoursesComponent implements OnInit, AfterContentInit, AfterViewInit {
    userDetails: any;
    userRoles: string[];
    courses: ICourse[];
    selectCourse: HTMLSelectElement;
    public hasPopulatedPage: boolean = false;
    setTo: NodeJS.Timeout;
    count: number = 0;
    ngOnInit(): void {
        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        if (!this.userDetails) this.userDetails = {};

        if (!this.userDetails.username) {
            this.userDetails.username = MyFundiService.clientEmailAddress;
        }
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        let courseObs = this.myFundiService.GetAllFundiCourses();

        this.selectCourse = document.querySelector('select#slcourseId');

        courseObs.map((res: ICourse[]) => {
            this.courses = res;
            let opts = document.querySelector('select#slcourseId').querySelector("option");
            if (opts) {
                document.querySelector('select#slcourseId').querySelector("option").remove();
            }

            let opt = document.createElement("option");
            opt.text = "Select Course";
            opt.value = "0";

            document.querySelector('select#slcourseId').append('opt');

            for (let n = 0; n < res.length; n++) {
                let option = document.createElement("option");
                option.value = res[n].courseId.toString();
                option.text = res[n].courseName;
                document.querySelector('select#slcourseId').append(option);
            }
        }).subscribe();
    }
    constructor(private myFundiService: MyFundiService) {
        this.userDetails = {};
    }
    addCourse() {

        let courseValue = jQuery('div#courses-wrapper select#slcourseId').val();
        let courseObs = this.myFundiService.AddFundiCourse(parseInt(courseValue), this.userDetails.username);
        courseObs.map((q: any) => {
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

        if (curthis.courses && curthis.courses.length > 1 && !curthis.hasPopulatedPage) {
            let selects = jQuery('div#courses-wrapper select');

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
