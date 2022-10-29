import { Component, OnInit, Injectable, AfterContentInit } from '@angular/core';
import { IAddress, ICourse, MyFundiService } from '../../../services/myFundiService';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
import * as EventEmitter from 'events';

@Component({
    selector: 'coursecrud',
    templateUrl: './coursescrud.component.html',
    providers: [MyFundiService]
})
@Injectable()
export class CourseCrudComponent implements OnInit, AfterContentInit {
    private myFundiService: MyFundiService;
    @Output() addressEmitter: EventEmitter = new EventEmitter();
    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }
    ngAfterContentInit(): void {
        let optionElem = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select Course";
        document.querySelector('select#coursecrudId').append(optionElem);


        let courseObs: Observable<ICourse[]> = this.myFundiService.GetAllFundiCourses();
        courseObs.map((adds: ICourse[]) => {
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
        $('form#locationView').css('display', 'block').slideDown();
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
        $('form#locationView').css('display', 'block').slideDown();
    }
    public selectCourse(): void {
        let actualResult: Observable<any> = this.myFundiService.GetCourseById(this.course.courseId);
        actualResult.map((p: any) => {
            this.course = p;
            this.addressEmitter.emit(this.course.courseId);
        }).subscribe();
        $('form#locationView').css('display', 'block').slideDown();
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
        $('form#locationView').css('display', 'block').slideDown();
    }
    public ngOnInit(): void {
        this.course = {}
    }
}
