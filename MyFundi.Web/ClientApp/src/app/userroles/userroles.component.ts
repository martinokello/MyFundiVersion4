import { Component, OnInit, ViewChild, ElementRef, Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { MyFundiService, IUserRole } from '../../services/myFundiService';
import 'rxjs/add/operator/map';
import * as $ from 'jquery';

@Component({
    selector: 'user-roles',
    templateUrl: './userroles.component.html',
    styleUrls: ['./userroles.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class UserRolesComponent implements OnInit{

  @ViewChild('rolesView', { static: false }) div: HTMLElement | any;
  private myFundiService: MyFundiService  | any;
    public userRoles: IUserRole[] | any;
    public email: string | any;

    ngOnInit(): void {
        this.getAllRoles();
    }
  public constructor(myFundiService: MyFundiService ) {
    this.myFundiService = myFundiService;
    }

    getSelectedRole(): string {

        let select = $("select#roleName");
        return select.val()+"";
    }
    public addUserToRole(): void {
        let role = this.getSelectedRole();
      let results: Observable<any> = this.myFundiService.AddUserToRole(this.email, role);
        results.map((q: boolean) => {
            if (q) {
                alert('Added user: ' + this.email + ' to role: ' + role);
            }
            else {

                alert('Failed to add user: ' + this.email + ' to role: ' + role);
            }
        }).subscribe();
    }
    public removeUserFromRole(): void {
      let role = this.getSelectedRole();
      let results: Observable<any> = this.myFundiService.RemoveUserFromRole(this.email, role);
        results.map((q: boolean) => {
            if (q) {
                alert('Removed user: ' + this.email + ' from role: ' + role);
            }
            else {

                alert('Failed to remove user: ' + this.email + ' from role: ' + role);
            }
        }).subscribe();
    }

    public getAllRoles() {
      let results: Observable<object[]> = this.myFundiService.GetAllRoles();
      results.map((q: object[]) => {
            this.userRoles = q;

            let select = $("select#roleName");
            console.log(select);

            select.remove('option');
            select.append('<option value="" selected="true">Select A Role</option>');
            for (let i = 0; i < this.userRoles.length; i++) {
                select.append('<option value="' + this.userRoles[i].roleName + '">' + this.userRoles[i].roleName + '</option>');
            } 
        }).subscribe();
    }

}
