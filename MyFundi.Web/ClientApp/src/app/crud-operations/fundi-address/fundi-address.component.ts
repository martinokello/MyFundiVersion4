import { Component, OnInit, EventEmitter, Injectable, Input, AfterViewInit } from '@angular/core';
import { IAddress, MyFundiService } from '../../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
declare var jQuery: any;
import { AfterContentInit } from '@angular/core';
import { AfterViewChecked } from '@angular/core';

@Component({
    selector: 'fundi-address',
    templateUrl: './fundi-address.component.html',
    styleUrls: ['./fundi-address.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class FundiAddressComponent implements OnInit, AfterViewInit, AfterContentInit {
    private myFundiService: MyFundiService;
    public hasPopulatedPage: boolean = false;
    public fundiAddress: IAddress | any;
    public addresses: IAddress[];
    @Output() fundiAddressChanged: EventEmitter<number> = new EventEmitter<number>();
    @Input("addressId") addressId: number;
    setTo: NodeJS.Timeout;
    count: number = 0;
    observer: MutationObserver;

    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }

    onFundiAddressChanged() {
        this.fundiAddress.addressId = this.addressId;
        this.selectAddress();
        this.fundiAddressChanged.emit(this.fundiAddress.addressId);
    }
    refreshAddresses() {
        let addSelect = document.querySelector('select#fundiAddressId');
        let opts = addSelect.querySelector('option');
        if (opts) {
            opts.remove();
        }
        let optionElem = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select Address";
        document.querySelector('select#fundiAddressId').append(optionElem);


        let addressesObs: Observable<IAddress[]> = this.myFundiService.GetAllAddresses();
        addressesObs.map((adds: IAddress[]) => {

            this.addresses = adds;
            adds.forEach((add: IAddress, index: number, adds) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = add.addressId.toString();
                optionElem.text = add.addressLine1 + ", " + add.town + ", " + add.postCode + ", " + add.country;
                document.querySelector('select#fundiAddressId').append(optionElem);
            });
        }).subscribe();
    }
    public addAddress(): void {

        let form: HTMLFormElement = document.querySelector('form#fundiAddForm1') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.PostOrCreateAddress(this.fundiAddress);
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
        let form: HTMLFormElement = document.querySelector('form#fundiAddForm1') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.UpdateAddress(this.fundiAddress);
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

        let actualResult: Observable<any> = this.myFundiService.GetAddressById(this.addressId)
        actualResult.map((p: any) => {
            this.fundiAddress = p;
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public deleteAddress() {
        let form: HTMLFormElement = document.querySelector('form#fundiAddForm1') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.DeleteAddress(this.fundiAddress);
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
        this.fundiAddress = {
            addressId: 0,
            addressLine1: "",
            addressLine2: "",
            town: "",
            postCode: "",
            country: ""
        };
        this.addresses = [];
        this.refreshAddresses();
        let curthis = this;
    }
    ngAfterContentInit() {

    }
    ngAfterViewInit() {
        let curthis = this;

        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
    runAutoCompleteOnSelects(curthis: any) {
        let hasFoundSelectsOnPage = false;

        if (curthis.addresses && curthis.addresses.length > 1 && !curthis.hasPopulatedPage) {
            let selects = jQuery('div#fundi-addresses-wrapper select');

            if (selects && selects.length > 0) {
                hasFoundSelectsOnPage = true;
            }

            if (hasFoundSelectsOnPage) {

                jQuery(selects.each((ind, elem) => {
                    jQuery(elem).parent('ul').css('background', 'white');
                    jQuery(elem).parent('ul').css('z-index', '100');
                    let id = 'autoComplete' + jQuery(elem).attr('id');
                    jQuery(elem).parent('div').prepend("<input type='text' placeholder='Search dropdown' id=" + `${id}` + " /><br/>");

                }));
                hasFoundSelectsOnPage = false;
            }
            //Check For Dom Change and Add auto complete to select elements
            jQuery('select').each((ind, sel) => {
                let options = jQuery(sel).children('option');

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

            curthis.hasPopulatedPage = true;
            clearTimeout(curthis.setTo);
        }
    }

}
