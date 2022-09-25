import { Component, OnInit, EventEmitter, Injectable, AfterContentInit, Input } from '@angular/core';
import { IAddress, MyFundiService } from '../../../services/myFundiService';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';

@Component({
  selector: 'address',
  templateUrl: './address.component.html',
  styleUrls: ['./address.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class AddressComponent implements OnInit, AfterContentInit {
  private myFundiService: MyFundiService;
  @Output() addressEventEmitter = new EventEmitter<number>();
  @Input() address: IAddress|any;;
  public constructor(myFundiService: MyFundiService, private router: Router) {
    this.myFundiService = myFundiService;
  }

  //public address: IAddress | any;

  refreshAddresses() {
    let addSelect = document.querySelector('select#addressId');
    let opts = addSelect.querySelector('option');
    if (opts)
    {
      opts.remove();
    }
    let optionElem = document.createElement('option');
    optionElem.selected = true;
    optionElem.value = (0).toString();
    optionElem.text = "Select Address";
    document.querySelector('select#addressId').append(optionElem);


    let addressesObs: Observable<IAddress[]> = this.myFundiService.GetAllAddresses();
    addressesObs.map((adds: IAddress[]) => {
      adds.forEach((add: IAddress, index: number, adds) => {
        let optionElem: HTMLOptionElement = document.createElement('option');
        optionElem.value = add.addressId.toString();
        optionElem.text = add.addressLine1 + ", " + add.town + ", " + add.postCode;
        document.querySelector('select#addressId').append(optionElem);
      });

    }).subscribe();
  }
  ngAfterContentInit(): void {
    this.refreshAddresses();
  }
  public addAddress(): void {
    let actualResult: Observable<any> = this.myFundiService.PostOrCreateAddress(this.address);
    actualResult.map((p: any) => {
      alert('Address Added: ' + p.result);
      if (p.result) {
        this.refreshAddresses();
        //this.router.navigateByUrl('success');
      }
      else {
        this.router.navigateByUrl('failure');
      }
    }).subscribe();
    $('form#locationView').css('display', 'block').slideDown();
  }
  public updateAddress() {
    let actualResult: Observable<any> = this.myFundiService.UpdateAddress(this.address);
    actualResult.map((p: any) => {
      alert('Address Updated: ' + p.result);
      if (p.result) {
        this.refreshAddresses();
        //this.router.navigateByUrl('success');
      }
      else {
        this.router.navigateByUrl('failure');
      }
    }).subscribe();
    $('form#locationView').css('display', 'block').slideDown();
  }
  public selectAddress(): void {
    let actualResult: Observable<any> = this.myFundiService.GetAddressById(this.address.addressId);
    actualResult.map((p: any) => {
      this.address = p;
      this.addressEventEmitter.emit(this.address.addressId);
    }).subscribe();
    $('form#locationView').css('display', 'block').slideDown();
  }
  public deleteAddress() {
    let actualResult: Observable<any> = this.myFundiService.DeleteAddress(this.address);
    actualResult.map((p: any) => {
      alert('Address Deleted: ' + p.result);
      if (p.result) {
        this.refreshAddresses();
        //this.router.navigateByUrl('success');
      }
      else {
        this.router.navigateByUrl('failure');
      }
    }).subscribe();
    $('form#locationView').css('display', 'block').slideDown();
  }
  public ngOnInit(): void {
    this.address = {}
  }
}
