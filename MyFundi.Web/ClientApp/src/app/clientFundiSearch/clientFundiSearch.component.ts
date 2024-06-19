import { Component, OnInit, Inject, AfterViewChecked, AfterViewInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IFundiRatingDictionary, IJob, ICoordinate, IWorkSubCategory, IClientProfile, IWorkAndSubWorkCategory, IPagingContent, IFundiLocationMonitor } from '../../services/myFundiService';
import { Observable, ObservableInput } from 'rxjs';
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
    profileId: number;
    jobId: number;
    jobLocationCoordinate: ICoordinate;
    jobs: IJob[];
    location: ILocation;
    fundiRatings: IFundiRating[];
    listToShow: [];
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
    fundiSatisfyingJobList: any[] = [];
    pagingContentModel: IPagingContent;
    numberOfResultsPerPage: number;
    currentPage: number;
    numberOfPageJumps: number;
    isSearchingOnLocality: boolean;
    numberOfResultsSet: 20;
    numberOfResultSetToSkip: 0;

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }

    ngOnInit(): void {
        this.numberOfResultsPerPage = 2;
        this.currentPage = 1;
        this.numberOfPageJumps = 2;
        this.numberOfResultsSet = 20;
        this.numberOfResultSetToSkip = 0;

        this.pagingContentModel = {
            isPageNextEnabled: false,
            isPageNext3Enabled: false,
            isPagePrevEnabled: false,
            isPagePrev3Enabled: false,
            pageNextClicked: false,
            pageNext3Clicked: false,
            pagePrevClicked: false,
            pagePrev3Clicked: false,
            content: []
        }
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

                attrName.value = cat.workCategoryType.toString();
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

        let clientProfileObs: Observable<IClientProfile> = this.myFundiService.GetClientProfile(this.userDetails.username);
        clientProfileObs.map((clientProfile: IClientProfile) => {
            let jobCatObs: Observable<IJob[]> = this.myFundiService.GetAllClientJobByClientProfileId(clientProfile.clientProfileId);

            jobCatObs.map((jobs: IJob[]) => {
                this.jobs = jobs;
                if (this.jobs.length > 0) this.job = this.jobs[0];
                else {
                    this.job = {
                        jobId : 0,
                        jobName:"",
                        jobDescription: "",
                        clientProfileId: 0,
                        clientProfile:
                        {
                            clientProfileId: 0,
                            userId: "",
                            profileSummary: "",
                            profileImageUrl: "",
                            addressId: 0
                        },
                        clientUserId: 0,
                        clientUser: {
                            emailAddress: "",
                            username: "",
                            mobileNumber: "",
                            password: "",
                            keepLoggedIn: false,
                            repassword: "",
                            role: "",
                            firstName: "",
                            lastName: "",
                            authToken: "",
                            fundi: false,
                            client: false,
                            message: ""
                        },
                        hasCompleted: false,
                        hasBeenAssignedFundi: false,
                        locationId: 0,
                        location: {
                            locationId: 0,
                            country: "",
                            locationName: "",
                            latitude: 0,
                            longitude: 0,
                            addressId: 0,
                            address: {
                                addressId: 0,
                                addressLine1: "",
                                addressLine2: "",
                                town: "",
                                postCode: "",
                                country: "",
                            },
                            isGeocoded: false
                        },
                        numberOfDaysToComplete: 0,
                        assignedFundiProfileId: 0,
                        assignedFundiProfile: {

                            fundiProfileId: 0,
                            userId: "",
                            profileSummary: "",
                            profileImageUrl: "",
                            skills: "",
                            usedPowerTools: "",
                            fundiProfileCvUrl: "",
                            locationId:0,
                            user: {
                                emailAddress: "",
                                username: "",
                                mobileNumber: "",
                                password: "",
                                keepLoggedIn: false,
                                repassword: "",
                                role: "",
                                firstName: "",
                                lastName: "",
                                authToken: "",
                                fundi: false,
                                client: false,
                                message: ""
                            },
                        },
                        assignedFundiUserId: "",
                        assignedFundiUser: {
                            emailAddress: "",
                            username: "",
                            mobileNumber: "",
                            password: "",
                            keepLoggedIn: false,
                            repassword: "",
                            role: "",
                            firstName: "",
                            lastName: "",
                            authToken: "",
                            fundi: false,
                            client: false,
                            message: ""
                        },
                        clientFundiContractId: 0,
                        dateCreated: new Date(),
                        dateUpdated: new Date()
                    }
                }
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
        }).subscribe();
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
        (this.fundiSatisfyingJobList.length > 0)
        {
            jQuery('div.rate,span.rate').rateit({
                min: 0,
                max: 5,
                step: 1,
                starwidth: 16,
                starheight: 16,
                resetable: true
            });
            jQuery('div.rateit, span.rateit').rateit();
            this.fundiSatisfyingJobList.forEach((r, ind, q) => {
                this.profileId = r.fundiProfileId
                jQuery('span#averageFundiRating-' + r.fundiProfileId).rateit('value', r.averageFundiRating);
            });
        }
    }

    searchCommand($event) {
        debugger;
        this.pagingContentModel = $event;
        this.bindContentToSearchResultsDiv();

        this.pagingContentModel.content = this.listToShow.slice(this.currentPage * this.numberOfResultsPerPage - this.numberOfResultsPerPage, this.currentPage * this.numberOfResultsPerPage);

        let mod = this.listToShow.length % this.numberOfResultsPerPage

        let numberOfPages = Math.floor(this.listToShow.length / this.numberOfResultsPerPage);

        if (mod > 0) numberOfPages += 1;

        this.fundiSatisfyingJobList  = this.pagingContentModel.content;

        if (this.currentPage < numberOfPages) {
            this.pagingContentModel.isPageNextEnabled = true;
        }
        else {
            this.pagingContentModel.isPageNextEnabled = false;
        }

        if (this.currentPage <= (numberOfPages - this.numberOfPageJumps)) {
            this.pagingContentModel.isPageNext3Enabled = true;
        }
        else {
            this.pagingContentModel.isPageNext3Enabled = false;
        }

        if (this.currentPage > 1) {
            this.pagingContentModel.isPagePrevEnabled = true;
        }
        else {
            this.pagingContentModel.isPagePrevEnabled = false;
        }

        if (this.currentPage > this.numberOfPageJumps) {
            this.pagingContentModel.isPagePrev3Enabled = true;
        }
        else {
            this.pagingContentModel.isPagePrev3Enabled = false;
        }
    }

    showFirstPage() {
        this.pagingContentModel.content = this.listToShow.slice(0, (this.currentPage * this.numberOfResultsPerPage));
        this.fundiSatisfyingJobList  = this.pagingContentModel.content;

        let mod = this.listToShow.length % this.numberOfResultsPerPage
        let numberOfPages = this.listToShow.length / this.numberOfResultsPerPage;

        if (mod > 0) numberOfPages += 1;

        if (this.currentPage < numberOfPages) {
            this.pagingContentModel.isPageNextEnabled = true;
        }
        else {
            this.pagingContentModel.isPageNextEnabled = false;
        }
        if (this.currentPage <= (numberOfPages - this.numberOfPageJumps)) {
            this.pagingContentModel.isPageNext3Enabled = true;
        }
        else {
            this.pagingContentModel.isPageNext3Enabled = false;
        }

        if (this.currentPage > 1) {
            this.pagingContentModel.isPagePrevEnabled = true;
        }
        else {
            this.pagingContentModel.isPagePrevEnabled = false;
        }
        this.pagingContentModel.isPagePrev3Enabled = false;
    }

    bindContentToSearchResultsDiv() {

        if (this.pagingContentModel.pageNextClicked) {
            this.currentPage += 1;
        }
        else if (this.pagingContentModel.pagePrevClicked) {
            this.currentPage -= 1;
        }
        else if (this.pagingContentModel.pageNext3Clicked) {
            this.currentPage += this.numberOfPageJumps;
        }
        else if (this.pagingContentModel.pagePrev3Clicked) {
            this.currentPage -= this.numberOfPageJumps;
        }
    }
    searchFundiByCurrentGeoLocation($event) {
        let curthis = this;
        this.fundiProfileList = [];
        let chosenCategories: string[] = [];
        let viewObjects: any[] = [];
        this.isSearchingOnLocality = true;

        let categories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulCategories > li > div > div > input[type="checkbox"]:checked');
        categories.each(function (ind, elem) {

            chosenCategories.push(elem.name);

            let chosenSubCategories: string[] = [];
            let subCategories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulSubCategories > li > div > div > input[type="checkbox"]:checked');
            subCategories.each(function (ind, elem) {

                chosenSubCategories.push(elem.name);

            });
            viewObjects.push({ username: curthis.userDetails.username, workCategories: chosenCategories, workSubCategories: chosenSubCategories, coordinate: { latitude: 0, longitude: 0 } });

        });
        let username: string = this.userDetails.username;

        let clientProfObjs: Observable<IClientProfile> = curthis.myFundiService.GetClientProfile(username);

        let jobsObj: Observable<IJob> = curthis.myFundiService.GetJobByJobId(this.job.jobId);

            jobsObj.map((j: IJob) => {
                clientProfObjs.map((q: IClientProfile) => {
                    let fundiLocObs: Observable<IFundiLocationMonitor[]> = curthis.myFundiService.GetFundiRealTimeLocations();

                    fundiLocObs.map((r: IFundiLocationMonitor[]) => {
                        for (let f = 0; f < r.length; f++) {

                            let profObs: Observable<IProfile> = this.myFundiService.GetFundiProfileByUsername(r[f].username);

                            profObs.map((pr: IProfile) => {
                                if (pr) {
                                    for (let n = 0; n < viewObjects.length; n++) {

                                    viewObjects[n].coordinate.latitude = r[f].latitude;
                                    viewObjects[n].coordinate.longitude = r[f].longitude;
                                    viewObjects[n].fundiProfileId = pr.fundiProfileId;
                                    }
                                }
                                let fundiRatingsObs: Observable<[]> = this.myFundiService.GetFundiRatingsAndReviewsGeolocation(viewObjects, q.clientProfileId, j.jobId, this.distanceKmLimitApart, this.numberOfResultSetToSkip, this.numberOfResultsSet);
                                this.numberOfResultSetToSkip += (this.numberOfResultsSet + 1);

                                fundiRatingsObs.map((q: []) => {

                                    if (q && q.length > 0 && this.isSearchingOnLocality) {
                                        this.listToShow = q;
                                        this.showFirstPage();
                                    } else {
                                        this.numberOfResultSetToSkip = 0;
                                        alert("There are currently no more Fundis that match your\ncriteria within your chosen location!")
                                    }

                                    this.isSearchingOnLocality = false;

                                    curthis.scrollTo('results');

                                }).subscribe();
                            }).subscribe();
                        }

                    }).subscribe();
                }).subscribe();
            }).subscribe();

    }

    searchFundiByCategories($event) {
        let curthis = this;
        this.fundiProfileList = [];
        let chosenCategories: string[] = [];
        let viewObjects: any[] = [];
        this.isSearchingOnLocality = false;


        let categories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulCategories > li > div > div > input[type="checkbox"]:checked');
        categories.each(function (ind, elem) {

            chosenCategories.push(elem.name);

            let chosenSubCategories: string[] = [];
            let subCategories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulSubCategories > li > div > div > input[type="checkbox"]:checked');
            subCategories.each(function (ind, elem) {

                chosenSubCategories.push(elem.name);

            });

            viewObjects.push({ username: curthis.userDetails.username, workCategories: chosenCategories, workSubCategories: chosenSubCategories, coordinate: { latitude: 0, longitude: 0 } });

        });

        let username: string = curthis.userDetails.username;
        let clientProfObjs: Observable<IClientProfile> = curthis.myFundiService.GetClientProfile(username);
        clientProfObjs.map((q: IClientProfile) => {
            let jobsObj: Observable<IJob> = curthis.myFundiService.GetJobByJobId(this.jobId);

            jobsObj.map((r: IJob) => {
                r.location
                this.jobLocation = r.location;
                for (let n = 0; n < viewObjects.length; n++) {
                    viewObjects[n].coordinate.latitude = this.jobLocation.latitude;
                    viewObjects[n].coordinate.longitude = this.jobLocation.longitude;
                }
                let fundiRatingsObs: Observable<[]> = this.myFundiService.GetFundiRatingsAndReviews(viewObjects, q.clientProfileId, r.jobId, this.distanceKmLimitApart, this.numberOfResultSetToSkip, this.numberOfResultsSet);
                this.numberOfResultSetToSkip += (this.numberOfResultsSet + 1);

                fundiRatingsObs.map((q: []) => {

                    if (q && q.length > 0) {
                        this.listToShow = q;
                        this.showFirstPage();
                    } else {
                        this.numberOfResultSetToSkip = 0;
                        alert("There are currently no more fundis that match your\ncriteria within your chosen location!")
                    }
                    curthis.scrollTo('results');
                }).subscribe();
            }).subscribe();
        }).subscribe();

        $event.stopPropagation();

    }

    scrollTo(elmId) {
        let element = document.getElementById(elmId);
        let topPos = element.getBoundingClientRect().top + window.scrollY;
        let leftPos = element.getBoundingClientRect().left + window.scrollX;

        window.scrollTo({
            top: topPos,
            left: 0,
            behavior: 'smooth'
        });
    }
    rateFundi($event) {

        let button = $event.target;
        let review = jQuery(button).parent('form').find('textarea').val();
        let profileId: number = jQuery(button).parent('form').attr('id').split('-')[1];
        let rating: number = jQuery('div#fundiRating-' + profileId).rateit('value');
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
            res.fundiProfileId = profileId;
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

