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
    let actualResult: Observable<any> = this.myFundiService.PostOrCreateCertification(this.certification);
      actualResult.map((p: any) => {
        alert('workCategory Added: ' + p.result);
        if (p.result) {
          this.router.navigateByUrl('success');
        }
        else {
          this.router.navigateByUrl('failure');
        }
        }).subscribe();
        $('form#locationView').css('display', 'block').slideDown();
    }
  public updateCertification() {
    let actualResult: Observable<any> = this.myFundiService.UpdateCertification(this.certification);
      actualResult.map((p: any) => {
        alert('Certification Updated: ' + p.result);
        if (p.result) {
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
    let actualResult: Observable<any> = this.myFundiService.DeleteCertification(this.certification);
    actualResult.map((p: any) => {
      alert('certification Deleted: ' + p.result);
      if (p.result) {
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
