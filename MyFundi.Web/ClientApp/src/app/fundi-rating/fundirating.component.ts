import { Component, OnInit, Inject, AfterViewChecked, AfterViewInit, Input } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IFundiRatingDictionary, IJob, ICoordinate, IWorkSubCategory, IClientProfile, IWorkAndSubWorkCategory, IPagingContent, IFundiLocationMonitor, IBareIWorkAndSubWorkCategory } from '../../services/myFundiService';
import { Observable, ObservableInput } from 'rxjs';
import { Router } from '@angular/router';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';
declare var jQuery: any;
declare let sceditor: any;
import { modifyHasPopulatedPage } from '../../imports.js';

@Component({
    selector: 'fundi-rating',
    templateUrl: './fundirating.component.html',
    providers: [AddressLocationGeoCodeService, MyFundiService]
})
export class FundiRatingComponent implements OnInit, AfterViewChecked {
    userDetails: any;
    userRoles: string[];
    jobId: number;
    fundiUser: any;
    profile: IProfile;
    profileId: number;
    contractId: number;
    averageFundiRatings: number;
    fundiRatings: IFundiRating[];
    workCategories: IWorkCategory[];
    categories: string;
    fundiProfileRatingDictionary: any;
    fundiWorkCategories: string[];
    fundiSkills: string[];
    hasGotRating: boolean = false;
    hasAddedAutoComplete: boolean = false;
    averageFundiRating: number = 0;
    jobWorkCategoryDetails: IBareIWorkAndSubWorkCategory[];

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }

    ngOnInit(): void {
        this.userDetails = JSON.parse(localStorage.getItem("userDetails")); 
        this.fundiUser = JSON.parse(localStorage.getItem("FundiUserTo"));
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        this.profileId = parseInt(JSON.parse(localStorage.getItem("RatingProfileId"))); 
        this.jobId = parseInt(JSON.parse(localStorage.getItem("ContractJobId")));
        this.profile = {
            fundiProfileId: this.profileId,
            userId: "",
            profileSummary: "",
            profileImageUrl: "",
            skills: "",
            usedPowerTools: "",
            fundiProfileCvUrl: "",
            locationId: 0,
            user: null
            
        }

        if (this.profileId > 0) {
            let prfObs: Observable<IProfile> = this.myFundiService.GetFundiProfileByProfileId(this.profileId.toString());
            prfObs.map((q: IProfile) => {
                this.profile = q;
                this.profileId = this.profile.fundiProfileId;
                this.getFundiWorkCategoriesByProfileId(this.profileId);

                this.generateFundiRatings();
            }).subscribe();
        }
    }

    constructor(private myFundiService: MyFundiService, private addressLocationService: AddressLocationGeoCodeService, private router: Router) {
        this.userDetails = {};
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
        jQuery('div.rate,span.rate').rateit({
            min: 0,
            max: 5,
            step: 1,
            starwidth: 16,
            starheight: 16,
            resetable: true
        });
        jQuery('div.rateit, span.rateit').rateit();
        if (this.profile) {
            this.profileId = this.profile.fundiProfileId;
            jQuery('span#averageFundiRating-' + this.profileId).rateit('value', this.averageFundiRating);
        }
    }
    generateFundiRatings() {
        let curthis = this;

        let wCatsSubCatsObs: Observable<IBareIWorkAndSubWorkCategory[]> = this.myFundiService.GetFundiWorkCategoriesAndSubCategoriesByJobId(this.jobId);
            if (this.profile) {

                let fundiRatingsObs: Observable<any[]> = this.myFundiService.GetFundiRatings(this.fundiUser.username);

                wCatsSubCatsObs.map((q: IBareIWorkAndSubWorkCategory[]) => {
                    this.jobWorkCategoryDetails = q;
                    fundiRatingsObs.map((r: any[]) => {
                        this.fundiRatings = r;
                        this.fundiRatings.forEach(q => {
                            this.averageFundiRating += q.rating;
                        });

                        this.averageFundiRating = parseInt((this.averageFundiRating / r.length).toString());
                        jQuery('span#averageFundiRating-' + this.profile.fundiProfileId).rateit('value', this.averageFundiRatings);
                   }).subscribe();
                }).subscribe();
            }
            else {
                alert("Fundi has no Profile");
            }


    }

    rateFundi($event) {

        let button = $event.target;

        let textarea = jQuery('textarea#review-' + this.profile.fundiProfileId)[0];
        let scEditInstance = sceditor.instance(textarea);
        let review = scEditInstance.getBody().innerHTML;
        
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
}

