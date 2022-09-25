import { Component, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { APP_BASE_HREF } from '@angular/common';
import { MyFundiService, ILocationWeather } from '../../services/myFundiService';
import * as $ from "jquery";
import { Observable } from 'rxjs';

@Component({
  selector: 'app-fetch-data',
  templateUrl: './fetch-data.component.html'
})
export class FetchDataComponent {
  public forecasts: ILocationWeather;
  locationAndCountryCode: string;
  constructor(private myFundiService: MyFundiService ) {
  }
  SearchLocationWeather(): ILocationWeather {
    //let searchLocation: HTMLElement = document.querySelector('input#locationAndCountryCode');
    var locationElems: string[] = this.locationAndCountryCode.match(/[^ ,]+/g);
    if (locationElems.length < 2) {
      alert("You need at least city followed by Country Code e.g. London,UK");
      return;
    }

    let weatherForcast: Observable<ILocationWeather> = this.myFundiService.GetSearchLocationWeather(locationElems[0], locationElems[1]);

    let searchDiv: HTMLElement = document.querySelector('div#results');
    searchDiv.setAttribute('style', "background-color:silver !important;padding:5px;");
    let divContent: HTMLElement = document.querySelector('div#content');
    if (divContent)
    divContent.remove();


    var div = document.createElement('div');
    div.id = 'content';
    weatherForcast.map((weatherFocus: ILocationWeather) => {
      let divCity = document.createElement('div');
      divCity.setAttribute('style', "background-color:gray !important;padding:5px;");
      divCity.innerHTML = "City Name: "+weatherFocus.location.cityName;
      div.append(divCity);

      let divCurrTemp = document.createElement('div');
      divCurrTemp.setAttribute('style', "background-color:beige !important;padding:5px;");
      divCurrTemp.innerHTML = "Current Temperature: " +weatherFocus.temperature.currentTemperature + "";
      div.append(divCurrTemp);

      let divMaxTemp = document.createElement('div');
      divMaxTemp.innerHTML = "Maximum Temperature: " + weatherFocus.temperature.maximumTemperature + "";
      divMaxTemp.setAttribute('style', "background-color:gray !important;padding:5px;");
      div.append(divMaxTemp);

      let divMinTemp = document.createElement('div');
      divMinTemp.innerHTML = "Minimum Temperature: " + weatherFocus.temperature.minmumTemperature + "";
      divMinTemp.setAttribute('style', "background-color:beige !important;padding:5px;");
      div.append(divMinTemp);

      let divPressure = document.createElement('div');
      divPressure.innerHTML = "Pressure: " + weatherFocus.pressure + "";
      divPressure.setAttribute('style', "background-color:gray !important;padding:5px;");
      div.append(divPressure);

      let divHumidity = document.createElement('div');
      divHumidity.innerHTML = "Humidity: " + weatherFocus.humidity + "";
      divHumidity.setAttribute('style', "background-color:beige !important;padding:5px;");
      div.append(divHumidity);

      let divSunrise = document.createElement('div');
      divSunrise.innerHTML = "Sunrise: "+new Date(weatherFocus.sunrise).toUTCString();
      divSunrise.setAttribute('style', "background-color:gray !important;padding:5px;");
      div.append(divSunrise);

      let divSunset = document.createElement('div');
      divSunset.innerHTML = "Sunset: " +new Date(weatherFocus.sunset).toUTCString();
      divSunset.setAttribute('style', "background-color:beige !important;padding:5px;");
      div.append(divSunset);

      searchDiv.append(div);
    }).subscribe();
  }

}

