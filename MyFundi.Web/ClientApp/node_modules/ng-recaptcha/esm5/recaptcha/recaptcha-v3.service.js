import * as tslib_1 from "tslib";
import { isPlatformBrowser } from '@angular/common';
import { Inject, Injectable, InjectionToken, NgZone, Optional, PLATFORM_ID } from '@angular/core';
import { Subject } from 'rxjs';
import { loadScript, RECAPTCHA_BASE_URL, RECAPTCHA_NONCE } from './recaptcha-loader.service';
export var RECAPTCHA_V3_SITE_KEY = new InjectionToken('recaptcha-v3-site-key');
/**
 * The main service for working with reCAPTCHA v3 APIs.
 *
 * Use the `execute` method for executing a single action, and
 * `onExecute` observable for listening to all actions at once.
 */
var ReCaptchaV3Service = /** @class */ (function () {
    function ReCaptchaV3Service(zone, siteKey, 
    // tslint:disable-next-line:no-any
    platformId, baseUrl, nonce) {
        var _this = this;
        /** @internal */
        this.onLoadComplete = function (grecaptcha) {
            _this.grecaptcha = grecaptcha;
            if (_this.actionBacklog && _this.actionBacklog.length > 0) {
                _this.actionBacklog.forEach(function (_a) {
                    var _b = tslib_1.__read(_a, 2), action = _b[0], subject = _b[1];
                    return _this.executeActionWithSubject(action, subject);
                });
                _this.actionBacklog = undefined;
            }
        };
        this.zone = zone;
        this.isBrowser = isPlatformBrowser(platformId);
        this.siteKey = siteKey;
        this.nonce = nonce;
        this.baseUrl = baseUrl;
        this.init();
    }
    Object.defineProperty(ReCaptchaV3Service.prototype, "onExecute", {
        get: function () {
            if (!this.onExecuteSubject) {
                this.onExecuteSubject = new Subject();
                this.onExecuteObservable = this.onExecuteSubject.asObservable();
            }
            return this.onExecuteObservable;
        },
        enumerable: true,
        configurable: true
    });
    /**
     * Executes the provided `action` with reCAPTCHA v3 API.
     * Use the emitted token value for verification purposes on the backend.
     *
     * For more information about reCAPTCHA v3 actions and tokens refer to the official documentation at
     * https://developers.google.com/recaptcha/docs/v3.
     *
     * @param {string} action the action to execute
     * @returns {Observable<string>} an `Observable` that will emit the reCAPTCHA v3 string `token` value whenever ready.
     * The returned `Observable` completes immediately after emitting a value.
     */
    ReCaptchaV3Service.prototype.execute = function (action) {
        var subject = new Subject();
        if (this.isBrowser) {
            if (!this.grecaptcha) {
                // todo: add to array of later executions
                if (!this.actionBacklog) {
                    this.actionBacklog = [];
                }
                this.actionBacklog.push([action, subject]);
            }
            else {
                this.executeActionWithSubject(action, subject);
            }
        }
        return subject.asObservable();
    };
    /** @internal */
    ReCaptchaV3Service.prototype.executeActionWithSubject = function (action, subject) {
        var _this = this;
        this.zone.runOutsideAngular(function () {
            // tslint:disable-next-line:no-any
            _this.grecaptcha.execute(_this.siteKey, { action: action }).then(function (token) {
                _this.zone.run(function () {
                    subject.next(token);
                    subject.complete();
                    if (_this.onExecuteSubject) {
                        _this.onExecuteSubject.next({ action: action, token: token });
                    }
                });
            });
        });
    };
    /** @internal */
    ReCaptchaV3Service.prototype.init = function () {
        if (this.isBrowser) {
            if ('grecaptcha' in window) {
                this.grecaptcha = grecaptcha;
            }
            else {
                loadScript(this.siteKey, this.onLoadComplete, '', this.baseUrl, this.nonce);
            }
        }
    };
    ReCaptchaV3Service = tslib_1.__decorate([
        Injectable(),
        tslib_1.__param(1, Inject(RECAPTCHA_V3_SITE_KEY)),
        tslib_1.__param(2, Inject(PLATFORM_ID)),
        tslib_1.__param(3, Optional()), tslib_1.__param(3, Inject(RECAPTCHA_BASE_URL)),
        tslib_1.__param(4, Optional()), tslib_1.__param(4, Inject(RECAPTCHA_NONCE)),
        tslib_1.__metadata("design:paramtypes", [NgZone, String, Object, String, String])
    ], ReCaptchaV3Service);
    return ReCaptchaV3Service;
}());
export { ReCaptchaV3Service };
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoicmVjYXB0Y2hhLXYzLnNlcnZpY2UuanMiLCJzb3VyY2VSb290Ijoibmc6Ly9uZy1yZWNhcHRjaGEvIiwic291cmNlcyI6WyJyZWNhcHRjaGEvcmVjYXB0Y2hhLXYzLnNlcnZpY2UudHMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLE9BQU8sRUFBRSxpQkFBaUIsRUFBRSxNQUFNLGlCQUFpQixDQUFDO0FBQ3BELE9BQU8sRUFBRSxNQUFNLEVBQUUsVUFBVSxFQUFFLGNBQWMsRUFBRSxNQUFNLEVBQUUsUUFBUSxFQUFFLFdBQVcsRUFBRSxNQUFNLGVBQWUsQ0FBQztBQUNsRyxPQUFPLEVBQWMsT0FBTyxFQUFFLE1BQU0sTUFBTSxDQUFDO0FBRTNDLE9BQU8sRUFBRSxVQUFVLEVBQUUsa0JBQWtCLEVBQUUsZUFBZSxFQUFFLE1BQU0sNEJBQTRCLENBQUM7QUFFN0YsTUFBTSxDQUFDLElBQU0scUJBQXFCLEdBQUcsSUFBSSxjQUFjLENBQVMsdUJBQXVCLENBQUMsQ0FBQztBQWV6Rjs7Ozs7R0FLRztBQUVIO0lBcUJFLDRCQUNFLElBQVksRUFDbUIsT0FBZTtJQUM5QyxrQ0FBa0M7SUFDYixVQUFlLEVBQ0ksT0FBZ0IsRUFDbkIsS0FBYztRQU5yRCxpQkFlQztRQXNFRCxnQkFBZ0I7UUFDUixtQkFBYyxHQUFHLFVBQUMsVUFBaUM7WUFDekQsS0FBSSxDQUFDLFVBQVUsR0FBRyxVQUFVLENBQUM7WUFDN0IsRUFBRSxDQUFDLENBQUMsS0FBSSxDQUFDLGFBQWEsSUFBSSxLQUFJLENBQUMsYUFBYSxDQUFDLE1BQU0sR0FBRyxDQUFDLENBQUMsQ0FBQyxDQUFDO2dCQUN4RCxLQUFJLENBQUMsYUFBYSxDQUFDLE9BQU8sQ0FBQyxVQUFDLEVBQWlCO3dCQUFqQiwwQkFBaUIsRUFBaEIsY0FBTSxFQUFFLGVBQU87b0JBQU0sT0FBQSxLQUFJLENBQUMsd0JBQXdCLENBQUMsTUFBTSxFQUFFLE9BQU8sQ0FBQztnQkFBOUMsQ0FBOEMsQ0FBQyxDQUFDO2dCQUNsRyxLQUFJLENBQUMsYUFBYSxHQUFHLFNBQVMsQ0FBQztZQUNqQyxDQUFDO1FBQ0gsQ0FBQyxDQUFBO1FBcEZDLElBQUksQ0FBQyxJQUFJLEdBQUcsSUFBSSxDQUFDO1FBQ2pCLElBQUksQ0FBQyxTQUFTLEdBQUcsaUJBQWlCLENBQUMsVUFBVSxDQUFDLENBQUM7UUFDL0MsSUFBSSxDQUFDLE9BQU8sR0FBRyxPQUFPLENBQUM7UUFDdkIsSUFBSSxDQUFDLEtBQUssR0FBRyxLQUFLLENBQUM7UUFDbkIsSUFBSSxDQUFDLE9BQU8sR0FBRyxPQUFPLENBQUM7UUFFdkIsSUFBSSxDQUFDLElBQUksRUFBRSxDQUFDO0lBQ2QsQ0FBQztJQUVELHNCQUFXLHlDQUFTO2FBQXBCO1lBQ0UsRUFBRSxDQUFDLENBQUMsQ0FBQyxJQUFJLENBQUMsZ0JBQWdCLENBQUMsQ0FBQyxDQUFDO2dCQUMzQixJQUFJLENBQUMsZ0JBQWdCLEdBQUcsSUFBSSxPQUFPLEVBQWlCLENBQUM7Z0JBQ3JELElBQUksQ0FBQyxtQkFBbUIsR0FBRyxJQUFJLENBQUMsZ0JBQWdCLENBQUMsWUFBWSxFQUFFLENBQUM7WUFDbEUsQ0FBQztZQUVELE1BQU0sQ0FBQyxJQUFJLENBQUMsbUJBQW1CLENBQUM7UUFDbEMsQ0FBQzs7O09BQUE7SUFFRDs7Ozs7Ozs7OztPQVVHO0lBQ0ksb0NBQU8sR0FBZCxVQUFlLE1BQWM7UUFDM0IsSUFBTSxPQUFPLEdBQUcsSUFBSSxPQUFPLEVBQVUsQ0FBQztRQUN0QyxFQUFFLENBQUMsQ0FBQyxJQUFJLENBQUMsU0FBUyxDQUFDLENBQUMsQ0FBQztZQUNuQixFQUFFLENBQUMsQ0FBQyxDQUFDLElBQUksQ0FBQyxVQUFVLENBQUMsQ0FBQyxDQUFDO2dCQUNyQix5Q0FBeUM7Z0JBQ3pDLEVBQUUsQ0FBQyxDQUFDLENBQUMsSUFBSSxDQUFDLGFBQWEsQ0FBQyxDQUFDLENBQUM7b0JBQ3hCLElBQUksQ0FBQyxhQUFhLEdBQUcsRUFBRSxDQUFDO2dCQUMxQixDQUFDO2dCQUVELElBQUksQ0FBQyxhQUFhLENBQUMsSUFBSSxDQUFDLENBQUMsTUFBTSxFQUFFLE9BQU8sQ0FBQyxDQUFDLENBQUM7WUFDN0MsQ0FBQztZQUFDLElBQUksQ0FBQyxDQUFDO2dCQUNOLElBQUksQ0FBQyx3QkFBd0IsQ0FBQyxNQUFNLEVBQUUsT0FBTyxDQUFDLENBQUM7WUFDakQsQ0FBQztRQUNILENBQUM7UUFFRCxNQUFNLENBQUMsT0FBTyxDQUFDLFlBQVksRUFBRSxDQUFDO0lBQ2hDLENBQUM7SUFFRCxnQkFBZ0I7SUFDUixxREFBd0IsR0FBaEMsVUFBaUMsTUFBYyxFQUFFLE9BQXdCO1FBQXpFLGlCQWdCQztRQWZDLElBQUksQ0FBQyxJQUFJLENBQUMsaUJBQWlCLENBQUM7WUFDMUIsa0NBQWtDO1lBQ2pDLEtBQUksQ0FBQyxVQUFVLENBQUMsT0FBZSxDQUM5QixLQUFJLENBQUMsT0FBTyxFQUNaLEVBQUUsTUFBTSxRQUFBLEVBQUUsQ0FDWCxDQUFDLElBQUksQ0FBQyxVQUFDLEtBQWE7Z0JBQ25CLEtBQUksQ0FBQyxJQUFJLENBQUMsR0FBRyxDQUFDO29CQUNaLE9BQU8sQ0FBQyxJQUFJLENBQUMsS0FBSyxDQUFDLENBQUM7b0JBQ3BCLE9BQU8sQ0FBQyxRQUFRLEVBQUUsQ0FBQztvQkFDbkIsRUFBRSxDQUFDLENBQUMsS0FBSSxDQUFDLGdCQUFnQixDQUFDLENBQUMsQ0FBQzt3QkFDMUIsS0FBSSxDQUFDLGdCQUFnQixDQUFDLElBQUksQ0FBQyxFQUFFLE1BQU0sUUFBQSxFQUFFLEtBQUssT0FBQSxFQUFFLENBQUMsQ0FBQztvQkFDaEQsQ0FBQztnQkFDSCxDQUFDLENBQUMsQ0FBQztZQUNMLENBQUMsQ0FBQyxDQUFDO1FBQ0wsQ0FBQyxDQUFDLENBQUM7SUFDTCxDQUFDO0lBRUQsZ0JBQWdCO0lBQ1IsaUNBQUksR0FBWjtRQUNFLEVBQUUsQ0FBQyxDQUFDLElBQUksQ0FBQyxTQUFTLENBQUMsQ0FBQyxDQUFDO1lBQ25CLEVBQUUsQ0FBQyxDQUFDLFlBQVksSUFBSSxNQUFNLENBQUMsQ0FBQyxDQUFDO2dCQUMzQixJQUFJLENBQUMsVUFBVSxHQUFHLFVBQVUsQ0FBQztZQUMvQixDQUFDO1lBQUMsSUFBSSxDQUFDLENBQUM7Z0JBQ04sVUFBVSxDQUFDLElBQUksQ0FBQyxPQUFPLEVBQUUsSUFBSSxDQUFDLGNBQWMsRUFBRSxFQUFFLEVBQUUsSUFBSSxDQUFDLE9BQU8sRUFBRSxJQUFJLENBQUMsS0FBSyxDQUFDLENBQUM7WUFDOUUsQ0FBQztRQUNILENBQUM7SUFDSCxDQUFDO0lBeEdVLGtCQUFrQjtRQUQ5QixVQUFVLEVBQUU7UUF3QlIsbUJBQUEsTUFBTSxDQUFDLHFCQUFxQixDQUFDLENBQUE7UUFFN0IsbUJBQUEsTUFBTSxDQUFDLFdBQVcsQ0FBQyxDQUFBO1FBQ25CLG1CQUFBLFFBQVEsRUFBRSxDQUFBLEVBQUUsbUJBQUEsTUFBTSxDQUFDLGtCQUFrQixDQUFDLENBQUE7UUFDdEMsbUJBQUEsUUFBUSxFQUFFLENBQUEsRUFBRSxtQkFBQSxNQUFNLENBQUMsZUFBZSxDQUFDLENBQUE7aURBTDlCLE1BQU07T0F0Qkgsa0JBQWtCLENBa0g5QjtJQUFELHlCQUFDO0NBQUEsQUFsSEQsSUFrSEM7U0FsSFksa0JBQWtCIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgaXNQbGF0Zm9ybUJyb3dzZXIgfSBmcm9tICdAYW5ndWxhci9jb21tb24nO1xuaW1wb3J0IHsgSW5qZWN0LCBJbmplY3RhYmxlLCBJbmplY3Rpb25Ub2tlbiwgTmdab25lLCBPcHRpb25hbCwgUExBVEZPUk1fSUQgfSBmcm9tICdAYW5ndWxhci9jb3JlJztcbmltcG9ydCB7IE9ic2VydmFibGUsIFN1YmplY3QgfSBmcm9tICdyeGpzJztcblxuaW1wb3J0IHsgbG9hZFNjcmlwdCwgUkVDQVBUQ0hBX0JBU0VfVVJMLCBSRUNBUFRDSEFfTk9OQ0UgfSBmcm9tICcuL3JlY2FwdGNoYS1sb2FkZXIuc2VydmljZSc7XG5cbmV4cG9ydCBjb25zdCBSRUNBUFRDSEFfVjNfU0lURV9LRVkgPSBuZXcgSW5qZWN0aW9uVG9rZW48c3RyaW5nPigncmVjYXB0Y2hhLXYzLXNpdGUta2V5Jyk7XG5cbmV4cG9ydCBpbnRlcmZhY2UgT25FeGVjdXRlRGF0YSB7XG4gIC8qKlxuICAgKiBUaGUgbmFtZSBvZiB0aGUgYWN0aW9uIHRoYXQgaGFzIGJlZW4gZXhlY3V0ZWQuXG4gICAqL1xuICBhY3Rpb246IHN0cmluZztcbiAgLyoqXG4gICAqIFRoZSB0b2tlbiB0aGF0IHJlQ0FQVENIQSB2MyBwcm92aWRlZCB3aGVuIGV4ZWN1dGluZyB0aGUgYWN0aW9uLlxuICAgKi9cbiAgdG9rZW46IHN0cmluZztcbn1cblxudHlwZSBBY3Rpb25CYWNrbG9nRW50cnkgPSBbc3RyaW5nLCBTdWJqZWN0PHN0cmluZz5dO1xuXG4vKipcbiAqIFRoZSBtYWluIHNlcnZpY2UgZm9yIHdvcmtpbmcgd2l0aCByZUNBUFRDSEEgdjMgQVBJcy5cbiAqXG4gKiBVc2UgdGhlIGBleGVjdXRlYCBtZXRob2QgZm9yIGV4ZWN1dGluZyBhIHNpbmdsZSBhY3Rpb24sIGFuZFxuICogYG9uRXhlY3V0ZWAgb2JzZXJ2YWJsZSBmb3IgbGlzdGVuaW5nIHRvIGFsbCBhY3Rpb25zIGF0IG9uY2UuXG4gKi9cbkBJbmplY3RhYmxlKClcbmV4cG9ydCBjbGFzcyBSZUNhcHRjaGFWM1NlcnZpY2Uge1xuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgcmVhZG9ubHkgaXNCcm93c2VyOiBib29sZWFuO1xuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgcmVhZG9ubHkgc2l0ZUtleTogc3RyaW5nO1xuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgcmVhZG9ubHkgem9uZTogTmdab25lO1xuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgYWN0aW9uQmFja2xvZzogQWN0aW9uQmFja2xvZ0VudHJ5W10gfCB1bmRlZmluZWQ7XG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSBub25jZTogc3RyaW5nO1xuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgYmFzZVVybDogc3RyaW5nO1xuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgZ3JlY2FwdGNoYTogUmVDYXB0Y2hhVjIuUmVDYXB0Y2hhO1xuXG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSBvbkV4ZWN1dGVTdWJqZWN0OiBTdWJqZWN0PE9uRXhlY3V0ZURhdGE+O1xuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgb25FeGVjdXRlT2JzZXJ2YWJsZTogT2JzZXJ2YWJsZTxPbkV4ZWN1dGVEYXRhPjtcblxuICBjb25zdHJ1Y3RvcihcbiAgICB6b25lOiBOZ1pvbmUsXG4gICAgQEluamVjdChSRUNBUFRDSEFfVjNfU0lURV9LRVkpIHNpdGVLZXk6IHN0cmluZyxcbiAgICAvLyB0c2xpbnQ6ZGlzYWJsZS1uZXh0LWxpbmU6bm8tYW55XG4gICAgQEluamVjdChQTEFURk9STV9JRCkgcGxhdGZvcm1JZDogYW55LFxuICAgIEBPcHRpb25hbCgpIEBJbmplY3QoUkVDQVBUQ0hBX0JBU0VfVVJMKSBiYXNlVXJsPzogc3RyaW5nLFxuICAgIEBPcHRpb25hbCgpIEBJbmplY3QoUkVDQVBUQ0hBX05PTkNFKSBub25jZT86IHN0cmluZyxcbiAgKSB7XG4gICAgdGhpcy56b25lID0gem9uZTtcbiAgICB0aGlzLmlzQnJvd3NlciA9IGlzUGxhdGZvcm1Ccm93c2VyKHBsYXRmb3JtSWQpO1xuICAgIHRoaXMuc2l0ZUtleSA9IHNpdGVLZXk7XG4gICAgdGhpcy5ub25jZSA9IG5vbmNlO1xuICAgIHRoaXMuYmFzZVVybCA9IGJhc2VVcmw7XG5cbiAgICB0aGlzLmluaXQoKTtcbiAgfVxuXG4gIHB1YmxpYyBnZXQgb25FeGVjdXRlKCk6IE9ic2VydmFibGU8T25FeGVjdXRlRGF0YT4ge1xuICAgIGlmICghdGhpcy5vbkV4ZWN1dGVTdWJqZWN0KSB7XG4gICAgICB0aGlzLm9uRXhlY3V0ZVN1YmplY3QgPSBuZXcgU3ViamVjdDxPbkV4ZWN1dGVEYXRhPigpO1xuICAgICAgdGhpcy5vbkV4ZWN1dGVPYnNlcnZhYmxlID0gdGhpcy5vbkV4ZWN1dGVTdWJqZWN0LmFzT2JzZXJ2YWJsZSgpO1xuICAgIH1cblxuICAgIHJldHVybiB0aGlzLm9uRXhlY3V0ZU9ic2VydmFibGU7XG4gIH1cblxuICAvKipcbiAgICogRXhlY3V0ZXMgdGhlIHByb3ZpZGVkIGBhY3Rpb25gIHdpdGggcmVDQVBUQ0hBIHYzIEFQSS5cbiAgICogVXNlIHRoZSBlbWl0dGVkIHRva2VuIHZhbHVlIGZvciB2ZXJpZmljYXRpb24gcHVycG9zZXMgb24gdGhlIGJhY2tlbmQuXG4gICAqXG4gICAqIEZvciBtb3JlIGluZm9ybWF0aW9uIGFib3V0IHJlQ0FQVENIQSB2MyBhY3Rpb25zIGFuZCB0b2tlbnMgcmVmZXIgdG8gdGhlIG9mZmljaWFsIGRvY3VtZW50YXRpb24gYXRcbiAgICogaHR0cHM6Ly9kZXZlbG9wZXJzLmdvb2dsZS5jb20vcmVjYXB0Y2hhL2RvY3MvdjMuXG4gICAqXG4gICAqIEBwYXJhbSB7c3RyaW5nfSBhY3Rpb24gdGhlIGFjdGlvbiB0byBleGVjdXRlXG4gICAqIEByZXR1cm5zIHtPYnNlcnZhYmxlPHN0cmluZz59IGFuIGBPYnNlcnZhYmxlYCB0aGF0IHdpbGwgZW1pdCB0aGUgcmVDQVBUQ0hBIHYzIHN0cmluZyBgdG9rZW5gIHZhbHVlIHdoZW5ldmVyIHJlYWR5LlxuICAgKiBUaGUgcmV0dXJuZWQgYE9ic2VydmFibGVgIGNvbXBsZXRlcyBpbW1lZGlhdGVseSBhZnRlciBlbWl0dGluZyBhIHZhbHVlLlxuICAgKi9cbiAgcHVibGljIGV4ZWN1dGUoYWN0aW9uOiBzdHJpbmcpOiBPYnNlcnZhYmxlPHN0cmluZz4ge1xuICAgIGNvbnN0IHN1YmplY3QgPSBuZXcgU3ViamVjdDxzdHJpbmc+KCk7XG4gICAgaWYgKHRoaXMuaXNCcm93c2VyKSB7XG4gICAgICBpZiAoIXRoaXMuZ3JlY2FwdGNoYSkge1xuICAgICAgICAvLyB0b2RvOiBhZGQgdG8gYXJyYXkgb2YgbGF0ZXIgZXhlY3V0aW9uc1xuICAgICAgICBpZiAoIXRoaXMuYWN0aW9uQmFja2xvZykge1xuICAgICAgICAgIHRoaXMuYWN0aW9uQmFja2xvZyA9IFtdO1xuICAgICAgICB9XG5cbiAgICAgICAgdGhpcy5hY3Rpb25CYWNrbG9nLnB1c2goW2FjdGlvbiwgc3ViamVjdF0pO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5leGVjdXRlQWN0aW9uV2l0aFN1YmplY3QoYWN0aW9uLCBzdWJqZWN0KTtcbiAgICAgIH1cbiAgICB9XG5cbiAgICByZXR1cm4gc3ViamVjdC5hc09ic2VydmFibGUoKTtcbiAgfVxuXG4gIC8qKiBAaW50ZXJuYWwgKi9cbiAgcHJpdmF0ZSBleGVjdXRlQWN0aW9uV2l0aFN1YmplY3QoYWN0aW9uOiBzdHJpbmcsIHN1YmplY3Q6IFN1YmplY3Q8c3RyaW5nPik6IHZvaWQge1xuICAgIHRoaXMuem9uZS5ydW5PdXRzaWRlQW5ndWxhcigoKSA9PiB7XG4gICAgICAvLyB0c2xpbnQ6ZGlzYWJsZS1uZXh0LWxpbmU6bm8tYW55XG4gICAgICAodGhpcy5ncmVjYXB0Y2hhLmV4ZWN1dGUgYXMgYW55KShcbiAgICAgICAgdGhpcy5zaXRlS2V5LFxuICAgICAgICB7IGFjdGlvbiB9LFxuICAgICAgKS50aGVuKCh0b2tlbjogc3RyaW5nKSA9PiB7XG4gICAgICAgIHRoaXMuem9uZS5ydW4oKCkgPT4ge1xuICAgICAgICAgIHN1YmplY3QubmV4dCh0b2tlbik7XG4gICAgICAgICAgc3ViamVjdC5jb21wbGV0ZSgpO1xuICAgICAgICAgIGlmICh0aGlzLm9uRXhlY3V0ZVN1YmplY3QpIHtcbiAgICAgICAgICAgIHRoaXMub25FeGVjdXRlU3ViamVjdC5uZXh0KHsgYWN0aW9uLCB0b2tlbiB9KTtcbiAgICAgICAgICB9XG4gICAgICAgIH0pO1xuICAgICAgfSk7XG4gICAgfSk7XG4gIH1cblxuICAvKiogQGludGVybmFsICovXG4gIHByaXZhdGUgaW5pdCgpIHtcbiAgICBpZiAodGhpcy5pc0Jyb3dzZXIpIHtcbiAgICAgIGlmICgnZ3JlY2FwdGNoYScgaW4gd2luZG93KSB7XG4gICAgICAgIHRoaXMuZ3JlY2FwdGNoYSA9IGdyZWNhcHRjaGE7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICBsb2FkU2NyaXB0KHRoaXMuc2l0ZUtleSwgdGhpcy5vbkxvYWRDb21wbGV0ZSwgJycsIHRoaXMuYmFzZVVybCwgdGhpcy5ub25jZSk7XG4gICAgICB9XG4gICAgfVxuICB9XG5cbiAgLyoqIEBpbnRlcm5hbCAqL1xuICBwcml2YXRlIG9uTG9hZENvbXBsZXRlID0gKGdyZWNhcHRjaGE6IFJlQ2FwdGNoYVYyLlJlQ2FwdGNoYSkgPT4ge1xuICAgIHRoaXMuZ3JlY2FwdGNoYSA9IGdyZWNhcHRjaGE7XG4gICAgaWYgKHRoaXMuYWN0aW9uQmFja2xvZyAmJiB0aGlzLmFjdGlvbkJhY2tsb2cubGVuZ3RoID4gMCkge1xuICAgICAgdGhpcy5hY3Rpb25CYWNrbG9nLmZvckVhY2goKFthY3Rpb24sIHN1YmplY3RdKSA9PiB0aGlzLmV4ZWN1dGVBY3Rpb25XaXRoU3ViamVjdChhY3Rpb24sIHN1YmplY3QpKTtcbiAgICAgIHRoaXMuYWN0aW9uQmFja2xvZyA9IHVuZGVmaW5lZDtcbiAgICB9XG4gIH1cbn1cbiJdfQ==