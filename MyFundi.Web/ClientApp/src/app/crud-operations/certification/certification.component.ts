import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../../services/myFundiService';

@Component({
  selector: 'certification',
  templateUrl: './certification.component.html'
})
export class CertificationComponent implements OnInit {
  userDetails: any;
  userRoles: string[];
  certifications: ICertification[];
  selectCertificate: HTMLSelectElement;

  ngOnInit(): void {
    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
    this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    let certificationsObs = this.myFundiService.GetAllFundiCertificates();

    this.selectCertificate = document.querySelector('select#slcertificationId');

    certificationsObs.map((res: ICertification[]) =>
    {
      this.certifications = res;
      let opts = document.querySelector('select#slcertificationId').querySelector("option");
      if (opts) {
        document.querySelector('select#slcertificationId').querySelector("option").remove();
      }

      let opt = document.createElement("option");
      opt.text = "Select Certification";
      opt.value = "0";

      document.querySelector('select#slcertificationId').append('opt');

      for (let n = 0; n < res.length; n++) {
        let option = document.createElement("option");
        option.value = res[n].certificationId.toString();
        option.text = res[n].certificationName;
        document.querySelector('select#slcertificationId').append(option);
      }
    }).subscribe();
  }
  constructor(private myFundiService: MyFundiService) {
    this.userDetails = {};
  }
  addCertification() {

    let certificateValue: HTMLSelectElement = document.querySelector('select#slcertificationId');
    let certsaddedObs = this.myFundiService.AddFundiCertificate(parseInt(certificateValue.value), this.userDetails.username);
    certsaddedObs.map((q: any) => {
        alert(q.message);
    }).subscribe();
  }
}

