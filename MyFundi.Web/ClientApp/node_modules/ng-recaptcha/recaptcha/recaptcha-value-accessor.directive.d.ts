import { ControlValueAccessor } from '@angular/forms';
import { RecaptchaComponent } from './recaptcha.component';
export declare class RecaptchaValueAccessorDirective implements ControlValueAccessor {
    private host;
    constructor(host: RecaptchaComponent);
    writeValue(value: string): void;
    registerOnChange(fn: (value: string) => void): void;
    registerOnTouched(fn: () => void): void;
    onResolve($event: string): void;
}
