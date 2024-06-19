import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { MyFundiService } from '../services/myFundiService';

@Injectable()
export class AuthFundiClientAdminGuard implements CanActivate {
    private myFundiService: MyFundiService;
    private userRoles: string[];
    // Inject Router so we can hand off the user to the Login Page 
    constructor(private router: Router, myFundiService: MyFundiService) {
        this.myFundiService = myFundiService;
    }

    canActivate(): boolean {
        if (MyFundiService.userRoles != null && MyFundiService.userRoles.length > 0) {
            this.userRoles = MyFundiService.userRoles;

            let clientLoginDetails = JSON.parse(localStorage.getItem("ClientLoginDetails"));
            return (this.userRoles.indexOf("Administrator") > -1 || (this.userRoles.indexOf('Client') > -1 && !clientLoginDetails ) || this.userRoles.indexOf('Fundi') > -1);
        }
        return false;
    }
}