import { Component, OnInit, Inject, AfterViewChecked, AfterContentInit, AfterViewInit } from '@angular/core';
import { Pipe, PipeTransform } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IAddress, IClientProfile, IJob, IEmailMessage, IWorkAndSubWorkCategory, IJobApplication } from '../../services/myFundiService';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
declare var jQuery: any;
import { modifyHasPopulatedPage } from '../../imports.js';
declare let sceditor: any;

@Component({
    selector: 'client-job-view',
    templateUrl: './clientjobview.component.html'
})
export class ClientJobViewComponent implements OnInit, AfterViewChecked, AfterContentInit, AfterViewInit {
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
    setTo: NodeJS.Timeout;
    jobApplication: IJobApplication;
    hasPopulatedPage: boolean = false;

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngAfterViewInit() {

        jQuery('#emailBody').focus();
    }
    ngOnInit(): void {
        this.chosenWorkCategories = [];
        this.userDetails = JSON.parse(localStorage.getItem("CurrentClientUserDetails"));
        this.clientProfile = JSON.parse(localStorage.getItem("CurrentJobClientProfile"));
        this.job = JSON.parse(localStorage.getItem("CurrentJob"));
        this.workCategories = JSON.parse(localStorage.getItem('CurrentJobWorkCategories'));

        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        this.jobApplication = {
            firstName: "",
            lastName: "",
            appliedToJob: this.job.jobName,
            coverLetter: "",
            emailAddress: "",
            earliestStartDate: new Date(),
            preferredInterviewDate: new Date(),
            fileAttachments: [],
            bidRatePerHour: 0,
            totalAmountPerHour: 0,
            upwardServiceFee: 0,
            justifyPercentOfServiceFee: "",
            amountYouWillRecieveMinusService: 0,
            mobileNumber:""
        }

        this.email = {
            emailBody: "",
            attachment: null,
            emailSubject: "",
            emailTo: "",
            emailFrom: ""
        }

    }
    ngAfterContentInit() {
        //this.jobApplication.fileAttachments = [];
    }
    constructor(private myFundiService: MyFundiService, private router: Router, private httpClient: HttpClient) {
        this.userDetails = {};
    }
    clearFiles($event) {
        this.jobApplication.fileAttachments = [];
        $event.preventDefault();
    }
    getFiles($event) {
        let file: File = $event.target.files.item(0);

        let val: File = this.jobApplication.fileAttachments.find((f, ind) => {
            return file.name === f.name;
        });
        if (!val) {
            this.jobApplication.fileAttachments.push(file);
        }
    }

    sendEmail($event): void {
        let value = this.jobApplication.coverLetter;
        let formData = new FormData();
        let emailbody = "";

        let textarea = jQuery('textarea#emailbody')[0];
        let scEditInstance = sceditor.instance(textarea);
        let emailBody = scEditInstance.getBody().innerHTML;

        formData.append('coverLetter', emailBody);
        formData.append('emailTo', this.userDetails.username);
        formData.append('emailFrom', this.jobApplication.emailAddress);
        formData.append('emailSubject', this.jobApplication.appliedToJob);
        formData.append('amountYouWillRecieveMinusService', this.jobApplication.amountYouWillRecieveMinusService.toString());
        formData.append('bidRatePerHour', this.jobApplication.bidRatePerHour.toString());
        formData.append('earliestStartDate', this.jobApplication.earliestStartDate.toString());
        formData.append('firstName', this.jobApplication.firstName);
        formData.append('lastName', this.jobApplication.lastName);
        formData.append('justifyPercentOfServiceFee', this.jobApplication.justifyPercentOfServiceFee);
        formData.append('totalAmountPerHour', this.jobApplication.totalAmountPerHour.toString());
        formData.append('mobileNumber', this.jobApplication.mobileNumber);
        formData.append('preferredInterviewDate', this.jobApplication.preferredInterviewDate.toString());

        for (let n = 0; n < this.jobApplication.fileAttachments.length; n++) {
            formData.append('attachment-' + n.toString(), this.jobApplication.fileAttachments[n]);
        }
        let result: Observable<boolean> = this.myFundiService.SendEmailMultiAttachments(formData);
        result.map((value: any) => {
            alert(value.message)
        }).subscribe();
        $event.preventDefault();
    }


    ngAfterViewChecked() {
    let curthis = this;

    this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
    runAutoCompleteOnSelects(curthis: any) {
    let hasFoundSelectsOnPage = false;

    if (!curthis.hasPopulatedPage) {

        let selects = jQuery('div#client-wrapper select');

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

        jQuery('div#editableClientDetails').hide(2000);
        clearTimeout(curthis.setTo);
    }
}
}

