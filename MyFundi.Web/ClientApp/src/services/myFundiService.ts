import { HttpClient, HttpHeaders } from '@angular/common/http';
import 'rxjs/add/operator/map';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Binary } from '@angular/compiler';
import { APP_BASE_HREF } from '@angular/common';
import * as google from '../assets/google/googleMaps.js';
import * as $ from 'jquery';
declare const google: any;

@Injectable()
export class MyFundiService {
 
    private baseServerUrl: string = /*"https://localhost:44343";*/ "https://myfundiv2.martinlayooinc.com";

    public constructor(private httpClient: HttpClient) {
    }
    public static isLoginPage: boolean = false;
    public actionResult: any;
    public getAllRoles: string = this.baseServerUrl + "/Account/GetAllRoles";
    public getTwitterFeedsUrl: string = this.baseServerUrl + "/SocialMedia/TwitterProfileFeeds";
    public getCityLocationWeatherFocus: string = this.baseServerUrl + "/api/LocationWeather/GetLocationWeather";

    public getUserGuidIdUrl: string = this.baseServerUrl + "/Account/GetUserGuidId";
    public getAllUserRoles: string = this.baseServerUrl + "/Account/GetAllUserRoles";
    public postOrCreateCourseUrl: string = this.baseServerUrl + "/Administration/PostOrCreateCourse";
    public updateworkCategoryUrl: string = this.baseServerUrl + "/FundiProfile/UpdateworkCategory";
    public updateCourseUrl: string = this.baseServerUrl + "/Administration/UpdateCourse";
    public deleteworkCategoryByIdUrl: string = this.baseServerUrl + "/Administration/DeleteworkCategory";
    public deleteCourseUrl: string = this.baseServerUrl + "/Administration/DeleteCourse";
    public getworkCategoryByIdUrl: string = this.baseServerUrl + "/Administration/GetworkCategoryById";
    public getCourseByIdUrl: string = this.baseServerUrl + "/Administration/GetCourseById"; 
    public postCreateWorkCategoryUrl: string = this.baseServerUrl + "/FundiProfile/PostCreateWorkCategory";
    public postOrCreateWorkSubCategoryUrl: string = this.baseServerUrl + "/FundiProfile/PostOrCreateWorkSubCategory"; 
    public updateWorkSubCategoryUrl: string = this.baseServerUrl + "/FundiProfile/UpdateWorkSubCategory";
    public deleteWorkSubCategoryUrl: string = this.baseServerUrl + "/FundiProfile/DeleteWorkSubCategory";
    public rateFundiByProfileIdUrl: string = this.baseServerUrl + "/FundiProfile/RateFundiByProfileId";
    public addFundiWorkCategorUrl: string = this.baseServerUrl + "/FundiProfile/AddFundiWorkCategory";
    public addFundiCertificateUrl: string = this.baseServerUrl + "/FundiProfile/AddFundiCertificate";
    public addFundiCourseUrl: string = this.baseServerUrl + "/FundiProfile/AddFundiCourse"; 
    public getFundiProfileRatingByIdUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiProfileRatingById";
    public getFundiCoursesUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiCoursesTaken";
    public getFundiRatingsUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiRatings";
    public payMonthlySubscriptionFeeUrl: string = this.baseServerUrl + "/FundiProfile/PayMonthlySubscriptionFee";
    public getFundiSkillsByProfileIdUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiSkillsByFundiProfileId";
    public getFundiWorkCategoriesByFundiProfileIdUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiWorkCategoriesByFundiProfileId";
    public getFundiWorkCategoriesUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiWorkCategories";
    public getFundiCertificationsUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiCertifications"; 
    public getAllFundiWorkCategoriesUrl: string = this.baseServerUrl + "/FundiProfile/GetAllFundiWorkCategories";
    public getAllFundiWorkSubCategoriesByWorkCategoryIdUrl: string = this.baseServerUrl + "/FundiProfile/GetAllFundiWorkSubCategoriesByWorkCategoryId";
    public getAllFundiCertificatesUrl: string = this.baseServerUrl + "/FundiProfile/GetAllFundiCertificates";
    public saveOrupdateClientProfileUrl: string = this.baseServerUrl + "/ClientProfile/CreateOrUpdateClientProfile";
    public updateJobUrl: string = this.baseServerUrl + "/ClientProfile/UpdateJob";
    public createOrUpdateClientJobUrl: string = this.baseServerUrl + "/ClientProfile/CreateOrUpdateClientJob";
    public getJobWorkCategoriesByJobIdUrl: string = this.baseServerUrl + "/ClientProfile/GetJobWorkCategoriesByJobId";
    public getWorkSubCategoriesBySubCategoryIdUrl: string = this.baseServerUrl + "/ClientProfile/GetWorkSubCategoriesBySubCategoryId";
    public getAllclientProfilesUrl: string = this.baseServerUrl + "/ClientProfile/GetAllClientProfiles"; 
    public getResultsRemoveWorkCategorFromJobIdUrl: string = this.baseServerUrl + "/ClientProfile/GetResultsRemoveWorkCategoryFromJobId";

    public getJobsByCategoriesAndFundiUserUrl: string = this.baseServerUrl + "/FundiProfile/JobsByCategoriesAndFundiUser";
    public postAllFundiRatingsAndReviewsByCategoriesUrl: string = this.baseServerUrl + "/FundiProfile/PostAllFundiRatingsAndReviewsByCategories";
    public updateFundiProfileUrl: string = this.baseServerUrl + "/FundiProfile/UpdateFundiProfile";
    public getFundiProfileUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiProfile";
    public getFundiProfileByProfileIdUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiProfileByProfileId";
    public getFundiLocationByFundiProfileIdUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiLocationByFundiProfileId";
    public getAllFundiProfilesUrl: string = this.baseServerUrl + "/FundiProfile/GetAllFundiProfiles";
    public getFundiUserByProfileIdUrl: string = this.baseServerUrl + "/FundiProfile/GetFundiUserByProfileId";
    public getFundiSubscriptionByProfileIdUrl: string = this.baseServerUrl + "/FundiProfile/FundiSubscriptionValidByProfileId"
    public getAllFundiCoursesUrl: string = this.baseServerUrl + "/FundiProfile/GetAllFundiCourses";
    public getUserInvoicedItems: string = this.baseServerUrl + "/Home/GetUserInvoicedItems";
    public createRoleUrl: string = this.baseServerUrl + "/Account/CreateRole";
    public deleteRoleUrl: string = this.baseServerUrl + "/Account/DeleteRole";
    public postRmoveUserFromRole: string = this.baseServerUrl + "/Account/RemoveUserFromRole";
    public postAddUserToRole: string = this.baseServerUrl + "/Account/AddUserToRole";
    public postCurrentPaymentUrl: string = this.baseServerUrl + "/Home/MakePayment";
    public getUserRolesByUsernameUrl: string = this.baseServerUrl + "/Account/GetUserRolesByUsername";
    public postLoginUrl: string = this.baseServerUrl + "/Account/Login";
    public getVerifyLoggedInUser: string = this.baseServerUrl + "/Account/VerifyLoggedInUser";
    public getLogoutUrl: string = this.baseServerUrl + "/Account/Logout";
    public postRegisterUrl: string = this.baseServerUrl + "/Account/Register";
    public postForgotPasswordUrl: string = this.baseServerUrl + "/Account/ForgotPassword";
    public static clientEmailAddress = "";
    public postSendEmail: string = this.baseServerUrl + "/AdhocReporting/SendEmail";
    public postVerifyQrcodeScan: string = this.baseServerUrl + "/AdhocReporting/GetClientEmailAndMobilePhoneNumber";
    
    public getJobByJobIdUrl: string = this.baseServerUrl + "/ClientProfile/getJobByJobId";

    public getFundiLocationByUsernameUrl: string = this.baseServerUrl + "GetFundiProfile";
    public getClientUserByIdUrl: string = this.baseServerUrl + "/ClientProfile/GetClientUserById";
    public getAllClientJobByClientProfileIdUrl: string = this.baseServerUrl + "/ClientProfile/GetAllClientJobByClientProfileId";
    public getClientProfileUrl: string = this.baseServerUrl + "/ClientProfile/GetClientProfile";
    public getClientProfileByIdUrl: string = this.baseServerUrl + "/ClientProfile/GetClientProfileById";
    public postOrCreateCompanyUrl: string = this.baseServerUrl + "/Company/PostOrCreateCompany";
    public updateCompanyUrl: string = this.baseServerUrl + "/Company/UpdateCompany";
    public getAllCompaniesUrl: string = this.baseServerUrl + "/Company/GetAllCompanies";
    public getCompanyByIdUrl: string = this.baseServerUrl + "/Company/GetCompanyById";
    public deleteCompanyUrl: string = this.baseServerUrl + "/Company/DeleteCompany";


    public getAllJobsUrl: string = this.baseServerUrl + "/Home/GetAllJobs";

    public postOrCreateCertificationUrl: string = this.baseServerUrl + "/Administration/PostOrCreateCertification";
    public updateCertificationUrl: string = this.baseServerUrl + "/Administration/UpdateCertification";
    public getAllCertificationUrl: string = this.baseServerUrl + "/Administration/GetAllCertification";
    public getCertificationByIdUrl: string = this.baseServerUrl + "/Administration/GetCertificationById";
    public deleteCertificationUrl: string = this.baseServerUrl + "/Administration/DeleteCertification"

    public postRemoveFundiFromMonitorUrl: string = this.baseServerUrl + "/AdhocReporting/RemoveFundiFromMonitor";
    public getFundiMobileLocationAppUrl: string = this.baseServerUrl + "/AdhocReporting/GetLocationEmitterApp";
    public getFundiRealTimeLocationsUrl: string = this.baseServerUrl + "/AdhocReporting/GetFundiLiveLocations";

    public postOrCreateAddressUrl: string = this.baseServerUrl + "/LocationAndAddress/PostOrCreateAddress";
    public updateAddressUrl: string = this.baseServerUrl + "/LocationAndAddress/UpdateAddress";
    public getAllAddressesUrl: string = this.baseServerUrl + "/LocationAndAddress/GetAllAddresses";
    public getAddressByIdUrl: string = this.baseServerUrl + "/LocationAndAddress/GetAddressById";
    public deleteAddressUrl: string = this.baseServerUrl + "/LocationAndAddress/DeleteAddress";

    public postOrCreateLocationUrl: string = this.baseServerUrl + "/LocationAndAddress/PostOrCreateLocation";
    public updateLocationUrl: string = this.baseServerUrl + "/LocationAndAddress/UpdateLocation";
    public getAllLocationsUrl: string = this.baseServerUrl + "/LocationAndAddress/GetAllLocations";
    public getLocationByIdUrl: string = this.baseServerUrl + "/LocationAndAddress/GetLocationById";
    public deleteLocationUrl: string = this.baseServerUrl + "/LocationAndAddress/DeleteLocation";

    public static actUserStatus: IUserStatus = {
        isUserLoggedIn: false,
        isUserAdministrator: false
    };
    public static userDetails: IUserDetail = {
        emailAddress: "",
        username: "",
        mobileNumber: "",
        password: "",
        keepLoggedIn: false,
        repassword: "",
        role: "",
        firstName: "",
        lastName: "",
        authToken: "",
        fundi: false,
        client: false
    }
    public static userRoles = []

    public GetUserRolesByUsername(username: string): Observable<string[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl: string = this.getUserRolesByUsernameUrl + "/" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): string[] => {
            let roles: string[] = res;
            return roles;
        });
    }
    GetClientProfileById(clientProfileId: number): Observable<IClientProfile> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getClientProfileByIdUrl + "/" + clientProfileId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): IClientProfile => {
            let clientProf: IClientProfile = res;
            return clientProf;
        });
    } 

    GetClientUserById(clientUserId: string): Observable<IUserDetail> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getClientUserByIdUrl + "/" + clientUserId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): IUserDetail => {
            let clientUser: IUserDetail = res;
            return clientUser;
        });
    }

    GetJobByJobId(jobId: number): Observable<IJob> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getJobByJobIdUrl + "/" + jobId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): IJob => {
            let job: IJob = res;
            return job;
        });
    }
    public static SetUserEmail(userEmailAddress: string) {
        MyFundiService.clientEmailAddress = userEmailAddress;
    }
    public GetJobWorkCategoriesByJobId(jobId: number): Observable<any[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getJobWorkCategoriesByJobIdUrl+"/"+jobId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): string[] => {
            let jobwkCats: any[] = res;
            return jobwkCats;
        });
    }
    public GetAllRoles(): Observable<any> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllRoles;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): object[] => {
            let roles: object[] = res;
            return roles;
        });
    }
    RemoveWorkCategorFromJobId(jobId: any, workCategoryId: number): Observable<boolean> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getResultsRemoveWorkCategorFromJobIdUrl + "/" + jobId + "/" + workCategoryId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): boolean => {
            let hasRemovedWorkCategoryFromJob: boolean = res;
            return hasRemovedWorkCategoryFromJob;
        });
    }
    GetworkSubCategoryById(workSubCatValue: number): Observable<any> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getWorkSubCategoriesBySubCategoryIdUrl + "/" + workSubCatValue;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): string[] => {
            let jobwkCats: any[] = res;
            return jobwkCats;
        });
    }

    CreateWorkSubCategory(workSubCategory: IWorkSubCategory): Observable<any> {
        var body = JSON.stringify(workSubCategory);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postOrCreateWorkSubCategoryUrl,
            headers: headers,
            body: body
        }; headers.append('Content-Type', 'application/json');

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    UpdateWorkSubCategory(workSubCategory: IWorkSubCategory): Observable<any> {
        var body = JSON.stringify(workSubCategory);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.updateWorkSubCategoryUrl,
            headers: headers,
            body: body
        }; headers.append('Content-Type', 'application/json');

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    DeleteworkSubCategory(workSubCategory: IWorkSubCategory): Observable<any> {
        var body = JSON.stringify(workSubCategory);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.deleteWorkSubCategoryUrl,
            headers: headers,
            body: body
        }; headers.append('Content-Type', 'application/json');

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    GetAllClientProfiles(): Observable<IProfile[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllclientProfilesUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): IProfile[] => {
            let clientProfiles: IProfile[] = res;
            return clientProfiles;
        });
    }
    
    GetFundiProfileRatingById(fundiProfileId: number):Observable<any> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiProfileRatingByIdUrl + "/" + fundiProfileId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): any => {
            let fundiProfileRating: any = res;
            return fundiProfileRating;
        });
    }

    GetAllFundiProfiles(): Observable<IProfile[]> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllFundiProfilesUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): IProfile[] => {
            let fundiProfiles: IProfile[] = res;
            return fundiProfiles;
        });
    }
    GetFundiSubscriptionByProfileId(profileId: number): Observable<boolean> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiSubscriptionByProfileIdUrl + "/" + profileId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            let isSubscribed: boolean = res;
            return isSubscribed;
        });
    }
    GetFundiUserByProfileId(profileId: number) {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiUserByProfileIdUrl + "/" + profileId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): object[] => {
            let courses: object[] = res;
            return courses;
        });
    }

    public GetAllCourses(): Observable<any> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllFundiCoursesUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): object[] => {
            let courses: object[] = res;
            return courses;
        });
    }
    public GetClientProfile(username: string): Observable<any> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getClientProfileUrl + "/" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            let clientProfile: IProfile = res;
            return clientProfile;
        });
    }

    public GetFundiLocationByFundiProfileId(profileId: number): Observable<any> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiLocationByFundiProfileIdUrl + "/" + profileId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            let location: any = res;
            return location;
        });
    }
    public GetFundiProfileByProfileId(profileId: string): Observable<any> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiProfileByProfileIdUrl + "/" + profileId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            let fundiProfile: IProfile = res;
            return fundiProfile;
        });
    }
    public GetFundiProfile(username: string): Observable<any> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiProfileUrl + "?username=" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            let fundiProfile: IProfile = res;
            return fundiProfile;
        });
    }
    public GetAllFundiCertificates(): Observable<any> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllFundiCertificatesUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): object[] => {
            let certificates: object[] = res;
            return certificates;
        });
    }
    public GetFundiSkillsByProfileId(fundiProfileId: number): Observable<string[]> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiSkillsByProfileIdUrl + "?fundiProfileId=" + fundiProfileId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): string[] => {
            let workCategories: string[] = res;
            return workCategories;
        });
    }
    public GetFundiWorkCategoriesByProfileId(fundiProfileId: number): Observable<string[]> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiWorkCategoriesByFundiProfileIdUrl + "?fundiProfileId=" + fundiProfileId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): string[] => {
            let workCategories: string[] = res;
            return workCategories;
        });
    }
    public GetFundiWorkCategories(username: string): Observable<IWorkCategory[]> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiWorkCategoriesUrl + "?username=" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): IWorkCategory[] => {
            let workCategories: IWorkCategory[] = res;
            return workCategories;
        });
    }

    public GetFundiRatings(username: string): Observable<IFundiRating[]> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiRatingsUrl + "?username=" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): IFundiRating[] => {
            let certs: IFundiRating[] = res;
            return certs;
        });
    }
    public GetFundiCertifications(username: string): Observable<ICertification[]> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiCertificationsUrl + "?username=" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): ICertification[] => {
            let certs: ICertification[] = res;
            return certs;
        });
    }
    public GetFundiCourses(username: string): Observable<ICourse[]> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiCoursesUrl + "?username=" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): ICourse[] => {
            let courses: ICourse[] = res;
            return courses;
        });
    }
    public GetAllFundiWorkCategories(): Observable<any> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllFundiWorkCategoriesUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): object[] => {
            let workCategories: object[] = res;
            return workCategories;
        });
    }


    GetAllFundiWorkSubCategoriesByWorkCategoryId(workCategoryId: number) {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllFundiWorkSubCategoriesByWorkCategoryIdUrl+`/${workCategoryId}`;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): object[] => {
            let workCategories: object[] = res;
            return workCategories;
        });
    }

    public GetAllFundiCourses(): Observable<any> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllFundiCoursesUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): object[] => {
            let workCategories: object[] = res;
            return workCategories;
        });
    }
    public CreateWorkCategory(workCategory: IWorkCategory): Observable<boolean> {

        let body = JSON.stringify(workCategory);
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postCreateWorkCategoryUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public PayMonthlySubscriptionFee(subscriptionFee: any): Observable<any> {
        let body = JSON.stringify(subscriptionFee);
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.payMonthlySubscriptionFeeUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public AddFundiWorkCategory(workCategoryId: number, username: string): Observable<boolean> {

        let body = JSON.stringify({ workCategoryId: workCategoryId, username: username });
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.addFundiWorkCategorUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    RateFundiByProfileId(fundiRated: any): Observable<any> {

        let body = JSON.stringify(fundiRated);
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.rateFundiByProfileIdUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }


    public AddFundiCourse(courseId: number, username: string): Observable<boolean> {

        let body = JSON.stringify({ courseId: courseId, username: username });
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.addFundiCourseUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public AddFundiCertificate(certificateId: number, username: string): Observable<boolean> {

        let body = JSON.stringify({ certificationId: certificateId, username: username });
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.addFundiCertificateUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    GetTwitterFeeds(): Observable<any[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getTwitterFeedsUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): any[] => {
            let twitterFeeds: any[] = res;
            return twitterFeeds;
        });
    }
    GetSearchLocationWeather(city: string, country: string): Observable<ILocationWeather> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getCityLocationWeatherFocus + "/" + city + "/" + country;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((weatherFocus: any) => {
            return weatherFocus;
        });
    }
    public GetUserGuidId(username: string): Observable<string> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getUserGuidIdUrl + "?username=" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): string => {
            let userId: string = res;
            return userId;
        });
    }
    public GetUserInvoicedItems(username: string): Observable<IInvoice[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getUserInvoicedItems + "?username=" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): IInvoice[] => {
            let invoices: IInvoice[] = res;
            return invoices;
        });
    }

    public GetAllUserRoles(username: string): Observable<string[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllUserRoles + "?username=" + username;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any): string[] => {
            let roles: string[] = res;
            return roles;
        });
    }
    public CreateUserRole(role: string): Observable<any> {
        let body = JSON.stringify({ role: role });

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.createRoleUrl,
            method: 'POST',
            headers: headers,
            body: body
        };

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public VerifyQrcodeScan(userDetail: IUserDetail): Observable<any> {
        let body = JSON.stringify(userDetail);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postVerifyQrcodeScan,
            method: 'POST',
            headers: headers,
            body: body
        };

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public DeleteUserRole(role: string): Observable<any> {
        let body = JSON.stringify({ role: role });

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.deleteRoleUrl,
            method: 'POST',
            headers: headers,
            body: body
        };

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public AddUserToRole(email: string, role: string): Observable<any> {
        let body = JSON.stringify({ email: email, role: role });

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postAddUserToRole,
            method: 'POST',
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public SendEmail(body: FormData): Observable<any> {
        const headers = new HttpHeaders({ 'Content-Type': 'multipart/form-data' });
        let requestOptions: any = {
            url: this.postSendEmail,
            headers: headers
        };

        return this.httpClient.post(requestOptions.url, body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public RemoveUserFromRole(email: string, role: string): Observable<any> {
        let body = JSON.stringify({ email: email, role: role });

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postRmoveUserFromRole,
            headers: headers,
            body: body
        };

        return this.httpClient.post(requestOptions.url, body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public VerifyLoggedInUser(): any {
        let headers = new HttpHeaders({ 'Content-Type': 'application/x-www-form-urlencoded' });
        let requestUrl = this.getVerifyLoggedInUser;
        let requestOptions: any = {
            url: requestUrl,
            headers: headers
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });

    }
    public LoginByPost(userDetail: IUserDetail): Observable<any> {
        let body = JSON.stringify(userDetail);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postLoginUrl,
            headers: headers,
            body: body
        };

        return this.httpClient.post(requestOptions.url, body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public LogOut(): Observable<any> {

        return this.httpClient.get(this.getLogoutUrl + "?userEmail=" + MyFundiService.userDetails.emailAddress).map((res: any) => {
            return res;
        });
    }
    public GetRequest(url): Observable<any> {

        return this.httpClient.get(url).map((res: any) => {
            return res;
        });
    }

    public registerByPost(userDetail: IUserDetail): Observable<any> {
        let body = JSON.stringify(userDetail);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postRegisterUrl,
            headers: headers,
            body: body
        };

        return this.httpClient.post(requestOptions.url, body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public forgotPasswordByPost(userDetail: IUserDetail): Observable<any> {
        let body = JSON.stringify(userDetail);
        var actionResult: any;

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postForgotPasswordUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public GetAllAddresses(): Observable<IAddress[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllAddressesUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public GetAllClientJobByClientProfileId(clientProfileId: number): Observable<IJob[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllClientJobByClientProfileIdUrl + "/" + clientProfileId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public GetAddressById(addressId: number): Observable<IAddress> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAddressByIdUrl + "/" + addressId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public DeleteAddress(address: IAddress): any {
        let body: string = JSON.stringify(address);
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.deleteAddressUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'POST',
            headers: headers,
            responseType: 'application/json',
            body: body
        };

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public GetAllLocations(): Observable<ILocation[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllLocationsUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    GetJobsByCategoriesAndFundiUser(categories: any[], fundiProfileId: number, distanceKmLimitApart:number, skip:number=0, take:number=5 ): Observable<any> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let body: string = JSON.stringify(categories);


        let requestUrl = this.getJobsByCategoriesAndFundiUserUrl + `/${fundiProfileId}/${distanceKmLimitApart}/${skip}/${take}`;
        let requestOptions: any = {
            url: requestUrl,
            method: 'POST',
            headers: headers,
            body: body,
            responseType: 'application/json'
        };

        return this.httpClient.post(requestOptions.url, body, { 'headers': requestOptions.headers }).map((res: any) => {

            return res;
        });
    }
    GetFundiRatingsAndReviews(categories: string[], jobLocationCoordinate: ICoordinate): Observable<any> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let body: string = JSON.stringify({ categories: categories, coordinate: jobLocationCoordinate });

        let requestUrl = this.postAllFundiRatingsAndReviewsByCategoriesUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'POST',
            headers: headers,
            body: body,
            responseType: 'application/json'
        };

        return this.httpClient.post(requestOptions.url, body, { 'headers': requestOptions.headers }).map((res: any) => {

            return res;
        });
    }

    public GetLocationById(locationId: number): Observable<ILocation> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getLocationByIdUrl + "/" + locationId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public DeleteLocation(location: ILocation): any {
        let body: string = JSON.stringify(location);
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.deleteLocationUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'POST',
            headers: headers,
            responseType: 'application/json',
            body: body
        };

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public GetUserDetails(): any {
        return localStorage.getItem("userDetails");
    }

    public GetAllCertification(): Observable<ICertification[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllCertificationUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public GetCourseById(csId: number): Observable<ICompany> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getCourseByIdUrl + "?courseId=" + csId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public GetCertificationById(certId: number): Observable<ICompany> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getCertificationByIdUrl + "?certificationId=" + certId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    GetAllJobs(): Observable<IJob[]> {

        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllJobsUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }


    public GetAllCompanies(): Observable<ICompany[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getAllCompaniesUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public GetCompanyById(companyId: number): Observable<ICompany> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getCompanyByIdUrl + "/" + companyId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public DeleteCompany(company: ICompany) {
        let body: string = JSON.stringify(company);
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.deleteCompanyUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'POST',
            headers: headers,
            responseType: 'application/json',
            body: body
        };

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public PostOrCreateCourse(course: ICourse): Observable<any> {
        let body = JSON.stringify(course);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postOrCreateCourseUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public PostOrCreateLocation(location: ILocation): Observable<any> {
        let body = JSON.stringify(location);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postOrCreateLocationUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public UpdateLocation(location: ILocation): Observable<any> {
        let body = JSON.stringify(location);
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.updateLocationUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    PostToRecaptchaVerify(googleUrl: string, dataStr: string): Promise<any> {
        let body = dataStr;
        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: googleUrl,
            headers: headers,
            body: body
        };

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).toPromise();
    }
    public PostOrCreateAddress(address: IAddress): Observable<any> {
        let body = JSON.stringify(address);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postOrCreateAddressUrl,
            headers: headers,
            body: body
        };

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public UpdateAddress(address: IAddress): Observable<any> {
        let body = JSON.stringify(address);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.updateAddressUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public PostOrCreateCompany(company: ICompany): Observable<any> {
        let body = JSON.stringify(company);
        var actionResult: any;

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postOrCreateCompanyUrl,
            headers: headers,
            body: body
        }; headers.append('Content-Type', 'application/json');

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    createOrUpdateClientJob(job: any): Observable<any> {
        let body = JSON.stringify(job);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.createOrUpdateClientJobUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    UpdateJob(job: any): Observable<any> {
        let body = JSON.stringify(job);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.updateJobUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public PostOrCreateCertification(certification: ICertification): Observable<any> {
        let body = JSON.stringify(certification);
        var actionResult: any;

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postOrCreateCertificationUrl,
            headers: headers,
            body: body
        }; headers.append('Content-Type', 'application/json');

        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public DeleteCourse(cert: ICourse) {
        let body = JSON.stringify(cert);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.deleteCourseUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public DeleteworkCategory(cert: IWorkCategory) {
        let body = JSON.stringify(cert);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.deleteworkCategoryByIdUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public DeleteCertification(cert: ICertification) {
        let body = JSON.stringify(cert);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.deleteCertificationUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public UpdateCertification(cert: ICertification): Observable<any> {
        let body = JSON.stringify(cert);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.updateCertificationUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }

    public GetworkCategoryById(workCategoryId: number): Observable<ICompany> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getworkCategoryByIdUrl + "?workCategoryId=" + workCategoryId;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public SaveProfile(profile: IProfile): Observable<any> {
        let body = JSON.stringify(profile);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.updateFundiProfileUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public SaveClientProfile(profile: IClientProfile): Observable<any> {
        let body = JSON.stringify(profile);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.saveOrupdateClientProfileUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public UpdateCourse(wc: ICourse): Observable<any> {
        let body = JSON.stringify(wc);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.updateCourseUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public UpdateWorkCategory(wc: IWorkCategory): Observable<any> {
        let body = JSON.stringify(wc);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.updateworkCategoryUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public UpdateCompany(company: ICompany): Observable<any> {
        let body = JSON.stringify(company);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.updateCompanyUrl,
            headers: headers,
            body: body
        };
        return this.httpClient.post(requestOptions.url, requestOptions.body, { 'headers': requestOptions.headers }).map((res: any) => {
            return res;
        });
    }
    public RemoveFundiFromMonitor(selectedFundi: IFundiLocationMonitor): Observable<any> {
        let body = JSON.stringify(selectedFundi);

        const headers = new HttpHeaders({ 'content-type': 'application/json' });

        let requestOptions: any = {
            url: this.postRemoveFundiFromMonitorUrl,
            headers: headers,
            body: body
        };

        return this.httpClient.post(requestOptions.url, body, { 'headers': requestOptions.headers }).
            map((res: any) => {
                return res;
            });
    }
    public GetFundiMobileLocationApp(appType: string): Observable<Blob> {

        let requestUrl = this.getFundiMobileLocationAppUrl + "/" + appType;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            responseType: 'blob'
        };

        return this.httpClient.get(requestOptions.url, requestOptions).map((res: any) => {
            let result: Blob = res;
            return result;
        });
    }
    public GetFundiRealTimeLocations(): Observable<IFundiLocationMonitor[]> {
        const headers = new HttpHeaders({ 'content-type': 'application/json' });
        let requestUrl = this.getFundiRealTimeLocationsUrl;
        let requestOptions: any = {
            url: requestUrl,
            method: 'GET',
            headers: headers,
            responseType: 'application/json'
        };

        return this.httpClient.get(requestOptions.url, { 'headers': requestOptions.headers }).map((res: any) => {
            let results: IFundiLocationMonitor[] = res;
            return results;
        });
    }

}
export interface IFundiLocationMonitor {
    fundiUserDetails: IUserDetail | any;
    phoneNumber: string;
    lattitude: number;
    longitude: number;
}
export interface IExtraCharges {
    tourClientId: number;
    tourClientExtraChargesId: number;
    extraCharges: number;
    description: string;
}
export interface IInvoice {
    invoiceId: number;
    invoiceName: string;
    netCost: number;
    percentTaxAppliable: number;
    grossTotalCost: number;
    dateUpdated: Date;
    dateCreated: Date;
}
export interface IVehicle {
    vehicleId: number;
    inGoodCondition: boolean;
    companyId: number;
    company: ICompany;
    vehicleRegistration: string;
    vehicleCategory: IVehicleCategory;
    vehicleCapacityId: number;
    vehicleCategoryId: number;
}
export interface IVehicleCategory {
    vehicleCategoryId: number;
    vehicleCategoryName: string;
    description: string;
}

export interface IAddress {
    addressId: number;
    addressLine1: string;
    addressLine2: string;
    town: string;
    postCode: string;
    country: string;
}
export interface IUserDetail {
    emailAddress: string | any;
    username: string;
    mobileNumber: string | any;
    password: string | any;
    keepLoggedIn: boolean;
    repassword: string;
    role: string;
    firstName: string;
    lastName: string;
    authToken: string;
    fundi: boolean,
    client: boolean
}
export interface IEmailMessage {
    emailFrom: string;
    emailTo: string;
    attachment: Blob;
    emailSubject: string;
    emailBody: string;
}
export interface IUserStatus {

    isUserLoggedIn: boolean;
    isUserAdministrator: boolean;
}
export interface ILogInStatus {
    isLoggedIn: boolean;
    isAdministrator: boolean;
    isRegistered: boolean;
    message: string;
    errorMessage: string;
    authToken: string;
}
export interface IUserRole {
    name: string;
}
export interface ICompany {
    companyId: number;
    companyName: string
    companyPhoneNUmber: string;
    locationId: number;
    location: ILocation;
}
export interface IInvoice {
    invoiceId: number;
    InvoiceName: string;
    hasFullyPaid: boolean;
}
export interface ILocation {
    locationId: number;
    country: string;
    locationName: string;
    latitude: number;
    longitude: number;
    addressId: number;
    address: IAddress;
    isGeocoded: boolean;
}

export interface IWeatherLocation {
    cityName: string;
    country: string;
}
export interface ITemperature {
    currentTemperature: number;
    maximumTemperature: number;
    minmumTemperature: number;
}
export interface ILocationWeather {
    location: IWeatherLocation;
    temperature: ITemperature;
    pressure: number;
    humidity: number;
    sunrise: string;
    sunset: string;
}

export interface IProfile {
    fundiProfileId: number;
    userId: string;
    profileSummary: string;
    profileImageUrl: string;
    skills: string;
    usedPowerTools: string;
    fundiProfileCvUrl: string;
    locationId: number;
    user: IUserDetail;
}

export interface ICoordinate {
    latitude: number;
    longitude: number;
}
export interface IClientProfile {
    clientProfileId: number;
    userId: string;
    profileSummary: string;
    profileImageUrl: string;
    addressId: number;
}
export interface IFundiRating {
    fundiRatingAndReviewId: number;
    userId: string;
    fundiProfileId: number;
    fundiProfile: any;
    rating: number;
    review: string;
    dateUpdated: Date;
}

export interface IFundiRatingDictionary {
    fundiProfileId: number,
    fundiRating: IFundiRating[]
}
export interface IWorkCategory {
    workCategoryId: number;
    workCategoryType: string;
    workCategoryDescription: string
}
export interface IWorkSubCategory {

    workSubCategoryId: number;
    workCategoryId: number;
    workSubCategoryType: string;
    workSubCategoryDescription: string
}
export interface ICertification {
    certificationId: number;
    certificationName: string;
    certificationDescription: string;
}
export interface ICourse {
    courseId: number;
    courseName: string;
    courseDescription: string
}
export interface IJob {
    jobId: number;
    jobDescription: string;
    jobName: string;
    clientProfileId: number;
    clientProfile: IClientProfile;
    clientUserId: number;
    clientUser: IUserDetail;
    hasCompleted: boolean;
    hasBeenAssignedFundi: boolean;
    locationId: number;
    location: ILocation;
    numberOfDaysToComplete: number;
    assignedFundiProfileId: number;
    assignedFundiProfile: IProfile;
    assignedFundiUserId: string;
    assignedFundiUser: IUserDetail;
    clientFundiContractId: number;
    dateCreated: Date;
    dateUpdated: Date;
}
