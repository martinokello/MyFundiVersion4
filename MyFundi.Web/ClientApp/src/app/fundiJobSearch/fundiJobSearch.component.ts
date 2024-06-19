import { Component, OnInit, Inject, AfterViewInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IFundiRatingDictionary, IJob, ICoordinate, IClientProfile, IWorkSubCategory, IWorkAndSubWorkCategory, IPagingContent, IFundiLocationMonitor, ISubscription } from '../../services/myFundiService';
import { Observable } from 'rxjs';
import { Router } from '@angular/router';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';
declare var jQuery: any;

@Component({
    selector: 'fundi-job-search',
    templateUrl: './fundiJobSearch.component.html',
    providers: [AddressLocationGeoCodeService]
})
export class FundiJobSearchComponent implements OnInit, AfterViewInit {
    userDetails: any;
    userRoles: string[];
    fundiId: number;
    jobs: IJob[];
    workCategories: IWorkCategory[];
    categories: string;
    fundiJobList: any[] = [];
    listToShow: [];
    fundiWorkCategories: string[];
    distanceKmLimitApart: number;
    skip: number;
    take: number;
    fundiLocation: ILocation;
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
        this.distanceKmLimitApart = 50000000;
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        jQuery('#fundiSearchForm div#fundiCategories').children().remove();

        let workCatObs: Observable<IWorkCategory[]> = this.myFundiService.GetWorkCategories();
        workCatObs.map((workCats: IWorkCategory[]) => {
            this.workCategories = workCats;
            this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
            this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
            let resObs = this.myFundiService.GetFundiProfile(this.userDetails.username);

            resObs.map((fundiProf: IProfile) => {
                let fundiSubsObs: Observable<ISubscription[]> = this.myFundiService.GetAllFundiSubscriptions(fundiProf.fundiProfileId);
                fundiSubsObs.map((q: ISubscription[]) => {
                    q.forEach((sub: ISubscription, ind: number) => {

                        //Dynamic check boxes for Categories To Search for:
                        let divFundiCategories: HTMLElement = document.querySelector('#fundiSearchForm div#fundiCategories');

                        for (let id = 0; id < sub.workCategoryAndSubCategoryIds.length; id++) {

                            this.workCategories.forEach((cat) => {
                                if (sub.workCategoryAndSubCategoryIds[id].workCategoryId == cat.workCategoryId) {

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
                                        let subCatIds: number[] = sub.workCategoryAndSubCategoryIds[id].workSubCategoryIds;
                                        //Dynamic check boxes for Categories To Search for:
                                        let ul2 = document.createElement('ul');
                                        ul2.setAttribute('class', 'ulSubCategories');

                                        let li2 = document.createElement('li');

                                        workSubCategories.forEach((cat) => {
                                            if (subCatIds.indexOf(cat.workSubCategoryId) > -1) {
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
                                            }
                                        });
                                        li.appendChild(hr);

                                    }).subscribe();
                                }
                            });
                        }
                    });
                }).subscribe();

            }).subscribe();
        }).subscribe();
    }
    constructor(private myFundiService: MyFundiService, private addressLocationService: AddressLocationGeoCodeService, private router: Router) {
    }
    ngAfterViewInit(): void {
        jQuery('ul.ulCategories  ul.ulSubCategories').hide('fast');
        jQuery('ul.ulCategories > li').children('checkbox').on('click', function () {
            jQuery(this).parents.find('ul.ulCategories').children('ul.ulSubCategories').toggle('fast');
        });
    }

    roundPositiveNumberTo2DecPlaces(num: number): number {
        return this.addressLocationService.roundPositiveNumberTo2DecPlaces(num);
    }
    seachJobsByCurrentGeoLocation($event) {
        this.numberOfResultsSet = 20;
        this.numberOfResultSetToSkip = 0;
        this.isSearchingOnLocality = true;
        let curthis = this;
        this.fundiJobList = [];
        let chosenCategories: string[] = [];
        let viewObjects: any[] = [];
        let categories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulCategories > li > div > div > input[type="checkbox"]:checked');
        categories.each(function (ind, elem) {

            chosenCategories.push(elem.name);

            let chosenSubCategories: string[] = [];
            let subCategories = jQuery('form#fundiSearchForm div#fundiCategories ul.ulSubCategories > li > div > div > input[type="checkbox"]:checked');
            subCategories.each(function (ind, elem) {

                chosenSubCategories.push(elem.name);
                viewObjects.push({ username: curthis.userDetails.username, workCategories: chosenCategories, workSubCategories: chosenSubCategories, coordinate: { latitude: 0, longitude: 0 }, fundiProfileId: -1 });
            });
        });
        let fundiLocObs: Observable<IFundiLocationMonitor> = this.myFundiService.GetFundiRealTimeLocationsByUsername(this.userDetails.username.toLowerCase());

        fundiLocObs.map((flocMon: IFundiLocationMonitor) => {

            if (flocMon) {
                let profObs: Observable<IProfile> = this.myFundiService.GetFundiProfileByUsername(flocMon.username);
                profObs.map((pr: IProfile) => {
                    if (pr) {
                        viewObjects[0].coordinate = { latitude: flocMon.latitude, longitude: flocMon.longitude };
                        viewObjects[0].fundiProfileId = pr.fundiProfileId;
                        let fundiJobsObs: Observable<[]> = this.myFundiService.GetJobsByCategoriesAndFundiUserGeoLocation(viewObjects, pr.fundiProfileId, this.distanceKmLimitApart, this.numberOfResultSetToSkip, this.numberOfResultsSet);
                        this.numberOfResultSetToSkip += (this.numberOfResultsSet + 1);

                        fundiJobsObs.map((q: []) => {

                            if (q && q.length > 0 && this.isSearchingOnLocality) {
                                this.listToShow = q;
                                this.showFirstPage();
                            } else {
                                this.numberOfResultSetToSkip = 0;
                                alert("There are currently no more jobs that match your\ncriteria within your chosen location!");
                            }

                            this.isSearchingOnLocality = false;

                            curthis.scrollTo('results');
                        }).subscribe();
                    }
                    else {

                        this.numberOfResultSetToSkip = 0;
                        alert("Your current location is not being monitored on map!!\nPlease use android app to start monitoring.");
                    }
                }).subscribe();
            }

        }).subscribe();
        $event.stopPropagation();
    }

    searchJobsByCategories($event) {

        let curthis = this;
        this.fundiJobList = [];
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
            viewObjects.push({ username: curthis.userDetails.username, workCategories: chosenCategories, workSubCategories: chosenSubCategories, coordinate: { latitude: 0, longitude: 0 } });

        });
        let username: string = curthis.userDetails.username;
        let fundiObjs: Observable<IProfile> = curthis.myFundiService.GetFundiProfile(username);
        fundiObjs.map((q: IProfile) => {
            let locsObj: Observable<ILocation> = curthis.myFundiService.GetFundiLocationByFundiProfileId(q.fundiProfileId);

            locsObj.map((r: ILocation) => {
                this.fundiLocation = r;
                for (let n = 0; n < viewObjects.length; n++) {
                    viewObjects[n].coordinate.latitude = r.latitude;
                    viewObjects[n].coordinate.longitude = r.longitude;
                }
                let fundiJobsObs: Observable<[]> = this.myFundiService.GetJobsByCategoriesAndFundiUser(viewObjects, q.fundiProfileId, this.distanceKmLimitApart, this.numberOfResultSetToSkip, this.numberOfResultsSet);
                this.numberOfResultSetToSkip += (this.numberOfResultsSet + 1);

                fundiJobsObs.map((q: []) => {
                    if (q && q.length > 0) {
                        this.listToShow = q;
                        this.showFirstPage();
                    } else {
                        this.numberOfResultSetToSkip = 0;
                        alert("There are currently no more jobs that match your\ncriteria within your chosen location!")
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
    searchCommand($event) {
        debugger;
        this.pagingContentModel = $event;
        this.bindContentToSearchResultsDiv();

        this.pagingContentModel.content = this.listToShow.slice(this.currentPage * this.numberOfResultsPerPage - this.numberOfResultsPerPage, this.currentPage * this.numberOfResultsPerPage);

        let mod = this.listToShow.length % this.numberOfResultsPerPage

        let numberOfPages = Math.floor(this.listToShow.length / this.numberOfResultsPerPage);

        if (mod > 0) numberOfPages += 1;

        this.fundiJobList = this.pagingContentModel.content;

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
        this.fundiJobList = this.pagingContentModel.content;

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
    getJobPage($event) {
        localStorage.removeItem('CurrentJob');
        localStorage.removeItem('CurrentClientUserDetails');
        localStorage.removeItem('CurrentJobClientProfile');
        localStorage.removeItem('CurrentJobWorkCategories');
        let jobId = parseInt(jQuery($event.target).attr('id'));
        let jobObs: Observable<IJob> = this.myFundiService.GetJobByJobId(jobId);

        jobObs.map((job: IJob) => {
            localStorage.setItem('CurrentJob', JSON.stringify(job));
            let clientObs: Observable<IClientProfile> = this.myFundiService.GetClientProfileById(job.clientProfileId);

            clientObs.map((clientProfile: IClientProfile) => {

                localStorage.setItem('CurrentJobClientProfile', JSON.stringify(clientProfile));

                let clientUserObs: Observable<IUserDetail> = this.myFundiService.GetClientUserById(clientProfile.userId);
                clientUserObs.map((clientUser: IUserDetail) => {
                    localStorage.setItem('CurrentClientUserDetails', JSON.stringify(clientUser));
                    let currJobWorkCatsObs: Observable<IWorkAndSubWorkCategory[]> = this.myFundiService.GetJobWorkCategoriesByJobId(job.jobId);
                    currJobWorkCatsObs.map((wCats: IWorkAndSubWorkCategory[]) => {

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

