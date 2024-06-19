import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, Inject } from '@angular/core';
import { MyFundiService, IFundiLocationMonitor, IProfile } from '../../services/myFundiService';
import 'rxjs/Rx';
import { saveAs } from 'file-saver';
import { Observable } from 'rxjs/Observable';
import * as google from '../../assets/google/googleMaps.js';
import { AfterViewChecked } from '@angular/core';
declare const google: any;
declare var jQuery: any;

@Component({
    selector: 'vehicle-monitor',
    templateUrl: './vehiclemonitor.component.html',
    styleUrls: ['./vehiclemonitor.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class VehicleMonitorComponent implements OnInit, AfterViewInit, AfterViewChecked {
    public fundiLocations: IFundiLocationMonitor[] = [];
    public currentFundi: IFundiLocationMonitor;
    private myFundiService: MyFundiService;
    public markers: any = [];
    public myMap: google.maps.Map;
    setTo: NodeJS.Timeout;
    hasPopulatedPage: boolean = false;

    public constructor(myFundiService: MyFundiService) {

        this.myFundiService = myFundiService;

        let defaultVehMonitor: IFundiLocationMonitor = {
            latitude: 0,
            longitude: 0,
            fundiProfileId: 0,
            username: "",
            email: "",
            driverName: "",
            mobileNumber: "",
            firstName: "",
            lastName: "",
            updatePhoneNumber: false
        };
        this.currentFundi = defaultVehMonitor;

    }

    public ngAfterViewInit(): void {

        this.getVehiclesHttp();
    }

    public getAndroidMobileLocationApp() {

        let actualResult: Observable<Blob> = this.myFundiService.GetFundiMobileLocationApp('android');
        actualResult.map((blob: Blob) => {
            saveAs(blob, 'MartinLayooInc.MyFundi.locationservice.apk');
        }).subscribe()
    }
    public getIosMobileLocationApp() {

        let actualResult: Observable<Blob> = this.myFundiService.GetFundiMobileLocationApp('ios');
        actualResult.map((blob: Blob) => {
            saveAs(blob, 'MartinLayooInc.MyFundi.locationservice.ipa');
        }).subscribe()
    }
    public getVehiclesHttp(): void {
        //$('div#vehicleView').css('display', 'block').slideDown();
        let actualResult: Observable<IFundiLocationMonitor[]> = this.myFundiService.GetFundiRealTimeLocations();
        actualResult.map((p: IFundiLocationMonitor[]) => {
            if (p && p.length > 0) {
                this.fundiLocations = p;
                let selector: HTMLSelectElement = document.querySelector('select#vhmonitor');

                //greater than default node: Select Fundi 1st Option:
                if (selector.children.length > 0) {
                    for (let n = selector.children.length - 1; n >= 0; n--) {
                        selector.children[n].remove();
                    }
                }

                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.selected = true;
                optionElem.value = (0).toString();
                optionElem.text = "Select Fundi";
                selector.append(optionElem);

                this.fundiLocations.forEach((vhm: IFundiLocationMonitor, index: number) => {
                    let optionElem1: HTMLOptionElement = document.createElement('option');
                    optionElem1.value = vhm.username;
                    optionElem1.text = vhm.username;
                    selector.append(optionElem1);
                });

                this.currentFundi = this.fundiLocations[0];
            }
            else {
                this.fundiLocations = [];
                let defaultVehMonitor: IFundiLocationMonitor = {
                    latitude: 0,
                    longitude: 0,
                    fundiProfileId:0,
                    username: "",
                    email: "",
                    driverName: "",
                    mobileNumber: "",
                    firstName: "",
                    lastName: "",
                    updatePhoneNumber: false
                };
                this.currentFundi = defaultVehMonitor;
            }
            this.fundiPlotOnMap();

        }).subscribe();
    }

    public ngOnInit(): void {
        this.myMap = new google.maps.Map(document.getElementById('monitormap'), {
            center: new google.maps.LatLng(10.3, 12.5),
            zoom: 8,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        });

        //Timer to keep plotting on Map Fundi Locations:
        let curThis = this;
        setInterval(() => {
            curThis.showAllFundis();
            for (let n = 0; n < curThis.fundiLocations.length; n++) {
                let vehMonitor: IFundiLocationMonitor = curThis.fundiLocations[n];
                let profObs: Observable<IProfile> = this.myFundiService.GetFundiProfileByUsername(vehMonitor.username);
                //Insert FundiMonitor In Database:
                profObs.map((pr: IProfile) => {
                    if (pr) {
                        vehMonitor.fundiProfileId = pr.fundiProfileId;
                        let vehMonObs: Observable<any> = this.myFundiService.SaveFundiGeoLocation(vehMonitor);
                        vehMonObs.map((res: any) => {
                            if (res.result) {
                                console.log(`Saved fundi ${vehMonitor.firstName} ${vehMonitor.firstName}, geolocation: ${vehMonitor.latitude},${vehMonitor.longitude}`)
                            }
                            else {
                                console.log(`Failed Saving fundi ${vehMonitor.firstName} ${vehMonitor.firstName}, geolocation: ${vehMonitor.latitude},${vehMonitor.longitude}`)
                            }
                        }).subscribe;
                    }
                }).subscribe();
            }
        }, 5 * 60 * 1000);

        this.showAllFundis();
    }

    public fundiPlotOnMap() {
        if (this.markers != null && this.markers.length > 0) {
            this.clearMarkers();
        }
        for (let n = 0; n < this.fundiLocations.length; n++) {
            let vehMonitor: IFundiLocationMonitor = this.fundiLocations[n];
            this.initMap(vehMonitor);
        }
    }
    public initMap(vehMonitor: IFundiLocationMonitor): void {

        let marker = new google.maps.Marker({
            position: new google.maps.LatLng(parseFloat(`${vehMonitor.latitude}`), parseFloat(`${vehMonitor.longitude}`)),
            title: vehMonitor.username + ", " + vehMonitor.mobileNumber,
            map: this.myMap
        });

        // Attaching a click event to the current marker
        google.maps.event.addListener(marker, 'click', (function (marker, map, vehMonitor) {
            let infowindow = new google.maps.InfoWindow({
                content: "<p>Marker Location:" + marker.getPosition().lat().toString() + "," + marker.getPosition().lng().toString() + "</p><p>" + vehMonitor.username + "</p><p>" + vehMonitor.mobileNumber + "</p>"
            });
            infowindow.open(map, marker);
        })(marker, this.myMap, vehMonitor));

        //marker.setMap(this.myMap);
        this.markers.push(marker);
    }
    clearMarkers() {
        this.markers = [];
    }

    showFundi(): void {

        let currentUsername: string = this.currentFundi.username;
        let selectedVe = this.fundiLocations.find(v => v.username.toLowerCase() == currentUsername.toLowerCase());
        //debugger;
        this.markers.forEach((mrk: google.maps.Marker, index: number) => {
            mrk.setMap(null);
        });
        this.markers = [];
        this.initMap(selectedVe);
    }
    showAllFundis() {
        this.getVehiclesHttp();
    }
    removeFundi() {
        let currentUsername: string = this.currentFundi.username;
        let index: number = -1;
        let selectedVeh = this.fundiLocations.find((v: IFundiLocationMonitor, n:number) => {
            index = n;
            return v.username.toLowerCase() == currentUsername.toLowerCase()
        });
        this.markers = [];
        this.fundiLocations.splice(index);
        let result: Observable<any> = this.myFundiService.RemoveFundiFromMonitor(selectedVeh);
        result.map((res: any) => {
            alert(res.message);
            if (res.success) {
                this.ngOnInit();
            }
            else {
                alert(res.message);
            }
        }).subscribe();

    }
    ngAfterViewChecked() {
        let curthis = this;

        this.setTo = setTimeout(this.runAutoCompleteOnSelects, 1000, curthis);

    }
    runAutoCompleteOnSelects(curthis: any) {
        let hasFoundSelectsOnPage = false;

        if (!curthis.hasPopulatedPage) {

            let selects = jQuery('div#vehiclemonitor-wrapper select');

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
            jQuery('div#vehiclemonitor-wrapper select').each((ind, sel) => {
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
