import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { MyFundiService } from '../services/myFundiService';

@Injectable()
export class AdminAuthGuard implements CanActivate {
  private myFundiService: MyFundiService ;
  private userRoles: string[];
  // Inject Router so we can hand off the user to the Login Page 
  constructor(private router: Router, myFundiService: MyFundiService ) {
    this.myFundiService = myFundiService;
  }

  canActivate(): boolean {
    if (MyFundiService.userRoles != null && MyFundiService.userRoles.length > 0) {
      this.userRoles = MyFundiService.userRoles;

      return this.userRoles.indexOf("Administrator") > -1;
    }
    return false;
  }
}
