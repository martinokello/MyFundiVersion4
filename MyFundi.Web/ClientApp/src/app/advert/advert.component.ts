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
    private advertGifFile: File;
    public userRoles: string[];
    public advertLinkUrl: string;

    public constructor(private myFundiService: MyFundiService, private httpClient: HttpClient) {
    }

    ngOnInit() {
        let url: string = "/Administration/GetAdvertLink";
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        this.httpClient.get(url, { headers: headers }).map((q: any) => {
            debugger;
            if (q) {
                this.advertLinkUrl = q.advertLinkUrl;
            }
        }).subscribe();
    }
    updateUploadAdvert($event) {
        this.advertGifFile = $event.target.files[0];
    }

    ngAfterViewChecked(): void {
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    }
    submitAdvert($event) {
        //upload File:
        let url: string = "/Administration/UploadAdvertGifImage";

        let formData = new FormData();
        formData.append("advertGifFile", this.advertGifFile);

        this.httpClient.post(url, formData).map((res: any) => {
            alert(res.message);
            if (res.result) {
                alert("Added Gif Advert!")
            }
        }).subscribe();
        $event.preventDefault();
    }
}
