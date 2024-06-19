import { Component, OnInit, Inject, AfterContentInit, AfterViewChecked } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { MyFundiService} from '../../services/myFundiService';
import { Observable } from 'rxjs';
import * as $ from 'jquery';
import { Router } from '@angular/router';
import { AfterViewInit } from '@angular/core';
import * as Recaptcha  from 'ng-recaptcha';


@Component({
    selector: 'myrecaptcha',
    templateUrl: './myrecaptcha.component.html',
    providers: [HttpClient, MyFundiService]
})
export class myRecaptchaComponent implements OnInit, AfterViewInit {

    private googleUrl = "https://www.google.com/recaptcha/api/siteverify";

    //private recaptchaSecretKey = "6Lf2450iAAAAAHfNolJ4SwXMy4i91dStnQNRyEKr";
    //private siteKey = "6Lf2450iAAAAAEviEkx3ED-JWZgMU7hfSyZ_RZFu";


    private recaptchaSecretKey = "6LdDVJ4iAAAAAFJU48v9Ip8YGw--mTL6uCUnZXeo";
    private siteKey = "6LdDVJ4iAAAAAFHVELvYKNjAf_MTm4vVgBzDdlFB";

    private isRecaptchaVerified: boolean;
    private showContent: boolean;

    constructor(private myFundiService: MyFundiService, private router: Router, private httpClient: HttpClient) {
        
    }
    ngAfterViewInit(): void {
        this.isRecaptchaVerified = false;
        if (this.isUrlValidForRecaptcha()) {

            $('input[type="submit"]#submit').css('display', 'none');
            $('input[type="submit"].oneRowRegButton').css('display', 'none');

        }
    }

    private CallRecaptureVerify(dataStr:string): void {

        let promObs: Promise<any> = this.myFundiService.PostToRecaptchaVerify(this.googleUrl, dataStr);
        promObs.then((q: any) => {
            this.isRecaptchaVerified = true;
            $('input[type="submit"]#submit').css('display', 'block');
        }).catch((reason: any) => {
            $('input[type="submit"]#submit').css('display', 'block');
        });

    }
    private validateResponse(responseResult: any): void {
        //debugger;
        document.querySelector('input[type="submit"]#submit').setAttribute('style','display:block !important;')
        /*
        var dataResp = {
            response: responseResult,
            secret: this.recaptchaSecretKey,
        };
        var dataStr = JSON.stringify(dataResp);

        console.log(dataStr);
        this.CallRecaptureVerify(dataStr);
        */
    }
    private isUrlValidForRecaptcha(): boolean {

        return window.location.href.toLowerCase().indexOf('/login') > -1 ||
            window.location.href.toLowerCase().indexOf('/register') > -1 ||
            window.location.href.toLowerCase().indexOf('/contactus') > -1;
    }
	private verifyTextbox(e): boolean {
    $('input[type="submit"]#submit').css('display', 'block');
    return true;
    }
    decoderUrl(url: string): string {
        return decodeURIComponent(url);
    }

    ngOnInit(): void {
        grecaptcha.render(document.querySelector('div#layooRecaptcha') as HTMLElement, {
            sitekey: this.siteKey,
            callback: this.validateResponse,
            theme: 'light'
        });
    }
}

