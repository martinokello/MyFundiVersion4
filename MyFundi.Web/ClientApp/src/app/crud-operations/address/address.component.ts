import { Component, OnInit, EventEmitter, Injectable, Input, AfterViewInit } from '@angular/core';
import { IAddress, MyFundiService } from '../../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
declare var jQuery: any;
import { AfterContentInit } from '@angular/core';

@Component({
    selector: 'address',
    templateUrl: './address.component.html',
    styleUrls: ['./address.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class AddressComponent implements OnInit, AfterViewInit, AfterContentInit {
    private myFundiService: MyFundiService;
    public hasPopulatedPage: boolean = false;
    public address: IAddress | any;
    public addresses: IAddress[];
    public addressId; number;
    setTo: NodeJS.Timeout;
    count: number = 0;
    observer: MutationObserver;

    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }

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

            this.addresses = adds;
            adds.forEach((add: IAddress, index: number, adds) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = add.addressId.toString();
                optionElem.text = add.addressLine1 + ", " + add.town + ", " + add.postCode + ", " + add.country;
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

        let actualResult: Observable<any> = this.myFundiService.GetAddressById(jQuery('div#addresses-wrapper select#addressId').val());
        actualResult.map((p: any) => {
            debugger;
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
        this.address = { addressId: 0 };
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
        debugger;
        let hasFoundSelectsOnPage = false;

        if (curthis.addresses && curthis.addresses.length > 1 && !curthis.hasPopulatedPage) {
            let selects = jQuery('div#addresses-wrapper select');

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
            debugger;
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
