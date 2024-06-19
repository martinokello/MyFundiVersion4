import { Component, OnInit, Inject, Input } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, IFundiRating, MyFundiService, IWorkAndSubWorkCategory, IFundiEngagement } from '../../services/myFundiService';
import { Observable } from 'rxjs';
declare var jQuery: any;

@Component({
    selector: 'fundi-engagement',
    templateUrl: './fundiengagement.component.html'
})
export class FundiEngagementComponent implements OnInit {
    profileUserDetails: any;
    @Input("profileId") profileId: number;
    fundiRatings: IFundiRating[];
    fundiLevelOfEngagement: IFundiEngagement[];
    profile: IProfile;
    static levelOfEngagement: any[];
    currentFundiNumbOfAssignments: number;
    constructor(private myFundiService: MyFundiService) {
        this.profileUserDetails = {};
    }

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {
        if (isNaN(this.profileId) || this.profileId == 0) {
            let profileUserDetails: any = JSON.parse(localStorage.getItem("profileUserDetails"));
            if (profileUserDetails) {
                this.profileId = parseInt(profileUserDetails.fundiProfileId);
                let levelEngObs = this.myFundiService.GetFundiLevelOfEngagement(this.profileId)

                levelEngObs.map((fundiEngagements: IFundiEngagement[]) => {
                    let numberOfAssignments = fundiEngagements[0].numberOfAssignments;
                    this.currentFundiNumbOfAssignments = numberOfAssignments;
                    let top = `${numberOfAssignments <= 1 ? '87%' : (numberOfAssignments == 2) ? '62%' : numberOfAssignments == 3 ? '37%' : '12%'}`;
                    jQuery("fundi-engagement#engagement-" + this.profileId + " div#indicator").css('height', '2%');
                    jQuery("fundi-engagement#engagement-" + this.profileId + " div#indicator").css('position', 'absolute');
                    jQuery("fundi-engagement#engagement-" + this.profileId + " div#indicator").css('top', top);
                    jQuery("fundi-engagement#engagement-" + this.profileId + " div#indicator").css('display', 'block');
                }).subscribe();
            }
            else {
                let userDetails = JSON.parse(localStorage.getItem("userDetails"));
                let fundiProfObs: Observable<any> = this.myFundiService.GetFundiProfile(userDetails.username);
                fundiProfObs.map((fprof: any) => {
                    let fundiProfile: IProfile = fprof;
                    let levelEngObs = this.myFundiService.GetFundiLevelOfEngagement(fundiProfile.fundiProfileId)

                    levelEngObs.map((fundiEngagements: IFundiEngagement[]) => {
                        let numberOfAssignments = fundiEngagements[0].numberOfAssignments;
                        this.currentFundiNumbOfAssignments = numberOfAssignments;
                        let top = `${numberOfAssignments <= 1 ? '87%' : (numberOfAssignments == 2) ? '62%' : numberOfAssignments == 3 ? '37%' : '12%'}`;
                        jQuery('fundi-engagement#profile-engagement-' + fundiProfile.fundiProfileId + ' div#indicator').css('height', '2%');
                        jQuery('fundi-engagement#profile-engagement-' + fundiProfile.fundiProfileId + ' div#indicator').css('position', 'absolute');
                        jQuery('fundi-engagement#profile-engagement-' + fundiProfile.fundiProfileId + ' div#indicator').css('top', top);
                        jQuery('fundi-engagement#profile-engagement-' + fundiProfile.fundiProfileId + ' div#indicator').css('display', 'block');
                    }).subscribe();
                }).subscribe(); }

        }
        else {
            let fundiProfObs: Observable<IProfile> = this.myFundiService.GetFundiProfileByProfileId(this.profileId.toString());
            fundiProfObs.map((fprof: IProfile) => {
                this.profile = fprof;
                let levelEngObs = this.myFundiService.GetFundiLevelOfEngagement(this.profileId)

                levelEngObs.map((fundiEngagements: IFundiEngagement[]) => {
                    let numberOfAssignments = fundiEngagements[0].numberOfAssignments;
                    this.currentFundiNumbOfAssignments = numberOfAssignments;
                    let top = `${numberOfAssignments <= 1 ? '87%' : (numberOfAssignments == 2) ? '62%' : numberOfAssignments == 3 ? '37%' : '12%'}`;
                    jQuery('fundi-engagement#clientSearchEngagement-'+this.profileId+ ' div#indicator').css('height', '2%');
                    jQuery('fundi-engagement#clientSearchEngagement-' + this.profileId + ' div#indicator').css('position', 'absolute');
                    jQuery('fundi-engagement#clientSearchEngagement-' + this.profileId + ' div#indicator').css('top', top);
                    jQuery('fundi-engagement#clientSearchEngagement-' + this.profileId + ' div#indicator').css('display', 'block');

                    jQuery("fundi-engagement#engagement-" + this.profileId + " div#indicator").css('height', '2%');
                    jQuery("fundi-engagement#engagement-" + this.profileId + " div#indicator").css('position', 'absolute');
                    jQuery("fundi-engagement#engagement-" + this.profileId + " div#indicator").css('top', top);
                    jQuery("fundi-engagement#engagement-" + this.profileId + " div#indicator").css('display', 'block');

                }).subscribe();
            }).subscribe();
        }
 

        let downloadLink: HTMLAnchorElement = document.querySelector('a#downloadCV');
        downloadLink.setAttribute('href', `/FundiProfile/GetFundiCVByUsername?username=${this.profileUserDetails.username}`);

    }
}

