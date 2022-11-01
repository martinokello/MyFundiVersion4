import { Component, OnInit, AfterViewChecked, ViewChild, ElementRef, Input, Output, Injectable, Inject, EventEmitter } from '@angular/core';
import { IAddress, ILocation, MyFundiService } from '../../services/myFundiService';
import { Element } from '@angular/compiler';
declare var jQuery: any;
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';
import { AfterViewInit } from '@angular/core';

@Component({
  selector: 'addLocation',
  templateUrl: './addLocation.component.html',
  styleUrls: ['./addLocation.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class AddLocationComponent implements OnInit, AfterViewInit {
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
    ngAfterViewInit() {
        jQuery('select').each((ind, sel) => {
            let options = jQuery(sel).children('option');
            debugger;
            let vals = [];
            jQuery(options).each((id, el) => {
                let optionText = jQuery(el).html();
                vals.push(optionText);
            });
            //options is source of auto complete:
            let jQueryinpId = jQuery('input#autoComplete' + jQuery(sel).attr('id'));
            jQueryinpId.autocomplete({ source: vals });
            jQuery(document).on('click', '.ui-menu .ui-menu-item-wrapper', function (event) {
                jQuery('select#' + jQuery(sel).attr('id')).find("option").filter(function () {
                    return jQuery(event.target).text() == jQuery(this).html();
                }).attr("selected", true);
            });
        });
    }
}
