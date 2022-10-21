import * as tslib_1 from "tslib";
import { Component, ElementRef, EventEmitter, HostBinding, Inject, Input, NgZone, Optional, Output, } from '@angular/core';
import { RecaptchaLoaderService } from './recaptcha-loader.service';
import { RECAPTCHA_SETTINGS } from './recaptcha-settings';
var nextId = 0;
var RecaptchaComponent = /** @class */ (function () {
    function RecaptchaComponent(elementRef, loader, zone, settings) {
        this.elementRef = elementRef;
        this.loader = loader;
        this.zone = zone;
        this.id = "ngrecaptcha-" + nextId++;
        this.resolved = new EventEmitter();
        if (settings) {
            this.siteKey = settings.siteKey;
            this.theme = settings.theme;
            this.type = settings.type;
            this.size = settings.size;
            this.badge = settings.badge;
        }
    }
    RecaptchaComponent.prototype.ngAfterViewInit = function () {
        var _this = this;
        this.subscription = this.loader.ready.subscribe(function (grecaptcha) {
            if (grecaptcha != null && grecaptcha.render instanceof Function) {
                _this.grecaptcha = grecaptcha;
                _this.renderRecaptcha();
            }
        });
    };
    RecaptchaComponent.prototype.ngOnDestroy = function () {
        // reset the captcha to ensure it does not leave anything behind
        // after the component is no longer needed
        this.grecaptchaReset();
        if (this.subscription) {
            this.subscription.unsubscribe();
        }
    };
    /**
     * Executes the invisible recaptcha.
     * Does nothing if component's size is not set to "invisible".
     */
    RecaptchaComponent.prototype.execute = function () {
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
    };
    RecaptchaComponent.prototype.reset = function () {
        if (this.widget != null) {
            if (this.grecaptcha.getResponse(this.widget)) {
                // Only emit an event in case if something would actually change.
                // That way we do not trigger "touching" of the control if someone does a "reset"
                // on a non-resolved captcha.
                this.resolved.emit(null);
            }
            this.grecaptchaReset();
        }
    };
    /** @internal */
    RecaptchaComponent.prototype.expired = function () {
        this.resolved.emit(null);
    };
    /** @internal */
    RecaptchaComponent.prototype.captchaResponseCallback = function (response) {
        this.resolved.emit(response);
    };
    /** @internal */
    RecaptchaComponent.prototype.grecaptchaReset = function () {
        var _this = this;
        if (this.widget != null) {
            this.zone.runOutsideAngular(function () { return _this.grecaptcha.reset(_this.widget); });
        }
    };
    /** @internal */
    RecaptchaComponent.prototype.renderRecaptcha = function () {
        var _this = this;
        this.widget = this.grecaptcha.render(this.elementRef.nativeElement, {
            badge: this.badge,
            callback: function (response) {
                _this.zone.run(function () { return _this.captchaResponseCallback(response); });
            },
            'expired-callback': function () {
                _this.zone.run(function () { return _this.expired(); });
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
            template: ""
        }),
        tslib_1.__param(3, Optional()), tslib_1.__param(3, Inject(RECAPTCHA_SETTINGS)),
        tslib_1.__metadata("design:paramtypes", [ElementRef,
            RecaptchaLoaderService,
            NgZone, Object])
    ], RecaptchaComponent);
    return RecaptchaComponent;
}());
export { RecaptchaComponent };
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoicmVjYXB0Y2hhLmNvbXBvbmVudC5qcyIsInNvdXJjZVJvb3QiOiJuZzovL25nLXJlY2FwdGNoYS8iLCJzb3VyY2VzIjpbInJlY2FwdGNoYS9yZWNhcHRjaGEuY29tcG9uZW50LnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQSxPQUFPLEVBRUwsU0FBUyxFQUNULFVBQVUsRUFDVixZQUFZLEVBQ1osV0FBVyxFQUNYLE1BQU0sRUFDTixLQUFLLEVBQ0wsTUFBTSxFQUVOLFFBQVEsRUFDUixNQUFNLEdBQ1AsTUFBTSxlQUFlLENBQUM7QUFHdkIsT0FBTyxFQUFFLHNCQUFzQixFQUFFLE1BQU0sNEJBQTRCLENBQUM7QUFDcEUsT0FBTyxFQUFFLGtCQUFrQixFQUFxQixNQUFNLHNCQUFzQixDQUFDO0FBRTdFLElBQUksTUFBTSxHQUFHLENBQUMsQ0FBQztBQU9mO0lBdUJFLDRCQUNVLFVBQXNCLEVBQ3RCLE1BQThCLEVBQzlCLElBQVksRUFDb0IsUUFBNEI7UUFINUQsZUFBVSxHQUFWLFVBQVUsQ0FBWTtRQUN0QixXQUFNLEdBQU4sTUFBTSxDQUF3QjtRQUM5QixTQUFJLEdBQUosSUFBSSxDQUFRO1FBdkJmLE9BQUUsR0FBRyxpQkFBZSxNQUFNLEVBQUksQ0FBQztRQVNyQixhQUFRLEdBQUcsSUFBSSxZQUFZLEVBQVUsQ0FBQztRQWlCckQsRUFBRSxDQUFDLENBQUMsUUFBUSxDQUFDLENBQUMsQ0FBQztZQUNiLElBQUksQ0FBQyxPQUFPLEdBQUcsUUFBUSxDQUFDLE9BQU8sQ0FBQztZQUNoQyxJQUFJLENBQUMsS0FBSyxHQUFHLFFBQVEsQ0FBQyxLQUFLLENBQUM7WUFDNUIsSUFBSSxDQUFDLElBQUksR0FBRyxRQUFRLENBQUMsSUFBSSxDQUFDO1lBQzFCLElBQUksQ0FBQyxJQUFJLEdBQUcsUUFBUSxDQUFDLElBQUksQ0FBQztZQUMxQixJQUFJLENBQUMsS0FBSyxHQUFHLFFBQVEsQ0FBQyxLQUFLLENBQUM7UUFDOUIsQ0FBQztJQUNILENBQUM7SUFFTSw0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QyxrQkFBa0IsQ0FBQyxDQUFBO2lEQUhuQixVQUFVO1lBQ2Qsc0JBQXNCO1lBQ3hCLE1BQU07T0ExQlgsa0JBQWtCLENBNkg5QjtJQUFELHlCQUFDO0NBQUEsQUE3SEQsSUE2SEM7U0E3SFksa0JBQWtCIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHtcbiAgQWZ0ZXJWaWV3SW5pdCxcbiAgQ29tcG9uZW50LFxuICBFbGVtZW50UmVmLFxuICBFdmVudEVtaXR0ZXIsXG4gIEhvc3RCaW5kaW5nLFxuICBJbmplY3QsXG4gIElucHV0LFxuICBOZ1pvbmUsXG4gIE9uRGVzdHJveSxcbiAgT3B0aW9uYWwsXG4gIE91dHB1dCxcbn0gZnJvbSAnQGFuZ3VsYXIvY29yZSc7XG5pbXBvcnQgeyBTdWJzY3JpcHRpb24gfSBmcm9tICdyeGpzJztcblxuaW1wb3J0IHsgUmVjYXB0Y2hhTG9hZGVyU2VydmljZSB9IGZyb20gJy4vcmVjYXB0Y2hhLWxvYWRlci5zZXJ2aWNlJztcbmltcG9ydCB7IFJFQ0FQVENIQV9TRVRUSU5HUywgUmVjYXB0Y2hhU2V0dGluZ3MgfSBmcm9tICcuL3JlY2FwdGNoYS1zZXR0aW5ncyc7XG5cbmxldCBuZXh0SWQgPSAwO1xuXG5AQ29tcG9uZW50KHtcbiAgZXhwb3J0QXM6ICdyZUNhcHRjaGEnLFxuICBzZWxlY3RvcjogJ3JlLWNhcHRjaGEnLFxuICB0ZW1wbGF0ZTogYGAsXG59KVxuZXhwb3J0IGNsYXNzIFJlY2FwdGNoYUNvbXBvbmVudCBpbXBsZW1lbnRzIEFmdGVyVmlld0luaXQsIE9uRGVzdHJveSB7XG4gIEBJbnB1dCgpXG4gIEBIb3N0QmluZGluZygnYXR0ci5pZCcpXG4gIHB1YmxpYyBpZCA9IGBuZ3JlY2FwdGNoYS0ke25leHRJZCsrfWA7XG5cbiAgQElucHV0KCkgcHVibGljIHNpdGVLZXk6IHN0cmluZztcbiAgQElucHV0KCkgcHVibGljIHRoZW1lOiBSZUNhcHRjaGFWMi5UaGVtZTtcbiAgQElucHV0KCkgcHVibGljIHR5cGU6IFJlQ2FwdGNoYVYyLlR5cGU7XG4gIEBJbnB1dCgpIHB1YmxpYyBzaXplOiBSZUNhcHRjaGFWMi5TaXplO1xuICBASW5wdXQoKSBwdWJsaWMgdGFiSW5kZXg6IG51bWJlcjtcbiAgQElucHV0KCkgcHVibGljIGJhZGdlOiBSZUNhcHRjaGFWMi5CYWRnZTtcblxuICBAT3V0cHV0KCkgcHVibGljIHJlc29sdmVkID0gbmV3IEV2ZW50RW1pdHRlcjxzdHJpbmc+KCk7XG5cbiAgLyoqIEBpbnRlcm5hbCAqL1xuICBwcml2YXRlIHN1YnNjcmlwdGlvbjogU3Vic2NyaXB0aW9uO1xuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgd2lkZ2V0OiBudW1iZXI7XG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSBncmVjYXB0Y2hhOiBSZUNhcHRjaGFWMi5SZUNhcHRjaGE7XG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSBleGVjdXRlUmVxdWVzdGVkOiBib29sZWFuO1xuXG4gIGNvbnN0cnVjdG9yKFxuICAgIHByaXZhdGUgZWxlbWVudFJlZjogRWxlbWVudFJlZixcbiAgICBwcml2YXRlIGxvYWRlcjogUmVjYXB0Y2hhTG9hZGVyU2VydmljZSxcbiAgICBwcml2YXRlIHpvbmU6IE5nWm9uZSxcbiAgICBAT3B0aW9uYWwoKSBASW5qZWN0KFJFQ0FQVENIQV9TRVRUSU5HUykgc2V0dGluZ3M/OiBSZWNhcHRjaGFTZXR0aW5ncyxcbiAgKSB7XG4gICAgaWYgKHNldHRpbmdzKSB7XG4gICAgICB0aGlzLnNpdGVLZXkgPSBzZXR0aW5ncy5zaXRlS2V5O1xuICAgICAgdGhpcy50aGVtZSA9IHNldHRpbmdzLnRoZW1lO1xuICAgICAgdGhpcy50eXBlID0gc2V0dGluZ3MudHlwZTtcbiAgICAgIHRoaXMuc2l6ZSA9IHNldHRpbmdzLnNpemU7XG4gICAgICB0aGlzLmJhZGdlID0gc2V0dGluZ3MuYmFkZ2U7XG4gICAgfVxuICB9XG5cbiAgcHVibGljIG5nQWZ0ZXJWaWV3SW5pdCgpIHtcbiAgICB0aGlzLnN1YnNjcmlwdGlvbiA9IHRoaXMubG9hZGVyLnJlYWR5LnN1YnNjcmliZSgoZ3JlY2FwdGNoYTogUmVDYXB0Y2hhVjIuUmVDYXB0Y2hhKSA9PiB7XG4gICAgICBpZiAoZ3JlY2FwdGNoYSAhPSBudWxsICYmIGdyZWNhcHRjaGEucmVuZGVyIGluc3RhbmNlb2YgRnVuY3Rpb24pIHtcbiAgICAgICAgdGhpcy5ncmVjYXB0Y2hhID0gZ3JlY2FwdGNoYTtcbiAgICAgICAgdGhpcy5yZW5kZXJSZWNhcHRjaGEoKTtcbiAgICAgIH1cbiAgICB9KTtcbiAgfVxuXG4gIHB1YmxpYyBuZ09uRGVzdHJveSgpIHtcbiAgICAvLyByZXNldCB0aGUgY2FwdGNoYSB0byBlbnN1cmUgaXQgZG9lcyBub3QgbGVhdmUgYW55dGhpbmcgYmVoaW5kXG4gICAgLy8gYWZ0ZXIgdGhlIGNvbXBvbmVudCBpcyBubyBsb25nZXIgbmVlZGVkXG4gICAgdGhpcy5ncmVjYXB0Y2hhUmVzZXQoKTtcbiAgICBpZiAodGhpcy5zdWJzY3JpcHRpb24pIHtcbiAgICAgIHRoaXMuc3Vic2NyaXB0aW9uLnVuc3Vic2NyaWJlKCk7XG4gICAgfVxuICB9XG5cbiAgLyoqXG4gICAqIEV4ZWN1dGVzIHRoZSBpbnZpc2libGUgcmVjYXB0Y2hhLlxuICAgKiBEb2VzIG5vdGhpbmcgaWYgY29tcG9uZW50J3Mgc2l6ZSBpcyBub3Qgc2V0IHRvIFwiaW52aXNpYmxlXCIuXG4gICAqL1xuICBwdWJsaWMgZXhlY3V0ZSgpOiB2b2lkIHtcbiAgICBpZiAodGhpcy5zaXplICE9PSAnaW52aXNpYmxlJykge1xuICAgICAgcmV0dXJuO1xuICAgIH1cblxuICAgIGlmICh0aGlzLndpZGdldCAhPSBudWxsKSB7XG4gICAgICB0aGlzLmdyZWNhcHRjaGEuZXhlY3V0ZSh0aGlzLndpZGdldCk7XG4gICAgfSBlbHNlIHtcbiAgICAgIC8vIGRlbGF5IGV4ZWN1dGlvbiBvZiByZWNhcHRjaGEgdW50aWwgaXQgYWN0dWFsbHkgcmVuZGVyc1xuICAgICAgdGhpcy5leGVjdXRlUmVxdWVzdGVkID0gdHJ1ZTtcbiAgICB9XG4gIH1cblxuICBwdWJsaWMgcmVzZXQoKSB7XG4gICAgaWYgKHRoaXMud2lkZ2V0ICE9IG51bGwpIHtcbiAgICAgIGlmICh0aGlzLmdyZWNhcHRjaGEuZ2V0UmVzcG9uc2UodGhpcy53aWRnZXQpKSB7XG4gICAgICAgIC8vIE9ubHkgZW1pdCBhbiBldmVudCBpbiBjYXNlIGlmIHNvbWV0aGluZyB3b3VsZCBhY3R1YWxseSBjaGFuZ2UuXG4gICAgICAgIC8vIFRoYXQgd2F5IHdlIGRvIG5vdCB0cmlnZ2VyIFwidG91Y2hpbmdcIiBvZiB0aGUgY29udHJvbCBpZiBzb21lb25lIGRvZXMgYSBcInJlc2V0XCJcbiAgICAgICAgLy8gb24gYSBub24tcmVzb2x2ZWQgY2FwdGNoYS5cbiAgICAgICAgdGhpcy5yZXNvbHZlZC5lbWl0KG51bGwpO1xuICAgICAgfVxuXG4gICAgICB0aGlzLmdyZWNhcHRjaGFSZXNldCgpO1xuICAgIH1cbiAgfVxuXG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSBleHBpcmVkKCkge1xuICAgIHRoaXMucmVzb2x2ZWQuZW1pdChudWxsKTtcbiAgfVxuXG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSBjYXB0Y2hhUmVzcG9uc2VDYWxsYmFjayhyZXNwb25zZTogc3RyaW5nKSB7XG4gICAgdGhpcy5yZXNvbHZlZC5lbWl0KHJlc3BvbnNlKTtcbiAgfVxuXG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSBncmVjYXB0Y2hhUmVzZXQoKSB7XG4gICAgaWYgKHRoaXMud2lkZ2V0ICE9IG51bGwpIHtcbiAgICAgIHRoaXMuem9uZS5ydW5PdXRzaWRlQW5ndWxhcigoKSA9PiB0aGlzLmdyZWNhcHRjaGEucmVzZXQodGhpcy53aWRnZXQpKTtcbiAgICB9XG4gIH1cblxuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgcmVuZGVyUmVjYXB0Y2hhKCkge1xuICAgIHRoaXMud2lkZ2V0ID0gdGhpcy5ncmVjYXB0Y2hhLnJlbmRlcih0aGlzLmVsZW1lbnRSZWYubmF0aXZlRWxlbWVudCwge1xuICAgICAgYmFkZ2U6IHRoaXMuYmFkZ2UsXG4gICAgICBjYWxsYmFjazogKHJlc3BvbnNlOiBzdHJpbmcpID0+IHtcbiAgICAgICAgdGhpcy56b25lLnJ1bigoKSA9PiB0aGlzLmNhcHRjaGFSZXNwb25zZUNhbGxiYWNrKHJlc3BvbnNlKSk7XG4gICAgICB9LFxuICAgICAgJ2V4cGlyZWQtY2FsbGJhY2snOiAoKSA9PiB7XG4gICAgICAgIHRoaXMuem9uZS5ydW4oKCkgPT4gdGhpcy5leHBpcmVkKCkpO1xuICAgICAgfSxcbiAgICAgIHNpdGVrZXk6IHRoaXMuc2l0ZUtleSxcbiAgICAgIHNpemU6IHRoaXMuc2l6ZSxcbiAgICAgIHRhYmluZGV4OiB0aGlzLnRhYkluZGV4LFxuICAgICAgdGhlbWU6IHRoaXMudGhlbWUsXG4gICAgICB0eXBlOiB0aGlzLnR5cGUsXG4gICAgfSk7XG5cbiAgICBpZiAodGhpcy5leGVjdXRlUmVxdWVzdGVkID09PSB0cnVlKSB7XG4gICAgICB0aGlzLmV4ZWN1dGVSZXF1ZXN0ZWQgPSBmYWxzZTtcbiAgICAgIHRoaXMuZXhlY3V0ZSgpO1xuICAgIH1cbiAgfVxufVxuIl19