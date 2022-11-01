import { Component, OnInit, Inject, AfterViewInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IAddress, IClientProfile, IJob } from '../../services/myFundiService';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
declare var jQuery: any;

@Component({
    selector: 'client',
    templateUrl: './client.component.html'
})
export class ClientProfileComponent implements OnInit, AfterViewInit {
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
    address: IAddress;
    addressId: number;
    profileSummary: string;
    clientFundiContractId: number;
    clientProfiles: IClientProfile[];
    fundiProfiles: IProfile[];
    workCategories: IWorkCategory[];
    chosenWorkCategories: IWorkCategory[];
    workCategoryId: number;
    job: any;
    jobs: IJob[];

    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }
    ngOnInit(): void {
        this.clientProfile = {};
        this.job = {};

        this.chosenWorkCategories = [];
        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
        let resObs = this.myFundiService.GetClientProfile(this.userDetails.username);

        resObs.map((clientProf: IClientProfile) => {

            if (clientProf) {
                this.clientProfile = clientProf;
                this.profileSummary = clientProf.profileSummary;
                this.clientProfileId = this.clientProfile.clientProfileId;
                let curAddObs = this.myFundiService.GetAddressById(this.clientProfile.addressId);
                curAddObs.map((q: IAddress) => {
                    this.address = q;
                    this.addressId = q.addressId;
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
                }).subscribe();
            }
            else {
                this.clientProfile = {
                    clientProfileId: 0,
                    userId: "",
                    profileSummary: "",
                    profileImageUrl: "",
                    addressId: 0
                }
            }
        }).subscribe();

        let userGuidObs = this.myFundiService.GetUserGuidId(this.userDetails.username);
        userGuidObs.map((q: string) => {
            this.clientUserGuidId = q;
            this.refreshAddresses();
        }).subscribe();

        let workCatObs = this.myFundiService.GetAllFundiWorkCategories();

        workCatObs.map((workCats: IWorkCategory[]) => {
            this.workCategories = workCats;

            //Dynamic check boxes for Categories To Search for:
            let selectWorkCategories: HTMLSelectElement = document.querySelector('select#workCategoryId');
            let selectWorkCategoriesOptions: HTMLSelectElement = document.querySelector('select#workCategoryId option');
            if (selectWorkCategoriesOptions) {
                selectWorkCategoriesOptions.remove();
            }

            let option = document.createElement('option');
            option.textContent = "Select Work Category";
            option.value = "0";
            selectWorkCategories.appendChild(option);

            this.workCategories.forEach((cat) => {
                let option = document.createElement('option');
                option.textContent = cat.workCategoryType;
                option.value = cat.workCategoryId.toString();
                selectWorkCategories.appendChild(option);
            });
        }).subscribe();


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
        }).subscribe();

        let locatObs: Observable<ILocation[]> = this.myFundiService.GetAllLocations();
        locatObs.map((loc: ILocation[]) => {
            let locations = loc;

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


            locations.forEach((comCat: ILocation, index: number, cmdCats) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = comCat.locationId.toString();
                optionElem.text = comCat.locationName;
                document.querySelector('select#locationId').append(optionElem);
            });
        }).subscribe();
    }
    constructor(private myFundiService: MyFundiService, private router: Router, private httpClient: HttpClient) {
        this.userDetails = {};
    }

    refreshAddresses() {
        let addSelect = document.querySelector('select#addressId');
        let opts = addSelect.querySelector('option');
        if (opts) {
            opts.remove();
        }
        let optionElem = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select Address";
        document.querySelector('select#addressId').append(optionElem);


        let addressesObs: Observable<IAddress[]> = this.myFundiService.GetAllAddresses();
        addressesObs.map((adds: IAddress[]) => {
            adds.forEach((add: IAddress, index: number, adds) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = add.addressId.toString();
                optionElem.text = add.addressLine1 + ", " + add.town + ", " + add.postCode;
                document.querySelector('select#addressId').append(optionElem);
            });

        }).subscribe();
    }
    handleProfileImage(files: FileList) {
        this.profileImage = files.item(0);
    }

    uploadProfileImage(): void {

        //let busyGif: HTMLDivElement = document.querySelector("div#loadingProfileImage");
        //busyGif.style.display = 'block';
        let url: string = "/ClientProfile/SaveClientProfileImage";

        let formData = new FormData();
        formData.append("profileImage", this.profileImage);
        formData.append("username", this.userDetails.username);

        this.httpClient.post(url, formData).map((res: any) => {
            alert(res.message);
        }).subscribe();;
    }

    saveOrUpdateClientProfile($event) {

        this.clientProfile.clientProfileId = this.clientProfileId;
        this.clientProfile.userId = this.clientUserGuidId;
        this.clientProfile.addressId = this.addressId;
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
        jQuery('div#editableClientDetails').css('display', 'block');
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
            assignedFundiUserId: null,//this.fundiProfile.user.userId,
            assignedFundiProfileId: null,//this.fundiProfile.fundiProfileId
            jobWorkCategoryIds: this.chosenWorkCategories.map((workCat: IWorkCategory) => {
                return workCat.workCategoryId;
            })
        };

        let obsj: Observable<any> = this.myFundiService.CreateFundiJob(job);
        obsj.map((q: any) => {
            alert(q.message)
        }).subscribe();
        $event.preventDefault();
    }
    selectJob($event) {
        let job: IJob = this.jobs.find((j: IJob) => {
            return j.jobId == this.job.jobId;
        });

        this.job = job;
        let jWCatsObs: Observable<any[]> = this.myFundiService.GetJobWorkCategoriesByJobId(job.jobId);

        this.chosenWorkCategories = [];
        jWCatsObs.map((jobWorkCats: any[]) => {
            let jwCats: any = jobWorkCats;
            this.chosenWorkCategories = jwCats;
            //populate ui with string ls of jobWorkCats:
            let ulWCats = jQuery('ul#ulistWorkCategories');
            jQuery('ul#ulistWorkCategories > li').remove();

            jwCats.forEach((cat) => {
                ulWCats.append('<li id="'+ cat.workCategoryId.toString()+'">' + cat.workCategory + '</li>');
            });
        }).subscribe();
        $event.preventDefault();
    }
    updateJob($event) {
        this.job.jobWorkCategoryIds = this.chosenWorkCategories.map((workCat: IWorkCategory) => {
            return workCat.workCategoryId;
        });
        debugger;
        let jobObs: Observable<any> = this.myFundiService.UpdateJob(this.job);
        jobObs.map((q: any) => {
            alert(q.message);
        }).subscribe();

        $event.preventDefault();
    }
    addWorkCategory($event) {

        let selectedWorkCategory: IWorkCategory = this.workCategories.find((workCat: IWorkCategory) => {

            return workCat.workCategoryId == this.workCategoryId;
        });
        this.chosenWorkCategories.push(selectedWorkCategory);
        let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
        let li = document.createElement("li");
        li.id = selectedWorkCategory.workCategoryId.toString();
        li.textContent = selectedWorkCategory.workCategoryType;
        ulSelectedCategories.appendChild(li);

        $event.preventDefault();
    }
    removeWorkCategory($event) {

        let selectedWorkCategory: IWorkCategory = this.workCategories.find((workCat: IWorkCategory) => {

            return workCat.workCategoryId == this.workCategoryId;
        });
        let curThis = this;

        let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
        let li = document.querySelector('ul#ulistWorkCategories > li[id="' + selectedWorkCategory.workCategoryId.toString() + '"]');
        ulSelectedCategories.removeChild(li);

        let chosenli = jQuery('ul#ulistWorkCategories li');

        let resObs: Observable<boolean> = this.myFundiService.RemoveWorkCategorFromJobId(this.job.jobId, selectedWorkCategory.workCategoryId);
        resObs.map((hasRemoved: boolean) => {
            if (hasRemoved) {
                alert("Work Category removed!");
                this.selectJob(null);
            }
            else {
                alert("Work Category Does Not Exist Or Failed Removal!");
            }
        }).subscribe();
        $event.preventDefault();
    }
    ngAfterViewInit() {
        jQuery('select').each((ind, sel) => {
            let options = jQuery(sel).children('option');
            debugger;
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
    }
}

