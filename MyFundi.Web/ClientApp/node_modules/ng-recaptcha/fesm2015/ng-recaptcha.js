import { __decorate, __param, __metadata } from 'tslib';
import { InjectionToken, Injectable, Inject, PLATFORM_ID, Optional, EventEmitter, Input, HostBinding, Output, Component, ElementRef, NgZone, NgModule, HostListener, Directive, forwardRef } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { of, BehaviorSubject, Subject } from 'rxjs';
import { NG_VALUE_ACCESSOR, FormsModule } from '@angular/forms';

const RECAPTCHA_LANGUAGE = new InjectionToken('recaptcha-language');
const RECAPTCHA_BASE_URL = new InjectionToken('recaptcha-base-url');
const RECAPTCHA_NONCE = new InjectionToken('recaptcha-nonce-tag');
function loadScript(renderMode, onLoaded, urlParams, url, nonce) {
    window.ng2recaptchaloaded = () => {
        onLoaded(grecaptcha);
    };
    const script = document.createElement('script');
    script.innerHTML = '';
    const baseUrl = url || 'https://www.google.com/recaptcha/api.js';
    script.src = `${baseUrl}?render=${renderMode}&onload=ng2recaptchaloaded${urlParams}`;
    if (nonce) {
        // tslint:disable-next-line:no-any Remove "any" cast once we upgrade Angular to 7 and TypeScript along with it
        script.nonce = nonce;
    }
    script.async = true;
    script.defer = true;
    document.head.appendChild(script);
}
let RecaptchaLoaderService = RecaptchaLoaderService_1 = class RecaptchaLoaderService {
    constructor(
    // tslint:disable-next-line:no-any
    platformId, language, baseUrl, nonce) {
        this.platformId = platformId;
        this.language = language;
        this.baseUrl = baseUrl;
        this.nonce = nonce;
        this.init();
        this.ready = isPlatformBrowser(this.platformId) ? RecaptchaLoaderService_1.ready.asObservable() : of();
    }
    /** @internal */
    init() {
        if (RecaptchaLoaderService_1.ready) {
            return;
        }
        if (isPlatformBrowser(this.platformId)) {
            const subject = new BehaviorSubject(null);
            RecaptchaLoaderService_1.ready = subject;
            const langParam = this.language ? '&hl=' + this.language : '';
            loadScript('explicit', (grecaptcha) => subject.next(grecaptcha), langParam, this.baseUrl, this.nonce);
        }
    }
};
/**
 * @internal
 * @nocollapse
 */
RecaptchaLoaderService.ready = null;
RecaptchaLoaderService = RecaptchaLoaderService_1 = __decorate([
    Injectable(),
    __param(0, Inject(PLATFORM_ID)),
    __param(1, Optional()), __param(1, Inject(RECAPTCHA_LANGUAGE)),
    __param(2, Optional()), __param(2, Inject(RECAPTCHA_BASE_URL)),
    __param(3, Optional()), __param(3, Inject(RECAPTCHA_NONCE)),
    __metadata("design:paramtypes", [Object, String, String, String])
], RecaptchaLoaderService);
var RecaptchaLoaderService_1;

const RECAPTCHA_SETTINGS = new InjectionToken('recaptcha-settings');

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
__decorate([
    Input(),
    HostBinding('attr.id'),
    __metadata("design:type", Object)
], RecaptchaComponent.prototype, "id", void 0);
__decorate([
    Input(),
    __metadata("design:type", String)
], RecaptchaComponent.prototype, "siteKey", void 0);
__decorate([
    Input(),
    __metadata("design:type", String)
], RecaptchaComponent.prototype, "theme", void 0);
__decorate([
    Input(),
    __metadata("design:type", String)
], RecaptchaComponent.prototype, "type", void 0);
__decorate([
    Input(),
    __metadata("design:type", String)
], RecaptchaComponent.prototype, "size", void 0);
__decorate([
    Input(),
    __metadata("design:type", Number)
], RecaptchaComponent.prototype, "tabIndex", void 0);
__decorate([
    Input(),
    __metadata("design:type", String)
], RecaptchaComponent.prototype, "badge", void 0);
__decorate([
    Output(),
    __metadata("design:type", Object)
], RecaptchaComponent.prototype, "resolved", void 0);
RecaptchaComponent = __decorate([
    Component({
        exportAs: 'reCaptcha',
        selector: 're-captcha',
        template: ``
    }),
    __param(3, Optional()), __param(3, Inject(RECAPTCHA_SETTINGS)),
    __metadata("design:paramtypes", [ElementRef,
        RecaptchaLoaderService,
        NgZone, Object])
], RecaptchaComponent);

let RecaptchaCommonModule = class RecaptchaCommonModule {
};
RecaptchaCommonModule = __decorate([
    NgModule({
        declarations: [
            RecaptchaComponent,
        ],
        exports: [
            RecaptchaComponent,
        ],
    })
], RecaptchaCommonModule);

let RecaptchaModule = RecaptchaModule_1 = class RecaptchaModule {
    // We need this to maintain backwards-compatibility with v4. Removing this will be a breaking change
    static forRoot() {
        return RecaptchaModule_1;
    }
};
RecaptchaModule = RecaptchaModule_1 = __decorate([
    NgModule({
        exports: [
            RecaptchaComponent,
        ],
        imports: [
            RecaptchaCommonModule,
        ],
        providers: [
            RecaptchaLoaderService,
        ],
    })
], RecaptchaModule);
var RecaptchaModule_1;

const RECAPTCHA_V3_SITE_KEY = new InjectionToken('recaptcha-v3-site-key');
/**
 * The main service for working with reCAPTCHA v3 APIs.
 *
 * Use the `execute` method for executing a single action, and
 * `onExecute` observable for listening to all actions at once.
 */
let ReCaptchaV3Service = class ReCaptchaV3Service {
    constructor(zone, siteKey, 
    // tslint:disable-next-line:no-any
    platformId, baseUrl, nonce) {
        /** @internal */
        this.onLoadComplete = (grecaptcha) => {
            this.grecaptcha = grecaptcha;
            if (this.actionBacklog && this.actionBacklog.length > 0) {
                this.actionBacklog.forEach(([action, subject]) => this.executeActionWithSubject(action, subject));
                this.actionBacklog = undefined;
            }
        };
        this.zone = zone;
        this.isBrowser = isPlatformBrowser(platformId);
        this.siteKey = siteKey;
        this.nonce = nonce;
        this.baseUrl = baseUrl;
        this.init();
    }
    get onExecute() {
        if (!this.onExecuteSubject) {
            this.onExecuteSubject = new Subject();
            this.onExecuteObservable = this.onExecuteSubject.asObservable();
        }
        return this.onExecuteObservable;
    }
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
    execute(action) {
        const subject = new Subject();
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
    }
    /** @internal */
    executeActionWithSubject(action, subject) {
        this.zone.runOutsideAngular(() => {
            // tslint:disable-next-line:no-any
            this.grecaptcha.execute(this.siteKey, { action }).then((token) => {
                this.zone.run(() => {
                    subject.next(token);
                    subject.complete();
                    if (this.onExecuteSubject) {
                        this.onExecuteSubject.next({ action, token });
                    }
                });
            });
        });
    }
    /** @internal */
    init() {
        if (this.isBrowser) {
            if ('grecaptcha' in window) {
                this.grecaptcha = grecaptcha;
            }
            else {
                loadScript(this.siteKey, this.onLoadComplete, '', this.baseUrl, this.nonce);
            }
        }
    }
};
ReCaptchaV3Service = __decorate([
    Injectable(),
    __param(1, Inject(RECAPTCHA_V3_SITE_KEY)),
    __param(2, Inject(PLATFORM_ID)),
    __param(3, Optional()), __param(3, Inject(RECAPTCHA_BASE_URL)),
    __param(4, Optional()), __param(4, Inject(RECAPTCHA_NONCE)),
    __metadata("design:paramtypes", [NgZone, String, Object, String, String])
], ReCaptchaV3Service);

let RecaptchaV3Module = class RecaptchaV3Module {
};
RecaptchaV3Module = __decorate([
    NgModule({
        providers: [
            ReCaptchaV3Service,
        ],
    })
], RecaptchaV3Module);

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
__decorate([
    HostListener('resolved', ['$event']),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], RecaptchaValueAccessorDirective.prototype, "onResolve", null);
RecaptchaValueAccessorDirective = RecaptchaValueAccessorDirective_1 = __decorate([
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
    __metadata("design:paramtypes", [RecaptchaComponent])
], RecaptchaValueAccessorDirective);
var RecaptchaValueAccessorDirective_1;

let RecaptchaFormsModule = class RecaptchaFormsModule {
};
RecaptchaFormsModule = __decorate([
    NgModule({
        declarations: [
            RecaptchaValueAccessorDirective,
        ],
        exports: [RecaptchaValueAccessorDirective],
        imports: [FormsModule, RecaptchaCommonModule],
    })
], RecaptchaFormsModule);

/**
 * Generated bundle index. Do not edit.
 */

export { RECAPTCHA_BASE_URL, RECAPTCHA_LANGUAGE, RECAPTCHA_NONCE, RECAPTCHA_SETTINGS, RECAPTCHA_V3_SITE_KEY, ReCaptchaV3Service, RecaptchaComponent, RecaptchaFormsModule, RecaptchaLoaderService, RecaptchaModule, RecaptchaV3Module, RecaptchaValueAccessorDirective, RecaptchaCommonModule as ɵa };
//# sourceMappingURL=ng-recaptcha.js.map
