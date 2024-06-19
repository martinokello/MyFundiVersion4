import {    Component, OnInit, ViewChild, ElementRef, Injectable,Input} from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { MyFundiService, IUserRole } from '../../services/myFundiService';
import 'rxjs/add/operator/map';
import * as $ from 'jquery';

@Component({
    selector: 'new-user-roles',
    templateUrl: './newroles.component.html',
    styleUrls: ['./newroles.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class NewRolesComponent implements OnInit{

  @ViewChild('rolesView', { static: false }) div: HTMLElement | any;
  private myFundiService: MyFundiService  | any;
    public userRoles: IUserRole[] | any;
    public email: string | any;
    public newRoleName: string | any;

    ngOnInit(): void {
    }
  public constructor(myFundiService: MyFundiService ) {
    this.myFundiService = myFundiService;
    }

    public createUserRole(): void {
      let results: Observable<any> = this.myFundiService.CreateUserRole(this.newRoleName);
        results.map((q: boolean) => {
            if (q) {
              alert('Role: ' + this.newRoleName +' Created Successfully!');
                return true;
            }
            else {

              alert('Failed to Create: ' + this.newRoleName + ' Role.');
                return false;
            }
        }).subscribe();
        
    }
    public deleteUserRole(): void {
      let results: Observable<any> = this.myFundiService.DeleteUserRole(this.newRoleName);
        results.map((q: boolean) => {
            if (q) {
              alert('Role: ' + this.newRoleName + ' Deleted Successfully!');
                return true;
            }
            else {

              alert('Failed to Delete: ' + this.newRoleName + ' Role.');
                return false;
            }
        }).subscribe();

    }

}
