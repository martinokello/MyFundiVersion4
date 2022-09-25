import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../services/myFundiService';

@Component({
  selector: 'profile-by-id',
  templateUrl: './fundiProfileById.component.html'
})
export class FundiProfileByIdComponent implements OnInit {
  profileUserDetails: any;
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
    this.profileUserDetails = JSON.parse(localStorage.getItem("profileUserDetails"));
    let resObs = this.myFundiService.GetFundiProfile(this.profileUserDetails.username);
    let certsObs = this.myFundiService.GetFundiCertifications(this.profileUserDetails.username);
    let workCatObs = this.myFundiService.GetFundiWorkCategories(this.profileUserDetails.username);
    let coursesObs = this.myFundiService.GetFundiCourses(this.profileUserDetails.username);
    let ratingsObs = this.myFundiService.GetFundiRatings(this.profileUserDetails.username);

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
    downloadLink.setAttribute('href', `/FundiProfile/GetFundiCVByUsername?username=${this.profileUserDetails.username}`);

  }
  constructor(private myFundiService: MyFundiService) {
    this.profileUserDetails = {};
  }
}

