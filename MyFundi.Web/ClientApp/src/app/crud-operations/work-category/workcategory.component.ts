import { Component, OnInit, Inject, AfterViewInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IProfile, ICertification, ICourse, IWorkCategory, IFundiRating, ILocation, IUserDetail, MyFundiService } from '../../../services/myFundiService';

declare var jQuery: any;

@Component({
  selector: 'workcategory',
  templateUrl: './workcategory.component.html'
})
export class WorkCategoryComponent implements OnInit, AfterViewInit {
  userDetails: any;
  userRoles: string[];
  workCategories: IWorkCategory[];
  selectCategory: HTMLSelectElement;

  ngOnInit(): void {
    this.userDetails = JSON.parse(localStorage.getItem("userDetails"));
    this.userRoles = JSON.parse(localStorage.getItem("userRoles"));
    let workCategoriesObs = this.myFundiService.GetAllFundiWorkCategories();

    this.selectCategory = document.querySelector('select#slworkCategoryId');

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
      debugger;
    let workCatValue = this.selectCategory.value;
    let workCatAddedObs = this.myFundiService.AddFundiWorkCategory(parseInt(workCatValue), this.userDetails.username);
    workCatAddedObs.map((q: any) => {
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
