import { Component, OnInit, ViewChild, ElementRef, Injectable, AfterViewInit, AfterViewChecked, Inject, Input, Output, EventEmitter } from '@angular/core';
import { MyFundiService, IEmailMessage } from '../../services/myFundiService';
import * as $ from "jquery";
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import * as google from '../../assets/google/googleMaps.js';
declare const google: any;

@Component({
    selector: 'contactus',
    templateUrl: './contactus.component.html',
    styleUrls: ['./contactus.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class ContactUsComponent implements OnInit {
  private myFundiService: MyFundiService  | any;
    email: IEmailMessage | any;

  @ViewChild('emailFormView', { static: false }) emailFormView: HTMLElement | any; 
  public constructor(myFundiService: MyFundiService ) {

    this.myFundiService = myFundiService;
    }
    sendEmail(): void {

        let formView = this.emailFormView;
        let form = formView.nativeElement.querySelector("form");
        if (form.checkValidity())
        form.submit();
        /*
        let form = new FormData();
        form.append('emailBody', this.email.emailBody);
        form.append('emailTo', this.email.emailTo);
        form.append('emailFrom', this.email.emailFrom);
        form.append('emailSubject', this.email.emailSubject);
        form.append('attachment', this.email.attachment);
        let result: Observable<boolean> = this.safariTourService.SendEmail(form);
        result.subscribe((value: any) => {
            alert('email ' + (value.result ? 'sent' : 'failed sending'));
        });
        */
    }
    getFiles(event) {
        this.email.attachment = event.target.files;
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
        $(document).ready(function () {

            $('div#ourContactDetails').html("<div align='center' style='width:240px;margin-top:10px;'><h2>Contact Details</h2></div><div align='center'><b>MartinLayooInc Software House,<br/> 2 St Johns Terrace<br/>Flat 3<br/>London<br/>W10 4RB<br/>email: <a href='mailto:business-enterprise@martinlayooinc.com' >MartinLayooInc.</a><br/>07809773365</div>");

            $('input[type="text"]').focus(function () {
                $(this).val("");
            });
            initialize();
            var textArea = document.getElementById('MessageText');
            var text = document.getElementById('mailFrom');
            var testAreaHasPlaceholder = elementSupportsAttribute('textArea', 'placeholder');
            var inputTextHasPlaceholder = elementSupportsAttribute('text', 'placeholder');

            $('textarea#MessageText').attr('title', '@(ViewBag.EmailSent == null ? "Enter your post here":(string)ViewBag.EmailSent)" name="MessageText');
            $('textarea#MessageText').css('color', 'gray');

            $('#mailFrom').attr('title', 'your email address');
            $('#mailFrom').css('color', 'gray');

            $('#mailTo').attr('title', 'to email addresses separated by commas" name="MessageText');
            $('#mailTo').css('color', 'gray');


            $('#mailSubject').attr('title', 'subject" name="MessageText');
            $('#mailSubject').css('color', 'gray');
            $('textarea#MessageText').css('min-height:200px;');
        });
    }
}
