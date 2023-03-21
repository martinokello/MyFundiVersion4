import { Component, OnInit, ViewChild, ElementRef, Input, Output, Injectable, Inject, EventEmitter } from '@angular/core';
import { IAddress, IBlog, ILocation, MyFundiService } from '../../services/myFundiService';
import { Element } from '@angular/compiler';
import * as $ from 'jquery';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import { Router } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AfterViewChecked } from '@angular/core';
declare var jQuery: any;

@Component({
    selector: 'blogs',
    templateUrl: './blogs.component.html',
})
export class BlogsComponent implements OnInit {
    private blogFile: File;
    public blogs: IBlog[];
    public blog: IBlog;
    public isAdiministrator = false;

    public constructor(private myFundiService: MyFundiService, private httpClient: HttpClient) {
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

    submitBlog($event) {
        //upload File:
        let url: string = "https://myfundiv2.martinlayooinc.com/Administration/UploadBlog";

        let formData = new FormData();
        formData.append("blogFile", this.blogFile);
        formData.append("blogName", this.blog.blogName);
        formData.append("blogContent", this.blog.blogContent);

        this.httpClient.post(url, formData).map((res: any) => {
            debugger;
            alert(res.message);
            if (res.result) {
                alert("Added Blog!")
            }
        }).subscribe();
        $event.preventDefault();
    }
}
