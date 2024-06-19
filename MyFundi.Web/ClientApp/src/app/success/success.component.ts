import { Component, Injectable, } from '@angular/core';
import { MyFundiService } from '../../services/myFundiService';
declare const google: any;

@Component({
  selector: 'success',
  templateUrl: './success.component.html',
  styleUrls: ['./success.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class SuccessComponent {
  public constructor() { }
}
