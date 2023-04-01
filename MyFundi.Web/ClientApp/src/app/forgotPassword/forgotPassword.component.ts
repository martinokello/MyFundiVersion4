import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, AfterViewChecked, Inject } from '@angular/core';
import { IVehicle, MyFundiService, IUserDetail } from '../../services/myFundiService';
import * as $ from "jquery";
import 'rxjs/add/operator/map';
import { Observable } from 'rxjs';
import { Router } from '@angular/router';
@Component({
    selector: 'forgotPassword',
    templateUrl: './forgotPassword.component.html',
    styleUrls: ['./forgotPassword.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class ForgotPasswordComponent implements OnInit {
    public userDetail: IUserDetail | any;
    private myFundiService: MyFundiService | any;
    ngOnInit(): void {
        let userDetail: IUserDetail = {
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

        this.userDetail = userDetail;
    }
    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }
    public forgotPassword($event): void {

        let passwordResObs: Observable<any> = this.myFundiService.ForgotPasswordByPost(this.userDetail);
        passwordResObs.map((q: any) => {
            if (q.errorMessage) {
                alert(q.errorMessage);
            }
            else if (q.message) {
                localStorage.setItem("UserIdResetPassword", q.userId);
                localStorage.setItem('PasswordResetToken', q.passwordResetToken);
                alert("You have been sent an email to reset your password!!");
                this.router.navigateByUrl('reset-password');
            }
            else {
                alert(q.errorMessage)
            }
        }).subscribe();
        $event.preventDefault();
    }
}
