import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, Inject } from '@angular/core';
import { MyFundiService, IFundiLocationMonitor } from '../../services/myFundiService';
import 'rxjs/Rx';
import * as $ from "jquery";
import { saveAs } from 'file-saver';
import { Observable } from 'rxjs/Observable';
import * as google from '../../assets/google/googleMaps.js';
declare const google: any;

@Component({
    selector: 'vehicle-monitor',
    templateUrl: './vehiclemonitor.component.html',
    styleUrls: ['./vehiclemonitor.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class VehicleMonitorComponent implements OnInit, AfterViewInit {
    public fundiLocations: IFundiLocationMonitor[] = [];
    public currentFundi: IFundiLocationMonitor;
    private myFundiService: MyFundiService;
    public markers: any = [];
    public myMap: google.maps.Map;

    public constructor(myFundiService: MyFundiService) {

        this.myFundiService = myFundiService;

        let defaultVehMonitor: IFundiLocationMonitor = {
            lattitude: 0,
            longitude: 0,
            fundiUserDetails: {},
            phoneNumber: "N/A"
        };
        this.currentFundi = defaultVehMonitor;

    }

    public ngAfterViewInit(): void {

        this.getVehiclesHttp();
    }

    public getAndroidMobileLocationApp() {

        let actualResult: Observable<Blob> = this.myFundiService.GetFundiMobileLocationApp('android');
        actualResult.map((blob: Blob) => {
            saveAs(blob, 'XamarinForms.locationservice.apk');
        }).subscribe()
    }
    public getIosMobileLocationApp() {

        let actualResult: Observable<Blob> = this.myFundiService.GetFundiMobileLocationApp('ios');
        actualResult.map((blob: Blob) => {
            saveAs(blob, 'XamarinForms.locationservice.ipa');
        }).subscribe()
    }
    public getVehiclesHttp(): void {
        //$('div#vehicleView').css('display', 'block').slideDown();
        let actualResult: Observable<IFundiLocationMonitor[]> = this.myFundiService.GetFundiRealTimeLocations();
        actualResult.map((p: IFundiLocationMonitor[]) => {
            if (p && p.length > 0) {
                this.fundiLocations = p;
                let selector: HTMLSelectElement = document.querySelector('select#vhmonitor');

                if (this.fundiLocations.length > 0 && selector.children.length > 0) {
                    selector.querySelector('option').remove();
                }

                let optionElem: HTMLOptionElement = document.createElement('option');
                optionElem.selected = true;
                optionElem.value = (0).toString();
                optionElem.text = "Select Vehicle";
                selector.append(optionElem);

                this.fundiLocations.forEach((vhm: IFundiLocationMonitor, index: number) => {
                    let optionElem1: HTMLOptionElement = document.createElement('option');
                    optionElem1.value = vhm.fundiUserDetails.username;
                    optionElem1.text = vhm.fundiUserDetails.username;
                    selector.append(optionElem1);
                });

                this.currentFundi = this.fundiLocations[0];
            }
            else {
                this.fundiLocations = [];
                let defaultVehMonitor: IFundiLocationMonitor = {
                    lattitude: 0,
                    longitude: 0,
                    phoneNumber: "N/A",
                    fundiUserDetails: {}
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
            position: new google.maps.LatLng(parseFloat(`${vehMonitor.lattitude}`), parseFloat(`${vehMonitor.longitude}`)),
            title: vehMonitor.fundiUserDetails.username + ", " + vehMonitor.phoneNumber,
            map: this.myMap
        });

        // Attaching a click event to the current marker
        google.maps.event.addListener(marker, 'click', (function (marker, map, vehMonitor) {
            let infowindow = new google.maps.InfoWindow({
                content: "<p>Marker Location:" + marker.getPosition().lat().toString() + "," + marker.getPosition().lng().toString() + "</p><p>" + vehMonitor.fundiUserDetails.username + "</p><p>" + vehMonitor.phoneNumber + "</p>"
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

        let currentUsername: string = this.currentFundi.fundiUserDetails.username;
        let selectedVe = this.fundiLocations.find(v => v.fundiUserDetails.username == currentUsername);

        this.markers.forEach((mrk: google.maps.Marker, index: number) => {
            mrk.setMap(null);
        });
        this.markers = [];
        this.initMap(selectedVe);
    }
    showAllFundis() {
        this.markers = [];
        this.fundiPlotOnMap();
    }
    removeFundi() {
        let currentUsername: string = this.currentFundi.fundiUserDetails.username;
        let index: number = -1;
        let selectedVeh = this.fundiLocations.find((v, n) => {
            index = n;
            return v.fundiUserDetails.username == currentUsername
        });
        this.markers = [];
        this.fundiLocations.splice(index);
        let result: Observable<any> = this.myFundiService.RemoveFundiFromMonitor(selectedVeh);
        result.map((res: any) => {
            alert(res.message);
            this.showAllFundis();
        }).subscribe();

    }

}
