import { Component, OnInit, EventEmitter, Injectable, AfterContentInit, Input, AfterViewInit } from '@angular/core';
import { IAddress, MyFundiService } from '../../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
declare var jQuery: any;

@Component({
    selector: 'address',
    templateUrl: './address.component.html',
    styleUrls: ['./address.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class AddressComponent implements OnInit, AfterViewInit {
    private myFundiService: MyFundiService;
    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }

    public address: IAddress | any;

    refreshAddresses() {
        let addSelect = document.querySelector('select#addressId');
        let opts = addSelect.querySelector('option');
        if (opts) {
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
    public addAddress(): void {

        let form: HTMLFormElement = document.querySelector('form#f1') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.PostOrCreateAddress(this.address);
        actualResult.map((p: any) => {
            alert('Address Added: ' + p.result);
            if (p.result) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public updateAddress() {
        let form: HTMLFormElement = document.querySelector('form#f1') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.UpdateAddress(this.address);
        actualResult.map((p: any) => {
            alert('Address Updated: ' + p.result);
            if (p.result) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public selectAddress(): void {
        let actualResult: Observable<any> = this.myFundiService.GetAddressById(this.address.addressId);
        actualResult.map((p: any) => {
            this.address = p;
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public deleteAddress() {
        let form: HTMLFormElement = document.querySelector('form#f1') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.DeleteAddress(this.address);
        actualResult.map((p: any) => {
            alert('Address Deleted: ' + p.result);
            if (p.result) {
                this.router.navigateByUrl('success');
            }
            else {
                this.router.navigateByUrl('failure');
            }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public ngOnInit(): void {
        this.address = {}
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
