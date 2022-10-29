import { Component, OnInit, Injectable,AfterContentInit } from '@angular/core';
import { IAddress,ICertification,IWorkCategory,MyFundiService } from '../../../services/myFundiService';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
import * as EventEmitter from 'events';

@Component({
  selector: 'certificationcrud',
  templateUrl: './certificationcrud.component.html',
  styleUrls: ['./certificationcrud.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class CertificationCrudComponent implements OnInit, AfterContentInit {
  private myFundiService: MyFundiService;
  public constructor(myFundiService: MyFundiService , private router:Router) {
    this.myFundiService = myFundiService;
    }
  ngAfterContentInit(): void {
    let optionElem = document.createElement('option');
    optionElem.selected = true;
    optionElem.value = (0).toString();
    optionElem.text = "Select Certification";
    document.querySelector('select#certificationcrudId').append(optionElem);


    let certsObs = this.myFundiService.GetAllFundiCertificates();
    certsObs.map((wcs: ICertification[]) => {
      wcs.forEach((c: ICertification, index: number, wcs)=>{
        let optionElem: HTMLOptionElement = document.createElement('option');
        optionElem.value = c.certificationId.toString();
        optionElem.text = c.certificationName;
        document.querySelector('select#certificationcrudId').append(optionElem);
      });
    }).subscribe();

  }
  public certification: ICertification | any;

    public addCertification(): void {
        let form: HTMLFormElement = document.querySelector('form#certificationcrudView');
        if (!form.checkValidity()) return;
    let actualResult: Observable<any> = this.myFundiService.PostOrCreateCertification(this.certification);
        actualResult.map((q: any) => {
            let p: boolean = q;
          alert('workCategory Added: ' + p);
        if (p) {
          this.router.navigateByUrl('success');
        }
        else {
          this.router.navigateByUrl('failure');
        }
        }).subscribe();
        $('form#locationView').css('display', 'block').slideDown();
    }
    public updateCertification() {
        let form: HTMLFormElement = document.querySelector('form') as HTMLFormElement;
        if (!form.checkValidity()) return;
    let actualResult: Observable<any> = this.myFundiService.UpdateCertification(this.certification);
        actualResult.map((q: any) => {
            let p: boolean = q;
        alert('Certification Updated: ' + p);
        if (p) {
          this.router.navigateByUrl('success');
        }
        else {
          this.router.navigateByUrl('failure');
        }
        }).subscribe();
        $('form#locationView').css('display', 'block').slideDown();
  }
  public selectCertification(): void {
    let actualResult: Observable<any> = this.myFundiService.GetCertificationById(this.certification.certificationId);
    actualResult.map((p: any) => {
      this.certification = p;
    }).subscribe();
    $('form#locationView').css('display', 'block').slideDown();
  }
    public deleteCertification() {
        let form: HTMLFormElement = document.querySelector('form#certificationcrudView');
        if (!form.checkValidity()) return;
    let actualResult: Observable<any> = this.myFundiService.DeleteCertification(this.certification);
        actualResult.map((q: any) => {
            let p: boolean = q;
      alert('certification Deleted: ' + p);
      if (p) {
        this.router.navigateByUrl('success');
      }
      else {
        this.router.navigateByUrl('failure');
      }
    }).subscribe();
    $('form#locationView').css('display', 'block').slideDown();
  }
    public ngOnInit(): void {
      this.certification = {}
    }
}
