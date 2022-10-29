import { Component, OnInit, ViewChild, ElementRef, Input, Output, Injectable, Inject, EventEmitter, AfterContentInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ICompany, IAddress, ILocation, MyFundiService } from '../../../services/myFundiService';
import { Element } from '@angular/compiler';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';

@Component({
    selector: 'company',
    templateUrl: './company.component.html',
    styleUrls: ['./company.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class CompanyComponent implements OnInit, AfterContentInit {
    private myFundiService: MyFundiService;
    public company: ICompany | any;
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
        $('form#locationView').css('display', 'block').slideDown();
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
        $('form#locationView').css('display', 'block').slideDown();
    }
    public selectCompany(): void {
        let actualResult: Observable<any> = this.myFundiService.GetCompanyById(this.company.companyId);
        actualResult.map((p: any) => {
            this.company = p;
        }).subscribe();
        $('form#locationView').css('display', 'block').slideDown();
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
        $('form#locationView').css('display', 'block').slideDown();
    }
    public ngOnInit(): void {
        this.company = {}
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
}
