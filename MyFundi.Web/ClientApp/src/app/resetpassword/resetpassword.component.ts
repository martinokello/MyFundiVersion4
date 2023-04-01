import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, AfterViewChecked, Inject } from '@angular/core';
import { IVehicle, MyFundiService, IUserDetail, IResetPassword } from '../../services/myFundiService';
import * as $ from "jquery";
import 'rxjs/add/operator/map';
import { Observable } from 'rxjs';
@Component({
    selector: 'resetpassword',
    templateUrl: './resetpassword.component.html',
    styleUrls: ['./resetpassword.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class ResetPasswordComponent implements OnInit{
    private myFundiService: MyFundiService | any;
    public passwordReset: IResetPassword;

    ngOnInit(): void {
        this.passwordReset = {
            id: localStorage.getItem("UserIdResetPassword"),
            password: "",
            repassword: "",
            token: ""
        };

    }
  public constructor(myFundiService: MyFundiService ) {
    this.myFundiService = myFundiService;
    }
    public resetPassword($event): void {
        if (localStorage.getItem('PasswordResetToken') !== this.passwordReset.token) {
            alert('Sorry your token is Invalid.\nPlease check your email and paste the right token!');
            return;
        }
      let resetPasswordResObs: Observable<any> = this.myFundiService.resetPasswordByPost(this.passwordReset);
      resetPasswordResObs.map((q: any) => {
          if (q.errorMessage) {
              alert("The user doesn't exist Or Bad Request!\nPlease check the email address.");
          }
          else if (q.message) {
              alert(q.message);
              localStorage.removeItem('UserIdResetPassword');
          }
          else {
              alert("Bad Request, something wrong happened.\nPlease contact the site administrator.")
          }
          localStorage.removeItem('PasswordResetToken');
      }).subscribe();

      $event.preventDefault();
    }
}
