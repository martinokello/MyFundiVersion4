import { Component, OnInit, Input, AfterViewChecked, EventEmitter, Output } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { IPagingContent } from '../../services/myFundiService';
declare var jQuery: any;

@Component({
    selector: 'paging',
    templateUrl: './paging.component.html'
})
export class PagingComponent implements AfterViewChecked {

    @Input("pagingContentModel") pagingContentModel: IPagingContent;
    @Output() searchEventEmitter: EventEmitter<IPagingContent>;

    constructor() {
        this.searchEventEmitter = new EventEmitter<IPagingContent>();
    }
    ngAfterViewChecked(): void {
        let prevLk = jQuery('a#prev');
        let prev3Lk = jQuery('a#prev3');
        let next3Lk = jQuery('a#next3');
        let nextLk = jQuery('a#next');

        if(!(this.pagingContentModel.isPagePrev3Enabled)){
            prev3Lk.css('pointer-events', 'none');
            prev3Lk.css('cursor', 'default');
        }
        else {
            prev3Lk.css('pointer-events', 'auto');
            prev3Lk.css('cursor', 'pointer');
        }

        if (!(this.pagingContentModel.isPagePrevEnabled)) {
            prevLk.css('pointer-events', 'none');
            prevLk.css('cursor', 'default');
        }
        else {
            prevLk.css('pointer-events', 'auto');
            prevLk.css('cursor', 'pointer');
        }

        if (!(this.pagingContentModel.isPageNext3Enabled)) {
            next3Lk.css('pointer-events', 'none');
            next3Lk.css('cursor', 'default');
        }
        else {
            next3Lk.css('pointer-events', 'auto');
            next3Lk.css('cursor', 'pointer');
        }

        if (!(this.pagingContentModel.isPageNextEnabled)) {
            nextLk.css('pointer-events', 'none');
            nextLk.css('cursor', 'default');
        }
        else {
            nextLk.css('pointer-events', 'auto');
            nextLk.css('cursor', 'pointer');
        }

        jQuery('span#search-navigation-links').parent('div').css('line-height', '3em');
        if (this.pagingContentModel && this.pagingContentModel.content.length == 0) {
            jQuery('span#search-navigation-links').parent('div').css('display', 'none');
        }
        else {
            jQuery('span#search-navigation-links').parent('div').css('display', 'block');
        }
    }
    nextPageClicked($event) {
        this.pagingContentModel.pageNextClicked = true;
        this.pagingContentModel.pagePrevClicked = false;
        this.pagingContentModel.pageNext3Clicked = false;
        this.pagingContentModel.pagePrev3Clicked = false;
        this.searchEventEmitter.emit(this.pagingContentModel);
        $event.preventDefault();
    }
    prevPageClicked($event) {
        this.pagingContentModel.pageNextClicked = false;
        this.pagingContentModel.pagePrevClicked = true;
        this.pagingContentModel.pageNext3Clicked = false;
        this.pagingContentModel.pagePrev3Clicked = false;
        this.searchEventEmitter.emit(this.pagingContentModel);
        $event.preventDefault();
    }
    next3PagesClicked($event) {
        this.pagingContentModel.pageNext3Clicked = true;
        this.pagingContentModel.pageNextClicked = false;
        this.pagingContentModel.pagePrevClicked = false;
        this.pagingContentModel.pagePrev3Clicked = false;
        this.searchEventEmitter.emit(this.pagingContentModel);
        $event.preventDefault();
    }
    prev3PagesClicked($event) {
        this.pagingContentModel.pagePrev3Clicked = true;
        this.pagingContentModel.pageNextClicked = false;
        this.pagingContentModel.pagePrevClicked = false;
        this.pagingContentModel.pageNext3Clicked = false;
        this.searchEventEmitter.emit(this.pagingContentModel);
        $event.preventDefault();
    }
}

