import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../services/myFundiService';

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
  workCategories: IWorkCategory[];
  certifications: ICertification[];
  courses: ICourse[];
  decoderUrl(url: string):string {
    return decodeURIComponent(url);
  }
  ngOnInit(): void {
    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
    this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    let resObs = this.myFundiService.GetFundiProfile(this.userDetails.username);
    let certsObs = this.myFundiService.GetFundiCertifications(this.userDetails.username);
    let workCatObs = this.myFundiService.GetFundiWorkCategories(this.userDetails.username);
    let coursesObs = this.myFundiService.GetFundiCourses(this.userDetails.username);
    let ratingsObs = this.myFundiService.GetFundiRatings(this.userDetails.username);

    resObs.map((fundiProf: IProfile) => {
      this.profile = fundiProf;
    }).subscribe();
    ratingsObs.map((ratings: IFundiRating[]) => {
      this.fundiRatings = ratings;
    }).subscribe();
    coursesObs.map((courses: ICourse[]) => {
      this.courses = courses;
    }).subscribe();
    workCatObs.map((workCats: IWorkCategory[]) => {
      this.workCategories = workCats;
    }).subscribe();
    certsObs.map((certs: ICertification[]) => {
      this.certifications = certs;
    }).subscribe();


    let downloadLink: HTMLAnchorElement = document.querySelector('a#downloadCV');
    downloadLink.setAttribute('href', `/FundiProfile/GetFundiCVByUsername?username=${this.userDetails.username}`);

  }
  constructor(private myFundiService: MyFundiService) {
    this.userDetails = {};
  }
}

