import { Component, Injectable, OnInit, AfterViewInit,AfterContentInit } from '@angular/core';
import { Router } from '@angular/router';
import 'rxjs/add/operator/map';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
@Component({
  selector: 'active-crud-operations',
  templateUrl: './activecrudoperations.component.html',
  styleUrls: ['./activecrudoperations.component.css']
})
@Injectable()
export class ActiveCrudOperationsComponent implements AfterContentInit {

  constructor(public router: Router) {

  }
  ngAfterContentInit() {
    let elNodeList: NodeListOf<HTMLElement> = document.querySelectorAll('div#createEcosystem ul.nav-tabs li a') as NodeListOf<HTMLElement>;
    elNodeList.forEach((ele: HTMLElement, ind: number, elNodeList) => {

        ele.onclick = (evt: MouseEvent) => {
          elNodeList.forEach((el: HTMLElement) => {
            if (el !== ele) {
              el.classList.remove('active');
            }
          });
          ele.classList.add('active');
          let contentId: string = ele.textContent.toLowerCase().replace(' ','-');
          let contents: NodeListOf<HTMLElement> = document.querySelectorAll('div#tabContent > div') as NodeListOf<HTMLElement>;
          contents.forEach((el2: HTMLElement, ind: number, elNodeList) => {
            if (el2.attributes.getNamedItem('id').value === contentId) {
              el2.style.display = 'block';
            }
            else {
              el2.style.display = 'none';
            }
          });
        }
    });

    let ddAnchNodeList: NodeListOf<HTMLElement> = document.querySelectorAll('div#createEcosystem ul.nav-tabs ul.dropdown-menu li a') as NodeListOf<HTMLElement>;
    ddAnchNodeList.forEach((ele: HTMLElement, ind: number, elNodeList) => {

      ele.onclick = (evt: MouseEvent) => {
        ddAnchNodeList.forEach((el: HTMLElement) => {
          if (el !== ele) {
            el.classList.remove('active');
          }
        });
        ele.classList.add('active');
        let contentId: string = ele.textContent.toLowerCase().replace(' ', '-');
        let contents: NodeListOf<HTMLElement> = document.querySelectorAll('div#tabContent > div') as NodeListOf<HTMLElement>;
        contents.forEach((el2: HTMLElement, ind: number, elNodeList) => {
          if (el2.attributes.getNamedItem('id').value === contentId) {
            el2.style.display = 'block';
          }
          else {
            el2.style.display = 'none';
          }
        });
      }
    });
  }
}
