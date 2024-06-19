import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, AfterViewChecked, Inject } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { MyFundiService, ILogInStatus, IUserDetail, IVehicle } from '../../services/myFundiService';
import { Router } from '@angular/router';
declare var jQuery: any;

@Component({
    selector: 'register',
    templateUrl: './register.component.html',
    styleUrls: ['./register.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class RegisterComponent implements OnInit, AfterViewInit{
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
            client: false,
            message: ""
        };

        this.userDetail = userDetail;
    }
  public constructor(myFundiService: MyFundiService , private router:Router) {
    this.myFundiService = myFundiService;
    }
    ngAfterViewInit(): void {
       
    }
    public registerUser(): void {
        if (localStorage.getItem("HasAcceptedTermsOfService") !== "true") {
            alert("You can't register unless you accept the terms and conditions");
            return;
        }
        if (this.userDetail.fundi && this.userDetail.client) {
          alert("You have to either be a Fundi or Client, and not Both!");
          return;
    }
    if (this.userDetail.fundi || this.userDetail.client) {

      this.userDetail.username = this.userDetail.emailAddress;
      let registeResults: Observable<ILogInStatus> = this.myFundiService.registerByPost(this.userDetail);

        registeResults.map((q: ILogInStatus) => {
            if (q.isRegistered){
                alert('Registration Successfull: ' + q.isRegistered);
                localStorage.removeItem('HasAcceptedTermsOfService');
                if (this.userDetail.fundi) {
                    this.router.navigateByUrl("/fundi-subscription");
                }
                else {
                    this.router.navigateByUrl("/client-subscription");
                }
            }
            else {
                alert('Registration Failed: ');
            }
        }).subscribe();
    }
    else alert("You have to either be a Fundi or Client.");
  }
}
