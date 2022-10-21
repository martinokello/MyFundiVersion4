(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('@angular/core'), require('@angular/common'), require('rxjs'), require('@angular/forms')) :
    typeof define === 'function' && define.amd ? define('ng-recaptcha', ['exports', '@angular/core', '@angular/common', 'rxjs', '@angular/forms'], factory) :
    (global = global || self, factory(global['ng-recaptcha'] = {}, global.ng.core, global.ng.common, global.rxjs, global.ng.forms));
}(this, function (exports, core, common, rxjs, forms) { 'use strict';

    /*! *****************************************************************************
    Copyright (c) Microsoft Corporation. All rights reserved.
    Licensed under the Apache License, Version 2.0 (the "License"); you may not use
    this file except in compliance with the License. You may obtain a copy of the
    License at http://www.apache.org/licenses/LICENSE-2.0

    THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
    WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
    MERCHANTABLITY OR NON-INFRINGEMENT.

    See the Apache Version 2.0 License for specific language governing permissions
    and limitations under the License.
    ***************************************************************************** */

    function __decorate(decorators, target, key, desc) {
        var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
        if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
        else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
        return c > 3 && r && Object.defineProperty(target, key, r), r;
    }

    function __param(paramIndex, decorator) {
        return function (target, key) { decorator(target, key, paramIndex); }
    }

    function __metadata(metadataKey, metadataValue) {
        if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(metadataKey, metadataValue);
    }

    function __read(o, n) {
        var m = typeof Symbol === "function" && o[Symbol.iterator];
        if (!m) return o;
        var i = m.call(o), r, ar = [], e;
        try {
            while ((n === void 0 || n-- > 0) && !(r = i.next()).done) ar.push(r.value);
        }
        catch (error) { e = { error: error }; }
        finally {
            try {
                if (r && !r.done && (m = i["return"])) m.call(i);
            }
            finally { if (e) throw e.error; }
        }
        return ar;
    }

    var RECAPTCHA_LANGUAGE = new core.InjectionToken('recaptcha-language');
    var RECAPTCHA_BASE_URL = new core.InjectionToken('recaptcha-base-url');
    var RECAPTCHA_NONCE = new core.InjectionToken('recaptcha-nonce-tag');
    function loadScript(renderMode, onLoaded, urlParams, url, nonce) {
        window.ng2recaptchaloaded = function () {
            onLoaded(grecaptcha);
        };
        var script = document.createElement('script');
        script.innerHTML = '';
        var baseUrl = url || 'https://www.google.com/recaptcha/api.js';
        script.src = baseUrl + "?render=" + renderMode + "&onload=ng2recaptchaloaded" + urlParams;
        if (nonce) {
            // tslint:disable-next-line:no-any Remove "any" cast once we upgrade Angular to 7 and TypeScript along with it
            script.nonce = nonce;
        }
        script.async = true;
        script.defer = true;
        document.head.appendChild(script);
    }
    var RecaptchaLoaderService = /** @class */ (function () {
        function RecaptchaLoaderService(
        // tslint:disable-next-line:no-any
        platformId, language, baseUrl, nonce) {
            this.platformId = platformId;
            this.language = language;
            this.baseUrl = baseUrl;
            this.nonce = nonce;
            this.init();
            this.ready = common.isPlatformBrowser(this.platformId) ? RecaptchaLoaderService_1.ready.asObservable() : rxjs.of();
        }
        RecaptchaLoaderService_1 = RecaptchaLoaderService;
        /** @internal */
        RecaptchaLoaderService.prototype.init = function () {
            if (RecaptchaLoaderService_1.ready) {
                return;
            }
            if (common.isPlatformBrowser(this.platformId)) {
                var subject_1 = new rxjs.BehaviorSubject(null);
                RecaptchaLoaderService_1.ready = subject_1;
                var langParam = this.language ? '&hl=' + this.language : '';
                loadScript('explicit', function (grecaptcha) { return subject_1.next(grecaptcha); }, langParam, this.baseUrl, this.nonce);
            }
        };
        /**
         * @internal
         * @nocollapse
         */
        RecaptchaLoaderService.ready = null;
        RecaptchaLoaderService = RecaptchaLoaderService_1 = __decorate([
            core.Injectable(),
            __param(0, core.Inject(core.PLATFORM_ID)),
            __param(1, core.Optional()), __param(1, core.Inject(RECAPTCHA_LANGUAGE)),
            __param(2, core.Optional()), __param(2, core.Inject(RECAPTCHA_BASE_URL)),
            __param(3, core.Optional()), __param(3, core.Inject(RECAPTCHA_NONCE)),
            __metadata("design:paramtypes", [Object, String, String, String])
        ], RecaptchaLoaderService);
        return RecaptchaLoaderService;
        var RecaptchaLoaderService_1;
    }());

    var RECAPTCHA_SETTINGS = new core.InjectionToken('recaptcha-settings');

    var nextId = 0;
    var RecaptchaComponent = /** @class */ (function () {
        function RecaptchaComponent(elementRef, loader, zone, settings) {
            this.elementRef = elementRef;
            this.loader = loader;
            this.zone = zone;
            this.id = "ngrecaptcha-" + nextId++;
            this.resolved = new core.EventEmitter();
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
        __decorate([
            core.Input(),
            core.HostBinding('attr.id'),
            __metadata("design:type", Object)
        ], RecaptchaComponent.prototype, "id", void 0);
        __decorate([
            core.Input(),
            __metadata("design:type", String)
        ], RecaptchaComponent.prototype, "siteKey", void 0);
        __decorate([
            core.Input(),
            __metadata("design:type", String)
        ], RecaptchaComponent.prototype, "theme", void 0);
        __decorate([
            core.Input(),
            __metadata("design:type", String)
        ], RecaptchaComponent.prototype, "type", void 0);
        __decorate([
            core.Input(),
            __metadata("design:type", String)
        ], RecaptchaComponent.prototype, "size", void 0);
        __decorate([
            core.Input(),
            __metadata("design:type", Number)
        ], RecaptchaComponent.prototype, "tabIndex", void 0);
        __decorate([
            core.Input(),
            __metadata("design:type", String)
        ], RecaptchaComponent.prototype, "badge", void 0);
        __decorate([
            core.Output(),
            __metadata("design:type", Object)
        ], RecaptchaComponent.prototype, "resolved", void 0);
        RecaptchaComponent = __decorate([
            core.Component({
                exportAs: 'reCaptcha',
                selector: 're-captcha',
                template: ""
            }),
            __param(3, core.Optional()), __param(3, core.Inject(RECAPTCHA_SETTINGS)),
            __metadata("design:paramtypes", [core.ElementRef,
                RecaptchaLoaderService,
                core.NgZone, Object])
        ], RecaptchaComponent);
        return RecaptchaComponent;
    }());

    var RecaptchaCommonModule = /** @class */ (function () {
        function RecaptchaCommonModule() {
        }
        RecaptchaCommonModule = __decorate([
            core.NgModule({
                declarations: [
                    RecaptchaComponent,
                ],
                exports: [
                    RecaptchaComponent,
                ],
            })
        ], RecaptchaCommonModule);
        return RecaptchaCommonModule;
    }());

    var RecaptchaModule = /** @class */ (function () {
        function RecaptchaModule() {
        }
        RecaptchaModule_1 = RecaptchaModule;
        // We need this to maintain backwards-compatibility with v4. Removing this will be a breaking change
        RecaptchaModule.forRoot = function () {
            return RecaptchaModule_1;
        };
        RecaptchaModule = RecaptchaModule_1 = __decorate([
            core.NgModule({
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
        return RecaptchaModule;
        var RecaptchaModule_1;
    }());

    var RECAPTCHA_V3_SITE_KEY = new core.InjectionToken('recaptcha-v3-site-key');
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
                        var _b = __read(_a, 2), action = _b[0], subject = _b[1];
                        return _this.executeActionWithSubject(action, subject);
                    });
                    _this.actionBacklog = undefined;
                }
            };
            this.zone = zone;
            this.isBrowser = common.isPlatformBrowser(platformId);
            this.siteKey = siteKey;
            this.nonce = nonce;
            this.baseUrl = baseUrl;
            this.init();
        }
        Object.defineProperty(ReCaptchaV3Service.prototype, "onExecute", {
            get: function () {
                if (!this.onExecuteSubject) {
                    this.onExecuteSubject = new rxjs.Subject();
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
            var subject = new rxjs.Subject();
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
        ReCaptchaV3Service = __decorate([
            core.Injectable(),
            __param(1, core.Inject(RECAPTCHA_V3_SITE_KEY)),
            __param(2, core.Inject(core.PLATFORM_ID)),
            __param(3, core.Optional()), __param(3, core.Inject(RECAPTCHA_BASE_URL)),
            __param(4, core.Optional()), __param(4, core.Inject(RECAPTCHA_NONCE)),
            __metadata("design:paramtypes", [core.NgZone, String, Object, String, String])
        ], ReCaptchaV3Service);
        return ReCaptchaV3Service;
    }());

    var RecaptchaV3Module = /** @class */ (function () {
        function RecaptchaV3Module() {
        }
        RecaptchaV3Module = __decorate([
            core.NgModule({
                providers: [
                    ReCaptchaV3Service,
                ],
            })
        ], RecaptchaV3Module);
        return RecaptchaV3Module;
    }());

    var RecaptchaValueAccessorDirective = /** @class */ (function () {
        function RecaptchaValueAccessorDirective(host) {
            this.host = host;
        }
        RecaptchaValueAccessorDirective_1 = RecaptchaValueAccessorDirective;
        RecaptchaValueAccessorDirective.prototype.writeValue = function (value) {
            if (!value) {
                this.host.reset();
            }
        };
        RecaptchaValueAccessorDirective.prototype.registerOnChange = function (fn) { this.onChange = fn; };
        RecaptchaValueAccessorDirective.prototype.registerOnTouched = function (fn) { this.onTouched = fn; };
        RecaptchaValueAccessorDirective.prototype.onResolve = function ($event) {
            if (this.onChange) {
                this.onChange($event);
            }
            if (this.onTouched) {
                this.onTouched();
            }
        };
        __decorate([
            core.HostListener('resolved', ['$event']),
            __metadata("design:type", Function),
            __metadata("design:paramtypes", [String]),
            __metadata("design:returntype", void 0)
        ], RecaptchaValueAccessorDirective.prototype, "onResolve", null);
        RecaptchaValueAccessorDirective = RecaptchaValueAccessorDirective_1 = __decorate([
            core.Directive({
                providers: [
                    {
                        multi: true,
                        provide: forms.NG_VALUE_ACCESSOR,
                        // tslint:disable-next-line:no-forward-ref
                        useExisting: core.forwardRef(function () { return RecaptchaValueAccessorDirective_1; }),
                    },
                ],
                // tslint:disable-next-line:directive-selector
                selector: 're-captcha[formControlName],re-captcha[formControl],re-captcha[ngModel]',
            }),
            __metadata("design:paramtypes", [RecaptchaComponent])
        ], RecaptchaValueAccessorDirective);
        return RecaptchaValueAccessorDirective;
        var RecaptchaValueAccessorDirective_1;
    }());

    var RecaptchaFormsModule = /** @class */ (function () {
        function RecaptchaFormsModule() {
        }
        RecaptchaFormsModule = __decorate([
            core.NgModule({
                declarations: [
                    RecaptchaValueAccessorDirective,
                ],
                exports: [RecaptchaValueAccessorDirective],
                imports: [forms.FormsModule, RecaptchaCommonModule],
            })
        ], RecaptchaFormsModule);
        return RecaptchaFormsModule;
    }());

    exports.RECAPTCHA_BASE_URL = RECAPTCHA_BASE_URL;
    exports.RECAPTCHA_LANGUAGE = RECAPTCHA_LANGUAGE;
    exports.RECAPTCHA_NONCE = RECAPTCHA_NONCE;
    exports.RECAPTCHA_SETTINGS = RECAPTCHA_SETTINGS;
    exports.RECAPTCHA_V3_SITE_KEY = RECAPTCHA_V3_SITE_KEY;
    exports.ReCaptchaV3Service = ReCaptchaV3Service;
    exports.RecaptchaComponent = RecaptchaComponent;
    exports.RecaptchaFormsModule = RecaptchaFormsModule;
    exports.RecaptchaLoaderService = RecaptchaLoaderService;
    exports.RecaptchaModule = RecaptchaModule;
    exports.RecaptchaV3Module = RecaptchaV3Module;
    exports.RecaptchaValueAccessorDirective = RecaptchaValueAccessorDirective;
    exports.ɵa = RecaptchaCommonModule;

    Object.defineProperty(exports, '__esModule', { value: true });

}));
//# sourceMappingURL=ng-recaptcha.umd.js.map
