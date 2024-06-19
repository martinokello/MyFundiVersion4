import { BrowserModule } from '@angular/platform-browser';
import { NgModule, NgZone } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { Router, RouterModule } from '@angular/router';
import { AppComponent } from './app.component';
import { NavMenuComponent } from './nav-menu/nav-menu.component';
import { HomeComponent } from './home/home.component';
import { ActiveCrudOperationsComponent } from './activecrudoperations/activecrudoperations.component';
import { FetchDataComponent } from './fetch-data/fetch-data.component';
import { LoginComponent } from './login/login.component';
import { RegisterComponent } from './register/register.component';
import { ForgotPasswordComponent } from './forgotPassword/forgotPassword.component';
import { UserRolesComponent } from './userroles/userroles.component';
import { ContactUsComponent } from './contactus/contactus.component';
import { AboutUsComponent } from './about/aboutus.component';
import { SectionsContactComponent } from './sectionscontact/sectionscontact.component';
import { PayPalSuccessComponent } from './paypalSuccess/paypal-success.component';
import { PayPalFailureComponent } from './paypalFailure/paypal-failure.component';
import { NewRolesComponent } from './newroles/newroles.component';
import { APP_BASE_HREF } from '@angular/common';
import { MyFundiService } from '../services/myFundiService';
import { AppInterceptor } from '../interceptors/app.interceptor';
import { QrCodeComponent } from './qrCodeReader/qrCodeReader.component';
import { AddressComponent } from './crud-operations/address/address.component';
import { CompanyComponent } from './crud-operations/company/company.component';
import { LocationComponent } from './crud-operations/location/location.component';
import { SuccessComponent } from './success/success.component';
import { FailureComponent } from './failure/failure.component';

import { GuestRoleComponent } from './roles/guest/guest.component';
import { FundiRoleComponent } from './roles/fundi/fundi.component';
import { AuthGuard } from '../guards/AuthGuard';
import { AuthFundiGuard } from '../guards/AuthFundiGuard';
import { AdminAuthGuard } from '../guards/AdminAuthGuard';;
import { TwitterProfileFeedsComponent } from '../socialmedia/twitterfeeds/twitterprofilefeeds.component';
import { ClientRoleComponent } from './roles/client/client.component';
import { AuthClientGuard } from '../guards/AuthClientGuard';
import { ProfileComponent } from './profile/profile.component';
import { CertificationComponent } from './crud-operations/certification/certification.component';
import { WorkCategoryComponent } from './crud-operations/work-category/workcategory.component';
import { ProfileCreateComponent } from './profile-create/profilecreate.component';
import { CourseCrudComponent } from './crud-operations/coursescrud/coursescrud.component';
import { CertificationCrudComponent } from './crud-operations/certificationcrud/certificationcrud.component';
import { WorkCategoryCrudComponent } from './crud-operations/workcategorycrud/workcategorycrud.component';
import { ClientFundiSearchComponent } from './clientFundiSearch/clientFundiSearch.component';
import { FundiProfileByIdComponent } from './fundiProfile-by-id/fundiProfileById.component';
import { ClientProfileComponent } from './client/client.component';
import { AddressLocationGeoCodeService } from '../services/AddressLocationGeoCodeService';
import { FundiJobSearchComponent } from './fundiJobSearch/fundiJobSearch.component';
import { FundiSubscriptionComponent } from './fundisubscription/fundisubscription.component';
import { AuthFundiSubscriptionGuard } from '../guards/AuthFundiSubscriptionGuard';
import { VehicleMonitorComponent } from './vehiclemonitor/vehiclemonitor.component';
import { myRecaptchaComponent } from './recaptcha/myrecaptcha.component';
import { ClientJobViewComponent } from './client-job-view/clientjobview.component';
import { CoursesComponent } from './crud-operations/courses/courses.component';
import { WorkSubCategoryCrudComponent } from './crud-operations/worksubcategorycrud/worksubcategorycrud.component';
import { FundiEngagementComponent } from './fundi-engagement/fundiengagement.component';
import { PagingComponent } from './paging/paging.component';
import { ChatComponent } from './chat/chat.component';
import { AuthFundiClientAdminGuard } from '../guards/AuthFundiClientAdminGuard';
import { ClientFundiContractComponent } from './clientfundi-contract/clientfundicontract.component';
import { TermsAndConditionsComponent } from './terms-conditions-service/termAndConditions.component'; 
import { ClientSubscriptionComponent } from './clientsubscription/clientsubscription.component';
import { AuthenticatedUserOveridesComponent } from './roles/authenticateduser/authenticateduser.component';
import { AdvertComponent } from './advert/advert.component';
import { BlogsComponent } from './blogs/blogs.component';
import { ResetPasswordComponent } from './resetpassword/resetpassword.component';
import { FundiContractComponent } from './fundi-contracts/fundicontract.component';
import { AuthFundiAdminGuard } from '../guards/AuthFundiAdminGuard';
import { ClientAddressComponent } from './crud-operations/client-address/client-address.component';
import { FundiAddressComponent } from './crud-operations/fundi-address/fundi-address.component';
import { FundiRatingComponent } from './fundi-rating/fundirating.component';
import { AuthClientAdminGuard } from '../guards/AuthClientAdminGuard';
import { AuthClientSubscriptionGuard } from '../guards/AuthClientSubscriptionGuard';
import { AuthFundiGuestGuard } from '../guards/AuthFundiGuestGuard';
import { ToFixedPipe } from '../pipes/roundpipe';

@NgModule({
    declarations: [
        AppComponent,
        NavMenuComponent,
        HomeComponent,
        ActiveCrudOperationsComponent,
        FetchDataComponent,
        LocationComponent,
        LoginComponent,
        ForgotPasswordComponent,
        RegisterComponent,
        ForgotPasswordComponent,
        UserRolesComponent,
        ContactUsComponent,
        AboutUsComponent,
        SectionsContactComponent,
        PayPalSuccessComponent,
        PayPalFailureComponent,
        NewRolesComponent,
        QrCodeComponent,
        AddressComponent,
        LocationComponent,
        CompanyComponent,
        SuccessComponent,
        FailureComponent,
        AuthenticatedUserOveridesComponent,
        GuestRoleComponent,
        FundiRoleComponent,
        ClientRoleComponent,
        TwitterProfileFeedsComponent,
        ProfileComponent,
        ProfileCreateComponent,
        CoursesComponent,
        CertificationComponent,
        WorkCategoryComponent,
        CourseCrudComponent,
        CertificationCrudComponent,
        WorkCategoryCrudComponent,
        ClientFundiSearchComponent,
        FundiProfileByIdComponent,
        ClientProfileComponent,
        FundiJobSearchComponent,
        FundiSubscriptionComponent,
        ClientSubscriptionComponent,
        VehicleMonitorComponent,
        myRecaptchaComponent,
        ClientJobViewComponent,
        WorkSubCategoryCrudComponent,
        FundiEngagementComponent,
        PagingComponent,
        ChatComponent,
        TermsAndConditionsComponent,
        ClientFundiContractComponent,
        AdvertComponent,
        BlogsComponent,
        ResetPasswordComponent,
        FundiContractComponent,
        FundiAddressComponent,
        ClientAddressComponent,
        FundiRatingComponent,
        ToFixedPipe

    ],
    imports: [
        BrowserModule.withServerTransition({ appId: 'ng-cli-universal' }),
        HttpClientModule,
        FormsModule,
        RouterModule.forRoot([
            { path: '', component: HomeComponent, pathMatch: 'full' },
            { path: 'home', component: HomeComponent },
            { path: 'manage-entities', component: ActiveCrudOperationsComponent, canActivate: [AdminAuthGuard] },
            { path: 'chat', component: ChatComponent, canActivate: [AuthFundiClientAdminGuard] },
            { path: 'create-profile', component: ProfileCreateComponent, canActivate: [AuthGuard] },
            { path: 'Fundi', component: FundiRoleComponent, canActivate: [AuthGuard] },
            { path: 'add-location', component: LocationComponent, canActivate: [AdminAuthGuard] },
            { path: 'login', component: LoginComponent },
            { path: 'register', component: RegisterComponent },
            { path: 'scanqrcode', component: QrCodeComponent, canActivate: [AuthGuard] },
            { path: 'forgot-password', component: ForgotPasswordComponent },
            { path: 'reset-password', component: ResetPasswordComponent },
            { path: 'logout', component: HomeComponent },
            { path: 'manage-roles', component: UserRolesComponent, canActivate: [AdminAuthGuard] },
            { path: 'contactus', component: ContactUsComponent },
            { path: 'aboutus', component: AboutUsComponent },
            { path: 'paypal-success', component: PayPalSuccessComponent },
            { path: 'paypal-failure', component: PayPalFailureComponent },
            { path: 'success', component: SuccessComponent },
            { path: 'failure', component: FailureComponent },
            { path: 'authenticated-entities-override', component: AuthenticatedUserOveridesComponent, canActivate: [AuthGuard] },
            { path: 'fundi-locations', component: VehicleMonitorComponent, canActivate: [AuthGuard] },
            { path: 'guest', component: GuestRoleComponent, canActivate: [AuthGuard] },
            { path: 'client', component: ClientRoleComponent, canActivate: [AuthClientGuard] },
            { path: 'clientsearch', component: ClientFundiSearchComponent, canActivate: [AuthClientAdminGuard] },
            { path: 'fundiprofile-by-id', component: FundiProfileByIdComponent, canActivate: [AuthGuard] },
            { path: 'client-create-job', component: ClientProfileComponent, canActivate: [AuthClientSubscriptionGuard] },
            { path: 'manage-profile', component: ProfileComponent, canActivate: [AuthFundiAdminGuard] }, 
            { path: 'job-details', component: ClientJobViewComponent, canActivate: [AuthGuard] },
            { path: 'fundi-subscription', component: FundiSubscriptionComponent, canActivate: [AuthFundiGuestGuard] },
            { path: 'client-subscription', component: ClientSubscriptionComponent, canActivate: [AuthClientSubscriptionGuard] },
            { path: 'fundi-search-job', component: FundiJobSearchComponent, canActivate: [AuthFundiAdminGuard] },
            { path: 'client-fundi-contract', component: ClientFundiContractComponent, canActivate: [AuthFundiClientAdminGuard] },
            { path: 'fundi-contract', component: FundiContractComponent, canActivate: [AuthFundiAdminGuard] },
            { path: 'terms-and-conditions', component: TermsAndConditionsComponent },
            { path: 'rate-fundiprofile-by-id', component: FundiRatingComponent, canActivate: [AuthClientAdminGuard] },
            { path: 'blogs', component: BlogsComponent }
        ])
    ],
    providers: [
        { provide: AuthGuard, useClass: AuthGuard },
        { provide: HttpClient, useClass: HttpClient },
        { provide: MyFundiService, useClass: MyFundiService },
        { provide: AdminAuthGuard, useClass: AdminAuthGuard },
        { provide: AuthFundiGuard, useClass: AuthFundiGuard },
        { provide: AuthFundiGuestGuard, useClass: AuthFundiGuestGuard }, 
        { provide: AuthClientGuard, useClass: AuthClientGuard },
        { provide: AuthFundiAdminGuard, useClass: AuthFundiAdminGuard },
        { provide: AuthClientAdminGuard, useClass: AuthClientAdminGuard },
        { provide: AuthClientSubscriptionGuard, useClass: AuthClientSubscriptionGuard }, 
        { provide: AuthFundiClientAdminGuard, useClass: AuthFundiClientAdminGuard },
        { provide: AuthFundiSubscriptionGuard, useClass: AuthFundiSubscriptionGuard },
        { provide: ToFixedPipe, useClass: ToFixedPipe },
        { provide: HTTP_INTERCEPTORS, useClass: AppInterceptor, multi: true },
        { provide: APP_BASE_HREF, useValue: '/myFundi/' },
    ],
    bootstrap: [AppComponent]
})
export class AppModule { }
