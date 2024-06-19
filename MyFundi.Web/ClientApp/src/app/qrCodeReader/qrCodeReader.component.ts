import { Component, Input, OnInit } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { Html5QrcodeScanner } from '../../html5QrCodescaner/src';
import 'rxjs/add/operator/filter';
import 'rxjs/add/operator/map';
import { IUserStatus, MyFundiService, IUserDetail } from '../../services/myFundiService';
import { Observable } from 'rxjs';

@Component({
  selector: 'qrcode-reader',
  templateUrl: './qrCodeReader.component.html'
})
export class QrCodeComponent implements OnInit {
  public title = 'QR Code Reader';
  presentLearnMore: boolean;
  userDetails: IUserDetail;
  static currentObject: any;

  constructor(private myFundiService: MyFundiService , private router: Router) {
    QrCodeComponent.currentObject = this;
  }
  submitScanToVerify() {
    let results: Observable<any> = this.myFundiService.VerifyQrcodeScan(this.userDetails);
    results.map((res) => {
      let statusCode: number = parseInt(res.statusCode);
      if (statusCode === 200) {
        alert("Completed Scan & verified Successfully!!");
        QrCodeComponent.currentObject.scanEventHandlers.html5QrcodeScanner.clear();
        this.router.navigateByUrl('crud');
      }
      else {
        alert("Completed Scan & Failed to Verify!!\rEnsure you use your right registered Mobile Number.");

        this.router.navigateByUrl('logout');
      }
    }).subscribe();
  }
  scanEventHandlers: any = {
    html5QrcodeScanner: Html5QrcodeScanner,
    onScanSuccess: function (qrMessage) {
      // handle the scanned code as you like, for example:
      QrCodeComponent.currentObject.submitScanToVerify();
    },
    onScanFailure: function (error) {
      // handle scan failure, usually better to ignore and keep scanning.
    }
  }
  ngOnInit() {
    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
  }

  scanQrCode() {
    this.scanEventHandlers.html5QrcodeScanner = new Html5QrcodeScanner("reader", { fps: 10, qrbox: 250 }, /* verbose= */ false);
    this.scanEventHandlers.html5QrcodeScanner.render(this.scanEventHandlers.onScanSuccess, this.scanEventHandlers.onScanFailure);
  }

}
