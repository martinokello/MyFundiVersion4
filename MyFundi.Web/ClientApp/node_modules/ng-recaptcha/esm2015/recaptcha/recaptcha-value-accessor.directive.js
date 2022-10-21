import * as tslib_1 from "tslib";
import { Directive, forwardRef, HostListener, } from '@angular/core';
import { NG_VALUE_ACCESSOR, } from '@angular/forms';
import { RecaptchaComponent } from './recaptcha.component';
let RecaptchaValueAccessorDirective = RecaptchaValueAccessorDirective_1 = class RecaptchaValueAccessorDirective {
    constructor(host) {
        this.host = host;
    }
    writeValue(value) {
        if (!value) {
            this.host.reset();
        }
    }
    registerOnChange(fn) { this.onChange = fn; }
    registerOnTouched(fn) { this.onTouched = fn; }
    onResolve($event) {
        if (this.onChange) {
            this.onChange($event);
        }
        if (this.onTouched) {
            this.onTouched();
        }
    }
};
tslib_1.__decorate([
    HostListener('resolved', ['$event']),
    tslib_1.__metadata("design:type", Function),
    tslib_1.__metadata("design:paramtypes", [String]),
    tslib_1.__metadata("design:returntype", void 0)
], RecaptchaValueAccessorDirective.prototype, "onResolve", null);
RecaptchaValueAccessorDirective = RecaptchaValueAccessorDirective_1 = tslib_1.__decorate([
    Directive({
        providers: [
            {
                multi: true,
                provide: NG_VALUE_ACCESSOR,
                // tslint:disable-next-line:no-forward-ref
                useExisting: forwardRef(() => RecaptchaValueAccessorDirective_1),
            },
        ],
        // tslint:disable-next-line:directive-selector
        selector: 're-captcha[formControlName],re-captcha[formControl],re-captcha[ngModel]',
    }),
    tslib_1.__metadata("design:paramtypes", [RecaptchaComponent])
], RecaptchaValueAccessorDirective);
export { RecaptchaValueAccessorDirective };
var RecaptchaValueAccessorDirective_1;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoicmVjYXB0Y2hhLXZhbHVlLWFjY2Vzc29yLmRpcmVjdGl2ZS5qcyIsInNvdXJjZVJvb3QiOiJuZzovL25nLXJlY2FwdGNoYS8iLCJzb3VyY2VzIjpbInJlY2FwdGNoYS9yZWNhcHRjaGEtdmFsdWUtYWNjZXNzb3IuZGlyZWN0aXZlLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQSxPQUFPLEVBQ0wsU0FBUyxFQUNULFVBQVUsRUFDVixZQUFZLEdBQ2IsTUFBTSxlQUFlLENBQUM7QUFDdkIsT0FBTyxFQUVMLGlCQUFpQixHQUNsQixNQUFNLGdCQUFnQixDQUFDO0FBRXhCLE9BQU8sRUFBRSxrQkFBa0IsRUFBRSxNQUFNLHVCQUF1QixDQUFDO0FBYzNELElBQWEsK0JBQStCLHVDQUE1QztJQU9FLFlBQW9CLElBQXdCO1FBQXhCLFNBQUksR0FBSixJQUFJLENBQW9CO0lBQUksQ0FBQztJQUUxQyxVQUFVLENBQUMsS0FBYTtRQUM3QixFQUFFLENBQUMsQ0FBQyxDQUFDLEtBQUssQ0FBQyxDQUFDLENBQUM7WUFDWCxJQUFJLENBQUMsSUFBSSxDQUFDLEtBQUssRUFBRSxDQUFDO1FBQ3BCLENBQUM7SUFDSCxDQUFDO0lBRU0sZ0JBQWdCLENBQUMsRUFBMkIsSUFBVSxJQUFJLENBQUMsUUFBUSxHQUFHLEVBQUUsQ0FBQyxDQUFDLENBQUM7SUFDM0UsaUJBQWlCLENBQUMsRUFBYyxJQUFVLElBQUksQ0FBQyxTQUFTLEdBQUcsRUFBRSxDQUFDLENBQUMsQ0FBQztJQUUxQixTQUFTLENBQUMsTUFBYztRQUNuRSxFQUFFLENBQUMsQ0FBQyxJQUFJLENBQUMsUUFBUSxDQUFDLENBQUMsQ0FBQztZQUNsQixJQUFJLENBQUMsUUFBUSxDQUFDLE1BQU0sQ0FBQyxDQUFDO1FBQ3hCLENBQUM7UUFDRCxFQUFFLENBQUMsQ0FBQyxJQUFJLENBQUMsU0FBUyxDQUFDLENBQUMsQ0FBQztZQUNuQixJQUFJLENBQUMsU0FBUyxFQUFFLENBQUM7UUFDbkIsQ0FBQztJQUNILENBQUM7Q0FDRixDQUFBO0FBUnVDO0lBQXJDLFlBQVksQ0FBQyxVQUFVLEVBQUUsQ0FBQyxRQUFRLENBQUMsQ0FBQzs7OztnRUFPcEM7QUF6QlUsK0JBQStCO0lBWjNDLFNBQVMsQ0FBQztRQUNULFNBQVMsRUFBRTtZQUNUO2dCQUNFLEtBQUssRUFBRSxJQUFJO2dCQUNYLE9BQU8sRUFBRSxpQkFBaUI7Z0JBQzFCLDBDQUEwQztnQkFDMUMsV0FBVyxFQUFFLFVBQVUsQ0FBQyxHQUFHLEVBQUUsQ0FBQyxpQ0FBK0IsQ0FBQzthQUMvRDtTQUNGO1FBQ0QsOENBQThDO1FBQzlDLFFBQVEsRUFBRSx5RUFBeUU7S0FDcEYsQ0FBQzs2Q0FRMEIsa0JBQWtCO0dBUGpDLCtCQUErQixDQTBCM0M7U0ExQlksK0JBQStCIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHtcbiAgRGlyZWN0aXZlLFxuICBmb3J3YXJkUmVmLFxuICBIb3N0TGlzdGVuZXIsXG59IGZyb20gJ0Bhbmd1bGFyL2NvcmUnO1xuaW1wb3J0IHtcbiAgQ29udHJvbFZhbHVlQWNjZXNzb3IsXG4gIE5HX1ZBTFVFX0FDQ0VTU09SLFxufSBmcm9tICdAYW5ndWxhci9mb3Jtcyc7XG5cbmltcG9ydCB7IFJlY2FwdGNoYUNvbXBvbmVudCB9IGZyb20gJy4vcmVjYXB0Y2hhLmNvbXBvbmVudCc7XG5cbkBEaXJlY3RpdmUoe1xuICBwcm92aWRlcnM6IFtcbiAgICB7XG4gICAgICBtdWx0aTogdHJ1ZSxcbiAgICAgIHByb3ZpZGU6IE5HX1ZBTFVFX0FDQ0VTU09SLFxuICAgICAgLy8gdHNsaW50OmRpc2FibGUtbmV4dC1saW5lOm5vLWZvcndhcmQtcmVmXG4gICAgICB1c2VFeGlzdGluZzogZm9yd2FyZFJlZigoKSA9PiBSZWNhcHRjaGFWYWx1ZUFjY2Vzc29yRGlyZWN0aXZlKSxcbiAgICB9LFxuICBdLFxuICAvLyB0c2xpbnQ6ZGlzYWJsZS1uZXh0LWxpbmU6ZGlyZWN0aXZlLXNlbGVjdG9yXG4gIHNlbGVjdG9yOiAncmUtY2FwdGNoYVtmb3JtQ29udHJvbE5hbWVdLHJlLWNhcHRjaGFbZm9ybUNvbnRyb2xdLHJlLWNhcHRjaGFbbmdNb2RlbF0nLFxufSlcbmV4cG9ydCBjbGFzcyBSZWNhcHRjaGFWYWx1ZUFjY2Vzc29yRGlyZWN0aXZlIGltcGxlbWVudHMgQ29udHJvbFZhbHVlQWNjZXNzb3Ige1xuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgb25DaGFuZ2U6ICh2YWx1ZTogc3RyaW5nKSA9PiB2b2lkO1xuXG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSBvblRvdWNoZWQ6ICgpID0+IHZvaWQ7XG5cbiAgY29uc3RydWN0b3IocHJpdmF0ZSBob3N0OiBSZWNhcHRjaGFDb21wb25lbnQpIHsgfVxuXG4gIHB1YmxpYyB3cml0ZVZhbHVlKHZhbHVlOiBzdHJpbmcpOiB2b2lkIHtcbiAgICBpZiAoIXZhbHVlKSB7XG4gICAgICB0aGlzLmhvc3QucmVzZXQoKTtcbiAgICB9XG4gIH1cblxuICBwdWJsaWMgcmVnaXN0ZXJPbkNoYW5nZShmbjogKHZhbHVlOiBzdHJpbmcpID0+IHZvaWQpOiB2b2lkIHsgdGhpcy5vbkNoYW5nZSA9IGZuOyB9XG4gIHB1YmxpYyByZWdpc3Rlck9uVG91Y2hlZChmbjogKCkgPT4gdm9pZCk6IHZvaWQgeyB0aGlzLm9uVG91Y2hlZCA9IGZuOyB9XG5cbiAgQEhvc3RMaXN0ZW5lcigncmVzb2x2ZWQnLCBbJyRldmVudCddKSBwdWJsaWMgb25SZXNvbHZlKCRldmVudDogc3RyaW5nKSB7XG4gICAgaWYgKHRoaXMub25DaGFuZ2UpIHtcbiAgICAgIHRoaXMub25DaGFuZ2UoJGV2ZW50KTtcbiAgICB9XG4gICAgaWYgKHRoaXMub25Ub3VjaGVkKSB7XG4gICAgICB0aGlzLm9uVG91Y2hlZCgpO1xuICAgIH1cbiAgfVxufVxuIl19