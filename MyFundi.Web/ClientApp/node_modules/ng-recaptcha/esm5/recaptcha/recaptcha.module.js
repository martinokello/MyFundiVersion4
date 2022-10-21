import * as tslib_1 from "tslib";
import { NgModule } from '@angular/core';
import { RecaptchaCommonModule } from './recaptcha-common.module';
import { RecaptchaLoaderService } from './recaptcha-loader.service';
import { RecaptchaComponent } from './recaptcha.component';
var RecaptchaModule = /** @class */ (function () {
    function RecaptchaModule() {
    }
    RecaptchaModule_1 = RecaptchaModule;
    // We need this to maintain backwards-compatibility with v4. Removing this will be a breaking change
    RecaptchaModule.forRoot = function () {
        return RecaptchaModule_1;
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
    return RecaptchaModule;
    var RecaptchaModule_1;
}());
export { RecaptchaModule };
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoicmVjYXB0Y2hhLm1vZHVsZS5qcyIsInNvdXJjZVJvb3QiOiJuZzovL25nLXJlY2FwdGNoYS8iLCJzb3VyY2VzIjpbInJlY2FwdGNoYS9yZWNhcHRjaGEubW9kdWxlLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQSxPQUFPLEVBQUUsUUFBUSxFQUFFLE1BQU0sZUFBZSxDQUFDO0FBRXpDLE9BQU8sRUFBRSxxQkFBcUIsRUFBRSxNQUFNLDJCQUEyQixDQUFDO0FBQ2xFLE9BQU8sRUFBRSxzQkFBc0IsRUFBRSxNQUFNLDRCQUE0QixDQUFDO0FBQ3BFLE9BQU8sRUFBRSxrQkFBa0IsRUFBRSxNQUFNLHVCQUF1QixDQUFDO0FBYTNEO0lBQUE7SUFLQSxDQUFDO3dCQUxZLGVBQWU7SUFDMUIsb0dBQW9HO0lBQ3RGLHVCQUFPLEdBQXJCO1FBQ0UsTUFBTSxDQUFDLGlCQUFlLENBQUM7SUFDekIsQ0FBQztJQUpVLGVBQWU7UUFYM0IsUUFBUSxDQUFDO1lBQ1IsT0FBTyxFQUFFO2dCQUNQLGtCQUFrQjthQUNuQjtZQUNELE9BQU8sRUFBRTtnQkFDUCxxQkFBcUI7YUFDdEI7WUFDRCxTQUFTLEVBQUU7Z0JBQ1Qsc0JBQXNCO2FBQ3ZCO1NBQ0YsQ0FBQztPQUNXLGVBQWUsQ0FLM0I7SUFBRCxzQkFBQzs7Q0FBQSxBQUxELElBS0M7U0FMWSxlQUFlIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgTmdNb2R1bGUgfSBmcm9tICdAYW5ndWxhci9jb3JlJztcblxuaW1wb3J0IHsgUmVjYXB0Y2hhQ29tbW9uTW9kdWxlIH0gZnJvbSAnLi9yZWNhcHRjaGEtY29tbW9uLm1vZHVsZSc7XG5pbXBvcnQgeyBSZWNhcHRjaGFMb2FkZXJTZXJ2aWNlIH0gZnJvbSAnLi9yZWNhcHRjaGEtbG9hZGVyLnNlcnZpY2UnO1xuaW1wb3J0IHsgUmVjYXB0Y2hhQ29tcG9uZW50IH0gZnJvbSAnLi9yZWNhcHRjaGEuY29tcG9uZW50JztcblxuQE5nTW9kdWxlKHtcbiAgZXhwb3J0czogW1xuICAgIFJlY2FwdGNoYUNvbXBvbmVudCxcbiAgXSxcbiAgaW1wb3J0czogW1xuICAgIFJlY2FwdGNoYUNvbW1vbk1vZHVsZSxcbiAgXSxcbiAgcHJvdmlkZXJzOiBbXG4gICAgUmVjYXB0Y2hhTG9hZGVyU2VydmljZSxcbiAgXSxcbn0pXG5leHBvcnQgY2xhc3MgUmVjYXB0Y2hhTW9kdWxlIHtcbiAgLy8gV2UgbmVlZCB0aGlzIHRvIG1haW50YWluIGJhY2t3YXJkcy1jb21wYXRpYmlsaXR5IHdpdGggdjQuIFJlbW92aW5nIHRoaXMgd2lsbCBiZSBhIGJyZWFraW5nIGNoYW5nZVxuICBwdWJsaWMgc3RhdGljIGZvclJvb3QoKSB7XG4gICAgcmV0dXJuIFJlY2FwdGNoYU1vZHVsZTtcbiAgfVxufVxuIl19