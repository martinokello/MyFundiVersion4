import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, AfterViewChecked, Inject } from '@angular/core';
import { IVehicle, MyFundiService, IUserDetail } from '../../services/myFundiService';
import * as $ from "jquery";
import 'rxjs/add/operator/map';
@Component({
    selector: 'forgotPassword',
    templateUrl: './forgotPassword.component.html',
    styleUrls: ['./forgotPassword.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class ForgotPasswordComponent implements OnInit{
    public userDetail: IUserDetail | any;
    private myFundiService: MyFundiService  | any;
    ngOnInit(): void {
        let userDetail: IUserDetail = {
            password: "",
            role: "",
            emailAddress: "",
            username: "",
            mobileNumber:"",
            repassword: "",
            firstName: "",
            lastName: "",
            keepLoggedIn: false,
          authToken: "",
          fundi: false,
          client: false
        };

        this.userDetail = userDetail;
    }
  public constructor(myFundiService: MyFundiService ) {
    this.myFundiService = myFundiService;
    }
  public forgotPassword(): void {
    this.userDetail.username = this.userDetail.emailAddress;
      this.myFundiService.forgotPasswordByPost(this.userDetail);
    }
}
