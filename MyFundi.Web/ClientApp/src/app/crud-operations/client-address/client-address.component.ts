import { Component, OnInit, EventEmitter, Injectable, Input, AfterViewInit, AfterViewChecked } from '@angular/core';
import { IAddress, MyFundiService } from '../../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
declare var jQuery: any;
import { AfterContentInit } from '@angular/core';

@Component({
    selector: 'client-address',
    templateUrl: './client-address.component.html',
    styleUrls: ['./client-address.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class ClientAddressComponent implements OnInit, AfterViewInit, AfterContentInit {
    private myFundiService: MyFundiService;
    public hasPopulatedPage: boolean = false;
    public clientAddress: IAddress | any;
    public addresses: IAddress[];
    @Input("addressId") addressId: number;
    @Output() clientAddressChanged: EventEmitter<number> = new EventEmitter<number>();
    setTo: NodeJS.Timeout;
    count: number = 0;
    observer: MutationObserver;

    public constructor(myFundiService: MyFundiService, private router: Router) {
        this.myFundiService = myFundiService;
    }
    ngAfterViewInit() {
        let curthis = this;

        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
    onClientAddressChanged() {
        this.clientAddress.addressId = this.addressId;
        this.selectAddress();
        this.clientAddressChanged.emit(this.clientAddress.addressId);
    }

    refreshAddresses() {
        let addSelect = document.querySelector('select#clientAddressId');
        let opts = addSelect.querySelector('option');
        if (opts) {
            opts.remove();
        }
        let optionElem = document.createElement('option');
        optionElem.selected = true;
        optionElem.value = (0).toString();
        optionElem.text = "Select Address";
        document.querySelector('select#clientAddressId').append(optionElem);


        let addressesObs: Observable<IAddress[]> = this.myFundiService.GetAllAddresses();
        addressesObs.map((adds: IAddress[]) => {

            this.addresses = adds;
            adds.forEach((add: IAddress, index: number, adds) => {
                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.value = add.addressId.toString();
                optionElem.text = add.addressLine1 + ", " + add.town + ", " + add.postCode + ", " + add.country;
                document.querySelector('select#clientAddressId').append(optionElem);
            });
        }).subscribe();
    }
    public addAddress(): void {

        let form: HTMLFormElement = document.querySelector('form#clientAddForm1') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.PostOrCreateAddress(this.clientAddress);
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
        let form: HTMLFormElement = document.querySelector('form#clientAddForm1') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.UpdateAddress(this.clientAddress);
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

        let actualResult: Observable<any> = this.myFundiService.GetAddressById(this.addressId);
        actualResult.map((p: any) => {
            debugger;
            this.clientAddress = p;
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public deleteAddress() {
        let form: HTMLFormElement = document.querySelector('form#clientAddForm1') as HTMLFormElement;
        if (!form.checkValidity()) return;
        let actualResult: Observable<any> = this.myFundiService.DeleteAddress(this.clientAddress);
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
        this.clientAddress = {
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

    runAutoCompleteOnSelects(curthis: any) {
        let hasFoundSelectsOnPage = false;

        if (curthis.addresses && curthis.addresses.length > 1 && !curthis.hasPopulatedPage) {
            let selects = jQuery('div#client-addresses-wrapper select');

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
