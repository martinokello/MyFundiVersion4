import { Component, OnInit, Inject, AfterViewChecked, AfterViewInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IAddress, IClientProfile, IJob, IEmailMessage, IWorkAndSubWorkCategory } from '../../services/myFundiService';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
declare var jQuery: any;
import { modifyHasPopulatedPage } from '../../imports.js';

@Component({
    selector: 'client-job-view',
    templateUrl: './clientjobview.component.html'
})
export class ClientJobViewComponent implements OnInit, AfterViewInit {
    userDetails: any;
    userRoles: string[];
    locationId: number;
    fundiProfileId: number;
    clientProfileId: number;
    numberOfDaysToComplete: number;
    profileImage: File;
    clientProfile: IClientProfile | any;
    fundiProfile: any;
    location: ILocation;
    clientUserGuidId: string;
    jobDescription: string;
    jobName: string;
    address: IAddress;
    addressId: number;
    profileSummary: string;
    clientProfiles: IClientProfile[];
    fundiProfiles: IProfile[];
    workCategories: IWorkAndSubWorkCategory[];
    chosenWorkCategories: IWorkCategory[];
    job: IJob;
    jobs: IJob[];
    coverNote: string = "";
    email: IEmailMessage;

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {

        this.chosenWorkCategories = [];
        this.userDetails = JSON.parse(localStorage.getItem("CurrentClientUserDetails"));
        this.clientProfile = JSON.parse(localStorage.getItem("CurrentJobClientProfile"));
        this.job = JSON.parse(localStorage.getItem("CurrentJob"));
        this.workCategories = JSON.parse(localStorage.getItem('CurrentJobWorkCategories'));

        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));

        this.email = {
            emailBody: "",
            attachment: null,
            emailSubject: "",
            emailTo: "",
            emailFrom: ""
        }

    }
    constructor(private myFundiService: MyFundiService, private router: Router, private httpClient: HttpClient) {
        this.userDetails = {};
    }

    getFiles($event) {
        this.email.attachment = $event.target.files;
    }

    sendEmail($event): void {

        let form: HTMLFormElement = document.querySelector("form#fundiJobApplicationForm");
        if (form.checkValidity()) {
            let formData = new FormData();
            formData.append('emailBody', this.email.emailBody);
            formData.append('emailTo', this.userDetails.username);
            formData.append('emailFrom', this.email.emailFrom);
            formData.append('emailSubject', this.email.emailSubject);
            formData.append('attachment', this.email.attachment);
            let result: Observable<boolean> = this.myFundiService.SendEmail(formData);
            result.map((value: any) => {
                alert(value.message)
            }).subscribe();}

        $event.preventDefault();
    }

    ngAfterViewInit() {

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

            modifyHasPopulatedPage(true);
        });
    }
}

