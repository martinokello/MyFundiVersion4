import { Component, AfterContentInit, ViewChild, ElementRef, Input, Output, EventEmitter, OnInit, AfterViewInit } from '@angular/core';
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
export class NavMenuComponent implements AfterContentInit, AfterViewInit {

    @Input("actUserStatus") actUserStatus: IUserStatus = {
        isUserLoggedIn: false,
        isUserAdministrator: false,
        isClientExpiredSubscription: false,
        isFundiExpiredSubscription: false,
        isFundi: false
    };
    public userRoles: string[];
    private timeOut: any;

    public myFundiService: MyFundiService;
    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
        this.router.events.filter(event => event instanceof NavigationEnd).subscribe((val: any) => { this.myInit(); });
    }

    ngAfterContentInit(): void {
        //this.myInit();
    }

    ngAfterViewInit(): void {
        let curThis = this;
        this.timeOut = setTimeout(() => {
            curThis.myInit();
        }, 700);
    }
    myInit(): void {
        this.verifyLoggedInUser();
    }
    verifyLoggedInUser(): void {
        this.actUserStatus.isUserLoggedIn = MyFundiService.actUserStatus.isUserLoggedIn;
        this.actUserStatus.isUserAdministrator = MyFundiService.actUserStatus.isUserAdministrator;
        this.actUserStatus.isClientExpiredSubscription = MyFundiService.actUserStatus.isClientExpiredSubscription;
        this.actUserStatus.isFundiExpiredSubscription = MyFundiService.actUserStatus.isFundiExpiredSubscription;
        this.actUserStatus.isFundi = MyFundiService.actUserStatus.isFundi;

        if (!this.actUserStatus.isUserLoggedIn && !MyFundiService.clientEmailAddress) {

            let verifyResult: Observable<any> = this.myFundiService.VerifyLoggedInUser();
            verifyResult.map((p: any) => {
                if (p.isLoggedIn) {
                    $('span#loginName').css('display', 'block');
                    $('span#loginName').text("logged in as: " + p.username);
                    MyFundiService.SetUserEmail(p.name);
                    MyFundiService.actUserStatus.isUserLoggedIn = this.actUserStatus.isUserLoggedIn = true;
                    if (p.isAdministrator) {
                        MyFundiService.actUserStatus.isUserAdministrator = this.actUserStatus.isUserAdministrator = p.isAdministrator;
                    }
                    this.actUserStatus.isClientExpiredSubscription = MyFundiService.actUserStatus.isClientExpiredSubscription = p.clientDueToPaySubscription;
                    this.actUserStatus.isFundiExpiredSubscription = MyFundiService.actUserStatus.isFundiExpiredSubscription = p.fundiDueToPaySubscription;
                    this.actUserStatus.isFundi = MyFundiService.actUserStatus.isFundi = p.isFundi;
                    localStorage.removeItem("actUserStatus");
                    localStorage.setItem("actUserStatus", JSON.stringify(this.actUserStatus));

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
        else {
            if (this.timeOut) {
                clearTimeout(this.timeOut);
            }
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
        
        localStorage.removeItem("userRoles");
        localStorage.removeItem("actUserStatus");
        localStorage.removeItem('authToken');
        this.userRoles = [];

        this.actUserStatus.isUserLoggedIn = MyFundiService.actUserStatus.isUserLoggedIn = false;
        this.actUserStatus.isUserAdministrator = MyFundiService.actUserStatus.isUserAdministrator = false;
        this.actUserStatus.isClientExpiredSubscription = MyFundiService.actUserStatus.isClientExpiredSubscription = false;
        this.actUserStatus.isFundiExpiredSubscription = MyFundiService.actUserStatus.isFundiExpiredSubscription = false;
        this.actUserStatus.isFundi = MyFundiService.actUserStatus.isFundi = false;
        MyFundiService.SetUserEmail('');
        let logOutResult: Observable<any> = this.myFundiService.LogOut();
        logOutResult.map((p: any) => {

            if (this.timeOut) {
                clearTimeout(this.timeOut);
            }
            $('span#loginName').css('display', 'none');
            localStorage.removeItem("userRoles");
            localStorage.removeItem("actUserStatus");
            this.actUserStatus.isUserLoggedIn = false;
            this.actUserStatus.isUserAdministrator = false;
            this.actUserStatus.isClientExpiredSubscription = false;
            this.actUserStatus.isFundiExpiredSubscription = false;
            this.actUserStatus.isFundi = false;
            this.userRoles = [];
        }).subscribe();

    }

    public ensureUserRolesGot(): void {
        let userRolesStr = localStorage.getItem("userRoles");

        this.userRoles = (userRolesStr == '' || userRolesStr == null) ? [] : JSON.parse(userRolesStr);

        if (this.userRoles.length > 0) {
            MyFundiService.userRoles = this.userRoles;
            localStorage.setItem("userRoles", JSON.stringify(this.userRoles));
        }
        if (this.userRoles == null || this.userRoles.length < 1) {
            this.myFundiService.GetAllUserRoles(MyFundiService.clientEmailAddress).
                map((userroles: string[]) => {
                    MyFundiService.userRoles = userroles;
                    this.userRoles = userroles;
                    localStorage.setItem("userRoles", JSON.stringify(userroles));
                }).subscribe();
        }
    }
}
