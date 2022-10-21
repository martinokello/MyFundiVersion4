import * as tslib_1 from "tslib";
import { Component, ElementRef, EventEmitter, HostBinding, Inject, Input, NgZone, Optional, Output, } from '@angular/core';
import { RecaptchaLoaderService } from './recaptcha-loader.service';
import { RECAPTCHA_SETTINGS } from './recaptcha-settings';
let nextId = 0;
let RecaptchaComponent = class RecaptchaComponent {
    constructor(elementRef, loader, zone, settings) {
        this.elementRef = elementRef;
        this.loader = loader;
        this.zone = zone;
        this.id = `ngrecaptcha-${nextId++}`;
        this.resolved = new EventEmitter();
        if (settings) {
            this.siteKey = settings.siteKey;
            this.theme = settings.theme;
            this.type = settings.type;
            this.size = settings.size;
            this.badge = settings.badge;
        }
    }
    ngAfterViewInit() {
        this.subscription = this.loader.ready.subscribe((grecaptcha) => {
            if (grecaptcha != null && grecaptcha.render instanceof Function) {
                this.grecaptcha = grecaptcha;
                this.renderRecaptcha();
            }
        });
    }
    ngOnDestroy() {
        // reset the captcha to ensure it does not leave anything behind
        // after the component is no longer needed
        this.grecaptchaReset();
        if (this.subscription) {
            this.subscription.unsubscribe();
        }
    }
    /**
     * Executes the invisible recaptcha.
     * Does nothing if component's size is not set to "invisible".
     */
    execute() {
        if (this.size !== 'invisible') {
            return;
        }
        if (this.widget != null) {
            this.grecaptcha.execute(this.widget);
        }
        else {
            // delay execution of recaptcha until it actually renders
            this.executeRequested = true;
        }
    }
    reset() {
        if (this.widget != null) {
            if (this.grecaptcha.getResponse(this.widget)) {
                // Only emit an event in case if something would actually change.
                // That way we do not trigger "touching" of the control if someone does a "reset"
                // on a non-resolved captcha.
                this.resolved.emit(null);
            }
            this.grecaptchaReset();
        }
    }
    /** @internal */
    expired() {
        this.resolved.emit(null);
    }
    /** @internal */
    captchaResponseCallback(response) {
        this.resolved.emit(response);
    }
    /** @internal */
    grecaptchaReset() {
        if (this.widget != null) {
            this.zone.runOutsideAngular(() => this.grecaptcha.reset(this.widget));
        }
    }
    /** @internal */
    renderRecaptcha() {
        this.widget = this.grecaptcha.render(this.elementRef.nativeElement, {
            badge: this.badge,
            callback: (response) => {
                this.zone.run(() => this.captchaResponseCallback(response));
            },
            'expired-callback': () => {
                this.zone.run(() => this.expired());
            },
            sitekey: this.siteKey,
            size: this.size,
            tabindex: this.tabIndex,
            theme: this.theme,
            type: this.type,
        });
        if (this.executeRequested === true) {
            this.executeRequested = false;
            this.execute();
        }
    }
};
tslib_1.__decorate([
    Input(),
    HostBinding('attr.id'),
    tslib_1.__metadata("design:type", Object)
], RecaptchaComponent.prototype, "id", void 0);
tslib_1.__decorate([
    Input(),
    tslib_1.__metadata("design:type", String)
], RecaptchaComponent.prototype, "siteKey", void 0);
tslib_1.__decorate([
    Input(),
    tslib_1.__metadata("design:type", String)
], RecaptchaComponent.prototype, "theme", void 0);
tslib_1.__decorate([
    Input(),
    tslib_1.__metadata("design:type", String)
], RecaptchaComponent.prototype, "type", void 0);
tslib_1.__decorate([
    Input(),
    tslib_1.__metadata("design:type", String)
], RecaptchaComponent.prototype, "size", void 0);
tslib_1.__decorate([
    Input(),
    tslib_1.__metadata("design:type", Number)
], RecaptchaComponent.prototype, "tabIndex", void 0);
tslib_1.__decorate([
    Input(),
    tslib_1.__metadata("design:type", String)
], RecaptchaComponent.prototype, "badge", void 0);
tslib_1.__decorate([
    Output(),
    tslib_1.__metadata("design:type", Object)
], RecaptchaComponent.prototype, "resolved", void 0);
RecaptchaComponent = tslib_1.__decorate([
    Component({
        exportAs: 'reCaptcha',
        selector: 're-captcha',
        template: ``
    }),
    tslib_1.__param(3, Optional()), tslib_1.__param(3, Inject(RECAPTCHA_SETTINGS)),
    tslib_1.__metadata("design:paramtypes", [ElementRef,
        RecaptchaLoaderService,
        NgZone, Object])
], RecaptchaComponent);
export { RecaptchaComponent };
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoicmVjYXB0Y2hhLmNvbXBvbmVudC5qcyIsInNvdXJjZVJvb3QiOiJuZzovL25nLXJlY2FwdGNoYS8iLCJzb3VyY2VzIjpbInJlY2FwdGNoYS9yZWNhcHRjaGEuY29tcG9uZW50LnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQSxPQUFPLEVBRUwsU0FBUyxFQUNULFVBQVUsRUFDVixZQUFZLEVBQ1osV0FBVyxFQUNYLE1BQU0sRUFDTixLQUFLLEVBQ0wsTUFBTSxFQUVOLFFBQVEsRUFDUixNQUFNLEdBQ1AsTUFBTSxlQUFlLENBQUM7QUFHdkIsT0FBTyxFQUFFLHNCQUFzQixFQUFFLE1BQU0sNEJBQTRCLENBQUM7QUFDcEUsT0FBTyxFQUFFLGtCQUFrQixFQUFxQixNQUFNLHNCQUFzQixDQUFDO0FBRTdFLElBQUksTUFBTSxHQUFHLENBQUMsQ0FBQztBQU9mLElBQWEsa0JBQWtCLEdBQS9CO0lBdUJFLFlBQ1UsVUFBc0IsRUFDdEIsTUFBOEIsRUFDOUIsSUFBWSxFQUNvQixRQUE0QjtRQUg1RCxlQUFVLEdBQVYsVUFBVSxDQUFZO1FBQ3RCLFdBQU0sR0FBTixNQUFNLENBQXdCO1FBQzlCLFNBQUksR0FBSixJQUFJLENBQVE7UUF2QmYsT0FBRSxHQUFHLGVBQWUsTUFBTSxFQUFFLEVBQUUsQ0FBQztRQVNyQixhQUFRLEdBQUcsSUFBSSxZQUFZLEVBQVUsQ0FBQztRQWlCckQsRUFBRSxDQUFDLENBQUMsUUFBUSxDQUFDLENBQUMsQ0FBQztZQUNiLElBQUksQ0FBQyxPQUFPLEdBQUcsUUFBUSxDQUFDLE9BQU8sQ0FBQztZQUNoQyxJQUFJLENBQUMsS0FBSyxHQUFHLFFBQVEsQ0FBQyxLQUFLLENBQUM7WUFDNUIsSUFBSSxDQUFDLElBQUksR0FBRyxRQUFRLENBQUMsSUFBSSxDQUFDO1lBQzFCLElBQUksQ0FBQyxJQUFJLEdBQUcsUUFBUSxDQUFDLElBQUksQ0FBQztZQUMxQixJQUFJLENBQUMsS0FBSyxHQUFHLFFBQVEsQ0FBQyxLQUFLLENBQUM7UUFDOUIs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O1FBQ3hCLE1BQU07R0ExQlgsa0JBQWtCLENBNkg5QjtTQTdIWSxrQkFBa0IiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQge1xuICBBZnRlclZpZXdJbml0LFxuICBDb21wb25lbnQsXG4gIEVsZW1lbnRSZWYsXG4gIEV2ZW50RW1pdHRlcixcbiAgSG9zdEJpbmRpbmcsXG4gIEluamVjdCxcbiAgSW5wdXQsXG4gIE5nWm9uZSxcbiAgT25EZXN0cm95LFxuICBPcHRpb25hbCxcbiAgT3V0cHV0LFxufSBmcm9tICdAYW5ndWxhci9jb3JlJztcbmltcG9ydCB7IFN1YnNjcmlwdGlvbiB9IGZyb20gJ3J4anMnO1xuXG5pbXBvcnQgeyBSZWNhcHRjaGFMb2FkZXJTZXJ2aWNlIH0gZnJvbSAnLi9yZWNhcHRjaGEtbG9hZGVyLnNlcnZpY2UnO1xuaW1wb3J0IHsgUkVDQVBUQ0hBX1NFVFRJTkdTLCBSZWNhcHRjaGFTZXR0aW5ncyB9IGZyb20gJy4vcmVjYXB0Y2hhLXNldHRpbmdzJztcblxubGV0IG5leHRJZCA9IDA7XG5cbkBDb21wb25lbnQoe1xuICBleHBvcnRBczogJ3JlQ2FwdGNoYScsXG4gIHNlbGVjdG9yOiAncmUtY2FwdGNoYScsXG4gIHRlbXBsYXRlOiBgYCxcbn0pXG5leHBvcnQgY2xhc3MgUmVjYXB0Y2hhQ29tcG9uZW50IGltcGxlbWVudHMgQWZ0ZXJWaWV3SW5pdCwgT25EZXN0cm95IHtcbiAgQElucHV0KClcbiAgQEhvc3RCaW5kaW5nKCdhdHRyLmlkJylcbiAgcHVibGljIGlkID0gYG5ncmVjYXB0Y2hhLSR7bmV4dElkKyt9YDtcblxuICBASW5wdXQoKSBwdWJsaWMgc2l0ZUtleTogc3RyaW5nO1xuICBASW5wdXQoKSBwdWJsaWMgdGhlbWU6IFJlQ2FwdGNoYVYyLlRoZW1lO1xuICBASW5wdXQoKSBwdWJsaWMgdHlwZTogUmVDYXB0Y2hhVjIuVHlwZTtcbiAgQElucHV0KCkgcHVibGljIHNpemU6IFJlQ2FwdGNoYVYyLlNpemU7XG4gIEBJbnB1dCgpIHB1YmxpYyB0YWJJbmRleDogbnVtYmVyO1xuICBASW5wdXQoKSBwdWJsaWMgYmFkZ2U6IFJlQ2FwdGNoYVYyLkJhZGdlO1xuXG4gIEBPdXRwdXQoKSBwdWJsaWMgcmVzb2x2ZWQgPSBuZXcgRXZlbnRFbWl0dGVyPHN0cmluZz4oKTtcblxuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgc3Vic2NyaXB0aW9uOiBTdWJzY3JpcHRpb247XG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSB3aWRnZXQ6IG51bWJlcjtcbiAgLyoqIEBpbnRlcm5hbCAqL1xuICBwcml2YXRlIGdyZWNhcHRjaGE6IFJlQ2FwdGNoYVYyLlJlQ2FwdGNoYTtcbiAgLyoqIEBpbnRlcm5hbCAqL1xuICBwcml2YXRlIGV4ZWN1dGVSZXF1ZXN0ZWQ6IGJvb2xlYW47XG5cbiAgY29uc3RydWN0b3IoXG4gICAgcHJpdmF0ZSBlbGVtZW50UmVmOiBFbGVtZW50UmVmLFxuICAgIHByaXZhdGUgbG9hZGVyOiBSZWNhcHRjaGFMb2FkZXJTZXJ2aWNlLFxuICAgIHByaXZhdGUgem9uZTogTmdab25lLFxuICAgIEBPcHRpb25hbCgpIEBJbmplY3QoUkVDQVBUQ0hBX1NFVFRJTkdTKSBzZXR0aW5ncz86IFJlY2FwdGNoYVNldHRpbmdzLFxuICApIHtcbiAgICBpZiAoc2V0dGluZ3MpIHtcbiAgICAgIHRoaXMuc2l0ZUtleSA9IHNldHRpbmdzLnNpdGVLZXk7XG4gICAgICB0aGlzLnRoZW1lID0gc2V0dGluZ3MudGhlbWU7XG4gICAgICB0aGlzLnR5cGUgPSBzZXR0aW5ncy50eXBlO1xuICAgICAgdGhpcy5zaXplID0gc2V0dGluZ3Muc2l6ZTtcbiAgICAgIHRoaXMuYmFkZ2UgPSBzZXR0aW5ncy5iYWRnZTtcbiAgICB9XG4gIH1cblxuICBwdWJsaWMgbmdBZnRlclZpZXdJbml0KCkge1xuICAgIHRoaXMuc3Vic2NyaXB0aW9uID0gdGhpcy5sb2FkZXIucmVhZHkuc3Vic2NyaWJlKChncmVjYXB0Y2hhOiBSZUNhcHRjaGFWMi5SZUNhcHRjaGEpID0+IHtcbiAgICAgIGlmIChncmVjYXB0Y2hhICE9IG51bGwgJiYgZ3JlY2FwdGNoYS5yZW5kZXIgaW5zdGFuY2VvZiBGdW5jdGlvbikge1xuICAgICAgICB0aGlzLmdyZWNhcHRjaGEgPSBncmVjYXB0Y2hhO1xuICAgICAgICB0aGlzLnJlbmRlclJlY2FwdGNoYSgpO1xuICAgICAgfVxuICAgIH0pO1xuICB9XG5cbiAgcHVibGljIG5nT25EZXN0cm95KCkge1xuICAgIC8vIHJlc2V0IHRoZSBjYXB0Y2hhIHRvIGVuc3VyZSBpdCBkb2VzIG5vdCBsZWF2ZSBhbnl0aGluZyBiZWhpbmRcbiAgICAvLyBhZnRlciB0aGUgY29tcG9uZW50IGlzIG5vIGxvbmdlciBuZWVkZWRcbiAgICB0aGlzLmdyZWNhcHRjaGFSZXNldCgpO1xuICAgIGlmICh0aGlzLnN1YnNjcmlwdGlvbikge1xuICAgICAgdGhpcy5zdWJzY3JpcHRpb24udW5zdWJzY3JpYmUoKTtcbiAgICB9XG4gIH1cblxuICAvKipcbiAgICogRXhlY3V0ZXMgdGhlIGludmlzaWJsZSByZWNhcHRjaGEuXG4gICAqIERvZXMgbm90aGluZyBpZiBjb21wb25lbnQncyBzaXplIGlzIG5vdCBzZXQgdG8gXCJpbnZpc2libGVcIi5cbiAgICovXG4gIHB1YmxpYyBleGVjdXRlKCk6IHZvaWQge1xuICAgIGlmICh0aGlzLnNpemUgIT09ICdpbnZpc2libGUnKSB7XG4gICAgICByZXR1cm47XG4gICAgfVxuXG4gICAgaWYgKHRoaXMud2lkZ2V0ICE9IG51bGwpIHtcbiAgICAgIHRoaXMuZ3JlY2FwdGNoYS5leGVjdXRlKHRoaXMud2lkZ2V0KTtcbiAgICB9IGVsc2Uge1xuICAgICAgLy8gZGVsYXkgZXhlY3V0aW9uIG9mIHJlY2FwdGNoYSB1bnRpbCBpdCBhY3R1YWxseSByZW5kZXJzXG4gICAgICB0aGlzLmV4ZWN1dGVSZXF1ZXN0ZWQgPSB0cnVlO1xuICAgIH1cbiAgfVxuXG4gIHB1YmxpYyByZXNldCgpIHtcbiAgICBpZiAodGhpcy53aWRnZXQgIT0gbnVsbCkge1xuICAgICAgaWYgKHRoaXMuZ3JlY2FwdGNoYS5nZXRSZXNwb25zZSh0aGlzLndpZGdldCkpIHtcbiAgICAgICAgLy8gT25seSBlbWl0IGFuIGV2ZW50IGluIGNhc2UgaWYgc29tZXRoaW5nIHdvdWxkIGFjdHVhbGx5IGNoYW5nZS5cbiAgICAgICAgLy8gVGhhdCB3YXkgd2UgZG8gbm90IHRyaWdnZXIgXCJ0b3VjaGluZ1wiIG9mIHRoZSBjb250cm9sIGlmIHNvbWVvbmUgZG9lcyBhIFwicmVzZXRcIlxuICAgICAgICAvLyBvbiBhIG5vbi1yZXNvbHZlZCBjYXB0Y2hhLlxuICAgICAgICB0aGlzLnJlc29sdmVkLmVtaXQobnVsbCk7XG4gICAgICB9XG5cbiAgICAgIHRoaXMuZ3JlY2FwdGNoYVJlc2V0KCk7XG4gICAgfVxuICB9XG5cbiAgLyoqIEBpbnRlcm5hbCAqL1xuICBwcml2YXRlIGV4cGlyZWQoKSB7XG4gICAgdGhpcy5yZXNvbHZlZC5lbWl0KG51bGwpO1xuICB9XG5cbiAgLyoqIEBpbnRlcm5hbCAqL1xuICBwcml2YXRlIGNhcHRjaGFSZXNwb25zZUNhbGxiYWNrKHJlc3BvbnNlOiBzdHJpbmcpIHtcbiAgICB0aGlzLnJlc29sdmVkLmVtaXQocmVzcG9uc2UpO1xuICB9XG5cbiAgLyoqIEBpbnRlcm5hbCAqL1xuICBwcml2YXRlIGdyZWNhcHRjaGFSZXNldCgpIHtcbiAgICBpZiAodGhpcy53aWRnZXQgIT0gbnVsbCkge1xuICAgICAgdGhpcy56b25lLnJ1bk91dHNpZGVBbmd1bGFyKCgpID0+IHRoaXMuZ3JlY2FwdGNoYS5yZXNldCh0aGlzLndpZGdldCkpO1xuICAgIH1cbiAgfVxuXG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSByZW5kZXJSZWNhcHRjaGEoKSB7XG4gICAgdGhpcy53aWRnZXQgPSB0aGlzLmdyZWNhcHRjaGEucmVuZGVyKHRoaXMuZWxlbWVudFJlZi5uYXRpdmVFbGVtZW50LCB7XG4gICAgICBiYWRnZTogdGhpcy5iYWRnZSxcbiAgICAgIGNhbGxiYWNrOiAocmVzcG9uc2U6IHN0cmluZykgPT4ge1xuICAgICAgICB0aGlzLnpvbmUucnVuKCgpID0+IHRoaXMuY2FwdGNoYVJlc3BvbnNlQ2FsbGJhY2socmVzcG9uc2UpKTtcbiAgICAgIH0sXG4gICAgICAnZXhwaXJlZC1jYWxsYmFjayc6ICgpID0+IHtcbiAgICAgICAgdGhpcy56b25lLnJ1bigoKSA9PiB0aGlzLmV4cGlyZWQoKSk7XG4gICAgICB9LFxuICAgICAgc2l0ZWtleTogdGhpcy5zaXRlS2V5LFxuICAgICAgc2l6ZTogdGhpcy5zaXplLFxuICAgICAgdGFiaW5kZXg6IHRoaXMudGFiSW5kZXgsXG4gICAgICB0aGVtZTogdGhpcy50aGVtZSxcbiAgICAgIHR5cGU6IHRoaXMudHlwZSxcbiAgICB9KTtcblxuICAgIGlmICh0aGlzLmV4ZWN1dGVSZXF1ZXN0ZWQgPT09IHRydWUpIHtcbiAgICAgIHRoaXMuZXhlY3V0ZVJlcXVlc3RlZCA9IGZhbHNlO1xuICAgICAgdGhpcy5leGVjdXRlKCk7XG4gICAgfVxuICB9XG59XG4iXX0=