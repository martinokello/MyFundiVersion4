import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../../services/myFundiService';
import { AfterViewInit } from '@angular/core';
declare var jQuery: any;

@Component({
  selector: 'courses',
  templateUrl: './courses.component.html'
})
export class CoursesComponent implements OnInit, AfterViewInit {
  userDetails: any;
  userRoles: string[];
  courses: ICourse[];
  selectCourse: HTMLSelectElement;

  ngOnInit(): void {
    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
    this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    let courseObs = this.myFundiService.GetAllFundiCourses();

    this.selectCourse = document.querySelector('select#slcourseId');

    courseObs.map((res: ICourse[]) =>
    {
      this.courses = res;
      let opts = document.querySelector('select#slcourseId').querySelector("option");
      if (opts) {
        document.querySelector('select#slcourseId').querySelector("option").remove();
      }

      let opt = document.createElement("option");
      opt.text = "Select Course";
      opt.value = "0";

      document.querySelector('select#slcourseId').append('opt');

      for (let n = 0; n < res.length; n++) {
        let option = document.createElement("option");
        option.value = res[n].courseId.toString();
        option.text = res[n].courseName;
        document.querySelector('select#slcourseId').append(option);
      }
    }).subscribe();
  }
  constructor(private myFundiService: MyFundiService) {
    this.userDetails = {};
  }
  addCourse() {

    let courseValue = this.selectCourse.value;
    let courseObs = this.myFundiService.AddFundiCourse(parseInt(courseValue), this.userDetails.username);
    courseObs.map((q: any) => {
      alert(q.message);
    }).subscribe();
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
