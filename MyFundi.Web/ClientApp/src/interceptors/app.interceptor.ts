import { Injectable } from '@angular/core';
import { HttpEvent, HttpInterceptor, HttpHandler, HttpRequest, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/do';

@Injectable()
export class AppInterceptor implements HttpInterceptor {

  constructor(/*you can inject services here like the notification service*/) {

  }

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    //You can mutate your request here
    return next
      .handle(req.clone({
        withCredentials: false,
        setHeaders: { 'authToken': localStorage.getItem('authToken') != null && !(req.url.indexOf('https://maps.googleapis.com') > -1)? localStorage.getItem('authToken'):""  }
      })).do((event: any) => {
        if (event instanceof HttpResponse) {
          //you can transform your response here
        }
      });
  }
}
