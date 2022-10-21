import * as tslib_1 from "tslib";
import { NgModule } from '@angular/core';
import { RecaptchaCommonModule } from './recaptcha-common.module';
import { RecaptchaLoaderService } from './recaptcha-loader.service';
import { RecaptchaComponent } from './recaptcha.component';
let RecaptchaModule = RecaptchaModule_1 = class RecaptchaModule {
    // We need this to maintain backwards-compatibility with v4. Removing this will be a breaking change
    static forRoot() {
        return RecaptchaModule_1;
    }
};
RecaptchaModule = RecaptchaModule_1 = tslib_1.__decorate([
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
export { RecaptchaModule };
var RecaptchaModule_1;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoicmVjYXB0Y2hhLm1vZHVsZS5qcyIsInNvdXJjZVJvb3QiOiJuZzovL25nLXJlY2FwdGNoYS8iLCJzb3VyY2VzIjpbInJlY2FwdGNoYS9yZWNhcHRjaGEubW9kdWxlLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQSxPQUFPLEVBQUUsUUFBUSxFQUFFLE1BQU0sZUFBZSxDQUFDO0FBRXpDLE9BQU8sRUFBRSxxQkFBcUIsRUFBRSxNQUFNLDJCQUEyQixDQUFDO0FBQ2xFLE9BQU8sRUFBRSxzQkFBc0IsRUFBRSxNQUFNLDRCQUE0QixDQUFDO0FBQ3BFLE9BQU8sRUFBRSxrQkFBa0IsRUFBRSxNQUFNLHVCQUF1QixDQUFDO0FBYTNELElBQWEsZUFBZSx1QkFBNUI7SUFDRSxvR0FBb0c7SUFDN0YsTUFBTSxDQUFDLE9BQU87UUFDbkIsTUFBTSxDQUFDLGlCQUFlLENBQUM7SUFDekIsQ0FBQztDQUNGLENBQUE7QUFMWSxlQUFlO0lBWDNCLFFBQVEsQ0FBQztRQUNSLE9BQU8sRUFBRTtZQUNQLGtCQUFrQjtTQUNuQjtRQUNELE9BQU8sRUFBRTtZQUNQLHFCQUFxQjtTQUN0QjtRQUNELFNBQVMsRUFBRTtZQUNULHNCQUFzQjtTQUN2QjtLQUNGLENBQUM7R0FDVyxlQUFlLENBSzNCO1NBTFksZUFBZSIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IE5nTW9kdWxlIH0gZnJvbSAnQGFuZ3VsYXIvY29yZSc7XG5cbmltcG9ydCB7IFJlY2FwdGNoYUNvbW1vbk1vZHVsZSB9IGZyb20gJy4vcmVjYXB0Y2hhLWNvbW1vbi5tb2R1bGUnO1xuaW1wb3J0IHsgUmVjYXB0Y2hhTG9hZGVyU2VydmljZSB9IGZyb20gJy4vcmVjYXB0Y2hhLWxvYWRlci5zZXJ2aWNlJztcbmltcG9ydCB7IFJlY2FwdGNoYUNvbXBvbmVudCB9IGZyb20gJy4vcmVjYXB0Y2hhLmNvbXBvbmVudCc7XG5cbkBOZ01vZHVsZSh7XG4gIGV4cG9ydHM6IFtcbiAgICBSZWNhcHRjaGFDb21wb25lbnQsXG4gIF0sXG4gIGltcG9ydHM6IFtcbiAgICBSZWNhcHRjaGFDb21tb25Nb2R1bGUsXG4gIF0sXG4gIHByb3ZpZGVyczogW1xuICAgIFJlY2FwdGNoYUxvYWRlclNlcnZpY2UsXG4gIF0sXG59KVxuZXhwb3J0IGNsYXNzIFJlY2FwdGNoYU1vZHVsZSB7XG4gIC8vIFdlIG5lZWQgdGhpcyB0byBtYWludGFpbiBiYWNrd2FyZHMtY29tcGF0aWJpbGl0eSB3aXRoIHY0LiBSZW1vdmluZyB0aGlzIHdpbGwgYmUgYSBicmVha2luZyBjaGFuZ2VcbiAgcHVibGljIHN0YXRpYyBmb3JSb290KCkge1xuICAgIHJldHVybiBSZWNhcHRjaGFNb2R1bGU7XG4gIH1cbn1cbiJdfQ==