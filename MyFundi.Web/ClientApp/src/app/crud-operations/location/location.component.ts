import { Component, OnInit, Injectable, Inject, AfterContentInit, EventEmitter, Input, Output } from '@angular/core';
import { IAddress, ILocation, MyFundiService } from '../../../services/myFundiService';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { AddressLocationGeoCodeService } from '../../../services/AddressLocationGeoCodeService';

@Component({
  selector: 'location',
  templateUrl: './location.component.html',
  styleUrls: ['./location.component.css'],
    providers: [MyFundiService, AddressLocationGeoCodeService]
})
@Injectable()
export class LocationComponent implements OnInit, AfterContentInit {

  public constructor(private myFundiService: MyFundiService, private router: Router, private geoCoder: AddressLocationGeoCodeService) {

    }

    @Output() locationEventEmitter = new EventEmitter<number>();
    @Input() location: ILocation | any;

    public addLocation(): void {
        let form: HTMLFormElement = document.querySelector('form#locationView') as HTMLFormElement;
        if (!form.checkValidity()) return;
        this.checkLocationGeoCodedAndUpdate("create");
  }
    public updateLocation() {
        let form: HTMLFormElement = document.querySelector('form#locationView') as HTMLFormElement;
        if (!form.checkValidity()) return;
        this.checkLocationGeoCodedAndUpdate("update");
  }

  public selectLocation(): void {
    let actualResult: Observable<any> = this.myFundiService.GetLocationById(this.location.locationId);
    actualResult.map((p: any) => {
        this.location = p;
        this.locationEventEmitter.emit(this.location.locationId);
    }).subscribe();
    $('form#locationView').css('display', 'block').slideDown();
  }
    public deleteLocation() {
        let form: HTMLFormElement = document.querySelector('form#locationView') as HTMLFormElement;
        if (!form.checkValidity()) return;
    let actualResult: Observable<any> = this.myFundiService.DeleteLocation(this.location);
    actualResult.map((p: any) => {
      alert('Location Deleted: ' + p.result); if (p.result) {
        this.router.navigateByUrl('success');
      }
      else {
        this.router.navigateByUrl('failure');
      }
    }).subscribe();
    $('form#locationView').css('display', 'block').slideDown();
  }
  public ngOnInit(): void {
    this.location = {}
    this.location.address = {};
  }
  ngAfterContentInit(): void {
    const addsObs: Observable<IAddress[]> = this.myFundiService.GetAllAddresses();
    const locatObs: Observable<ILocation[]> = this.myFundiService.GetAllLocations();

    let optionElem: HTMLOptionElement = document.createElement('option');
    optionElem.selected = true;
    optionElem.value = (0).toString();
    optionElem.text = "Select Location";
    document.querySelector('select#locationId').append(optionElem);

    optionElem = document.createElement('option');
    optionElem.value = (0).toString();
    optionElem.text = "Select Address";
    document.querySelector('select#locaddressId').append(optionElem);

    addsObs.map((cmds: IAddress[]) => {
      cmds.forEach((cmd: IAddress, index: number, cmds) => {
        let optionElem: HTMLOptionElement = document.createElement('option');
        optionElem.value = cmd.addressId.toString();
        optionElem.text = cmd.addressLine1 + ", " + cmd.town + ", " + cmd.postCode;
        document.querySelector('select#locaddressId').append(optionElem);
      });
    }).subscribe();

    locatObs.map((cmdCats: ILocation[]) => {
      cmdCats.forEach((comCat: ILocation, index: number, cmdCats) => {
        let optionElem: HTMLOptionElement = document.createElement('option');
        optionElem.value = comCat.locationId.toString();
        optionElem.text = comCat.locationName;
        document.querySelector('select#locationId').append(optionElem);
      });
    }).subscribe();
  }

  checkLocationGeoCodedAndUpdate(operation: string) {

      if (operation === 'update' || operation === 'create') {
      let addObs: Observable<IAddress> = this.myFundiService.GetAddressById(this.location.addressId);
      addObs.map((add: IAddress) => {
        this.geoCoder.location = this.location;
        this.geoCoder.geocodeAddress(add, operation);
        document.getElementById("locmap").style.display = "block";

        this.geoCoder.setCreateUpdateLocation(operation, this.location);
      }).subscribe();
    }
    else {
      document.getElementById("locmap").style.display = "none";
    }
  }
}
