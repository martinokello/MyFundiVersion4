var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var _a;
import { Component } from '@angular/core';
import { MyFundiService } from '../../services/myFundiService';
import { Router } from '@angular/router';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';
let FundiJobSearchComponent = class FundiJobSearchComponent {
    constructor(myFundiService, addressLocationService, router) {
        this.myFundiService = myFundiService;
        this.addressLocationService = addressLocationService;
        this.router = router;
        this.fundiJobList = [];
    }
    decoderUrl(url) {
        return decodeURIComponent(url);
    }
    ngOnInit() {
        this.distanceKmLimitApart = 50000000;
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        jQuery('#fundiSearchForm div#fundiCategories').children().remove();
        let workCatObs = this.myFundiService.GetWorkCategories();
        workCatObs.map((workCats) => {
            this.workCategories = workCats;
            //Dynamic check boxes for Categories To Search for:
            let divFundiCategories = document.querySelector('#fundiSearchForm div#fundiCategories');
            this.workCategories.forEach((cat) => {
                let chBoxLabel = document.createElement('label');
                chBoxLabel.textContent = cat.workCategoryType;
                let chBox = document.createElement('input');
                let type = document.createAttribute('type');
                let value = document.createAttribute('value');
                let attrName = document.createAttribute('name');
                let cbzindex = document.createAttribute('style');
                cbzindex.value = "z-index: 1";
                value.value = cat.workCategoryId.toString();
                type.value = "checkbox";
                chBox.attributes.setNamedItem(type);
                chBox.attributes.setNamedItem(value);
                chBox.attributes.setNamedItem(cbzindex);
                attrName.value = cat.workCategoryId.toString();
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
                let ul = document.createElement('ul');
                let li = document.createElement('li');
                ul.setAttribute('class', 'ulCategories');
                divFormGroup.appendChild(divWrapper);
                li.append(divFormGroup);
                ul.appendChild(li);
                divFundiCategories.appendChild(ul);
                let workSubCatObs = this.myFundiService.GetAllFundiWorkSubCategoriesByWorkCategoryId(cat.workCategoryId);
                workSubCatObs.map((workSubCats) => {
                    let workSubCategories = workSubCats;
                    //Dynamic check boxes for Categories To Search for:
                    let ul2 = document.createElement('ul');
                    ul2.setAttribute('class', 'ulSubCategories');
                    let li2 = document.createElement('li');
                    workSubCategories.forEach((cat) => {
                        let chBoxLabel = document.createElement('label');
                        chBoxLabel.textContent = cat.workSubCategoryType;
                        let chBox = document.createElement('input');
                        let type = document.createAttribute('type');
                        let value = document.createAttribute('value');
                        let attrName = document.createAttribute('name');
                        let cbzindex = document.createAttribute('style');
                        cbzindex.value = "z-index: 1";
                        value.value = cat.workSubCategoryType;
                        type.value = "checkbox";
                        chBox.attributes.setNamedItem(type);
                        chBox.attributes.setNamedItem(value);
                        chBox.attributes.setNamedItem(cbzindex);
                        attrName.value = cat.workSubCategoryType;
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
                        divFormGroup.append(divWrapper);
                        li2.appendChild(divFormGroup);
                        li2.appendChild(hr);
                        ul2.appendChild(li2);
                        li.appendChild(ul2);
                    });
                    li.appendChild(hr);
                }).subscribe();
            });
        }).subscribe();
        jQuery('ul.ulCategories  ul.ulSubCategories').hide('fast');
        jQuery('ul.ulCategories').children('checkbox').click(function () {
            jQuery(this).children('ul.ulSubCategories').toggle('slow');
        });
    }
    roundPositiveNumberTo2DecPlaces(num) {
        return this.addressLocationService.roundPositiveNumberTo2DecPlaces(num);
    }
    searchJobsByCategories($event) {
        ;
        let curthis = this;
        this.fundiJobList = [];
        let chosenCategories = [];
        let viewObjects = [];
        let categories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulCategories > li > div > div > input[type="checkbox"]:checked');
        categories.each(function (ind, elem) {
            chosenCategories.push(elem.name);
            let chosenSubCategories = [];
            let subCategories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulSubCategories > li > div > div > input[type="checkbox"]:checked');
            subCategories.each(function (ind, elem) {
                chosenSubCategories.push(elem.name);
            });
            viewObjects.push({ username: MyFundiService.clientEmailAddress, workCategories: chosenCategories, workSubCategories: chosenSubCategories, coordinate: { latitude: 0, longitude: 0 } });
        });
        let username = MyFundiService.clientEmailAddress;
        let fundiObjs = curthis.myFundiService.GetFundiProfile(username);
        fundiObjs.map((q) => {
            let locsObj = curthis.myFundiService.GetFundiLocationByFundiProfileId(q.fundiProfileId);
            locsObj.map((r) => {
                this.fundiLocation = r;
                for (let n = 0; n < viewObjects.length; n++) {
                    viewObjects[n].coordinate.latitude = r.latitude;
                    viewObjects[n].coordinate.longitude = r.longitude;
                }
                let fundiJobsObs = this.myFundiService.GetJobsByCategoriesAndFundiUser(viewObjects, q.fundiProfileId, this.distanceKmLimitApart, this.skip, this.take);
                fundiJobsObs.map((n) => {
                    debugger;
                    let q = n;
                    debugger;
                    if (q && q.length > 0) {
                        this.fundiJobList = q;
                    }
                    else {
                        alert("There are currently no jobs that match your criteria within 5Km of your chosen location!");
                    }
                }).subscribe();
            }).subscribe();
        }).subscribe();
        $event.stopPropagation();
    }
    getJobPage($event) {
        localStorage.removeItem('CurrentJob');
        localStorage.removeItem('CurrentClientUserDetails');
        localStorage.removeItem('CurrentJobClientProfile');
        localStorage.removeItem('CurrentJobWorkCategories');
        let jobId = parseInt(jQuery($event.target).attr('id'));
        let jobObs = this.myFundiService.GetJobByJobId(jobId);
        jobObs.map((job) => {
            localStorage.setItem('CurrentJob', JSON.stringify(job));
            let clientObs = this.myFundiService.GetClientProfileById(job.clientProfileId);
            clientObs.map((clientProfile) => {
                localStorage.setItem('CurrentJobClientProfile', JSON.stringify(clientProfile));
                let clientUserObs = this.myFundiService.GetClientUserById(clientProfile.userId);
                clientUserObs.map((clientUser) => {
                    localStorage.setItem('CurrentClientUserDetails', JSON.stringify(clientUser));
                    let currJobWorkCatsObs = this.myFundiService.GetJobWorkCategoriesByJobId(job.jobId);
                    currJobWorkCatsObs.map((wCats) => {
                        localStorage.setItem('CurrentJobWorkCategories', JSON.stringify(wCats));
                        if (clientProfile && job) {
                            this.router.navigateByUrl('job-details');
                        }
                        else {
                            alert('Job doesn\'t exist!');
                        }
                    }).subscribe();
                }).subscribe();
            }).subscribe();
        }).subscribe();
        $event.preventDefault();
    }
    getFundiWorkCategoriesByProfileId(profileId) {
        let fundiWorkCatObs = this.myFundiService.GetFundiWorkCategoriesByProfileId(profileId);
        fundiWorkCatObs.map((res) => {
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
    getFundiSkillsByProfileId(profileId) {
        let fundiSkillsObs = this.myFundiService.GetFundiSkillsByProfileId(profileId);
        fundiSkillsObs.map((res) => {
            let fundiSkills = res;
            let ul = jQuery(document).find(`ul#${profileId}-skills`);
            let ulskillsChildren = jQuery(document).find(`ul#${profileId}-skills li`);
            //ulskillsChildren.remove();
            let li = document.createElement('li');
            li.innerHTML = fundiSkills[0];
            jQuery(ul).append(li);
        }).subscribe();
    }
    populateFundiUserDetails($event, profileId) {
        let userObs = this.myFundiService.GetFundiUserByProfileId(profileId);
        userObs.map((res) => {
            localStorage.setItem("profileUserDetails", JSON.stringify(res));
            this.router.navigateByUrl('/fundiprofile-by-id');
        }).subscribe();
        $event.preventDefault();
    }
    arePointsNear(checkPoint, centerPoint, km) {
        var ky = 40000 / 360;
        var kx = Math.cos(Math.PI * centerPoint.latitude / 180.0) * ky;
        var dx = Math.abs(centerPoint.longitude - checkPoint.longitude) * kx;
        var dy = Math.abs(centerPoint.latitude - checkPoint.latitude) * ky;
        return Math.sqrt(dx * dx + dy * dy) <= km;
    }
};
FundiJobSearchComponent = __decorate([
    Component({
        selector: 'fundi-job-search',
        templateUrl: './fundiJobSearch.component.html',
        providers: [AddressLocationGeoCodeService]
    }),
    __metadata("design:paramtypes", [MyFundiService, AddressLocationGeoCodeService, typeof (_a = typeof Router !== "undefined" && Router) === "function" ? _a : Object])
], FundiJobSearchComponent);
export { FundiJobSearchComponent };
