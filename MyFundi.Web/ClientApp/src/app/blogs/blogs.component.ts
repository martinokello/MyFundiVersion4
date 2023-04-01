import { Component, OnInit, ViewChild, ElementRef, Input, Output, Injectable, Inject, EventEmitter, AfterViewInit } from '@angular/core';
import { IAddress, IBlog, ILocation, MyFundiService } from '../../services/myFundiService';
import { Element } from '@angular/compiler';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AfterViewChecked } from '@angular/core';
declare var sceditor: any;
declare var jQuery: any;

@Component({
    selector: 'blogs',
    templateUrl: './blogs.component.html',
})
export class BlogsComponent implements OnInit, AfterViewInit {
    private blogFile: File;
    public blogs: IBlog[];
    public blog: IBlog;
    public isAdiministrator = false;
    public searchQuery: string;
    public baseUrl: string = this.myFundiService.BaseServerUrl;
    public blogSingleImage: File;

    public constructor(private myFundiService: MyFundiService, private httpClient: HttpClient) {
    }
    ngAfterViewInit() {

        var textarea = document.getElementById('blogContent');
        sceditor.create(textarea, {
            format: 'bbcode',
            width:'100%',
            icons: 'monocons',
            style: 'minified/themes/content/default.min.css'
        });
    }
    ngOnInit() {

        this.blog = {
            blogName:"",
            blogContent: "",
            blogFile: null,
            blogId: 0,
            dateCreated: new Date(),
            dateCreatedUtc:""
        }
		let roles:string[] = JSON.parse(localStorage.getItem("userRoles"));
        if (roles && roles.indexOf("Administrator") > -1) {
            this.isAdiministrator = true;
        }
        else {
            this.isAdiministrator = false;
        }
        let blogObs:Observable<IBlog[]> = this.myFundiService.GetBlogs();

        blogObs.map((q: IBlog[]) => {
            debugger;
            if (q && q.length > 0) {
                for (let n = 0; n < q.length;n++){
                    q[n].blogContent = q[n].blogContent.replace('\n', '<br/>');
                    q[n].dateCreatedUtc = q[n].dateCreated.toString();
                }

                this.blogs = q;
            }
        }).subscribe();
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

        let textarea = document.getElementById('blogContent');
        let value = sceditor.instance(textarea).getBody().innerHTML;

        formData.append("blogContent", value);

        this.httpClient.post(url, formData).map((res: any) => {
            debugger;
            alert(res.message);
            if (res.result) {
                alert("Added Blog!")
            }
        }).subscribe();
        $event.preventDefault();
    }
    searchBlogs($event) {

        let query: string = this.searchQuery.toLowerCase();
        let keywords: string[] = query.replace(".", "").replace("the", "").replace(" it ", "").replace(" a ", "").replace(" there ", "").replace(" why ", "").replace(" and ", "").replace("you", "").replace(" we ", "")
            .replace(" their ", "").replace(" this ", "").replace(" where ", "").replace(" her ", "").replace(" him ", "").replace(" he ", "").replace(" she ", "").split(" ");

        let serchObs: Observable<IBlog[]> = this.myFundiService.SearchForKeyWords(keywords);

        serchObs.map((q: IBlog[]) => {
            debugger;
            if (q && q.length > 0) {
                for (let n = 0; n < q.length; n++) {
                    q[n].blogContent = q[n].blogContent.replace('\n', '<br/>');
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
