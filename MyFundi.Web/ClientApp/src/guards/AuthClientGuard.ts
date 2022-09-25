import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { MyFundiService, IUserStatus } from '../services/myFundiService';


@Injectable()
export class AuthClientGuard implements CanActivate {
  private myFundiService: MyFundiService ;
    userRoles: string[];

  // Inject Router so we can hand off the user to the Login Page 
  constructor(private router: Router, myFundiService: MyFundiService ) {
    this.myFundiService = myFundiService;
  }
 canActivate(): boolean {
   if (MyFundiService.userRoles != null && MyFundiService.userRoles.length > 0) {
     this.userRoles = MyFundiService.userRoles;

     return this.userRoles.indexOf("Client") > -1;
   }
   return false;
  }
}
