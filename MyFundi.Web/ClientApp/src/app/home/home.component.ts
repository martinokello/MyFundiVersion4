import { Component, OnInit, ViewChild, ElementRef, Input, Output, Injectable, Inject, EventEmitter } from '@angular/core';
import { IAddress, ILocation, MyFundiService } from '../../services/myFundiService';
import { Element } from '@angular/compiler';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
})
export class HomeComponent {
  public constructor(private myFundiService: MyFundiService ) {
  }
}
