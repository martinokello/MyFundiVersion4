import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, AfterViewChecked, Inject, Input, Output, EventEmitter } from '@angular/core';
import { MyFundiService, IEmailMessage } from '../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import * as google from '../../assets/google/googleMaps.js';
declare var jQuery: any;
declare let sceditor: any;
declare const google: any;

@Component({
    selector: 'contactus',
    templateUrl: './contactus.component.html',
    styleUrls: ['./contactus.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class ContactUsComponent implements OnInit, AfterViewInit {
  private myFundiService: MyFundiService  | any;
    email: IEmailMessage | any;

  @ViewChild('emailFormView', { static: false }) emailFormView: HTMLElement | any; 
  public constructor(myFundiService: MyFundiService ) {

    this.myFundiService = myFundiService;
    }
    ngAfterViewInit(): void {

        jQuery('textarea#MessageText').focus();
    }
    sendEmail($event): void {

        let formView = this.emailFormView;
        let form:HTMLFormElement = formView.nativeElement.querySelector("form");
        if (form.checkValidity()) {

            let formData = new FormData();

            let textarea = jQuery('textarea#MessageText')[0];
            let scEditInstance = sceditor.instance(textarea);
            let emailBody = scEditInstance.getBody().innerHTML;

            formData.append('emailBody', emailBody);
            formData.append('emailTo', this.email.emailTo);
            formData.append('emailFrom', this.email.emailFrom);
            formData.append('emailSubject', this.email.emailSubject);
            formData.append('fileUpload', this.email.attachment);
            let result: Observable<boolean> = this.myFundiService.SendEmail(formData);
            result.subscribe((value: any) => {
                alert(value.message);
            });
        }
        $event.preventDefault();
    }
    getFiles(event) {
        this.email.attachment = event.target.files.item(0);
    } 
    ngOnInit() {
        this.email = {
            emailBody: "",
            attachment: null,
            emailSubject: "",
            emailTo: "",
            emailFrom: ""
        }
        var map: any;
        var geocoder: any;
        var poly: any[] = [];
        var line: any;
        // Draw a circle on map around center (radius in miles)
        // Modified by Jeremy Schneider based on https://maps.huge.info/dragcircle2.htm
        function drawCircle(map, center, radius, numPoints) {
            poly = [];
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
            if (line) {
                map.removeOverlay(line);
            }
            //Add the first point to complete the circle
            poly.push(poly[0]);
            //Create a line with teh points from poly, red, 3 pixels wide, 80% opaque
            line = new google.maps.Polyline(poly, '#FF0000', 3, 0.5);
            map.addOverlay(line);
        }

        function initialize() {
            geocoder = new google.maps.Geocoder();

            showAddress("London, St. Johns Terrace W10 4RB");
        }
        function showAddress(address) {
            geocoder.geocode({ 'address': address }, function (results, status) {
                if (status != google.maps.GeocoderStatus.OK) {
                    alert(address + " not found");
                }
                else {
                    var myOptions = {
                        zoom: 15,
                        center: results[0].geometry.location,
                        mapTypeControl: true,
                        mapTypeControlOptions: { style: google.maps.MapTypeControlStyle.DROPDOWN_MENU },
                        navigationControl: true,
                        mapTypeId: google.maps.MapTypeId.ROADMAP
                    };

                    map = new google.maps.Map(document.getElementById("map"), myOptions);

                    map.setCenter(results[0].geometry.location);

                    var infowindow = new google.maps.InfoWindow(
                        {
                            content: '<b>' + address + '</b>',
                            size: new google.maps.Size(150, 50)
                        });
                    var address = "London, St. Johns Terrace W10 4RB";
                    var marker = new google.maps.Marker({
                        position: results[0].geometry.location,
                        map: map,
                        title: address
                    });
                    //drawCircle(map, results[0].geometry.location, 2.5, 40);

                    google.maps.event.addListener(marker, 'click', function () {
                        infowindow.open(map, marker);
                    });
                }
            }
            );
        }
        function elementSupportsAttribute(element, attribute) {
            var test = document.createElement(element);
            if (attribute in test) {
                return true;
            } else {
                return false;
            }
        }
        jQuery(document).ready(function () {

            jQuery('div#ourContactDetails').html("<div align='center' style='min-width:240px;margin-top:10px;'><h2>Contact Details</h2></div><div align='center'><b>MartinLayooInc Software House,<br/> 2 St Johns Terrace<br/>Flat 3<br/>London<br/>W10 4RB<br/>email: <a href='mailto:business-enterprise@martinlayooinc.com' >MartinLayooInc.</a><br/>07809773365</div>");

            jQuery('input[type="text"]').focus(function () {
                jQuery(this).val("");
            });
            initialize();
            //var textArea = document.getElementById('MessageText');
            var text = document.getElementById('mailFrom');
            var testAreaHasPlaceholder = elementSupportsAttribute('textArea', 'placeholder');
            var inputTextHasPlaceholder = elementSupportsAttribute('text', 'placeholder');

            jQuery('textarea#MessageText').attr('title', '@(ViewBag.EmailSent == null ? "Enter your post here":(string)ViewBag.EmailSent)" name="MessageText');
            jQuery('textarea#MessageText').css('color', 'gray');

            jQuery('#mailFrom').attr('title', 'your email address');
            jQuery('#mailFrom').css('color', 'gray');

            jQuery('#mailTo').attr('title', 'to email addresses separated by commas" name="MessageText');
            jQuery('#mailTo').css('color', 'gray');


            jQuery('#mailSubject').attr('title', 'subject" name="MessageText');
            jQuery('#mailSubject').css('color', 'gray');
            jQuery('textarea#MessageText').css('min-height:400px;');
        });
    }
}
