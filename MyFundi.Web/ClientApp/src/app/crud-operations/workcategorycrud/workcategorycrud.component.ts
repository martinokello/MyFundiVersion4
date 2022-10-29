import { Component, OnInit, Injectable, AfterContentInit } from '@angular/core';
import { IAddress, IWorkCategory, MyFundiService } from '../../../services/myFundiService';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
import * as EventEmitter from 'events';

@Component({
    selector: 'workcategorycrud',
    templateUrl: './workcategorycrud.component.html',
    styleUrls: ['./workcategorycrud.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class WorkCategoryCrudComponent implements OnInit, AfterContentInit {
    private myFundiService: MyFundiService;
    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }
    ngAfterContentInit(): void {
        let optionElem = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select WorkCategory";
        document.querySelector('select#workCategoryCrudId').append(optionElem);


        let workCategoriesObs = this.myFundiService.GetAllFundiWorkCategories();
        workCategoriesObs.map((wcs: IWorkCategory[]) => {
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
            let p: boolean = q;
            alert('workCategory Added: ' + p);
            if (p) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        $('form#locationView').css('display', 'block').slideDown();
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
        $('form#locationView').css('display', 'block').slideDown();
    }
    public selectworkCategory(): void {
        let actualResult: Observable<any> = this.myFundiService.GetworkCategoryById(this.workCategory.workCategoryId);
        actualResult.map((p: any) => {
            this.workCategory = p;
        }).subscribe();
        $('form#locationView').css('display', 'block').slideDown();
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
        $('form#locationView').css('display', 'block').slideDown();
    }
    public ngOnInit(): void {
        this.workCategory = {}
    }
}
