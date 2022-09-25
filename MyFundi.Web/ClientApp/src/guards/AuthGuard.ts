import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { MyFundiService, IUserStatus } from '../services/myFundiService';


@Injectable()
export class AuthGuard implements CanActivate {

  // Inject Router so we can hand off the user to the Login Page 
  constructor(private router: Router) { }

 canActivate(): boolean {

    // Token from the LogIn is avaiable, so the user can pass to the route
   let actUserStatus: IUserStatus = JSON.parse(localStorage.getItem("actUserStatus"));

    if (actUserStatus) {
      return actUserStatus.isUserLoggedIn;
    }
    return false;
  }
}
