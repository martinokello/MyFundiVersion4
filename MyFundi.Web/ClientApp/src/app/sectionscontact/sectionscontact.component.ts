import { Component, OnInit, ViewChild, ElementRef, Injectable } from '@angular/core';
import { MyFundiService, IEmailMessage } from '../../services/myFundiService';
import * as $ from "jquery";

@Component({
    selector: 'sections-contact',
    templateUrl: './sectionscontact.component.html',
    styleUrls: ['./sectionscontact.component.css'],
  providers: [MyFundiService]
})
@Injectable()
export class SectionsContactComponent implements OnInit {
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
        
        $(document).ready(function () {
           
            $('input[type="text"]').focus(function () {
                $(this).val("");
            });
        });
    }
}
