import { Component, OnInit, Inject, AfterViewInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IAddress, IClientProfile, IJob, IWorkSubCategory, IWorkAndSubWorkCategory } from '../../services/myFundiService';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
declare var jQuery: any;
import { AfterViewChecked } from '@angular/core';

@Component({
    selector: 'client',
    templateUrl: './client.component.html'
})
export class ClientProfileComponent implements OnInit, AfterViewChecked, AfterViewInit {

    hasPopulatedPage: boolean = false;
    userDetails: any;
    userRoles: string[];
    locationId: number;
    fundiProfileId: number;
    clientProfileId: number;
    numberOfDaysToComplete: number;
    profileImage: File;
    clientProfile: IClientProfile | any;
    fundiProfile: any;
    location: ILocation;
    clientUserGuidId: string;
    jobDescription: string;
    jobName: string;
    jobId: number;
    clientAddress: IAddress;
    clientAddressId: number;
    profileSummary: string;
    clientFundiContractId: number;
    clientProfiles: IClientProfile[];
    fundiProfiles: IProfile[];
    workCategories: IWorkAndSubWorkCategory[];
    chosenWorkCategories: IWorkAndSubWorkCategory[];
    workCategoryAndSubCatId: string;
    requiresSubscriptionRenewal: boolean;
    job:any;
    jobs: IJob[];
    clientAddresses: IAddress[];
    locations: ILocation[]
    setTo: NodeJS.Timeout;


    constructor(private myFundiService: MyFundiService, private router: Router, private httpClient: HttpClient) {
        this.userDetails = {};
    }
    ngAfterViewInit(): void {
        let subsClientDetails = JSON.parse(localStorage.getItem("ClientLoginDetails"));

        this.requiresSubscriptionRenewal = subsClientDetails == null ? false : subsClientDetails.clientDueToPaySubscription?true:false;
        jQuery('div#editableClientDetails').hide('slow');
    }

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {
        this.clientProfile = { clientProfileId: 0 };
        this.job = { jobId: 0, locationId: 0, clientFundiContractId: 0 };
        this.fundiProfile = { fundiProfileId: 0 }
        this.locations = [];
        this.clientAddresses = [];
        this.workCategories = [];
        this.clientProfiles = [];
        this.jobs = [];

        this.chosenWorkCategories = [];
        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        let resObs = this.myFundiService.GetClientProfile(this.userDetails.username);
        debugger;
        resObs.map((clientProf: IClientProfile) => {

            if (clientProf) {
                this.clientProfile = clientProf;
                this.profileSummary = clientProf.profileSummary;
                this.clientProfileId = this.clientProfile.clientProfileId;

                let jobCatObs: Observable<IJob[]> = this.myFundiService.GetAllClientJobByClientProfileId(this.clientProfile.clientProfileId);

                jobCatObs.map((jobCats: IJob[]) => {

                    this.jobs = jobCats;

                    //Dynamic check boxes for Categories To Search for:
                    let selectjobCategories: HTMLSelectElement = document.querySelector('select#jobId');
                    let selectJobIdOptions: HTMLSelectElement = document.querySelector('select#jobId option');
                    if (selectJobIdOptions) {
                        selectJobIdOptions.remove();
                    }

                    let option = document.createElement('option');
                    option.textContent = "Select Job";
                    option.value = "0";
                    selectjobCategories.appendChild(option);

                    this.jobs.forEach((cat: IJob) => {
                        let option = document.createElement('option');
                        option.textContent = cat.jobName;
                        option.value = cat.jobId.toString();
                        selectjobCategories.appendChild(option);
                    });
                }).subscribe();
            }
            else {
                this.clientProfile = {
                    clientProfileId: 0,
                    userId: "",
                    profileSummary: "",
                    profileImageUrl: "",
                    locationId: 0
                }
            }

        }).subscribe();

        let userGuidObs = this.myFundiService.GetUserGuidId(this.userDetails.username);
        userGuidObs.map((q: string) => {
            this.clientUserGuidId = q;

        }).subscribe();

        let workCatObs = this.myFundiService.GetWorkCategoriesAndSubCategories();

        workCatObs.map((workCats: IWorkAndSubWorkCategory[]) => {

            this.workCategories = workCats;

            //Dynamic check boxes for Categories To Search for:
            let selectWorkCategories: HTMLSelectElement = document.querySelector('select#workCategoryAndSubCatId');
            let selectWorkCategoriesOptions: HTMLSelectElement = document.querySelector('select#workCategoryAndSubCatId option');
            if (selectWorkCategoriesOptions) {
                selectWorkCategoriesOptions.remove();
            }

            let option = document.createElement('option');
            option.textContent = "Select Work Category: [SubWork Category]";
            option.value = "0,0";
            selectWorkCategories.appendChild(option);

            this.workCategories.forEach((cat) => {
                let option = document.createElement('option');
                option.textContent = `${cat.workCategory.workCategoryType}: [${cat.workSubCategory.workSubCategoryType}]`;
                option.value = `${cat.workCategoryId.toString()},${cat.workSubCategoryId.toString()}`;
                selectWorkCategories.appendChild(option);
            });
            let funidProfilesObs: Observable<IProfile[]> = this.myFundiService.GetAllFundiProfiles();
            funidProfilesObs.map((q: IProfile[]) => {
                this.fundiProfiles = q;

                let addSelect = document.querySelector('select#assignedFundiProfileId');
                let opts = addSelect.querySelector('option');
                if (opts) {
                    opts.remove();
                }
                let optionElem = document.createElement('option');
                optionElem.selected = true;
                optionElem.value = (0).toString();
                optionElem.text = "Select Fundi Profile";
                addSelect.append(optionElem);

                this.fundiProfiles.map((fundiProf: IProfile) => {
                    let optionElem: HTMLOptionElement = document.createElement('option');
                    optionElem.value = fundiProf.fundiProfileId.toString();
                    optionElem.text = fundiProf.user.firstName + " " + fundiProf.user.lastName;
                    addSelect.append(optionElem);
                });

                this.fundiProfile = {};
                this.fundiProfile.fundiProfileId = 0;
                let locatObs: Observable<ILocation[]> = this.myFundiService.GetAllLocations();
                locatObs.map((loc: ILocation[]) => {
                    this.locations = loc;

                    let addSelect = document.querySelector('select#locationId');

                    let opts = addSelect.querySelector('option');
                    if (opts) {
                        opts.remove();
                    }


                    let optionElem: HTMLOptionElement = document.createElement('option');
                    optionElem.selected = true;
                    optionElem.value = (0).toString();
                    optionElem.text = "Select Location";
                    document.querySelector('select#locationId').append(optionElem);

                    this.locations.forEach((comCat: ILocation, index: number, cmdCats) => {
                        let optionElem: HTMLOptionElement = document.createElement('option');
                        optionElem.value = comCat.locationId.toString();
                        optionElem.text = comCat.locationName;
                        document.querySelector('select#locationId').append(optionElem);
                    });
                    let clientaddObs: Observable<IAddress[]> = this.myFundiService.GetAllAddresses();

                    clientaddObs.map((q: IAddress[]) => {
                        this.clientAddresses = q;
                        let addresses = q;

                        let addrSelector = document.querySelector('select#clientAddressId');
                        let clopts = addrSelector.querySelector('option');
                        if (clopts) {
                            clopts.remove();
                        }
                        let cloptionElem: HTMLOptionElement = document.createElement('option');
                        cloptionElem.selected = true;
                        cloptionElem.value = (0).toString();

                        cloptionElem.text = "Select Address";

                        document.querySelector('select#clientAddressId').append(cloptionElem);

                        addresses.forEach((comCat: IAddress, index: number, cmdCats) => {

                            let optionElem: HTMLOptionElement = document.createElement('option');
                            optionElem.value = comCat.addressId.toString();
                            optionElem.text = comCat.addressLine1 + ", " + comCat.addressLine2 + ", " + comCat.town + ", " + comCat.country;
                            document.querySelector('select#clientAddressId').append(optionElem);
                        });
                    }).subscribe();
                }).subscribe();
            }).subscribe();
        }).subscribe();
    }
    draftContract($event) {
        let assigneFundiProfileId =parseInt(jQuery('select#assignedFundiProfileId').val());
        let fundiUserObs: Observable<any> = this.myFundiService.GetFundiUserByProfileId(assigneFundiProfileId);
        fundiUserObs.map((fundiUser: any) => {
            debugger;
            let draftContractData: any = {
                fundiProfileId: assigneFundiProfileId,
                clientProfileId: this.clientProfile.clientProfileId,
                fundiFirstName: fundiUser.firstName,
                fundiLastName: fundiUser.lastName,
                fundiUsername: fundiUser.username,
                clientFirstName: this.userDetails.firstName,
                clientLastName: this.userDetails.lastName,
                clientUsername: this.userDetails.username,
                clientFundiContractId: this.clientFundiContractId,
                numberOfDaysToComplete: this.numberOfDaysToComplete,
                jobName: this.job.jobName,
                contractualDescription: this.job.jobDescription,
                jobId: this.job.jobId
            }
            
            localStorage.setItem("DraftContractData", JSON.stringify(draftContractData));
            this.router.navigateByUrl("/client-fundi-contract");
        }).subscribe();

        $event.preventDefault();
    }
    handleProfileImage(files: FileList) {
        this.profileImage = files.item(0);
    }

    uploadProfileImage($event): void {

        //let busyGif: HTMLDivElement = document.querySelector("div#loadingProfileImage");
        //busyGif.style.display = 'block';
        let url: string = "/ClientProfile/SaveClientProfileImage";

        let formData = new FormData();
        formData.append("profileImage", this.profileImage);
        formData.append("username", this.userDetails.username);

        this.httpClient.post(url, formData).map((res: any) => {
            alert(res.message);
        }).subscribe();
        $event.preventDefault();
    }

    saveOrUpdateClientProfile($event) {

        this.clientProfile.clientProfileId = this.clientProfileId;
        this.clientProfile.userId = this.clientUserGuidId;
        this.clientProfile.addressId = this.clientAddressId;
        this.clientProfile.profileSummary = this.profileSummary;
        this.clientProfile.profileImageUrl = "";
        let profileObs = this.myFundiService.SaveClientProfile(this.clientProfile);

        profileObs.map((res: any) => {
            alert(res.message);
            this.router.navigateByUrl('success');
        }).subscribe();
        $event.preventDefault();
    }
    showClientProfileEditable($event) {
        jQuery('div#editableClientDetails').toggle(2000);
        $event.preventDefault();
    }
    createJob($event) {

        let job: any = {
            jobId: 0,
            jobName: this.userDetails.firstName + " " + this.userDetails.lastName + "-" + this.job.jobName,
            jobDescription: this.job.jobDescription,
            clientProfileId: this.clientProfile.clientProfileId,
            clientUserId: this.clientProfile.userId,
            hasCompleted: this.job.hasCompleted,
            hasBeenAssignedFundi: this.job.hasBeenAssignedFundi,
            locationId: this.job.locationId,
            numberOfDaysToComplete: this.job.numberOfDaysToComplete,
            clientFundiContractId: null,
            //assignedFundiUserId: this.fundiProfile.user.userId,
            assignedFundiProfileId: this.fundiProfile.fundiProfileId,
            jobWorkCategoryIds: this.chosenWorkCategories
        };

        let obsj: Observable<any> = this.myFundiService.createOrUpdateClientJob(job);
        obsj.map((q: any) => {
            alert(q.message)
        }).subscribe();
        $event.preventDefault();
    }
    selectJob($event) {
        let selectedJobId: number = jQuery('div#client-wrapper select#jobId').val();

        let job: IJob = this.jobs.find((j: IJob) => {

            return j.jobId == selectedJobId;
        });
        this.job = job;
        jQuery('select#assignedFundiProfileId').val(this.job.assignedFundiProfileId);
        let jWCatsObs: Observable<IWorkAndSubWorkCategory[]> = this.myFundiService.GetJobWorkCategoriesByJobId(this.job.jobId);

        this.chosenWorkCategories = [];
        jWCatsObs.map((jwCats: IWorkAndSubWorkCategory[]) => {

            this.chosenWorkCategories = jwCats;
            //populate ui with string ls of jobWorkCats:
            let ulWCats = jQuery('ul#ulistWorkCategories');
            jQuery('ul#ulistWorkCategories > li').remove();

            jwCats.forEach((cat) => {
                ulWCats.append('<li id="' + `${cat.workCategoryId.toString()},${cat.workSubCategoryId.toString()}` + '">' + `${cat.workCategory.workCategoryType}: [${cat.workSubCategory.workSubCategoryType}]` + '</li>');
            });
        }).subscribe();

        jQuery('select#assignedFundiProfileId').val(job.assignedFundiProfileId);
        $event.preventDefault();
    }
    updateJob($event) {
        this.job.jobWorkCategoryIds = this.chosenWorkCategories;

        let jobObs: Observable<any> = this.myFundiService.UpdateJob(this.job);
        jobObs.map((q: any) => {
            alert(q.message);
        }).subscribe();

        $event.preventDefault();
    }
    deleteJob($event) {
        let jobObs: Observable<any> = this.myFundiService.DeleteJob(this.job.jobId);
        jobObs.map((q: any) => {
            alert(q.message);
        }).subscribe();

        $event.preventDefault();
    }
    addWorkCategory($event) {

        let selectedWorkCategory: IWorkAndSubWorkCategory = this.workCategories.find((workCat: IWorkAndSubWorkCategory) => {
            return workCat.workCategoryId == parseInt(this.workCategoryAndSubCatId.split(',')[0]) && workCat.workSubCategoryId == parseInt(this.workCategoryAndSubCatId.split(',')[1]);

        });

        this.chosenWorkCategories.push(selectedWorkCategory);
        let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
        let li = document.createElement("li");
        li.id = `${selectedWorkCategory.workCategoryId.toString()},${selectedWorkCategory.workSubCategoryId.toString()}` ;

        li.textContent = selectedWorkCategory.workCategory.workCategoryType + ` :[${selectedWorkCategory.workSubCategory.workSubCategoryType}]`;
        ulSelectedCategories.appendChild(li);

        $event.preventDefault();
    }
    removeWorkCategory($event) {

        let selectedWorkCategory: IWorkAndSubWorkCategory = this.workCategories.find((workCat: IWorkAndSubWorkCategory) => {
            return workCat.workCategoryId == parseInt(this.workCategoryAndSubCatId.split(',')[0]) && workCat.workSubCategoryId == parseInt(this.workCategoryAndSubCatId.split(',')[1]);

        });
        let curThis = this;

        let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
        let li = document.querySelector('ul#ulistWorkCategories > li[id="' + `${selectedWorkCategory.workCategoryId.toString()},${selectedWorkCategory.workSubCategoryId.toString()}` + '"]');
        ulSelectedCategories.removeChild(li);

        let chosenli = jQuery('ul#ulistWorkCategories li');

        let resObs: Observable<boolean> = this.myFundiService.RemoveWorkCategorFromJobId(this.job.jobId, selectedWorkCategory.workCategoryId, selectedWorkCategory.workSubCategoryId);
        resObs.map((hasRemoved: boolean) => {
            if (hasRemoved) {
                alert("Work Category removed!");
                this.selectJob(null);
            }
            else {
                alert("Work Category And Sub Category Do Not Exist Or Failed Removal!");
            }
        }).subscribe();
        $event.preventDefault();
    }

    ngAfterViewChecked() {
        let curthis = this;

        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
    runAutoCompleteOnSelects(curthis: any) {
        let hasFoundSelectsOnPage = false;

        if (!curthis.hasPopulatedPage && curthis.jobs && curthis.jobs.length > 0 && curthis.workCategories && curthis.workCategories.length > 0 &&
            curthis.locations && curthis.locations.length > 0 && curthis.fundiProfiles && curthis.fundiProfiles.length > 0 &&
            curthis.clientAddresses && curthis.clientAddresses.length > 0)
        {

            let selects = jQuery('div#client-wrapper select');

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
            debugger;
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

            jQuery('div#editableClientDetails').hide(2000);
            clearTimeout(curthis.setTo);
        }
    }
}

