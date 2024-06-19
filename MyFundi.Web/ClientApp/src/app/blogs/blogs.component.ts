import { Component, OnInit, ViewChild, ElementRef, Input, Output, Injectable, Inject, EventEmitter, AfterViewInit, AfterContentInit, AfterContentChecked } from '@angular/core';
import { IAddress, IBlog, ILocation, MyFundiService } from '../../services/myFundiService';
import { Element } from '@angular/compiler';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AfterViewChecked } from '@angular/core';
import { DOCUMENT } from '@angular/common';
declare var jQuery: any;
declare let sceditor: any;

@Component({
    selector: 'blogs',
    templateUrl: './blogs.component.html',
})
export class BlogsComponent implements OnInit, AfterContentInit, AfterViewInit {
    
    private blogFile: File;
    public blogs: IBlog[];
    public blog: IBlog;
    public isAdiministrator = false;
    public searchQuery: string;
    public baseUrl: string = this.myFundiService.BaseServerUrl;
    public blogSingleImage: File;
    public updateBlogId: number = 0;
    setCreateOrEditBlog: boolean;
    public constructor(private myFundiService: MyFundiService, private httpClient: HttpClient) {
    }
    ngOnInit() {
        this.setCreateOrEditBlog = false;
        let curThis = this;
        setInterval((q) => {
            curThis.setupEvents();
        }, 3500);
    }
    setupEvents() {
        let currentThis = this;
        jQuery(document).ready(function () {
            var events = jQuery._data(document.querySelector('.editBlogDivAnchor > input[type="submit"]'), "events");
            var hasEvents = (events != null);

            if (!hasEvents) {

                jQuery('div.editBlogDivAnchor > input[type="submit"]').on('click touchstart', function (event) {

                    let blogId = jQuery(this).prop('id');
                    currentThis.updateBlogId = blogId;
                    //Get BlogId:
                    jQuery.ajax({
                        url: '/Administration/GetBlog/' + blogId,
                        method: 'GET',
                        async: true,
                        dataType: 'json',
                        success: function (data) {
                            if (data.blog) {
                                if (!this.setCreateOrEditBlog) {
                                    this.setCreateOrEditBlog = true;

                                    currentThis.blog = data.blog
                                }
                                //alert('Blog '+ currentThis.blog.blogName + ' Selected!!');
                                //jQuery('div#blogContent').val();
                                jQuery('textarea#blogContent').html(currentThis.blog.blogContent);
                                jQuery('textarea#blogContent').focus();
                            }
                            else {
                                //alert('Blog Does Not Exist!!');
                            }
                            jQuery('html, body').animate({
                                scrollTop: jQuery("#createBlogDiv").offset().top
                            }, 2000);
                        },
                        error: function (xhReq, error, errorMethod) {
                            alert('Error occured!!');

                        }
                    });
                    return false;
                    //event.preventDefault;
                });
                return false;
            }
        });
    }
    ngAfterViewInit() {
        jQuery('#blogContent').focus();
    }
    ngAfterContentInit() {

        this.blog = {
            blogName: "",
            blogContent: "",
            blogFile: null,
            blogId: 0,
            dateCreated: new Date(),
            dateCreatedUtc: ""
        }
        
        let blogObs: Observable<IBlog[]> = this.myFundiService.GetBlogs();

        blogObs.map((q: IBlog[]) => {
            
            if (q && q.length > 0) {
                for (let n = 0; n < q.length; n++) {
                    q[n].blogContent = q[n].blogContent.replace('\n', '<br/>');
                    const regex: RegExp = /(<img.* src=\"(?!https:\/\/media\.).*\.jpg\")/gi;
                    let ary: RegExpExecArray = regex.exec(q[n].blogContent);
                    if (ary) {
                        q[n].blogContent = q[n].blogContent.replace(regex, "<img src=\"/FileContentServe/GetImageSrcFromImageRootDirectory/" + ary[0].substring(ary[0].lastIndexOf("/") + 1));
                    }
                    q[n].dateCreatedUtc = q[n].dateCreated.toString();
                }

                this.blogs = q;
            }
        }).subscribe();
        let curThis = this;

        setInterval((q) => {

            let roles: string[] = JSON.parse(localStorage.getItem("userRoles"));
            if (roles && roles.indexOf("Administrator") > -1) {
                curThis.isAdiministrator = true;
            }
            else {
                curThis.isAdiministrator = false;
            }
        }, 3500);
    }
    uploadBlogFile($event) {
        this.blogFile = $event.target.files[0];
    }
    uploadBlogSingleImages($event) {
        this.blogSingleImage = $event.target.files[0];
    }

    submitBlogSingleImage($event) {
        //upload File:
        let url: string = `${this.baseUrl}/Administration/UploadBlogSingleImages`;

        let formData = new FormData();
        formData.append("blogFile", this.blogSingleImage);

        this.httpClient.post(url, formData).map((res: any) => {
            debugger;
            alert(res.message);
            if (res.result) {
                alert("Added Blog Single Image!")
            }
        }).subscribe();
        $event.preventDefault();
    }
    submitBlog($event) {
        //upload File:
        let url: string = `${this.baseUrl}/Administration/UploadBlog`;

        let formData = new FormData();
        formData.append("blogFile", this.blogFile);
        formData.append("blogName", this.blog.blogName);


        //let value = jQuery("textarea#blogContent").val();
        //let value = sceditor.instance(textarea).getBody().innerHTML;

        let textarea = jQuery('#blogContent')[0];
        let scEditInstance = sceditor.instance(textarea);
        let message = scEditInstance.getBody().innerHTML;

        formData.append("blogContent", message);
        

        this.httpClient.post(url, formData).map((res: any) => {
            alert(res.message);
            if (res.result) {
                alert("Added Blog!")
            }
        }).subscribe();
        $event.preventDefault();
    }
    deleteBlog($event) {        //upload File:
        let url: string = `/Administration/DeleteBlog/${this.updateBlogId.toString()}`;
        
        this.httpClient.get(url).map((res: any) => {
            debugger;
            alert(res.message);
           
        }).subscribe();
        $event.preventDefault();
    }
    updateBlog($event) {
        //upload File:
        let url: string = `${this.baseUrl}/Administration/UpdateBlog`;

        let formData = new FormData();
        formData.append("blogFile", this.blogFile);
        formData.append("blogName", this.blog.blogName);
        formData.append("blogId", this.updateBlogId.toString());

        let textarea = jQuery('#blogContent')[0];
        let scEditInstance = sceditor.instance(textarea);
        let message = scEditInstance.getBody().innerHTML;

        formData.append("blogContent", message);
        //let value = jQuery("textarea#blogContent").val();
        //let value = sceditor.instance(textarea).getBody().innerHTML;

        this.httpClient.post(url, formData).map((res: any) => {
            debugger;
            alert(res.message);
            if (res.result) {
                alert("Updated Blog!")
            }
        }).subscribe();
        $event.preventDefault();
    }
    getImageUrl(blogName: string) {
        return this.baseUrl + "/images/" + blogName + ".jpg";
    }
    searchBlogs($event) {

        let query: string = this.searchQuery.toLowerCase();
        let keywords: string[] = query.replace(".", "").replace("the", "").replace(" it ", "").replace(" a ", "").replace(" there ", "").replace(" why ", "").replace(" and ", "").replace("you", "").replace(" we ", "")
            .replace(" their ", "").replace(" this ", "").replace(" where ", "").replace(" her ", "").replace(" him ", "").replace(" he ", "").replace(" she ", "").split(" ");

        let serchObs: Observable<IBlog[]> = this.myFundiService.SearchForKeyWords(keywords);

        serchObs.map((q: IBlog[]) => {
                    debugger;
            if (q && q.length > 0)
            {
                for (let n = 0; n < q.length; n++) {
                    q[n].blogContent = q[n].blogContent.replace('\n', '<br/>');
                    const regex: RegExp = /(<img.* src=\"(?!https:\/\/media\.).*\.jpg\")/gi;
                    let ary: RegExpExecArray = regex.exec(q[n].blogContent);
                    if (ary) {
                        q[n].blogContent = q[n].blogContent.replace(regex, "<img src=\"/FileContentServe/GetImageSrcFromImageRootDirectory/" + ary[0].substring(ary[0].lastIndexOf("/") + 1));
                    }
                    q[n].dateCreatedUtc = q[n].dateCreated.toString();
                }

                this.blogs = q;
            
            }
            else {
                this.blogs = [];
                alert('No Blogs matching your search Criteria!!');
            }
        }).subscribe();
        $event.preventDefault();
    }
}
