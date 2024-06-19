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
    private isClientSubscriptionExpired: boolean;
    actUserStatus: IUserStatus;
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
            client: false,
            message: ""
        };
        this.actUserStatus = {
            isUserAdministrator: false,
            isUserLoggedIn: false,
            isClientExpiredSubscription: false,
            isFundiExpiredSubscription: false,
            isFundi : false
        };
    }
    public constructor(myFundiService: MyFundiService, router: Router) {
        this.myFundiService = myFundiService;
        this.router = router;
    }

    public loginUser(): void {

        debugger;
        localStorage.setItem("userRoles", '');
        this.userDetail.authToken = localStorage.getItem('authToken');

        MyFundiService.clientEmailAddress = this.userDetail.username = this.userDetail.emailAddress;

        this.ensureUserRolesGot();
        let loginResults: Observable<any> = this.myFundiService.LoginByPost(this.userDetail);

        loginResults.map((q: any) => {
            console.log(JSON.stringify(q));
            debugger;
            if (q.isClient) {
                localStorage.setItem("ClientLoginDetails", JSON.stringify(q));
            }
            if (q.clientDueToPaySubscription) {
                this.isClientSubscriptionExpired = true;
                MyFundiService.actUserStatus.isFundi = this.actUserStatus.isFundi = false;
            }
            else{
                this.isClientSubscriptionExpired = false;
            }
            if (q.isLoggedIn == true || q.clientDueToPaySubscription || q.fundiDueToPaySubscription) {

                if (q.message) {
                    alert(q.message);
                }
                this.userDetail.firstName = q.firstName;
                this.userDetail.lastName = q.lastName;
                this.userDetail.userId = q.userId;
                this.userDetail.username = q.username;
                this.userDetail.email = q.username;

                localStorage.setItem("userDetails", JSON.stringify(this.userDetail));

                if (q.authToken) {
                    localStorage.setItem('authToken', q.authToken);
                }
                this.actUserStatus.isUserLoggedIn = MyFundiService.actUserStatus.isUserLoggedIn = true;
                if (q.isAdministrator) {
                    this.actUserStatus.isUserAdministrator = MyFundiService.actUserStatus.isUserAdministrator = true;
                    MyFundiService.actUserStatus.isFundi = this.actUserStatus.isFundi = true;
                }

                localStorage.setItem("actUserStatus", JSON.stringify(this.actUserStatus));
                $('span#loginName').css('display', 'block');
                $('span#loginName').text("logged in as: " + this.userDetail.emailAddress);
                MyFundiService.isLoginPage = false;
                if (q.isClient && this.isClientSubscriptionExpired) {
                    MyFundiService.actUserStatus.isClientExpiredSubscription = true;
                    MyFundiService.actUserStatus.isFundi = false;
                    this.actUserStatus.isFundi = false;

                    this.router.navigateByUrl('/client-subscription');
                }
                else if (q.isClient) {
                    this.router.navigateByUrl('/client-create-job');
                    MyFundiService.actUserStatus.isFundi = false;
                    this.actUserStatus.isFundi = false;
                }
                else if (q.isFundi && q.fundiDueToPaySubscription) {
                    MyFundiService.actUserStatus.isFundi = true;
                    this.actUserStatus.isFundi = true;
                    MyFundiService.actUserStatus.isFundiExpiredSubscription = true;

                    this.router.navigateByUrl('/fundi-subscription');
                }
                else if (this.userRoles && (this.userRoles.indexOf('Fundi') > -1 || this.userRoles.indexOf('Administrator') > -1)) {

                    MyFundiService.actUserStatus.isFundi = true;
                    this.actUserStatus.isFundi = true;
                    this.router.navigateByUrl("/manage-profile");
                }
                else{
                    this.router.navigateByUrl("/home");
                }
                return;
            }
            else {
                if (q.message) {
                    alert(q.message);
                }
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

        this.userRoles = (userRolesStr == '' || userRolesStr == null) ? [] : JSON.parse(userRolesStr);

        if (this.userRoles.length > 0) {
            MyFundiService.userRoles = this.userRoles;
            localStorage.setItem("userRoles", JSON.stringify(this.userRoles));
        }
        if (this.userRoles == null || this.userRoles.length < 1 ) {
            this.myFundiService.GetAllUserRoles(MyFundiService.clientEmailAddress).
                map((userroles: string[]) => {
                    MyFundiService.userRoles = userroles;
                    localStorage.setItem("userRoles", JSON.stringify(userroles));
                    this.userRoles = userroles;
                }).subscribe();
        }
    }
}


