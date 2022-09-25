import { AfterContentInit, Component, Input, OnInit} from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import 'rxjs/add/operator/filter';
import { IUserStatus, MyFundiService } from '../services/myFundiService';
import * as $ from 'jquery';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent implements OnInit{
  public title = 'app';
   presentLearnMore: boolean;
   actUserStatus: IUserStatus;

  constructor(private router: Router) {
    router.events
      .filter(event => event instanceof NavigationEnd)
      .subscribe((event: NavigationEnd) => {
        // You only receive NavigationEnd events
        this.presentLearnMore = this.isPresentLearnMore(event.url);
      });
      
    setInterval(this.adaptResizeWindowsMenus, 500);
  }

  ngOnInit() {

    this.actUserStatus = MyFundiService.actUserStatus;

    $('input#mobilemenu').click(function () {
      document.getElementById('mainmenucontent').scrollIntoView({
        behavior: "smooth"
      });
    });

    $('#mainmenucontent').click(function () {
      document.getElementById('mainbodycontent').scrollIntoView({
        behavior: "smooth"
      });
    });

  }
  adaptResizeWindowsMenus() {

    if (window.matchMedia("(max-width: 512px)").matches) {

      $('div#linkToMainMenu').css('display', 'block');
    } else {

      $('div#linkToMainMenu').css('display', 'none');
    }
  }
  private isPresentLearnMore(url:string): boolean {
    this.presentLearnMore = false;
    if (url.toLowerCase().indexOf('/login') > -1 ||
      url.toLowerCase().indexOf('/register') > -1 ||
      url.toLowerCase().indexOf('/forgot-password') > -1) {
      return false;
    }
    else { return true;}
  }
}
