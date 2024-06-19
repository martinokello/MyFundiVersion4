using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.SpaServices.AngularCli;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using MyFundi.Web.ViewModels;
using AutoMapper;
using BLG.Business.Concretes;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MyFundi.AppConfigurations;
using MyFundi.DataAccess;
using MyFundi.Domain;
using MyFundi.IdentityServices;
using MyFundi.Services.EmailServices.Concretes;
using MyFundi.Services.EmailServices.Interfaces;
using MyFundi.Web.Models;
using PaymentGateway;
using PaypalFacility;
using System;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using System.Threading.Tasks;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.Services.RepositoryServices.Concretes;
using MyFundi.Services.RepositoryServices.Abstracts;
using BLG.Business;
using Microsoft.Extensions.FileProviders;
using Microsoft.AspNetCore.SpaServices;
using AesCryptoSystemExtra.AESCryptoSystem.ExternalCryptoUnit;
using MyFundiProfile.ServiceEndPoint.GeneralSevices;
using MartinLayooInc.Web.Infrastructure;
using System.Collections.Generic;
using PaymentCalculater;

namespace MyFundi.Web
{

    // This method gets called by the runtime. Use this method to add services to the container.
    public class RoleInitializationMiddleware
    {
        public async Task Invoke(HttpContext context)
        {
            var rolesInitializer = context.RequestServices.GetService<InitializeDatabaseRoles>();
            await rolesInitializer.CreateRolesAsync();
        }
    }
    public class InitializeDatabaseRoles
    {
        private readonly IServiceProvider _serviceProvider;
        public InitializeDatabaseRoles(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }
        public async Task CreateRolesAsync()
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                UserService _userService = scope.ServiceProvider.GetService<IUserService>() as UserService;
                RoleService _roleService = scope.ServiceProvider.GetService<IRoleService>() as RoleService;
                var dbContext = scope.ServiceProvider.GetService<MyFundiDBContext>();

                //var tableName = dbContext.Model.GetEntityTypes().First().GetTableName();
                // dbContext.Database.ExecuteSqlRaw($"SET IDENTITY_INSERT {tableName} ON");
                var serviceEndPoint = scope.ServiceProvider.GetService<ServicesEndPoint>();
                var unitOfWork = scope.ServiceProvider.GetService<MyFundiUnitOfWork>();

                var adminRole = new Role();
                adminRole.RoleName = "Administrator";
                UserInteractionResults result = UserInteractionResults.Failed;

                if (await _roleService.FindByNameAsync(adminRole.RoleName) == null)
                {
                    result = await _roleService.CreateAsync(adminRole);
                }
                if (await _roleService.FindByNameAsync("Fundi") == null)
                {
                    var standardUser = new Role();
                    standardUser.RoleName = "Fundi";
                    result = await _roleService.CreateAsync(standardUser);
                }
                if (await _roleService.FindByNameAsync("Client") == null)
                {
                    var roleGuest = new Role();
                    roleGuest.RoleName = "Client";
                    result = await _roleService.CreateAsync(roleGuest);
                }
                if (await _roleService.FindByNameAsync("Guest") == null)
                {
                    var roleGuest = new Role();
                    roleGuest.RoleName = "Guest";
                    result = await _roleService.CreateAsync(roleGuest);
                }
                try
                {
                    var defaultAddress = new Address { AddressLine1 = "MartinLayooInc Software Ltd.", AddressLine2 = "Unit 3, 2 St. Johns Terrace", Country = "United Kingdom", PostCode = "W10", PhoneNumber = "07809773365", Town = "London", DateCreated = DateTime.Now, DateUpdated = DateTime.Now };
                    var existingAdd = unitOfWork._addressRepository.GetAll().Where(q => q.AddressLine1 == defaultAddress.AddressLine1 &&
                    q.AddressLine2 == defaultAddress.AddressLine2 && q.Country == defaultAddress.Country &&
                    q.PostCode == defaultAddress.PostCode).FirstOrDefault();
                    if(existingAdd == null)
                        await serviceEndPoint.CreateAddress(defaultAddress);

                    var locationDefault = new Location { LocationName = "3, 2 St John's Terrace, London W10 4SB, UK", AddressId = defaultAddress.AddressId, DateCreated = DateTime.Now, DateUpdated = DateTime.Now, IsGeocoded = false, Latitude = null, Longitude = null, Country = "UK" };
                    var existingLoc = unitOfWork._locationRepository.GetAll().Where(q => q.LocationName == locationDefault.LocationName).FirstOrDefault();
                    if (existingAdd == null) 
                        await serviceEndPoint.CreateLocation(locationDefault);
                    
                    var compDefault = new Company { CompanyName = "MartinLayooInc Software", CompanyPhoneNUmber = "07809773365", DateCreated = DateTime.Now, DateUpdated = DateTime.Now, LocationId = locationDefault.LocationId };
                    var existingCom = unitOfWork._companyRepository.GetAll().Include(q=>q.Location).Where(q => q.CompanyName == compDefault.CompanyName &&
                    q.Location.LocationName == locationDefault.LocationName).FirstOrDefault();
                    if (existingCom == null)
                        await serviceEndPoint.CreateCompany(compDefault);

                    var user = new User();
                    user.Username = "administrator@martinlayooinc.com";
                    user.Email = "administrator@martinlayooinc.com";
                    user.MobileNumber = "07809773365";
                    user.FirstName = "Administrator";
                    user.LastName = "Administrator";
                    user.IsActive = true;
                    user.IsLockedOut = false;
                    user.CompanyId = compDefault.CompanyId;

                    string userPWD = "d3lt4X!505";

                    var userChecked = await _userService.FindByEmailAsync(user.Email);
                    if (userChecked == null)
                    {
                        UserInteractionResults chkUser = await _userService.CreateAsync(user, userPWD);
                    }
                    var userRoles = _roleService.GetAllUserRolesAsString(user.Username);
                    if (!userRoles.Any() || !userRoles.Where(r => r.ToLower().Equals(adminRole.RoleName.ToLower())).Any())
                    {
                        await _userService.AddToRoleAsync(user, adminRole.RoleName);
                    }
                }
                catch (Exception e)
                {

                }
            }
        }

    }
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }
        public static async Task ValidateAsync(CookieValidatePrincipalContext context)
        {
            context = context ?? throw new ArgumentNullException(nameof(context));

            String username = context.Principal.Claims.FirstOrDefault(claim => claim.Type == ClaimTypes.Email)?.Value;

            if (username == null)
            {
                context.RejectPrincipal();
                await context.HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                return;
            }

            MyFundiDBContext dbContext = context.HttpContext.RequestServices.GetRequiredService<MyFundiDBContext>();
            User user = await dbContext.Users.FirstOrDefaultAsync(u => u.Username.ToLower().Equals(username.ToLower()));

            if (user == null)
            {
                context.RejectPrincipal();
                await context.HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                return;
            }
        }
        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddCors(options =>
            {
                options.AddPolicy("CorsPolicy",
                    builder => builder.AllowAnyOrigin()
                    .AllowAnyMethod()
                    .AllowAnyHeader());
            });

            services.AddSpaStaticFiles(configuration =>
            {
                configuration.RootPath = "ClientApp/dist";
            });
            HttpClientHandler clientHandler = new HttpClientHandler();
            clientHandler.ServerCertificateCustomValidationCallback = (sender, cert, chain, sslPolicyErrors) => { return true; };

            // Pass the handler to httpclient(from you are calling api)
            HttpClient client = new HttpClient(clientHandler);

            services.AddAuthentication(options => { options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme; })
                .AddCookie("Cookies", config =>
                {
                    config.Cookie.SameSite = SameSiteMode.Lax;
                    config.ExpireTimeSpan = TimeSpan.FromMinutes(20);
                    config.LoginPath = "/Account/Login";
                    config.Cookie.Name = "LoginCookieAuth";
                    config.Cookie.HttpOnly = false;
                    config.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
                    config.Cookie.IsEssential = true;
                    config.SlidingExpiration = true;
                    //config.Events.OnValidatePrincipal = ValidateAsync;
                });
            services.AddAuthorization(config =>
            {
            });
            services.AddMvc().AddNewtonsoftJson(options =>
            {
                options.UseCamelCasing(true);
            });

            services.AddControllers().AddJsonOptions(options => options.JsonSerializerOptions.PropertyNameCaseInsensitive = true).
                AddNewtonsoftJson(options => options.UseCamelCasing(true))
                .AddXmlDataContractSerializerFormatters();
            services.AddDistributedMemoryCache();


            services.AddControllersWithViews();
            services.AddRazorPages();
            services.AddSession(options =>
            {
                // Set a short timeout for easy testing.
                options.IdleTimeout = TimeSpan.FromMinutes(15);
                options.Cookie.HttpOnly = true;
            });
            // In production, the Angular files will be served from this directory
            services.AddSpaStaticFiles(configuration =>
            {
                configuration.RootPath = "ClientApp/dist";
            });

            services.AddControllers().AddJsonOptions(options => options.JsonSerializerOptions.PropertyNameCaseInsensitive = true).
                AddNewtonsoftJson(options => options.UseCamelCasing(true))
                .AddXmlDataContractSerializerFormatters();
            services.AddDistributedMemoryCache();

            var connectionString = Configuration.GetSection("ConnectionStrings")["MyFundiConnection"];

            services.AddDbContext<MyFundiDBContext>(options =>
            {
                options.UseSqlServer(connectionString, b => b.MigrationsAssembly("MyFundi.Web"));
            });

            services.AddControllersWithViews();
            services.AddRazorPages();
            services.AddSession(options =>
            {
                // Set a short timeout for easy testing.
                options.IdleTimeout = TimeSpan.FromMinutes(15);
                options.Cookie.HttpOnly = true;
            });
            // In production, the Angular files will be served from this directory
            services.AddSpaStaticFiles(configuration =>
            {
                configuration.RootPath = "ClientApp/dist";
            });
            var mapperConfiguration = new MapperConfiguration((conf) =>
            {

                conf.CreateMap<CompanyViewModel, Company>();
                conf.CreateMap<CompanyViewModel, Company>().ReverseMap();
                conf.CreateMap<LocationViewModel, Location>();
                conf.CreateMap<LocationViewModel, Location>().ReverseMap();
                conf.CreateMap<AddressViewModel, Address>();
                conf.CreateMap<AddressViewModel, Address>().ReverseMap();
                conf.CreateMap<CertificationViewModel, Certification>();
                conf.CreateMap<CertificationViewModel, Certification>().ReverseMap();
                conf.CreateMap<ClientFundiContractViewModel, ClientFundiContract>();
                conf.CreateMap<ClientFundiContractViewModel, ClientFundiContract>().ReverseMap();
                conf.CreateMap<CourseViewModel, Course>();
                conf.CreateMap<CourseViewModel, Course>().ReverseMap();
                conf.CreateMap<FundiProfileViewModel, FundiProfile>();
                conf.CreateMap<FundiProfileViewModel, FundiProfile>().ReverseMap();
                conf.CreateMap<FundiProfileCertificationViewModel, FundiProfileCertification>();
                conf.CreateMap<FundiProfileCertificationViewModel, FundiProfileCertification>().ReverseMap();
                conf.CreateMap<FundiProfileCourseTakenViewModel, FundiProfileCourseTaken>();
                conf.CreateMap<FundiProfileCourseTakenViewModel, FundiProfileCourseTaken>().ReverseMap();
                conf.CreateMap<FundiRatingAndReviewViewModel, FundiRatingAndReview>();
                conf.CreateMap<FundiRatingAndReviewViewModel, FundiRatingAndReview>().ReverseMap();
                conf.CreateMap<FundiRatingAndReviewViewModel, FundiRatingAndReview>();
                conf.CreateMap<FundiRatingAndReviewViewModel, FundiRatingAndReview>().ReverseMap();
                conf.CreateMap<FundiWorkCategoryViewModel, FundiWorkCategory>();
                conf.CreateMap<FundiWorkCategoryViewModel, FundiWorkCategory>().ReverseMap();
                conf.CreateMap<WorkCategoryViewModel, WorkCategory>();
                conf.CreateMap<WorkCategoryViewModel, WorkCategory>().ReverseMap();
                conf.CreateMap<UserViewModel, User>();
                conf.CreateMap<UserViewModel, User>().ReverseMap();
                conf.CreateMap<ClientProfileViewModel, ClientProfile>();
                conf.CreateMap<ClientProfileViewModel, ClientProfile>().ReverseMap();
                conf.CreateMap<JobViewModel, Job>();
                conf.CreateMap<JobViewModel, Job>().ReverseMap();
                conf.CreateMap<JobWorkCategoryViewModel, JobWorkCategory>();
                conf.CreateMap<JobWorkCategoryViewModel, JobWorkCategory>().ReverseMap();
                conf.CreateMap<WorkSubCategoryViewModel, WorkSubCategory>();
                conf.CreateMap<WorkSubCategoryViewModel, WorkSubCategory>().ReverseMap();
                conf.CreateMap<MonthlySubscriptionViewModel, MonthlySubscription>();
                conf.CreateMap<MonthlySubscriptionViewModel, MonthlySubscription>().ReverseMap();
                conf.CreateMap<FundiLocationViewModel, FundiLocation>();
                conf.CreateMap<FundiLocationViewModel, FundiLocation>().ReverseMap();
                conf.CreateMap<MonthlySubscriptionViewModel, FundiSubscription>();
                conf.CreateMap<MonthlySubscriptionViewModel, FundiSubscription>().ReverseMap();
                conf.CreateMap<ClientSubscriptionViewModel, ClientSubscription>();
                conf.CreateMap<ClientSubscriptionViewModel, ClientSubscription>().ReverseMap();
                conf.CreateMap<MonthlySubscriptionViewModel, FundiSubscriptionQueue>();
                conf.CreateMap<MonthlySubscriptionViewModel, FundiSubscriptionQueue>().ReverseMap();
                conf.CreateMap<MonthlySubscriptionViewModel, MonthlySubscriptionQueue>();
                conf.CreateMap<MonthlySubscriptionViewModel, MonthlySubscriptionQueue>().ReverseMap();
                conf.CreateMap<BlogViewModel, Blog>();
                conf.CreateMap<BlogViewModel, Blog>().ReverseMap();
                conf.CreateMap<QuestionViewModel, Question>();
                conf.CreateMap<QuestionViewModel, Question>().ReverseMap();
                conf.CreateMap<AnswerViewModel, Answer>();
                conf.CreateMap<AnswerViewModel, Answer>().ReverseMap();

            });
            services.AddScoped<DiscountCalculator>(ds => new DiscountCalculator(Decimal.Parse(Configuration.GetSection("MTNApiConfig").GetSection("FundiMonthlySubscritpion").Value)));
            services.AddSingleton<MartinLayooIncChat>();
            services.AddSingleton<List<FundiLocationViewModel>>();
            services.AddScoped<AppSettingsConfigurations>();
            services.AddScoped<IMailService, EmailService>(smtp => new EmailService(Configuration));
            services.AddScoped<DbContext, MyFundiDBContext>();
            var httpClient = new BGLHttpClient();
            httpClient.HttpRequestClient = new HttpClient();

            var masterkeyDirPath = $"{Directory.GetCurrentDirectory()}\\Master";
            var masterKeyFilePath = $"{masterkeyDirPath}\\masterkey.txt";
            var paypalSettings = Configuration.GetSection("ApplicationConstants");
            services.AddScoped<PayPalHandler>(pHandle => new PayPalHandler(
              paypalSettings.GetSection("PaypalBaseUrl").Value,
              paypalSettings.GetSection("BusinessEmail").Value, 
              paypalSettings.GetSection("SuccessUrl").Value, 
              paypalSettings.GetSection("CancelUrl").Value,
              paypalSettings.GetSection("NotifyUrl").Value, 
              "",
              new DiscountCalculator(Decimal.Parse(paypalSettings.GetSection("FundiMonthlySubscritpion").Value))
              ));
            services.AddScoped<MtnAirTelHandler>(pHandle => new MtnAirTelHandler(
             Configuration.GetSection("MTNApiConfig").GetSection("MTNBaseUrl").Value,
             Configuration.GetSection("MTNApiConfig").GetSection("BusinessEmail").Value,
             Configuration.GetSection("MTNApiConfig").GetSection("SuccessUrl").Value,
             Configuration.GetSection("MTNApiConfig").GetSection("CancelUrl").Value,
             Configuration.GetSection("MTNApiConfig").GetSection("NotifyUrl").Value, "",
             Configuration.GetSection("MTNApiConfig").GetSection("Phone").Value,
             Configuration.GetSection("MTNApiConfig").GetSection("Username").Value,
             Configuration.GetSection("MTNApiConfig").GetSection("Password").Value,
             Configuration.GetSection("MTNApiConfig").GetSection("Currency").Value,
             Configuration.GetSection("MTNApiConfig").GetSection("Action").Value,
              new DiscountCalculator(Decimal.Parse(Configuration.GetSection("MTNApiConfig").GetSection("FundiMonthlySubscritpion").Value))
              ));
            services.AddScoped<Mapper>(map => new Mapper(mapperConfiguration));
            services.AddScoped<MyFundiUnitOfWork>();
            services.AddScoped<ServicesEndPoint, ServicesEndPoint>();
            services.AddTransient<BLGLocationWeatherRequests>(weatherReq => new BLGLocationWeatherRequests(httpClient, new AppSettingsConfigurations(Configuration).GetConfigSetting("OpenWeatherMapAPIKey")));
            services.AddScoped<AbstractRepository<Address>, AddressRepository>();
            services.AddScoped<AbstractRepository<Item>, ItemRepository>();
            services.AddScoped<AbstractRepository<Location>, LocationRepository>();
            services.AddScoped<AbstractRepository<Role>, RolesRepository>();
            services.AddScoped<AbstractRepository<User>, UserRepository>();
            services.AddScoped<AbstractRepository<Domain.UserRole>, UserInRolesRepository>();
            services.AddScoped<AbstractRepository<Company>, CompanyRepository>();
            services.AddScoped<AbstractRepository<Domain.Invoice>, InvoiceRepository>();
            services.AddScoped<AbstractRepository<Certification>, CertificationRepository>();
            services.AddScoped<AbstractRepository<ClientFundiContract>, ClientFundiContractRepository>();
            services.AddScoped<AbstractRepository<Course>, CourseRepository>();
            services.AddScoped<AbstractRepository<FundiProfile>, FundiProfileRepository>();
            services.AddScoped<AbstractRepository<FundiProfileCertification>, FundiProfileCertificationRepository>();
            services.AddScoped<AbstractRepository<FundiProfileCourseTaken>, FundiProfileCourseTakenRepository>();
            services.AddScoped<AbstractRepository<FundiRatingAndReview>, FundiRatingsAndReviewRepository>();
            services.AddScoped<AbstractRepository<FundiWorkCategory>, FundiWorkCategoryRepository>();
            services.AddScoped<AbstractRepository<WorkCategory>, WorkCategoryRepository>();
            services.AddScoped<AbstractRepository<ClientProfile>, ClientProfileRepository>();
            services.AddScoped<AbstractRepository<Job>, JobRepository>();
            services.AddScoped<AbstractRepository<JobWorkCategory>, JobWorkCategoryRepository>();
            services.AddScoped<AbstractRepository<WorkSubCategory>, WorkSubCategoryRepository>();
            services.AddScoped<AbstractRepository<FundiLocation>, FundiLocationRepository>();
            services.AddScoped<AbstractRepository<MonthlySubscription>, MonthlySubscriptionRepository>();
            services.AddScoped<AbstractRepository<FundiSubscription>, FundiSubscriptionRepository>();
            services.AddScoped<AbstractRepository<ClientSubscription>, ClientSubscriptionRepository>();
            services.AddScoped<AbstractRepository<FundiSubscriptionQueue>, FundiSubscriptionQueueRepository>();
            services.AddScoped<AbstractRepository<MonthlySubscriptionQueue>, MonthlySubscriptionQueueRepository>();
            services.AddScoped<AbstractRepository<Blog>, BlogsRepository>();
            services.AddScoped<AbstractRepository<Question>, QuestionRepository>();
            services.AddScoped<AbstractRepository<Answer>, AnswerRepository>();
            services.AddScoped<SimbaToursEastAfrica.Caching.Interfaces.ICaching, SimbaToursEastAfrica.Caching.Concretes.SimbaToursEastAfricaCahing>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IRoleService, RoleService>();
            services.AddSingleton<IConfiguration>(Configuration);
            services.AddScoped<AppSettingsConfigurations>();
            services.AddTransient<AesExternalProcedures>(s => new AesExternalProcedures(masterkeyDirPath));
            services.AddScoped<IMailService, EmailService>(smtp => new EmailService(Configuration));
            services.AddScoped<PaymentsManager>();
            services.AddScoped<InitializeDatabaseRoles>();

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {

            string contentPath = env.ContentRootPath;
            var profileDirPath = contentPath + "\\MyFundiProfile";
            DirectoryInfo pfDir = new DirectoryInfo(profileDirPath);

            if (!pfDir.Exists)
            {
                pfDir.Create();
            }


            app.UsePathBase("/myfundi");

            app.Use((context, next) =>
            {
                context.Request.PathBase = "/myfundi";
                return next();
            });

            //Initialize Roles:
            var initRoles = new RoleInitializationMiddleware();
            app.Use((context, next) =>
            {
                initRoles.Invoke(context).ConfigureAwait(true).GetAwaiter().GetResult();
                return next();
            });
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseSession();
            app.UseHttpsRedirection();

            if (!env.IsDevelopment())
            {
                app.UseSpaStaticFiles();
            }
            app.UseStaticFiles(new StaticFileOptions()
            {
                FileProvider = new PhysicalFileProvider(
                    Path.Combine(Directory.GetCurrentDirectory(), "MyFundiProfile")),
                RequestPath = new PathString("/MyFundiProfile")
            });
            app.UseHttpsRedirection();
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }


            app.UseRouting();
            app.UseCors("CorsPolicy"); app.Use((context, next) =>
            {
                context.Request.Headers.Add("Access-Control-Allow-Origin", "*");
                context.Request.Headers.Add("Access-Control-Allow-Methods", "GET , PUT , POST , DELETE");
                context.Response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, x-requested-with");
                return next(); // Important
            });

            app.UseAuthentication();
            app.UseAuthorization();



            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller}/{action=Index}/{id?}");
            });

            app.UseSpa(spa =>
            {
                // To learn more about options for serving an Angular SPA from ASP.NET Core,
                // see https://go.microsoft.com/fwlink/?linkid=864501

                spa.Options.SourcePath = "ClientApp";

                if (env.IsDevelopment())
                {
					spa.UseAngularCliServer(npmScript: "start");
				}

            });

        }
    }

}




/*namespace MyFundi.Web
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllersWithViews();
            // In production, the Angular files will be served from this directory
            services.AddSpaStaticFiles(configuration =>
            {
                configuration.RootPath = "ClientApp/dist";
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();
            if (!env.IsDevelopment())
            {
                app.UseSpaStaticFiles();
            }

            app.UseRouting();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller}/{action=Index}/{id?}");
            });

            app.UseSpa(spa =>
            {
                // To learn more about options for serving an Angular SPA from ASP.NET Core,
                // see https://go.microsoft.com/fwlink/?linkid=864501

                spa.Options.SourcePath = "ClientApp";

                if (env.IsDevelopment())
                {
                    spa.UseAngularCliServer(npmScript: "start");
                }
            });
        }
    }


}*/
