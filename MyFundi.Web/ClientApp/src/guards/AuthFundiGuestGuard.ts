import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { MyFundiService, IUserStatus, IUserDetail } from '../services/myFundiService';


@Injectable()
export class AuthFundiGuestGuard implements CanActivate {
    userRoles: string[];

    // Inject Router so we can hand off the user to the Login Page 
    constructor(private router: Router, private myFundiService: MyFundiService) {
    }

    canActivate(): boolean {

        if (MyFundiService.userRoles != null && MyFundiService.userRoles.length > 0) {
            this.userRoles = MyFundiService.userRoles;

            return this.userRoles.indexOf("Fundi") > -1 || this.userRoles.indexOf("Guest") > -1;
        }
        return false;
    }
}
