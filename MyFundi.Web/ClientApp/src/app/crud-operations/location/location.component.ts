import { Component, OnInit, Injectable, Inject, AfterContentInit, EventEmitter, Input, Output, AfterViewInit } from '@angular/core';
import { IAddress, ILocation, MyFundiService } from '../../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { AddressLocationGeoCodeService } from '../../../services/AddressLocationGeoCodeService';
import { AfterViewChecked } from '@angular/core';
declare var jQuery: any;

@Component({
    selector: 'location',
    templateUrl: './location.component.html',
    styleUrls: ['./location.component.css'],
    providers: [MyFundiService, AddressLocationGeoCodeService]
})
@Injectable()
export class LocationComponent implements OnInit, AfterViewInit, AfterContentInit {
    setTo: NodeJS.Timeout;

    public constructor(private myFundiService: MyFundiService, private router: Router, private geoCoder: AddressLocationGeoCodeService) {

    }

    @Output() locationEventEmitter = new EventEmitter<number>();
    @Input() location: ILocation | any;
    locations: ILocation[];
    hasPopulatedPage: boolean = false;
    count: number = 0;
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
        let locationId: number = jQuery('div#locations-wrapper select#locationId').val();
        let actualResult: Observable<any> = this.myFundiService.GetLocationById(locationId);
        actualResult.map((p: any) => {
            this.location = p;
            this.locationEventEmitter.emit(this.location.locationId);
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
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
        jQuery('form#locationView').css('display', 'block').slideDown();
    }
    public ngOnInit(): void {
        this.location = { locationId: 0 }
        this.locations = [];
        this.location.address = {}; const addsObs: Observable<IAddress[]> = this.myFundiService.GetAllAddresses();
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

            locatObs.map((cmdCats: ILocation[]) => {
                this.locations = cmdCats;
                cmdCats.forEach((comCat: ILocation, index: number, cmdCats) => {
                    let optionElem: HTMLOptionElement = document.createElement('option');
                    optionElem.value = comCat.locationId.toString();
                    optionElem.text = comCat.locationName;
                    document.querySelector('select#locationId').append(optionElem);
                });
            }).subscribe();
        }).subscribe();

    }

    checkLocationGeoCodedAndUpdate(operation: string) {

        if (operation === 'update' || operation === 'create') {
            let addObs: Observable<IAddress> = this.myFundiService.GetAddressById(this.location.addressId);
            addObs.map((add: IAddress) => {
                this.geoCoder.location = this.location;
                this.geoCoder.geocodeAddress(add,this.location.locationName, operation);
                document.getElementById("locmap").style.display = "block";

                //this.geoCoder.setCreateUpdateLocation(operation, this.location);
            }).subscribe();
        }
        else {
            document.getElementById("locmap").style.display = "none";
        }
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

        if (curthis.locations && curthis.locations.length > 1 && !curthis.hasPopulatedPage) {
            let selects = jQuery('div#locations-wrapper select');

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
