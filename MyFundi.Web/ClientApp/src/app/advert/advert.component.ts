import { Component, OnInit, ViewChild, ElementRef, Input, Output, Injectable, Inject, EventEmitter } from '@angular/core';
import { IAddress, ILocation, MyFundiService } from '../../services/myFundiService';
import { Element } from '@angular/compiler';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AfterViewChecked } from '@angular/core';
declare var jQuery: any;

@Component({
    selector: 'advert',
    templateUrl: './advert.component.html',
})
export class AdvertComponent implements OnInit, AfterViewChecked {
    private advertGifFiles: File[];
    public userRoles: string[];
    public advertLinkUrl1: string;
    public advertLinkUrl2: string;
    public advertLinkUrl3: string;
    public baseUrl: string = this.myFundiService.BaseServerUrl;

    public constructor(private myFundiService: MyFundiService, private httpClient: HttpClient) {
    }

    ngOnInit() {
		this.advertGifFiles = [];
        let url: string = `${this.baseUrl}/Administration/GetAdvertLinks`;
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        this.httpClient.get(url, { headers: headers }).map((q: any) => {
            debugger;
            if (q) {
                this.advertLinkUrl1 = q.advertLinkUrl1;
                this.advertLinkUrl2 = q.advertLinkUrl2;
                this.advertLinkUrl3 = q.advertLinkUrl3;
            }
        }).subscribe();
    }
    updateUploadAdvert1($event) {
        this.advertGifFiles.push($event.target.files[0]);
    }

    updateUploadAdvert2($event) {
        this.advertGifFiles.push($event.target.files[0]); 
    }

    updateUploadAdvert3($event) {
        this.advertGifFiles.push($event.target.files[0]);
    }

    ngAfterViewChecked(): void {
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    }

    submitAdvert($event) {
        let url: string = `${this.baseUrl}/Administration/UploadAdvertGifImage`;
        for (let n = 0; n < this.advertGifFiles.length; n++) {

            let formData = new FormData();
            formData.append('advertGifFiles', this.advertGifFiles[n])

            this.httpClient.post(url+(n+1), formData).map((res: any) => {
                debugger;
                alert(res.message);
                if (res.result) {
                    alert('Uploaded Advert file: advertGifFiles' + (n + 1));
                }
            }).subscribe();
        }
        $event.preventDefault();
    }
}
