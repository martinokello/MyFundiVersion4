import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IWorkSubCategory, IWorkAndSubWorkCategory } from '../../services/myFundiService';
declare var jQuery: any;

@Component({
    selector: 'profile',
    templateUrl: './profile.component.html'
})
export class ProfileComponent implements OnInit {
    userDetails: any;
    userRoles: string[];
    profile: IProfile;
    location: ILocation;
    fundiRatings: IFundiRating[];
    workCategories: IWorkAndSubWorkCategory[];
    certifications: ICertification[];
    courses: ICourse[];
    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {

        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        if (!this.userDetails) this.userDetails = {};
        if (!this.userDetails.username) {
            this.userDetails.username = MyFundiService.clientEmailAddress;
        }
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));


        let resObs = this.myFundiService.GetFundiProfile(this.userDetails.username);
        resObs.map((prof: IProfile) => {
            this.profile = prof;

            let workCatObs = this.myFundiService.GetFundiWorkCategories(this.userDetails.username);
            workCatObs.map((workCats: IWorkAndSubWorkCategory[]) => {
                this.workCategories = workCats;
                let coursesObs = this.myFundiService.GetFundiCourses(this.userDetails.username);
                    coursesObs.map((courses: ICourse[]) => {
                        this.courses = courses;
                        let certsObs = this.myFundiService.GetFundiCertifications(this.userDetails.username);
                        certsObs.map((certs: ICertification[]) => {
                            this.certifications = certs;
                            let ratingsObs = this.myFundiService.GetFundiRatings(this.userDetails.username);
                            ratingsObs.map((ratings: IFundiRating[]) => {
                                this.fundiRatings = ratings;
                        }).subscribe();
                    }).subscribe();
                }).subscribe();
            }).subscribe();
        }).subscribe();


    }
    constructor(private myFundiService: MyFundiService) {
        this.userDetails = {};
        this.profile = {
            fundiProfileId: 0,
            userId: "",
            profileSummary: "",
            profileImageUrl: "",
            skills: "",
            usedPowerTools: "",
            fundiProfileCvUrl: "",
            locationId: 0,
            user: null
        };
    }
}

