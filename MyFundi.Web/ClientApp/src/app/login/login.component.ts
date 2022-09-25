import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, AfterViewChecked, Inject, Output, Input } from '@angular/core';
import { Router } from '@angular/router';
import { Observable } from 'rxjs/Observable';
import { MyFundiService, ILogInStatus, IUserDetail, IUserStatus } from '../../services/myFundiService';
import 'rxjs/add/operator/map';
import * as $ from 'jquery';

@Component({
  selector: 'login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class LoginComponent implements OnInit {
  userRoles: string[] = [];
  public userDetail: IUserDetail | any;
  private myFundiService: MyFundiService | any;
  private router: Router;
  actUserStatus: IUserStatus = {
    isUserAdministrator: false,
    isUserLoggedIn: false
  }
  ngOnInit(): void {

    this.userDetail = {
      password: "",
      role: "",
      emailAddress: "",
      username: "",
      mobileNumber: "",
      repassword: "",
      firstName: "",
      lastName: "",
      keepLoggedIn: false,
      authToken: "",
      fundi: false,
      client: false
    };
 
  }
  public constructor(myFundiService: MyFundiService, router: Router) {
    this.myFundiService = myFundiService;
    this.router = router;
  }

  public loginUser(): void {

    localStorage.setItem("userRoles", '');
    sessionStorage.removeItem("Orders");

    this.userDetail.authToken = localStorage.getItem('authToken');
    this.userDetail.username = this.userDetail.emailAddress;

    let loginResults: Observable<any> = this.myFundiService.LoginByPost(this.userDetail);
    loginResults.map((q: any) => {
      console.log(q.toString());
      if (q.isLoggedIn === true) {
        this.userDetail.firstName = q.firstName;
        this.userDetail.lastName = q.lastName;
        this.userDetail.userId = q.userId;

        localStorage.setItem("userDetails", JSON.stringify(this.userDetail));

        if (q.authToken) {
          localStorage.setItem('authToken', q.authToken);
        }
        this.actUserStatus.isUserLoggedIn = MyFundiService.actUserStatus.isUserLoggedIn = true;
        if (q.isAdministrator) {
          this.actUserStatus.isUserAdministrator = MyFundiService.actUserStatus.isUserAdministrator = true;
        }

        localStorage.setItem("actUserStatus", JSON.stringify(this.actUserStatus));
        $('span#loginName').css('display', 'block');
        $('span#loginName').text("logged in as: " + this.userDetail.emailAddress);
        MyFundiService.isLoginPage = false;
        MyFundiService.SetUserEmail(this.userDetail.emailAddress);
        this.ensureUserRolesGot();
      }
      else {
        $('span#loginName').css('display', 'none');
        $('span#loginName').text("");
        alert('Login Failed. Unknown User');
        this.actUserStatus.isUserLoggedIn = MyFundiService.actUserStatus.isUserLoggedIn = false;
        this.actUserStatus.isUserAdministrator = MyFundiService.actUserStatus.isUserAdministrator = false;

        MyFundiService.SetUserEmail('');
        localStorage.removeItem("actUserStatus");
        localStorage.removeItem('authToken');
        localStorage.removeItem("userRoles");
      }
    }).subscribe();
  }

  public ensureUserRolesGot(): void {
    let userRolesStr = localStorage.getItem("userRoles");
    if (userRolesStr != null && userRolesStr.length > 0) {
      this.userRoles = JSON.parse(userRolesStr);
      MyFundiService.userRoles = this.userRoles;
      localStorage.setItem("userRoles", JSON.stringify(this.userRoles));
    }
    if (this.userRoles == null || this.userRoles.length < 1) {
      this.myFundiService.GetAllUserRoles(MyFundiService.clientEmailAddress).
        map((userroles: string[]) => {
          localStorage.setItem("userRoles", JSON.stringify(userroles));
          this.userRoles = userroles;
          MyFundiService.userRoles = userroles;
          this.router.navigateByUrl("/scanqrcode");
        }).subscribe();
    }
    else {
      this.router.navigateByUrl("/scanqrcode");
    }
  }
}
