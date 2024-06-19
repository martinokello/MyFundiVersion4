import { Component, OnInit, Injectable, AfterViewInit, AfterContentInit, AfterViewChecked } from '@angular/core';
import { IAddress, ICourse, MyFundiService } from '../../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
import * as EventEmitter from 'events';
declare var jQuery: any;

@Component({
    selector: 'coursecrud',
    templateUrl: './coursescrud.component.html',
    providers: [MyFundiService]
})
@Injectable()
export class CourseCrudComponent implements OnInit, AfterContentInit, AfterViewInit {
    private myFundiService: MyFundiService;
    @Output() addressEmitter: EventEmitter = new EventEmitter();
    private courses: ICourse[];
    public hasPopulatedPage: boolean = false;
    setTo: NodeJS.Timeout;
    count: number = 0;
    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }
    ngOnInit(): void {
        this.course = { courseId: 0 }
        this.courses = [];
        let optionElem = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select Course";
        document.querySelector('select#coursecrudId').append(optionElem);


        let courseObs: Observable<ICourse[]> = this.myFundiService.GetAllFundiCourses();
        courseObs.map((adds: ICourse[]) => {
            this.courses = adds;
            adds.forEach((add: ICourse, index: number, adds) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = add.courseId.toString();
                optionElem.text = add.courseName;
                document.querySelector('select#coursecrudId').append(optionElem);
            });
        }).subscribe();
    }
    public course: ICourse | any;

    public addCourse(): void {
        let form: HTMLFormElement = document.querySelector('form#coursecrudView') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.PostOrCreateCourse(this.course);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('Course Added: ' + p);
            if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public updateCourse() {
        let form: HTMLFormElement = document.querySelector('form#coursecrudView') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.UpdateCourse(this.course);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('Course Updated: ' + p);
            if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public selectCourse(): void {
        let actualResult: Observable<any> = this.myFundiService.GetCourseById(jQuery('div#coursecrud-wrapper select#coursecrudId').val());
        actualResult.map((p: any) => {
            this.course = p;
            this.addressEmitter.emit(this.course.courseId);
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public deleteCourse() {
        let form: HTMLFormElement = document.querySelector('form#coursecrudView') as HTMLFormElement;
        if (!form.checkValidity()) return;

        let actualResult: Observable<any> = this.myFundiService.DeleteCourse(this.course);
        actualResult.map((q: any) => {
            let p: boolean = q;
            alert('Course Deleted: ' + p);
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

        if (curthis.courses && curthis.courses.length > 1 && !curthis.hasPopulatedPage) {
            let selects = jQuery('div#coursecrud-wrapper select');

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
