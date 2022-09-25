import { HttpClient, HttpHeaders } from '@angular/common/http';
import 'rxjs/add/operator/map';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Binary } from '@angular/compiler';
import { APP_BASE_HREF } from '@angular/common';
import { IAddress, ICoordinate, ILocation, MyFundiService } from './myFundiService';
import * as google from '../assets/google/googleMaps.js';
import * as $ from 'jquery';
declare const google: any;

@Injectable()
export class AddressLocationGeoCodeService {

  map: any;
  geocoder: any;
  poly: any[] = [];
  line: any;
  address: IAddress;
  location: ILocation;
  addressString: string;
  successGeocode: boolean = false;
  operation: string;
  googleGeocodeBaseUrl: string = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyCNPbLu2PRqU9dWbtw6WE5qijg9o7B3FDQ&address=";

  constructor(private httpClient: HttpClient, private myFundiService: MyFundiService) {
  }
  ngOnInit() {

  }
  // Draw a circle on map around center (radius in miles)
  // Modified by Jeremy Schneider based on https://maps.huge.info/dragcircle2.htm
  drawCircle(map, center, radius, numPoints) {
    var poly = [];
    var lat = parseFloat(center.lat);
    var lng = parseFloat(center.lng);
    var d2r = Math.PI / 180; // degrees to radians
    var r2d = 180 / Math.PI; // radians to degrees
    var Clat = (radius / 3963) * r2d; // using 3963 as earth's radius
    var Clng = Clat / Math.cos(lat * d2r);
    //Add each point in the circle
    for (var i = 0; i < numPoints; i++) {
      var theta = Math.PI * (i / (numPoints / 2));
      let Cx = lng + (Clng * Math.cos(theta));
      let Cy = lat + (Clat * Math.sin(theta));
      poly.push(new google.maps.LatLng('' + Cy, '' + Cx));
    }
    //Remove the old line if it exists
    if (this.line) {
      map.removeOverlay(this.line);
    }
    //Add the first point to complete the circle
    poly.push(poly[0]);
    //Create a line with the oints from poly, red, 3 pixels wide, 80% opaque
    this.line = new google.maps.Polyline(poly, '#FF0000', 3, 0.5);
    map.addOverlay(this.line);
  }

  showAddress(address: IAddress, operation: string) {
    this.addressString = address.country + "," + address.town + "," + address.addressLine1 + "," + address.addressLine2 + "," + address.postCode;
    this.address = address;
    this.operation = operation;
    this.geocode(this.googleGeocodeBaseUrl + this.addressString);
  }
  geocode(requestUrl) {

    let actualAdLocService = this;

    $.ajax({
      url: requestUrl,
      method: "GET",
      crossDomain: true,
      success: function (data) {

        if (data.status != "OK") {

          alert("Failed to Geocode location! Please, check location Address is correct.");
        }
        else {
          let results: any[] = data.results;

          var myOptions = {
            zoom: 15,
            center: results[0].geometry.location,
            mapTypeControl: true,
            mapTypeControlOptions: { style: google.maps.MapTypeControlStyle.DROPDOWN_MENU },
            navigationControl: true,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          };

          let actMap = new google.maps.Map(document.getElementById("locmap"), myOptions);

          var infowindow = new google.maps.InfoWindow(
            {
              content: '<b>' + results[0].formatted_address + '</b>',
              size: new google.maps.Size(150, 50)
            });
          //var address = "London, St. Johns Terrace W10 4RB";
          var marker = new google.maps.Marker({
            position: results[0].geometry.location,
            map: actMap,
            title: results[0].formatted_address
          });
          //drawCircle(map, results[0].geometry.location, 2.5, 40);

          google.maps.event.addListener(marker, 'click', function () {
            infowindow.open(actMap, marker);
          });

          let curLoc: ILocation = {
            locationId: actualAdLocService.location.locationId,
            locationName: results[0].formatted_address,
            latitude: parseFloat(results[0].geometry.location.lat),
            longitude: parseFloat(results[0].geometry.location.lng),
            country: actualAdLocService.location.country,
            addressId: actualAdLocService.address.addressId,
            address: null,
            isGeocoded: true
          }
          actualAdLocService.setCreateUpdateLocation(actualAdLocService.operation, curLoc);
        }
      }
    });
  }

  setCreateUpdateLocation(operation: string, loc: ILocation) {

    if (operation.toLowerCase() === "create") {
      let actualResult: Observable<any> = this.myFundiService.PostOrCreateLocation(loc);
      actualResult.map((p: any) => {
        alert('Location Added: ' + p.result);
        this.successGeocode = true;
        document.getElementById('locmap').scrollIntoView({ behavior: "smooth", block: "end", inline: "nearest" });
      }).subscribe();
    }
    else if (operation.toLowerCase() === "update") {
      let actualResult: Observable<any> = this.myFundiService.UpdateLocation(loc);
      actualResult.map((p: any) => {
        alert('Location Updated: ' + p.result);
        this.successGeocode = true;
        document.getElementById('locmap').scrollIntoView({ behavior: "smooth", block: "end", inline: "nearest" });
      }).subscribe();
    }
  }

  geocodeAddress(address: IAddress, operation: string) {
    this.showAddress(address, operation);
  }

  arePointsNear(checkPoint: ICoordinate, centerPoint: ICoordinate, km: number): boolean {
    var ky = 40000 / 360;
    var kx = Math.cos(Math.PI * centerPoint.latitude / 180.0) * ky;
    var dx = Math.abs(centerPoint.longitude - checkPoint.longitude) * kx;
    var dy = Math.abs(centerPoint.latitude - checkPoint.latitude) * ky;
    return Math.sqrt(dx * dx + dy * dy) <= km;
  }

  roundPositiveNumberTo2DecPlaces(num: number):number {
    var m = Number((Math.abs(num) * 100).toPrecision(15));
    return Math.round(m) / 100;// * Math.sign(num);
  }
}
