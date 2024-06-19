import { Component, Injectable, } from '@angular/core';
import { MyFundiService, IEmailMessage } from '../../services/myFundiService';
import { Router } from '@angular/router';
declare const google: any;

@Component({
  selector: 'failure',
  templateUrl: './failure.component.html',
  styleUrls: ['./failure.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class FailureComponent {
  public constructor() { }
}
