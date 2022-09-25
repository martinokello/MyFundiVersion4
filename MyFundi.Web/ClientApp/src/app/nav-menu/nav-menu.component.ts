import { Component,AfterContentInit, ViewChild, ElementRef, Input, Output, EventEmitter, OnInit, AfterViewInit } from '@angular/core';
import { Element } from '@angular/compiler';
import { Observable } from 'rxjs/Observable';
import { MyFundiService, IUserStatus, IUserDetail } from '../../services/myFundiService';
import 'rxjs/add/operator/map';
import * as $ from 'jquery';
import { Router, NavigationEnd } from '@angular/router';

@Component({
  selector: 'app-nav-menu',
  templateUrl: './nav-menu.component.html',
  styleUrls: ['./nav-menu.component.css']
})
export class NavMenuComponent implements AfterContentInit,AfterViewInit {

  @Input("actUserStatus") actUserStatus: IUserStatus = {
    isUserLoggedIn: false,
    isUserAdministrator: false
  };
  public userRoles: string[];

  public myFundiService: MyFundiService ;
  public constructor(myFundiService: MyFundiService , private router: Router) {
    this.myFundiService = myFundiService;
    this.router.events.filter(event => event instanceof NavigationEnd).subscribe((val: any) => { this.myInit(); });
  }

  ngAfterContentInit(): void {
    this.myInit();
  }

  ngAfterViewInit(): void {
    this.myInit();
  }
  myInit(): void {
    this.verifyLoggedInUser();
  }
  verifyLoggedInUser(): void {
    this.actUserStatus.isUserLoggedIn = MyFundiService.actUserStatus.isUserLoggedIn;
    this.actUserStatus.isUserAdministrator = MyFundiService.actUserStatus.isUserAdministrator;
    if (!this.actUserStatus.isUserLoggedIn) {

      let verifyResult: Observable<any> = this.myFundiService.VerifyLoggedInUser();
      verifyResult.map((p: any) => {
        if (p.isLoggedIn) {
          $('span#loginName').css('display', 'block');
          $('span#loginName').text("logged in as: " + p.name);
          MyFundiService.SetUserEmail(p.name);
          MyFundiService.actUserStatus.isUserLoggedIn = this.actUserStatus.isUserLoggedIn = true;
          if (p.isAdministrator) {
            MyFundiService.actUserStatus.isUserAdministrator = this.actUserStatus.isUserAdministrator = true;
          }
          localStorage.removeItem("actUserStatus");
          localStorage.setItem("actUserStatus", JSON.stringify(this.actUserStatus));

          this.ensureUserRolesGot();
        }
        else {
          MyFundiService.actUserStatus.isUserLoggedIn = this.actUserStatus.isUserLoggedIn = false;
          MyFundiService.actUserStatus.isUserAdministrator = this.actUserStatus.isUserAdministrator = false;

          localStorage.removeItem("userRoles");
          localStorage.removeItem("actUserStatus");
          localStorage.removeItem('authToken');
          $('span#loginName').css('display', 'none');
        }
      }).subscribe();
    }

    this.ensureUserRolesGot();
  }
  makePayments(): void {
  }
  setIsLogInPage(): void {
    MyFundiService.isLoginPage = true;
    this.logOut();
  }
  logOut(): void {
    localStorage.removeItem('authToken');
    localStorage.removeItem("userDetails");
    localStorage.removeItem("userRoles");
    localStorage.removeItem("Orders");
    this.userRoles = [];

    this.actUserStatus.isUserLoggedIn = MyFundiService.actUserStatus.isUserLoggedIn = false;
    this.actUserStatus.isUserAdministrator = MyFundiService.actUserStatus.isUserAdministrator = false;
    MyFundiService.SetUserEmail('');
    let logOutResult: Observable<any> = this.myFundiService.LogOut();
    logOutResult.map((p: any) => {

      $('span#loginName').css('display', 'none');
      localStorage.removeItem("userRoles");
      localStorage.removeItem("actUserStatus");
      this.actUserStatus.isUserLoggedIn = false;
      this.actUserStatus.isUserAdministrator = false;
      this.userRoles = [];
    }).subscribe();

  }

  public ensureUserRolesGot(): void {
    if (this.actUserStatus.isUserLoggedIn) {
      let userRolesStr = JSON.parse(localStorage.getItem("userRoles"));
      if (userRolesStr != null && userRolesStr.length > 0) {
        this.userRoles = MyFundiService.userRoles = userRolesStr;
        localStorage.setItem("userRoles", JSON.stringify(MyFundiService.userRoles));
        return;
      }
      if (this.userRoles == null || this.userRoles.length < 1) {
        this.myFundiService.GetAllUserRoles(MyFundiService.clientEmailAddress).
          map((userroles: string[]) => {
            localStorage.setItem("userRoles", JSON.stringify(userroles));
            this.userRoles = MyFundiService.userRoles =  userroles;
          }).subscribe();
      }
    }

  }
}
