import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IWorkAndSubWorkCategory } from '../../services/myFundiService';

@Component({
    selector: 'profile-by-id',
    templateUrl: './fundiProfileById.component.html'
})
export class FundiProfileByIdComponent implements OnInit {
    profileUserDetails: any;
    userRoles: string[];
    profile: IProfile;
    profileId: number;
    location: ILocation;
    fundiRatings: IFundiRating[];
    workCategories: IWorkAndSubWorkCategory[];
    certifications: ICertification[];
    courses: ICourse[];
    fundiAverageRating: number = 0;

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {
        this.profileUserDetails = JSON.parse(localStorage.getItem("profileUserDetails"));
        this.profileId = this.profileUserDetails.fundiProfileId;
        let resObs = this.myFundiService.GetFundiProfileByProfileId(this.profileId.toString());
        let certsObs = this.myFundiService.GetFundiCertifications(this.profileUserDetails.username);
        let workCatObs = this.myFundiService.GetFundiWorkCategories(this.profileUserDetails.username);
        let coursesObs = this.myFundiService.GetFundiCourses(this.profileUserDetails.username);
        let ratingsObs = this.myFundiService.GetFundiRatings(this.profileUserDetails.username);

        resObs.map((fundiProf: IProfile) => {
            this.profile = fundiProf;;
            ratingsObs.map((ratings: IFundiRating[]) => {
                this.fundiRatings = ratings;
                this.fundiAverageRating = 0
                this.fundiRatings.forEach((rating, index, ratings) => {
                    this.fundiAverageRating += rating.rating;
                });

                this.fundiAverageRating = (this.fundiAverageRating / ratings.length);

            }).subscribe();
            coursesObs.map((courses: ICourse[]) => {
                this.courses = courses;
            }).subscribe();
            workCatObs.map((workCats: IWorkAndSubWorkCategory[]) => {
                this.workCategories = workCats;
            }).subscribe();
            certsObs.map((certs: ICertification[]) => {
                this.certifications = certs;
            }).subscribe();
            localStorage.removeItem("profileUserDetails");
        }).subscribe();

        let downloadLink: HTMLAnchorElement = document.querySelector('a#downloadCV');
        downloadLink.setAttribute('href', `/FundiProfile/GetFundiCVByUsername?username=${this.profileUserDetails.username}`);

    }
    constructor(private myFundiService: MyFundiService) {
        this.profileUserDetails = {};
    }
}

