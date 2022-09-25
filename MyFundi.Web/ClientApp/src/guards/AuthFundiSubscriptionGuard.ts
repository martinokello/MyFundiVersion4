import { Injectable } from '@angular/core';
import { CanActivate,Router } from '@angular/router';
import { Observable } from 'rxjs';
import { IUserStatus, MyFundiService } from '../services/myFundiService';

@Injectable()
export class AuthFundiSubscriptionGuard implements CanActivate {
  userDetails: any;
  fundiHasSubscription: boolean;
  userRoles: string[];
  fundiSubscribed: boolean;
  fundiProfileid: number;

 constructor(private router: Router, private myFundiService: MyFundiService ) {
  }

  canActivate(): Observable<boolean> | boolean | any {

    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
    if (!this.userDetails)
      return false;
      let fundiProfileId = 0;

    let resObs: any = this.myFundiService.GetFundiProfile(this.userDetails.username);

    return resObs.map((fundiProf: any): boolean => {
      this.fundiProfileid = fundiProf.fundiProfileId;
      let fundiSubsObj: any = this.myFundiService.GetFundiSubscriptionByProfileId(this.fundiProfileid);

      return fundiSubsObj.map((q: any):boolean => {
        this.fundiHasSubscription = q.isValid;
        return this.userRoles.indexOf("Fundi") > -1 && this.fundiHasSubscription;
      }).first();
    }).first();
  }
}

