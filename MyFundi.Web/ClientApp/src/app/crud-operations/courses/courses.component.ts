import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../../services/myFundiService';

@Component({
  selector: 'courses',
  templateUrl: './courses.component.html'
})
export class CoursesComponent implements OnInit {
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
}
