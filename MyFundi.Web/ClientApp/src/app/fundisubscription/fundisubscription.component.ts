import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../services/myFundiService';
import { Observable } from 'rxjs';

@Component({
  selector: 'fundisubscription',
  templateUrl: './fundisubscription.component.html'
})
export class FundiSubscriptionComponent implements OnInit {
  userDetails: any;
  userRoles: string[];
  location: ILocation;
  subscriptionFee: number = 2500;
  subscriptionDescritption: string;
  subscriptionName: string;
  fundi: any = {};

  decoderUrl(url: string):string {
    return decodeURIComponent(url);
  }
  ngOnInit(): void {
    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
    this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    let resObs = this.myFundiService.GetFundiProfile(this.userDetails.username);

    resObs.map((fundiProf: IProfile) => {
      this.fundi = fundiProf;
      this.fundi.subscriptionFee = this.subscriptionFee;
      this.fundi.subscriptionName = `Fundi User ${this.userDetails.firstName} ${this.userDetails.lastName} Subscription for 31 days`;
      this.fundi.subscriptionDescription = "Attempting Monthly Payment!";
   
      let userIdObs: Observable<string> = this.myFundiService.GetUserGuidId(this.userDetails.username);
      userIdObs.map((q: string) => {
        this.fundi.userId = q;
      }).subscribe();
    }).subscribe();
  }
  constructor(private myFundiService: MyFundiService) {
    this.userDetails = {};
  }
  paySubscriptionMonthlyFee($event) {

      let subscriptionFeeExpense: any = {
        monthlySubscriptionId: 0,
        userId: this.fundi.userId,
        fundiProfileId: this.fundi.fundiProfileId,
        startDate: new Date(),
        username: this.userDetails.username,
        subscriptionFee: this.fundi.subscriptionFee,
        hasPaid: false,
        subscriptionName: this.fundi.subscriptionName,
        subscriptionDescription: this.fundi.subscriptionDescription
      };
    let resultObs: Observable<any> = this.myFundiService.PayMonthlySubscriptionFee(subscriptionFeeExpense);

      resultObs.map((q: any) => {
        if (q.payPalRedirectUrl) {
          window.open(q.payPalRedirectUrl);
          console.log('Response received');
          console.log(q.paypalUrl);
          alert("Payment made. Currently being processed by paypal service!\nYou will be informed once all is set up by email.");
        }
        else {
          alert("Paypal error happened. We are sorry something went bad. Please contact Admin");
        }
      }).subscribe();
      $event.preventDefault();
    }
}

