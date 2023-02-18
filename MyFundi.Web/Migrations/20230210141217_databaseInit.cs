using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace MyFundi.Web.Migrations
{
    public partial class databaseInit : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Addresses",
                columns: table => new
                {
                    AddressId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AddressLine1 = table.Column<string>(nullable: true),
                    AddressLine2 = table.Column<string>(nullable: true),
                    Country = table.Column<string>(nullable: true),
                    Town = table.Column<string>(nullable: true),
                    PostCode = table.Column<string>(nullable: true),
                    PhoneNumber = table.Column<string>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Addresses", x => x.AddressId);
                });

            migrationBuilder.CreateTable(
                name: "Certifications",
                columns: table => new
                {
                    CertificationId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CertificationName = table.Column<string>(nullable: true),
                    CertificationDescription = table.Column<string>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Certifications", x => x.CertificationId);
                });

            migrationBuilder.CreateTable(
                name: "Courses",
                columns: table => new
                {
                    CourseId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CourseName = table.Column<string>(nullable: true),
                    CourseDescription = table.Column<string>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Courses", x => x.CourseId);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    RoleId = table.Column<Guid>(nullable: false),
                    RoleName = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.RoleId);
                });

            migrationBuilder.CreateTable(
                name: "WorkCategories",
                columns: table => new
                {
                    WorkCategoryId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    WorkCategoryType = table.Column<string>(nullable: true),
                    WorkCategoryDescription = table.Column<string>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkCategories", x => x.WorkCategoryId);
                });

            migrationBuilder.CreateTable(
                name: "Locations",
                columns: table => new
                {
                    LocationId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Country = table.Column<string>(nullable: true),
                    AddressId = table.Column<int>(nullable: false),
                    LocationName = table.Column<string>(nullable: true),
                    Latitude = table.Column<float>(nullable: true),
                    Longitude = table.Column<float>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false),
                    IsGeocoded = table.Column<bool>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Locations", x => x.LocationId);
                    table.ForeignKey(
                        name: "FK_Locations_Addresses_AddressId",
                        column: x => x.AddressId,
                        principalTable: "Addresses",
                        principalColumn: "AddressId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "WorkSubCategories",
                columns: table => new
                {
                    WorkSubCategoryId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    WorkSubCategoryType = table.Column<string>(nullable: true),
                    WorkSubCategoryDescription = table.Column<string>(nullable: true),
                    WorkCategoryId = table.Column<int>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkSubCategories", x => x.WorkSubCategoryId);
                    table.ForeignKey(
                        name: "FK_WorkSubCategories_WorkCategories_WorkCategoryId",
                        column: x => x.WorkCategoryId,
                        principalTable: "WorkCategories",
                        principalColumn: "WorkCategoryId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "Companies",
                columns: table => new
                {
                    CompanyId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CompanyName = table.Column<string>(nullable: true),
                    CompanyPhoneNUmber = table.Column<string>(nullable: true),
                    LocationId = table.Column<int>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Companies", x => x.CompanyId);
                    table.ForeignKey(
                        name: "FK_Companies_Locations_LocationId",
                        column: x => x.LocationId,
                        principalTable: "Locations",
                        principalColumn: "LocationId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    UserId = table.Column<Guid>(nullable: false),
                    FirstName = table.Column<string>(nullable: true),
                    LastName = table.Column<string>(nullable: true),
                    Username = table.Column<string>(nullable: false),
                    Password = table.Column<string>(nullable: true),
                    Email = table.Column<string>(nullable: true),
                    MobileNumber = table.Column<string>(nullable: true),
                    Token = table.Column<string>(nullable: true),
                    CompanyId = table.Column<int>(nullable: true),
                    CreateTime = table.Column<DateTime>(nullable: false),
                    LastLogInTime = table.Column<DateTime>(nullable: false),
                    IsActive = table.Column<bool>(nullable: false),
                    IsLockedOut = table.Column<bool>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.UserId);
                    table.UniqueConstraint("AK_Users_Username", x => x.Username);
                    table.ForeignKey(
                        name: "FK_Users_Companies_CompanyId",
                        column: x => x.CompanyId,
                        principalTable: "Companies",
                        principalColumn: "CompanyId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ClientProfiles",
                columns: table => new
                {
                    ClientProfileId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<Guid>(nullable: false),
                    AddressId = table.Column<int>(nullable: false),
                    ProfileSummary = table.Column<string>(nullable: true),
                    ProfileImageUrl = table.Column<string>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClientProfiles", x => x.ClientProfileId);
                    table.ForeignKey(
                        name: "FK_ClientProfiles_Addresses_AddressId",
                        column: x => x.AddressId,
                        principalTable: "Addresses",
                        principalColumn: "AddressId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_ClientProfiles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "FundiProfiles",
                columns: table => new
                {
                    FundiProfileId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<Guid>(nullable: false),
                    ProfileSummary = table.Column<string>(nullable: true),
                    ProfileImageUrl = table.Column<string>(nullable: true),
                    Skills = table.Column<string>(nullable: true),
                    UsedPowerTools = table.Column<string>(nullable: true),
                    LocationId = table.Column<int>(nullable: false),
                    FundiProfileCvUrl = table.Column<string>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FundiProfiles", x => x.FundiProfileId);
                    table.ForeignKey(
                        name: "FK_FundiProfiles_Locations_LocationId",
                        column: x => x.LocationId,
                        principalTable: "Locations",
                        principalColumn: "LocationId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_FundiProfiles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "Invoices",
                columns: table => new
                {
                    InvoiceId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    InvoiceName = table.Column<string>(nullable: true),
                    NetCost = table.Column<decimal>(nullable: false),
                    UserId = table.Column<Guid>(nullable: false),
                    PercentTaxAppliable = table.Column<decimal>(nullable: false),
                    HasFullyPaid = table.Column<bool>(nullable: false),
                    GrossCost = table.Column<decimal>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Invoices", x => x.InvoiceId);
                    table.ForeignKey(
                        name: "FK_Invoices_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "UserRoles",
                columns: table => new
                {
                    UserRoleId = table.Column<Guid>(nullable: false),
                    UserId = table.Column<Guid>(nullable: false),
                    RoleId = table.Column<Guid>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRoles", x => x.UserRoleId);
                    table.UniqueConstraint("AK_UserRoles_UserId_RoleId", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_UserRoles_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "RoleId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_UserRoles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "ClientFundiContracts",
                columns: table => new
                {
                    ClientFundiContractId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ClientProfileId = table.Column<int>(nullable: false),
                    FundiProfileId = table.Column<int>(nullable: false),
                    NumberOfDaysToComplete = table.Column<decimal>(nullable: false),
                    ContractualDescription = table.Column<string>(nullable: true),
                    AgreedStartDate = table.Column<DateTime>(nullable: false),
                    AgreedEndDate = table.Column<DateTime>(nullable: false),
                    IsCompleted = table.Column<bool>(nullable: false),
                    IsSignedByClient = table.Column<bool>(nullable: false),
                    IsSignedByFundi = table.Column<bool>(nullable: false),
                    IsSignedOffByClient = table.Column<bool>(nullable: false),
                    NotesForNotice = table.Column<string>(nullable: true),
                    AgreedCost = table.Column<decimal>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClientFundiContracts", x => x.ClientFundiContractId);
                    table.ForeignKey(
                        name: "FK_ClientFundiContracts_ClientProfiles_ClientProfileId",
                        column: x => x.ClientProfileId,
                        principalTable: "ClientProfiles",
                        principalColumn: "ClientProfileId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_ClientFundiContracts_FundiProfiles_FundiProfileId",
                        column: x => x.FundiProfileId,
                        principalTable: "FundiProfiles",
                        principalColumn: "FundiProfileId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "FundiLocations",
                columns: table => new
                {
                    FundiLocationId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FundiProfileId = table.Column<int>(nullable: false),
                    Latitude = table.Column<double>(nullable: false),
                    Longitude = table.Column<double>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FundiLocations", x => x.FundiLocationId);
                    table.ForeignKey(
                        name: "FK_FundiLocations_FundiProfiles_FundiProfileId",
                        column: x => x.FundiProfileId,
                        principalTable: "FundiProfiles",
                        principalColumn: "FundiProfileId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "FundiProfileAndReviewRatings",
                columns: table => new
                {
                    FundiRatingAndReviewId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<Guid>(nullable: false),
                    Rating = table.Column<int>(nullable: false),
                    Review = table.Column<string>(nullable: true),
                    FundiProfileId = table.Column<int>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false),
                    WorkCategoryType = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FundiProfileAndReviewRatings", x => x.FundiRatingAndReviewId);
                    table.ForeignKey(
                        name: "FK_FundiProfileAndReviewRatings_FundiProfiles_FundiProfileId",
                        column: x => x.FundiProfileId,
                        principalTable: "FundiProfiles",
                        principalColumn: "FundiProfileId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_FundiProfileAndReviewRatings_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "FundiProfileCertifications",
                columns: table => new
                {
                    FundiProfileCertificationId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FundiProfileId = table.Column<int>(nullable: false),
                    CertificationId = table.Column<int>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FundiProfileCertifications", x => x.FundiProfileCertificationId);
                    table.ForeignKey(
                        name: "FK_FundiProfileCertifications_Certifications_CertificationId",
                        column: x => x.CertificationId,
                        principalTable: "Certifications",
                        principalColumn: "CertificationId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_FundiProfileCertifications_FundiProfiles_FundiProfileId",
                        column: x => x.FundiProfileId,
                        principalTable: "FundiProfiles",
                        principalColumn: "FundiProfileId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "FundiProfileCourses",
                columns: table => new
                {
                    FundiProfileCourseTakenId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CourseId = table.Column<int>(nullable: false),
                    FundiProfileId = table.Column<int>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FundiProfileCourses", x => x.FundiProfileCourseTakenId);
                    table.ForeignKey(
                        name: "FK_FundiProfileCourses_Courses_CourseId",
                        column: x => x.CourseId,
                        principalTable: "Courses",
                        principalColumn: "CourseId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_FundiProfileCourses_FundiProfiles_FundiProfileId",
                        column: x => x.FundiProfileId,
                        principalTable: "FundiProfiles",
                        principalColumn: "FundiProfileId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "FundiWorkCategories",
                columns: table => new
                {
                    FundiWorkCategoryId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FundiProfileId = table.Column<int>(nullable: false),
                    WorkCategoryId = table.Column<int>(nullable: false),
                    WorkSubCategoryId = table.Column<int>(nullable: true),
                    JobId = table.Column<int>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FundiWorkCategories", x => x.FundiWorkCategoryId);
                    table.ForeignKey(
                        name: "FK_FundiWorkCategories_FundiProfiles_FundiProfileId",
                        column: x => x.FundiProfileId,
                        principalTable: "FundiProfiles",
                        principalColumn: "FundiProfileId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_FundiWorkCategories_WorkCategories_WorkCategoryId",
                        column: x => x.WorkCategoryId,
                        principalTable: "WorkCategories",
                        principalColumn: "WorkCategoryId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_FundiWorkCategories_WorkSubCategories_WorkSubCategoryId",
                        column: x => x.WorkSubCategoryId,
                        principalTable: "WorkSubCategories",
                        principalColumn: "WorkSubCategoryId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Jobs",
                columns: table => new
                {
                    JobId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    JobName = table.Column<string>(nullable: true),
                    JobDescription = table.Column<string>(nullable: true),
                    LocationId = table.Column<int>(nullable: false),
                    ClientProfileId = table.Column<int>(nullable: false),
                    ClientUserId = table.Column<Guid>(nullable: false),
                    AssignedFundiUserId = table.Column<Guid>(nullable: true),
                    AssignedFundiProfileId = table.Column<int>(nullable: true),
                    HasBeenAssignedFundi = table.Column<bool>(nullable: false),
                    HasCompleted = table.Column<bool>(nullable: false),
                    ClientFundiContractId = table.Column<int>(nullable: true),
                    NumberOfDaysToComplete = table.Column<int>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Jobs", x => x.JobId);
                    table.ForeignKey(
                        name: "FK_Jobs_FundiProfiles_AssignedFundiProfileId",
                        column: x => x.AssignedFundiProfileId,
                        principalTable: "FundiProfiles",
                        principalColumn: "FundiProfileId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Jobs_Users_AssignedFundiUserId",
                        column: x => x.AssignedFundiUserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Jobs_ClientProfiles_ClientProfileId",
                        column: x => x.ClientProfileId,
                        principalTable: "ClientProfiles",
                        principalColumn: "ClientProfileId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_Jobs_Users_ClientUserId",
                        column: x => x.ClientUserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_Jobs_Locations_LocationId",
                        column: x => x.LocationId,
                        principalTable: "Locations",
                        principalColumn: "LocationId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "MonthlySubscriptions",
                columns: table => new
                {
                    MonthlySubscriptionId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<Guid>(nullable: true),
                    Username = table.Column<string>(nullable: true),
                    SubscriptionName = table.Column<string>(nullable: true),
                    SubscriptionDescription = table.Column<string>(nullable: true),
                    FundiProfileId = table.Column<int>(nullable: true),
                    HasPaid = table.Column<bool>(nullable: false),
                    HasExpired = table.Column<bool>(nullable: false),
                    SubscriptionFee = table.Column<decimal>(nullable: false),
                    StartDate = table.Column<DateTime>(nullable: false),
                    EndDate = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MonthlySubscriptions", x => x.MonthlySubscriptionId);
                    table.ForeignKey(
                        name: "FK_MonthlySubscriptions_FundiProfiles_FundiProfileId",
                        column: x => x.FundiProfileId,
                        principalTable: "FundiProfiles",
                        principalColumn: "FundiProfileId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MonthlySubscriptions_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Items",
                columns: table => new
                {
                    ItemId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ItemName = table.Column<string>(nullable: true),
                    Quantity = table.Column<int>(nullable: false),
                    ItemCost = table.Column<decimal>(nullable: false),
                    InvoiceId = table.Column<int>(nullable: false),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Items", x => x.ItemId);
                    table.ForeignKey(
                        name: "FK_Items_Invoices_InvoiceId",
                        column: x => x.InvoiceId,
                        principalTable: "Invoices",
                        principalColumn: "InvoiceId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "JobWorkCategories",
                columns: table => new
                {
                    JobWorkCategoryId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    JobId = table.Column<int>(nullable: true),
                    WorkCategoryId = table.Column<int>(nullable: true),
                    WorkSubCategoryId = table.Column<int>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_JobWorkCategories", x => x.JobWorkCategoryId);
                    table.ForeignKey(
                        name: "FK_JobWorkCategories_Jobs_JobId",
                        column: x => x.JobId,
                        principalTable: "Jobs",
                        principalColumn: "JobId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_JobWorkCategories_WorkCategories_WorkCategoryId",
                        column: x => x.WorkCategoryId,
                        principalTable: "WorkCategories",
                        principalColumn: "WorkCategoryId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_JobWorkCategories_WorkSubCategories_WorkSubCategoryId",
                        column: x => x.WorkSubCategoryId,
                        principalTable: "WorkSubCategories",
                        principalColumn: "WorkSubCategoryId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "FundiSubscriptions",
                columns: table => new
                {
                    FundiSubscriptionId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false),
                    StartDate = table.Column<DateTime>(nullable: false),
                    SubscriptionName = table.Column<string>(nullable: true),
                    SubscriptionFee = table.Column<decimal>(nullable: false),
                    SubscriptionDescription = table.Column<string>(nullable: true),
                    EndDate = table.Column<DateTime>(nullable: false),
                    MonthlySubscriptionId = table.Column<int>(nullable: false),
                    FundiWorkCategoryId = table.Column<int>(nullable: false),
                    FundiWorkSubCategoryId = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FundiSubscriptions", x => x.FundiSubscriptionId);
                    table.ForeignKey(
                        name: "FK_FundiSubscriptions_WorkSubCategories_FundiWorkSubCategoryId",
                        column: x => x.FundiWorkSubCategoryId,
                        principalTable: "WorkSubCategories",
                        principalColumn: "WorkSubCategoryId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_FundiSubscriptions_MonthlySubscriptions_MonthlySubscriptionId",
                        column: x => x.MonthlySubscriptionId,
                        principalTable: "MonthlySubscriptions",
                        principalColumn: "MonthlySubscriptionId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ClientFundiContracts_ClientProfileId",
                table: "ClientFundiContracts",
                column: "ClientProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_ClientFundiContracts_FundiProfileId",
                table: "ClientFundiContracts",
                column: "FundiProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_ClientProfiles_AddressId",
                table: "ClientProfiles",
                column: "AddressId");

            migrationBuilder.CreateIndex(
                name: "IX_ClientProfiles_UserId",
                table: "ClientProfiles",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Companies_LocationId",
                table: "Companies",
                column: "LocationId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiLocations_FundiProfileId",
                table: "FundiLocations",
                column: "FundiProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiProfileAndReviewRatings_FundiProfileId",
                table: "FundiProfileAndReviewRatings",
                column: "FundiProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiProfileAndReviewRatings_UserId",
                table: "FundiProfileAndReviewRatings",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiProfileCertifications_CertificationId",
                table: "FundiProfileCertifications",
                column: "CertificationId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiProfileCertifications_FundiProfileId",
                table: "FundiProfileCertifications",
                column: "FundiProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiProfileCourses_CourseId",
                table: "FundiProfileCourses",
                column: "CourseId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiProfileCourses_FundiProfileId",
                table: "FundiProfileCourses",
                column: "FundiProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiProfiles_LocationId",
                table: "FundiProfiles",
                column: "LocationId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiProfiles_UserId",
                table: "FundiProfiles",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiSubscriptions_FundiWorkSubCategoryId",
                table: "FundiSubscriptions",
                column: "FundiWorkSubCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiSubscriptions_MonthlySubscriptionId",
                table: "FundiSubscriptions",
                column: "MonthlySubscriptionId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiWorkCategories_FundiProfileId",
                table: "FundiWorkCategories",
                column: "FundiProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiWorkCategories_WorkCategoryId",
                table: "FundiWorkCategories",
                column: "WorkCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiWorkCategories_WorkSubCategoryId",
                table: "FundiWorkCategories",
                column: "WorkSubCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_UserId",
                table: "Invoices",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Items_InvoiceId",
                table: "Items",
                column: "InvoiceId");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_AssignedFundiProfileId",
                table: "Jobs",
                column: "AssignedFundiProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_AssignedFundiUserId",
                table: "Jobs",
                column: "AssignedFundiUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_ClientProfileId",
                table: "Jobs",
                column: "ClientProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_ClientUserId",
                table: "Jobs",
                column: "ClientUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_LocationId",
                table: "Jobs",
                column: "LocationId");

            migrationBuilder.CreateIndex(
                name: "IX_JobWorkCategories_JobId",
                table: "JobWorkCategories",
                column: "JobId");

            migrationBuilder.CreateIndex(
                name: "IX_JobWorkCategories_WorkCategoryId",
                table: "JobWorkCategories",
                column: "WorkCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_JobWorkCategories_WorkSubCategoryId",
                table: "JobWorkCategories",
                column: "WorkSubCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_Locations_AddressId",
                table: "Locations",
                column: "AddressId");

            migrationBuilder.CreateIndex(
                name: "IX_MonthlySubscriptions_FundiProfileId",
                table: "MonthlySubscriptions",
                column: "FundiProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_MonthlySubscriptions_UserId",
                table: "MonthlySubscriptions",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Roles_RoleName",
                table: "Roles",
                column: "RoleName",
                unique: true,
                filter: "[RoleName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_RoleId",
                table: "UserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_CompanyId",
                table: "Users",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true,
                filter: "[Email] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Username",
                table: "Users",
                column: "Username",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_WorkSubCategories_WorkCategoryId",
                table: "WorkSubCategories",
                column: "WorkCategoryId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ClientFundiContracts");

            migrationBuilder.DropTable(
                name: "FundiLocations");

            migrationBuilder.DropTable(
                name: "FundiProfileAndReviewRatings");

            migrationBuilder.DropTable(
                name: "FundiProfileCertifications");

            migrationBuilder.DropTable(
                name: "FundiProfileCourses");

            migrationBuilder.DropTable(
                name: "FundiSubscriptions");

            migrationBuilder.DropTable(
                name: "FundiWorkCategories");

            migrationBuilder.DropTable(
                name: "Items");

            migrationBuilder.DropTable(
                name: "JobWorkCategories");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "Certifications");

            migrationBuilder.DropTable(
                name: "Courses");

            migrationBuilder.DropTable(
                name: "MonthlySubscriptions");

            migrationBuilder.DropTable(
                name: "Invoices");

            migrationBuilder.DropTable(
                name: "Jobs");

            migrationBuilder.DropTable(
                name: "WorkSubCategories");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "FundiProfiles");

            migrationBuilder.DropTable(
                name: "ClientProfiles");

            migrationBuilder.DropTable(
                name: "WorkCategories");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Companies");

            migrationBuilder.DropTable(
                name: "Locations");

            migrationBuilder.DropTable(
                name: "Addresses");
        }
    }
}
