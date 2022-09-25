import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, AfterViewChecked, Inject } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import * as $ from "jquery";
import 'rxjs/add/operator/map';
import { MyFundiService, ILogInStatus, IUserDetail, IVehicle } from '../../services/myFundiService';
import { Router } from '@angular/router';
@Component({
    selector: 'register',
    templateUrl: './register.component.html',
    styleUrls: ['./register.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class RegisterComponent implements OnInit{
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
          client:false
        };

        this.userDetail = userDetail;
    }
  public constructor(myFundiService: MyFundiService , private router:Router) {
    this.myFundiService = myFundiService;
    }
  public registerUser(): void {
    if (this.userDetail.fundi && this.userDetail.client) {
      alert("You have to either be a Fundi or Client, and not Both!");
      return;
    }
    if (this.userDetail.fundi || this.userDetail.client) {

      this.userDetail.username = this.userDetail.emailAddress;
      let registeResults: Observable<ILogInStatus> = this.myFundiService.registerByPost(this.userDetail);

      registeResults.map((q: ILogInStatus) => {
            if (q.isRegistered) {
              alert('Registration Successfull: ' + q.isRegistered);
              this.router.navigateByUrl("/login");
            }
            else {
              alert('Registration Failed: ');
        }
        }).subscribe();
    }
    else alert("You have to either be a Fundi or Client.");
  }
}
