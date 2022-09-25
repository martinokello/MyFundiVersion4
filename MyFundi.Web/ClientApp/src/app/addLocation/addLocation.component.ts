import { Component, OnInit, ViewChild, ElementRef, Input, Output, Injectable, Inject, EventEmitter } from '@angular/core';
import { IAddress, ILocation, MyFundiService } from '../../services/myFundiService';
import { Element } from '@angular/compiler';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';

@Component({
  selector: 'addLocation',
  templateUrl: './addLocation.component.html',
  styleUrls: ['./addLocation.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class AddLocationComponent implements OnInit {
  private myFundiService: MyFundiService;
  private geoCoder: AddressLocationGeoCodeService;
  public constructor(myFundiService: MyFundiService, geoCoder: AddressLocationGeoCodeService) {
    this.myFundiService = myFundiService;
    this.geoCoder = geoCoder;
  }
  public location: ILocation | any;

  public addLocation(): void {
    this.checkLocationGeoCodedAndUpdate("create");
  }
  public updateLocation() {
    this.checkLocationGeoCodedAndUpdate("update");
  }

  checkLocationGeoCodedAndUpdate(operation: string) {

    if (!this.location.isGeocoded) {
      let addObs: Observable<IAddress> = this.myFundiService.GetAddressById(this.location.addressId);
      addObs.map((add: IAddress) => {
        this.geoCoder.geocodeAddress(add, operation);
        document.getElementById("locmap").style.display = "block";

      }).subscribe();
    }
    else {
      this.geoCoder.setCreateUpdateLocation(operation, this.location);
      document.getElementById("locmap").style.display = "block";
    }
  }

  public ngOnInit(): void {
    this.location = {}
    this.location.address = {};
  }
}
