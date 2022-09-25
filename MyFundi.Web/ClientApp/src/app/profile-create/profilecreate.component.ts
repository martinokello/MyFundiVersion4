import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService, IAddress } from '../../services/myFundiService';

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
  workCategories: IWorkCategory[];
  certifications: ICertification[];
  courses: ICourse[];
  userGuidId: string;
  address: IAddress;

  ngOnInit(): void {
    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
    this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    let userGuidObs = this.myFundiService.GetUserGuidId(this.userDetails.username);

    userGuidObs.map((q: string) => {
      this.userGuidId = q;
    }).subscribe();

    let resObs = this.myFundiService.GetFundiProfile(this.userDetails.username);


    resObs.map((fundiProf: IProfile) => {
      if (fundiProf) {
        this.profile = fundiProf;

        let curAddObs = this.myFundiService.GetAddressById(fundiProf.addressId);
        curAddObs.map((q: IAddress) => {
          this.address = q;
        }).subscribe();
      }
      else {
        this.profile = {
          fundiProfileId: 0,
          user: null,
          userId:"",
          profileSummary: "",
          profileImageUrl: "",
          skills: "",
          usedPowerTools: "",
          fundiProfileCvUrl: "",
          addressId: 0
        }
      }
    }).subscribe();
  }
  constructor(private myFundiService: MyFundiService,private httpClient: HttpClient) {
    this.userDetails = {};
    this.profile =  {
      fundiProfileId: 0,
      userId: "",
      user:null,
      profileSummary: "",
      profileImageUrl: "",
      skills: "",
      usedPowerTools: "",
      fundiProfileCvUrl: "",
      addressId: 0
    };
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
    }).subscribe();
  }
  getSelectedAddress(addressId: number) {
    this.profile.addressId = addressId;
  }
}

