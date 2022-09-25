import { Component, OnInit, Inject, AfterContentInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IFundiRatingDictionary, IJob, ICoordinate } from '../../services/myFundiService';
import { Observable } from 'rxjs';
//import * as $ from 'jquery';
import { Router } from '@angular/router';
import { AfterViewInit } from '@angular/core';
import { AfterViewChecked } from '@angular/core';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';
declare var jQuery: any;


@Component({
  selector: 'client-fundi-search',
  templateUrl: './clientFundiSearch.component.html',
  providers: [AddressLocationGeoCodeService, MyFundiService]
})
export class ClientFundiSearchComponent implements OnInit, AfterViewChecked {
  userDetails: any;
  userRoles: string[];
  profile: IProfile;
  jobId: number;
  jobLocationCoordinate: ICoordinate;
  jobs: IJob[];
  location: ILocation;
  fundiRatings: IFundiRating[];
  workCategories: IWorkCategory[];
  certifications: ICertification[];
  courses: ICourse[];
  categories: string;
  fundiProfileRatingDictionary: any;
  profileIdKeys: string[];
  currentRating: number;
  fundiWorkCategories: string[];
  fundiSkills: string[];
  actualProfileIdKeys: string[];
  fundiListSatisfyingJobRadiusDictionary: any[];

  decoderUrl(url: string): string {
    return decodeURIComponent(url);
  }

  ngOnInit(): void {
    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
    this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    jQuery('#fundiSearchForm div#fundiCategories').children().remove();

    let workCatObs = this.myFundiService.GetAllFundiWorkCategories();
    workCatObs.map((workCats: IWorkCategory[]) => {
      this.workCategories = workCats;

      //Dynamic check boxes for Categories To Search for:
      let divFundiCategories: HTMLElement = document.querySelector('#fundiSearchForm div#fundiCategories');


      this.workCategories.forEach((cat) => {
        let chBoxLabel = document.createElement('label');
        chBoxLabel.textContent = cat.workCategoryType;
        let chBox = document.createElement('input');
        let type = document.createAttribute('type');
        let value = document.createAttribute('value');
        let attrName = document.createAttribute('name');
        let cbzindex = document.createAttribute('style');
        cbzindex.value = "z-index: 1";
        value.value = cat.workCategoryType;
        type.value = "checkbox";
        chBox.attributes.setNamedItem(type);
        chBox.attributes.setNamedItem(value);
        chBox.attributes.setNamedItem(cbzindex);

        attrName.value = cat.workCategoryType;
        chBox.attributes.setNamedItem(attrName);
        let hr = document.createElement('hr');
        let br = document.createElement('br');
        chBoxLabel.className = 'custom-control-label';
        chBox.className = 'custom-control-input';
        let divWrapper = document.createElement('div');
        let divFormGroup = document.createElement('div');
        divFormGroup.className = "form-group";
        divWrapper.className = "custom-control custom-checkbox";

        divWrapper.appendChild(chBox);
        divWrapper.appendChild(chBoxLabel);
        divWrapper.appendChild(br);
        divWrapper.appendChild(hr);

        divFormGroup.appendChild(divWrapper);
        divFundiCategories.appendChild(divFormGroup);

      });
    }).subscribe();


    let locatObs: Observable<IJob[]> = this.myFundiService.GetAllJobs();

    locatObs.map((jobs: IJob[]) => {

      let addSelect = document.querySelector('select#jobId');
      let opts = addSelect.querySelector('option');
      if (opts) {
        opts.remove();
      }


      let optionElem: HTMLOptionElement = document.createElement('option');
      optionElem.selected = true;
      optionElem.value = (0).toString();
      optionElem.text = "Select Job";
      document.querySelector('select#jobId').append(optionElem);

      if (jobs && jobs.length > 0) {
        let allJobs: IJob[] = jobs;
        this.jobs = allJobs;

        allJobs.forEach((comCat: IJob, index: number, cmdCats) => {
          let optionElem: HTMLOptionElement = document.createElement('option');
          optionElem.value = comCat.jobId.toString();
          optionElem.text = comCat.jobName;
          document.querySelector('select#jobId').append(optionElem);
        });
      }

    }).subscribe();
  }
  constructor(private myFundiService: MyFundiService,private addressLocationService:AddressLocationGeoCodeService, private router: Router) {
    this.userDetails = {};
  }
  roundPositiveNumberTo2DecPlaces(num: number): number {
    return this.addressLocationService.roundPositiveNumberTo2DecPlaces(num);
  }
  ngAfterViewChecked(): void {
    let curthis = this;
    jQuery('div.rating').starRating(
      {
        initialRating: 0,
        starSize: 25,
        useFullStars: true,
        callback: function (rating) {
          curthis.currentRating = rating;
        }
      });

  }

  searchFundiByCategories($event) {

    this.fundiListSatisfyingJobRadiusDictionary = [];
    this.fundiProfileRatingDictionary = {};
    this.actualProfileIdKeys = [];
    this.profileIdKeys = null;
    let divFundiCategories: HTMLElement = document.querySelector('form#fundiSearchForm div#fundiCategories');
    let chosenCategories: string[] = [];

    if (this.jobs && this.jobs.length > 0) {

      let selectedJob: IJob = this.jobs.find((j: IJob) => {
        return j.jobId == this.jobId;
      });

      this.jobLocationCoordinate = {
        latitude: selectedJob.location.latitude,
        longitude: selectedJob.location.longitude
      };

      let checkedboxes = jQuery('form#fundiSearchForm div#fundiCategories').find('input[type="checkbox"]:checked');
      for (let n = 0; n < checkedboxes.length; n++) {
        chosenCategories.push(checkedboxes[n].name);
      }
      let fundiRatingsObs: Observable<any> = this.myFundiService.GetFundiRatingsAndReviews(chosenCategories, this.jobLocationCoordinate);

      fundiRatingsObs.map((q: any) => {

        this.fundiProfileRatingDictionary = q;
        this.profileIdKeys = Object.keys(this.fundiProfileRatingDictionary);

        if (this.profileIdKeys && this.profileIdKeys.length > 0) {

          for (var n = 0; n < this.profileIdKeys.length; n++) {

            let fundiProfileId: number = parseInt(this.profileIdKeys[n]);

            this.getFundiWorkCategoriesByProfileId(fundiProfileId);

            this.fundiListSatisfyingJobRadiusDictionary.push(
              {
                fundiProfileId: fundiProfileId, fundiProfileData: this.fundiProfileRatingDictionary[fundiProfileId]
              }
            );
            this.actualProfileIdKeys.push(fundiProfileId.toString());
          }
        }

      }).subscribe();

      $event.stopPropagation();
    }
    else {
      alert("There are currently no jobs that match your criteria within 5Km of your chosen location!")
    }
  }

  rateFundi($event) {

    let button = $event.target;
    let review = jQuery(button).parent('form').find('textarea').val();
    let profileId: number = button.id;
    let rating: number = this.currentRating;
    let workCategory: string = jQuery(button).parent('form').find('select').val();

    alert('rated ' + rating);
    let userIdObs: Observable<any> = this.myFundiService.GetUserGuidId(this.userDetails.username);

    userIdObs.map((userId: any) => {

      let fundiRated: any = {
        fundiProfileId: profileId,
        rating: rating,
        review: review,
        userId: userId,
        workCategoryType: workCategory
      };

      let fundiRatedObs: Observable<any> = this.myFundiService.RateFundiByProfileId(fundiRated);
      fundiRatedObs.map((res: any) => {
        alert(res.message);
      }).subscribe();
    }).subscribe();

  }
  getFundiWorkCategoriesByProfileId(profileId: number) {
    let fundiWorkCatObs: Observable<string[]> = this.myFundiService.GetFundiWorkCategoriesByProfileId(profileId);

    fundiWorkCatObs.map((res: string[]) => {
      let fundiWorkCategories = res;
      let ul = jQuery(document).find(`ul#${profileId}-workCategory`);
      let ulskillsChildren = jQuery(document).find(`ul#${profileId}-workCategory li`);
      //ulWorkCatChildren.remove();
      for (let workCat in fundiWorkCategories) {
        let li = document.createElement('li');
        li.innerHTML = fundiWorkCategories[workCat];
        jQuery(ul).append(li);
      }
      this.getFundiSkillsByProfileId(profileId);
    }).subscribe();
  }
  getFundiSkillsByProfileId(profileId: number) {
    let fundiSkillsObs: Observable<string[]> = this.myFundiService.GetFundiSkillsByProfileId(profileId);

    fundiSkillsObs.map((res: string[]) => {
      let fundiSkills = res;
      let ul = jQuery(document).find(`ul#${profileId}-skills`);
      let ulskillsChildren = jQuery(document).find(`ul#${profileId}-skills li`);
      //ulskillsChildren.remove();
      let li = document.createElement('li');
      li.innerHTML = fundiSkills[0];
      jQuery(ul).append(li);
    }).subscribe();
  }
  populateFundiUserDetails($event, profileId: number) {
    let userObs: Observable<any> = this.myFundiService.GetFundiUserByProfileId(profileId);

    userObs.map((res: any) => {
      localStorage.setItem("profileUserDetails", JSON.stringify(res));
      this.router.navigateByUrl('/fundiprofile-by-id');
    }).subscribe();
    $event.preventDefault();
  }

  arePointsNear(checkPoint: ICoordinate, centerPoint: ICoordinate, km: number): boolean {
    var ky = 40000 / 360;
    var kx = Math.cos(Math.PI * centerPoint.latitude / 180.0) * ky;
    var dx = Math.abs(centerPoint.longitude - checkPoint.longitude) * kx;
    var dy = Math.abs(centerPoint.latitude - checkPoint.latitude) * ky;
    return Math.sqrt(dx * dx + dy * dy) <= km;
  }

}

