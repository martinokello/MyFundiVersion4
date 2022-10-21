/// <reference types="grecaptcha" />
import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';
export declare const RECAPTCHA_LANGUAGE: InjectionToken<string>;
export declare const RECAPTCHA_BASE_URL: InjectionToken<string>;
export declare const RECAPTCHA_NONCE: InjectionToken<string>;
declare global  {
    interface Window {
        ng2recaptchaloaded: () => void;
    }
}
export declare function loadScript(renderMode: 'explicit' | string, onLoaded: (grecaptcha: ReCaptchaV2.ReCaptcha) => void, urlParams: string, url?: string, nonce?: string): void;
export declare class RecaptchaLoaderService {
    private readonly platformId;
    ready: Observable<ReCaptchaV2.ReCaptcha>;
    constructor(platformId: any, language?: string, baseUrl?: string, nonce?: string);
}
