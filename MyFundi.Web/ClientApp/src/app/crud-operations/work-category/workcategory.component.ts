import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../../services/myFundiService';

@Component({
  selector: 'workcategory',
  templateUrl: './workcategory.component.html'
})
export class WorkCategoryComponent implements OnInit {
  userDetails: any;
  userRoles: string[];
  workCategories: IWorkCategory[];
  selectCategory: HTMLSelectElement;

  ngOnInit(): void {
    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
    this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    let workCategoriesObs = this.myFundiService.GetAllFundiWorkCategories();

    this.selectCategory = document.querySelector('#allWorkCategoryForm select#slworkCategoryId');

    workCategoriesObs.map((res: IWorkCategory[]) =>
    {
      this.workCategories = res;
      let opts = document.querySelector('select#slworkCategoryId').querySelector("option");
      if (opts) {
        document.querySelector('select#slworkCategoryId').querySelector("option").remove();
      }
      
      let opt = document.createElement("option");
      opt.text = "Select Work Category";
      opt.value = "0";
      document.querySelector('select#slworkCategoryId').append('opt');

      for (let n = 0; n < res.length; n++) {
        let option = document.createElement("option");
        option.value = res[n].workCategoryId.toString();
        option.text = res[n].workCategoryType;
        document.querySelector('select#slworkCategoryId').append(option);
      }
    }).subscribe();
  }
  constructor(private myFundiService: MyFundiService) {
    this.userDetails = {};
  }
  addCategory() {

    let workCatValue = this.selectCategory.value;
    let workCatAddedObs = this.myFundiService.AddFundiWorkCategory(parseInt(workCatValue), this.userDetails.username);
    workCatAddedObs.map((q: any) => {
      alert(q.message);
    }).subscribe();
  }
}
