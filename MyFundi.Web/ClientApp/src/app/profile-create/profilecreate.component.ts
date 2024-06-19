import { Component, OnInit, Inject, AfterViewInit } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IAddress, IWorkAndSubWorkCategory } from '../../services/myFundiService';
import { AfterViewChecked } from '@angular/core';
import { Observable } from 'rxjs';
declare var jQuery: any;

@Component({
    selector: 'profile-create',
    templateUrl: './profilecreate.component.html'
})
export class ProfileCreateComponent implements OnInit {
    userDetails: any;
    userRoles: string[];
    profileImage: File;
    profileCV: File;
    profile: IProfile;
    location: ILocation;
    fundiRatings: IFundiRating[];
    certifications: ICertification[];
    courses: ICourse[];
    userGuidId: string;
    hasPopulatedPage: boolean = false;
    setTo: any;
    workCategories: IWorkAndSubWorkCategory[];
    chosenWorkCategories: IWorkAndSubWorkCategory[];
    workCategoryAndSubCatId: string;

    constructor(private myFundiService: MyFundiService, private httpClient: HttpClient) {
        this.userDetails = {};
        this.profile = {
            fundiProfileId: 0,
            userId: "",
            user: null,
            profileSummary: "",
            profileImageUrl: "",
            skills: "",
            usedPowerTools: "",
            fundiProfileCvUrl: "",
            locationId: 0
        };
    }

    ngOnInit(): void {

        jQuery('input#locationAddLocationId').css('display', 'none');
        jQuery('input#locationUpdateLocationId').css('display', 'none');
        jQuery('input#locationDeleteLocationId').css('display', 'none');
        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
        if (!this.userDetails) this.userDetails = {};
        if (!this.userDetails.username) {
            this.userDetails.username = MyFundiService.clientEmailAddress;
        }
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));


        let userGuidObs = this.myFundiService.GetUserGuidId(this.userDetails.username);
        userGuidObs.map((q: string) => {
            this.userGuidId = q;

            let resObs: Observable<any> = this.myFundiService.GetFundiProfile(this.userDetails.username);
            resObs.map((fundiProf: IProfile) => {

                if (fundiProf) {
                    this.profile = fundiProf;

                    let curAddObs = this.myFundiService.GetLocationById(fundiProf.locationId);
                    curAddObs.map((q: ILocation) => {
                        this.location = q;
                    }).subscribe();

                }
                else {

                    this.profile = {
                        fundiProfileId: 0,
                        user: null,
                        userId: "",
                        profileSummary: "",
                        profileImageUrl: "",
                        skills: "",
                        usedPowerTools: "",
                        fundiProfileCvUrl: "",
                        locationId: 0
                    }

                }
            }).subscribe();
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
            let listWorkCatObs: Observable<IWorkAndSubWorkCategory[]> = this.myFundiService.GetFundiWorkCategories(this.userDetails.username);

            listWorkCatObs.map((q: IWorkAndSubWorkCategory[]) => {
                debugger;
                if (q && q.length > 0) {
                    let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
                    q.forEach((wkcCatSubCat, index, q) => {
                        let li = document.createElement("li");
                        li.setAttribute('id', `${wkcCatSubCat.workCategoryId.toString()},${wkcCatSubCat.workSubCategoryId.toString()}`);
                        li.textContent = wkcCatSubCat.workCategory.workCategoryType + ` :[${wkcCatSubCat.workSubCategory.workSubCategoryType}]`;

                        ulSelectedCategories.appendChild(li);
                    });
                }
            }).subscribe();
        }).subscribe();
    }

    handleProfileCV(files: FileList) {
        this.profileCV = files.item(0);
    }

    handleProfileImage(files: FileList) {
        this.profileImage = files.item(0);
    }

    uploadFundiCV(): void {
        //let busyGif: HTMLDivElement = document.querySelector("div#loadingProfileCV");
        //busyGif.style.display = 'block';
        let url: string = "/FundiProfile/SaveFundiCV";

        let formData = new FormData();
        formData.append("fundiProfileCv", this.profileCV);
        formData.append("username", this.userDetails.username);

        this.httpClient.post(url, formData).map((res: any) => {
            alert(res.message);
        }).subscribe();
    }
    uploadProfileImage(): void {

        //let busyGif: HTMLDivElement = document.querySelector("div#loadingProfileImage");
        //busyGif.style.display = 'block';
        let url: string = "/FundiProfile/SaveFundiProfileImage";

        let formData = new FormData();
        formData.append("profileImage", this.profileImage);
        formData.append("username", this.userDetails.username);

        this.httpClient.post(url, formData).map((res: any) => {
            alert(res.message);
        }).subscribe();;
    }
    saveProfile(): void {
        this.profile.userId = this.userGuidId;
        let profileObs = this.myFundiService.SaveProfile(this.profile);

        profileObs.map((res: any) => {
            alert(res.message);
            if (!res.result) {
                alert("Falied to Save Profile, please contact site administrator")
                sessionStorage.setItem("ProfileExists", '0');
            }
        }).subscribe();
    }
    addWorkCategory($event) {

        let selectedWorkCategory: IWorkAndSubWorkCategory = this.workCategories.find((workCat: IWorkAndSubWorkCategory) => {
            let workCatsSubCatsAry = this.workCategoryAndSubCatId.split(',');
            return workCat.workCategoryId == parseInt(workCatsSubCatsAry[0]) && workCat.workSubCategoryId == parseInt(workCatsSubCatsAry[1]);

        });
        let addWkCatObs: Observable<boolean> = this.myFundiService.AddFundiWorkCategory(selectedWorkCategory.workCategoryId, selectedWorkCategory.workSubCategoryId, this.userDetails.username);
        //this.chosenWorkCategories.push(selectedWorkCategory);
        addWkCatObs.map((q: boolean) => {
            if (q) {
                let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
                let li = document.createElement("li");
                li.setAttribute('id', `${selectedWorkCategory.workCategoryId.toString()},${selectedWorkCategory.workSubCategoryId.toString()}`);

                li.textContent = selectedWorkCategory.workCategory.workCategoryType + ` :[${selectedWorkCategory.workSubCategory.workSubCategoryType}]`;
                ulSelectedCategories.appendChild(li);

                let addWkCatSubCatObs = this.myFundiService.AddFundiWorkCategory(selectedWorkCategory.workCategoryId, selectedWorkCategory.workSubCategoryId, this.userDetails.username);
                addWkCatSubCatObs.map((q: any) => {
                    if (q) {
                        alert(q.message);
                    }
                }).subscribe();
            }
        }).subscribe();


        $event.preventDefault();
    }
    removeWorkCategory($event) {

        let selectedWorkCategory: IWorkAndSubWorkCategory = this.workCategories.find((workCat: IWorkAndSubWorkCategory) => {
            let workCatsSubCatsAry = this.workCategoryAndSubCatId.split(',');
            return workCat.workCategoryId == parseInt(workCatsSubCatsAry[0]) && workCat.workSubCategoryId == parseInt(workCatsSubCatsAry[1]);

        });
        let curThis = this;
        debugger;
        let ulSelectedCategories = document.querySelector('ul#ulistWorkCategories');
        let li = document.querySelector('ul#ulistWorkCategories > li[id="' + `${selectedWorkCategory.workCategoryId.toString()},${selectedWorkCategory.workSubCategoryId.toString()}` + '"]');
        ulSelectedCategories.removeChild(li);

        let resObs: Observable<any> = this.myFundiService.RemoveFundiWorkCategory(selectedWorkCategory.workCategoryId, selectedWorkCategory.workSubCategoryId, this.userDetails.username);
        resObs.map((removed: any) => {
            if (removed) {
                alert(removed.message);
            }
        }).subscribe();
        $event.preventDefault();
    }

    getSelectedLocation(locationId: number) {
        this.profile.locationId = locationId;
        let curAddObs = this.myFundiService.GetLocationById(locationId);
        curAddObs.map((q: ILocation) => {
            this.location = q;
            alert('Location selected!')
        }).subscribe();
    }

}

