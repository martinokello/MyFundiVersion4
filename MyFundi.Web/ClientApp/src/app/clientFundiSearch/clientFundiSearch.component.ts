import { Component, OnInit, Inject, AfterViewChecked, AfterViewInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IFundiRatingDictionary, IJob, ICoordinate, IWorkSubCategory, IClientProfile, IWorkAndSubWorkCategory } from '../../services/myFundiService';
import { Observable } from 'rxjs';
import { Router } from '@angular/router';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';
declare var jQuery: any;
import { modifyHasPopulatedPage } from '../../imports.js';

@Component({
    selector: 'client-fundi-search',
    templateUrl: './clientFundiSearch.component.html',
    providers: [AddressLocationGeoCodeService, MyFundiService]
})
export class ClientFundiSearchComponent implements OnInit, AfterViewInit, AfterViewChecked {
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
    hasGotRating: boolean = false;
    hasAddedAutoComplete: boolean = false;
    setTo: NodeJS.Timeout;
    distanceKmLimitApart: number;
    skip: number;
    take: number;
    fundiProfileList: any[];
    job: IJob;
    jobLocation: ILocation;
    fundiSatisfyingJobList: any[] = [];;

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }

    ngOnInit(): void {
        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));

        this.distanceKmLimitApart = 50000000;
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        jQuery('#fundiSearchForm div#fundiCategories').children().remove();

        let workCatObs: Observable<IWorkCategory[]> = this.myFundiService.GetWorkCategories();
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
                li.append(divFormGroup)
                ul.appendChild(li)
                divFundiCategories.appendChild(ul);

                let workSubCatObs = this.myFundiService.GetAllFundiWorkSubCategoriesByWorkCategoryId(cat.workCategoryId);
                workSubCatObs.map((workSubCats: IWorkSubCategory[]) => {
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

        let locatObs: Observable<IJob[]> = this.myFundiService.GetAllJobs();

        locatObs.map((jobs: IJob[]) => {
            this.jobs = jobs;
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

        jQuery('ul.ulCategories > li > checkbox').click(function () {

            jQuery(this).parent('li').parent('ul.ulCategories').toggle('slow');
        });
    }
    constructor(private myFundiService: MyFundiService, private addressLocationService: AddressLocationGeoCodeService, private router: Router) {
        this.userDetails = {};
    }


    ngAfterViewInit() {
        let curthis = this;
        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }

    runAutoCompleteOnSelects(curthis: any) {

        if (curthis.jobs && curthis.jobs.length > 0) {
                //Check For Dom Change and Add auto complete to select elements
            let hasFoundSelectsOnPage = false;

                let selects = jQuery('div#clientfundisearch-wrapper select');

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
                clearTimeout(curthis.setTo);
        }
    }
    ngAfterViewChecked(): void {

        let curthis = this;

        let profileRatingSpans: any[] = jQuery('span.profileRatingSpan');
        if (!curthis.hasGotRating && profileRatingSpans && profileRatingSpans.length > 0) {
            jQuery('div.rate,span.rate').rateit({
                min: 0,
                max: 5,
                step: 1,
                starwidth: 16,
                starheight: 16,
                resetable: true
            });
            jQuery('div.rateit, span.rateit').rateit();
            jQuery(profileRatingSpans).each(function (index, value) {
                let profileIdStr = jQuery(value).attr('id');

                let fundiProfileId = parseInt(profileIdStr.split('-')[1])
                let fundiAvgRateObs: Observable<any> = curthis.myFundiService.GetFundiProfileRatingById(fundiProfileId);

                curthis.hasGotRating = true;
                fundiAvgRateObs.map(q => {
                    let ratingReviewObj = this.fundiSatisfyingJobList.find(q => {
                        return parseInt(q.fundiProfileId) == fundiProfileId;
                    });
                    jQuery('span#averageFundiRating-' + fundiProfileId).rateit('value', ratingReviewObj.averageFundiRating);
                }).subscribe();
            });
        }
    }
    searchFundiByCategories($event) {
        let curthis = this;
        this.fundiProfileList = [];
        let chosenCategories: string[] = [];
        let viewObjects: any[] = [];
        let categories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulCategories > li > div > div > input[type="checkbox"]:checked');
        categories.each(function (ind, elem) {

            chosenCategories.push(elem.name);

            let chosenSubCategories: string[] = [];
            let subCategories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulSubCategories > li > div > div > input[type="checkbox"]:checked');
            subCategories.each(function (ind, elem) {

                chosenSubCategories.push(elem.name);

            });
            viewObjects.push({ username: MyFundiService.clientEmailAddress, workCategories: chosenCategories, workSubCategories: chosenSubCategories, coordinate: { latitude: 0, longitude: 0 } });

        });
        debugger;
        let username: string = MyFundiService.clientEmailAddress;
        let clientProfObjs: Observable<IClientProfile> = curthis.myFundiService.GetClientProfile(username);
        clientProfObjs.map((q: IClientProfile) => {
            let locsObj: Observable<IJob> = curthis.myFundiService.GetJobByJobId(this.jobId);

            locsObj.map((r: IJob) => {
                r.location
                this.jobLocation = r.location;
                for (let n = 0; n < viewObjects.length; n++) {
                    viewObjects[n].coordinate.latitude = this.jobLocation.latitude;
                    viewObjects[n].coordinate.longitude = this.jobLocation.longitude;
                }
                let fundiJobsObs: Observable<any[]> = this.myFundiService.GetFundiRatingsAndReviews(viewObjects, q.clientProfileId,r.jobId, this.distanceKmLimitApart, this.skip, this.take);

                fundiJobsObs.map((n: any[]) => {
                    debugger;
                    let q: any[] = n;

                    if (q && q.length > 0) {

                        this.fundiSatisfyingJobList = q;

                    } else {
                        alert("There are currently no jobs that match your criteria within 5Km of your chosen location!")
                    }

                }).subscribe();
            }).subscribe();


        }).subscribe();

        $event.stopPropagation();
        /*
        this.hasGotRating = false;
        this.fundiListSatisfyingJobRadiusDictionary = [];
        this.fundiProfileRatingDictionary = {};
        this.actualProfileIdKeys = [];
        this.profileIdKeys = null;

        let divFundiCategories: HTMLElement = document.querySelector('form#fundiSearchForm div#fundiCategories');
        let chosenCategories: string[] = [];
        let curthis = this;
        if (this.jobs && this.jobs.length > 0) {
            let selectedJobId: number = jQuery('div#clientfundisearch-wrapper select#jobId').val();
            let selectedJob: IJob = this.jobs.find((j: IJob) => {
                return j.jobId == selectedJobId;
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
        }*/
    }

    rateFundi($event) {

        let button = $event.target;
        let review = jQuery(button).parent('form').find('textarea').val();
        let profileId: number = jQuery(button).parent('form').attr('id').split('-')[1];
        let rating: number = jQuery('div#fundiRating-'+profileId).rateit('value');
        let workCategory: string = jQuery(button).parent('form').find('select').val();

        alert('rated: ' + rating);
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

