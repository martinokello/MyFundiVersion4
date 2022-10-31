import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IAddress, IClientProfile, IJob } from '../../services/myFundiService';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
declare var jQuery: any;

@Component({
    selector: 'client-job-view',
    templateUrl: './clientjobview.component.html'
})
export class ClientJobViewComponent implements OnInit {
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
    workCategories: IWorkCategory[];
    chosenWorkCategories: IWorkCategory[];
    job: IJob;
    jobs: IJob[];

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

        debugger;
    }
    constructor(private myFundiService: MyFundiService, private router: Router, private httpClient: HttpClient) {
        this.userDetails = {};
    }

    applyForJob($event){
        //Send Email Application to Client Email:
        alert('Applied For Job');
        $event.preventDefault();
    }
}

