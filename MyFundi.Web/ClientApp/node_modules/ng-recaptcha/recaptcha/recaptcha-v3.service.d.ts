import { InjectionToken, NgZone } from '@angular/core';
import { Observable } from 'rxjs';
export declare const RECAPTCHA_V3_SITE_KEY: InjectionToken<string>;
export interface OnExecuteData {
    /**
     * The name of the action that has been executed.
     */
    action: string;
    /**
     * The token that reCAPTCHA v3 provided when executing the action.
     */
    token: string;
}
/**
 * The main service for working with reCAPTCHA v3 APIs.
 *
 * Use the `execute` method for executing a single action, and
 * `onExecute` observable for listening to all actions at once.
 */
export declare class ReCaptchaV3Service {
    constructor(zone: NgZone, siteKey: string, platformId: any, baseUrl?: string, nonce?: string);
    readonly onExecute: Observable<OnExecuteData>;
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
    execute(action: string): Observable<string>;
}
