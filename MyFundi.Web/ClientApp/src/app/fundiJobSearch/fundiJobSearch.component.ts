import { Component, OnInit, Inject, AfterContentInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IFundiRatingDictionary, IJob, ICoordinate } from '../../services/myFundiService';
import { Observable } from 'rxjs';
//import * as $ from 'jquery';
import { Router } from '@angular/router';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';
declare var jQuery: any;

@Component({
  selector: 'fundi-job-search',
    templateUrl: './fundiJobSearch.component.html',
    providers: [AddressLocationGeoCodeService]
})
export class FundiJobSearchComponent implements OnInit {
  userDetails: any;
  userRoles: string[];
  fundiId: number;
  jobs: IJob[];
  workCategories: IWorkCategory[];
  categories: string;
  fundiJobList: any;
  fundiWorkCategories: string[];

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

  }
  constructor(private myFundiService: MyFundiService, private addressLocationService: AddressLocationGeoCodeService, private router: Router) {
    this.userDetails = {};
  }

  getWorkCategoryNameById(catId: number): string {
    return this.workCategories.find(q => { return q.workCategoryId == catId }).workCategoryType;
  }
  roundPositiveNumberTo2DecPlaces(num: number): number {
    return this.addressLocationService.roundPositiveNumberTo2DecPlaces(num);
  }
  searchJobsByCategories($event) {

    this.fundiJobList = [];
    let divFundiCategories: HTMLElement = document.querySelector('form#fundiSearchForm div#fundiCategories');
    let chosenCategories: string[] = [];


      let checkedboxes = jQuery('form#fundiSearchForm div#fundiCategories').find('input[type="checkbox"]:checked');
      for (let n = 0; n < checkedboxes.length; n++) {
        chosenCategories.push(checkedboxes[n].name);
      }
      let fundiJobsObs: Observable<any> = this.myFundiService.GetJobsByCategoriesAndFundiUser(this.userDetails.username, chosenCategories);

      fundiJobsObs.map((n: any) => {
          let q: any[] = n;
        if (q && q.length > 0) {

          this.fundiJobList = q;

        } else {
          alert("There are currently no jobs that match your criteria within 5Km of your chosen location!")
        }

      }).subscribe();

      $event.stopPropagation();
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

