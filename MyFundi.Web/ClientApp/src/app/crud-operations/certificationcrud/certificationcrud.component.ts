import { Component, OnInit, Injectable,AfterContentInit, AfterViewChecked, AfterViewInit } from '@angular/core';
import { IAddress,ICertification,IWorkCategory,MyFundiService } from '../../../services/myFundiService';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { Output } from '@angular/core';
import * as EventEmitter from 'events';
declare var jQuery: any;

@Component({
  selector: 'certificationcrud',
  templateUrl: './certificationcrud.component.html',
  styleUrls: ['./certificationcrud.component.css'],
    providers: [MyFundiService]
})
@Injectable()
export class CertificationCrudComponent implements OnInit, AfterContentInit, AfterViewInit {
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

          jQuery('select').each((ind, sel) => {
              let options = jQuery(sel).children('option');
              debugger;
              let vals = [];
              jQuery(options).each((id, el) => {
                  let optionText = jQuery(el).html();
                  vals.push(optionText);
              });
              //options is source of auto complete:
              let jQueryinpId = jQuery('input#autoComplete' + jQuery(sel).attr('id'));
              jQuery(jQueryinpId).autocomplete({ source: vals });
              jQuery(jQueryinpId).on('focusout', (e) => {
                  jQuery('select#' + jQuery(sel).attr('id') + ':selected').text(jQuery(jQueryinpId).val());
              });
          });

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
          alert('Certification Added: ' + p);
        if (p) {
          this.router.navigateByUrl('success');
        }
        else {
          this.router.navigateByUrl('failure');
        }
        }).subscribe();
        jQuery('form#locationView').css('display', 'block').slideDown();
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
        jQuery('form#locationView').css('display', 'block').slideDown();
  }
  public selectCertification(): void {
    let actualResult: Observable<any> = this.myFundiService.GetCertificationById(this.certification.certificationId);
    actualResult.map((p: any) => {
      this.certification = p;
    }).subscribe();
    jQuery('form#locationView').css('display', 'block').slideDown();
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
    jQuery('form#locationView').css('display', 'block').slideDown();
  }
    public ngOnInit(): void {
      this.certification = {}
    }
    ngAfterViewInit() {
        jQuery('select').each((ind, sel) => {
            let options = jQuery(sel).children('option');
            debugger;
            let vals = [];
            jQuery(options).each((id, el) => {
                let optionText = jQuery(el).html();
                vals.push(optionText);
            });
            //options is source of auto complete:
            let jQueryinpId = jQuery('input#autoComplete' + jQuery(sel).attr('id'));
            jQueryinpId.autocomplete({ source: vals });
            jQuery(document).on('click', '.ui-menu .ui-menu-item-wrapper', function (event) {
                jQuery('select#' + jQuery(sel).attr('id')).find("option").filter(function () {
                    return jQuery(event.target).text() == jQuery(this).html();
                }).attr("selected", true);
            });
        });
    }
}
