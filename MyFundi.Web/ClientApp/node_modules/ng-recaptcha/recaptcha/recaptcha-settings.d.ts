/// <reference types="grecaptcha" />
import { InjectionToken } from '@angular/core';
export declare const RECAPTCHA_SETTINGS: InjectionToken<RecaptchaSettings>;
export interface RecaptchaSettings {
    siteKey?: string;
    theme?: ReCaptchaV2.Theme;
    type?: ReCaptchaV2.Type;
    size?: ReCaptchaV2.Size;
    badge?: ReCaptchaV2.Badge;
}
