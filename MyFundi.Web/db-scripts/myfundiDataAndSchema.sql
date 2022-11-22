USE [myfundiv2]
GO
/****** Object:  UserDefinedFunction [dbo].[ArePointsNearEnough]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
  arePointsNear(checkPoint: ICoordinate, centerPoint: ICoordinate, km: number): boolean {
    var ky = 40000 / 360;
    var kx = Math.cos(Math.PI * centerPoint.latitude / 180.0) * ky;
    var dx = Math.abs(centerPoint.longitude - checkPoint.longitude) * kx;
    var dy = Math.abs(centerPoint.latitude - checkPoint.latitude) * ky;
    return Math.sqrt(dx * dx + dy * dy) <= km;
  }

  roundPositiveNumberTo2DecPlaces(num: number):number {
    var m = Number((Math.abs(num) * 100).toPrecision(15));
    return Math.round(m) / 100;// * Math.sign(num);
  }
  */
CREATE function [dbo].[ArePointsNearEnough]( @xcheckPoint float, @ycheckPoint float, @xcenterPoint float, @ycenterPoint float, @km float)
returns @distanceLocation Table(
	--Id int primary key not null,
	DistanceApart float,
	IsWithinDistance bit
)
As
begin			
			declare @ky float = 40000/360;
			declare @angle float = PI() * @xcenterPoint / 180.0;
            declare @kx float = Cos(@angle) * @ky;
			declare @subX float = @ycenterPoint - @ycheckPoint
			declare @subY float = @xcenterPoint - @xcheckPoint
            declare @dx float = Abs(@subX) * @kx;
            declare @dy float = Abs(@subY)* @ky;
			declare @resdoubled float = @dx * @dx + @dy * @dy 
            declare @dist float = Sqrt(@resdoubled);

            declare @distApart bit = 0;
			
			if(@dist <= @km)set @distApart = 1;

			insert into @distanceLocation
			values(Round(@dist,3), @distApart)
			 
			return 
End
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplit]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnSplit](@sInputList VARCHAR(MAX), @sDelimiter VARCHAR(8000) = ',')
RETURNS @List TABLE (item VARCHAR(8000))
BEGIN

    DECLARE @sItem VARCHAR(8000)
    WHILE CHARINDEX(@sDelimiter, @sInputList, 0) <> 0
    BEGIN

        SELECT @sItem = RTRIM(LTRIM(SUBSTRING(@sInputList, 1, CHARINDEX(@sDelimiter, @sInputList,0) - 1))),
               @sInputList = RTRIM(LTRIM(SUBSTRING(@sInputList, CHARINDEX(@sDelimiter, @sInputList, 0) + LEN(@sDelimiter),LEN(@sInputList))))

        -- Indexes to keep the position of searching
        IF LEN(@sItem) > 0

        INSERT INTO @List SELECT @sItem

    END

    IF LEN(@sInputList) > 0
    BEGIN

        INSERT INTO @List SELECT @sInputList -- Put the last item in

    END

    RETURN

END
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Addresses]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Addresses](
	[AddressId] [int] IDENTITY(1,1) NOT NULL,
	[AddressLine1] [nvarchar](max) NULL,
	[AddressLine2] [nvarchar](max) NULL,
	[Country] [nvarchar](max) NULL,
	[Town] [nvarchar](max) NULL,
	[PostCode] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Addresses] PRIMARY KEY CLUSTERED 
(
	[AddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Certifications]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Certifications](
	[CertificationId] [int] IDENTITY(1,1) NOT NULL,
	[CertificationName] [nvarchar](max) NULL,
	[CertificationDescription] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Certifications] PRIMARY KEY CLUSTERED 
(
	[CertificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClientFundiContracts]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientFundiContracts](
	[ClientFundiContractId] [int] IDENTITY(1,1) NOT NULL,
	[ClientUserId] [uniqueidentifier] NOT NULL,
	[FundiUserId] [uniqueidentifier] NOT NULL,
	[NumberOfDaysToComplete] [decimal](18, 2) NOT NULL,
	[ContractualDescription] [nvarchar](max) NULL,
	[IsCompleted] [bit] NOT NULL,
	[IsSignedOffByClient] [bit] NOT NULL,
	[NotesForNotice] [nvarchar](max) NULL,
	[AgreedCost] [decimal](18, 2) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ClientFundiContracts] PRIMARY KEY CLUSTERED 
(
	[ClientFundiContractId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClientProfiles]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientProfiles](
	[ClientProfileId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[AddressId] [int] NOT NULL,
	[ProfileSummary] [nvarchar](max) NULL,
	[ProfileImageUrl] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ClientProfiles] PRIMARY KEY CLUSTERED 
(
	[ClientProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Companies]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Companies](
	[CompanyId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](max) NULL,
	[CompanyPhoneNUmber] [nvarchar](max) NULL,
	[LocationId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Companies] PRIMARY KEY CLUSTERED 
(
	[CompanyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Courses]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Courses](
	[CourseId] [int] IDENTITY(1,1) NOT NULL,
	[CourseName] [nvarchar](max) NULL,
	[CourseDescription] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Courses] PRIMARY KEY CLUSTERED 
(
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundiProfileAndReviewRatings]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundiProfileAndReviewRatings](
	[FundiRatingAndReviewId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Rating] [int] NOT NULL,
	[Review] [nvarchar](max) NULL,
	[FundiProfileId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
	[WorkCategoryType] [nvarchar](max) NULL,
 CONSTRAINT [PK_FundiProfileAndReviewRatings] PRIMARY KEY CLUSTERED 
(
	[FundiRatingAndReviewId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundiProfileCertifications]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundiProfileCertifications](
	[FundiProfileCertificationId] [int] IDENTITY(1,1) NOT NULL,
	[FundiProfileId] [int] NOT NULL,
	[CertificationId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FundiProfileCertifications] PRIMARY KEY CLUSTERED 
(
	[FundiProfileCertificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundiProfileCourses]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundiProfileCourses](
	[FundiProfileCourseTakenId] [int] IDENTITY(1,1) NOT NULL,
	[CourseId] [int] NOT NULL,
	[FundiProfileId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FundiProfileCourses] PRIMARY KEY CLUSTERED 
(
	[FundiProfileCourseTakenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundiProfiles]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundiProfiles](
	[FundiProfileId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[ProfileSummary] [nvarchar](max) NULL,
	[ProfileImageUrl] [nvarchar](max) NULL,
	[Skills] [nvarchar](max) NULL,
	[UsedPowerTools] [nvarchar](max) NULL,
	[LocationId] [int] NOT NULL,
	[FundiProfileCvUrl] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FundiProfiles] PRIMARY KEY CLUSTERED 
(
	[FundiProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundiWorkCategories]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundiWorkCategories](
	[FundiWorkCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[FundiProfileId] [int] NOT NULL,
	[WorkCategoryId] [int] NOT NULL,
	[JobId] [int] NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FundiWorkCategories] PRIMARY KEY CLUSTERED 
(
	[FundiWorkCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Invoices]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Invoices](
	[InvoiceId] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceName] [nvarchar](max) NULL,
	[NetCost] [decimal](18, 2) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[PercentTaxAppliable] [decimal](18, 2) NOT NULL,
	[HasFullyPaid] [bit] NOT NULL,
	[GrossCost] [decimal](18, 2) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Invoices] PRIMARY KEY CLUSTERED 
(
	[InvoiceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Items]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Items](
	[ItemId] [int] IDENTITY(1,1) NOT NULL,
	[ItemName] [nvarchar](max) NULL,
	[Quantity] [int] NOT NULL,
	[ItemCost] [decimal](18, 2) NOT NULL,
	[InvoiceId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Items] PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Jobs]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Jobs](
	[JobId] [int] IDENTITY(1,1) NOT NULL,
	[JobName] [nvarchar](max) NULL,
	[JobDescription] [nvarchar](max) NULL,
	[LocationId] [int] NOT NULL,
	[ClientProfileId] [int] NOT NULL,
	[ClientUserId] [uniqueidentifier] NOT NULL,
	[AssignedFundiUserId] [uniqueidentifier] NULL,
	[AssignedFundiProfileId] [int] NULL,
	[HasBeenAssignedFundi] [bit] NOT NULL,
	[HasCompleted] [bit] NOT NULL,
	[ClientFundiContractId] [int] NULL,
	[NumberOfDaysToComplete] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Jobs] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobWorkCategories]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobWorkCategories](
	[JobWorkCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[JobId] [int] NULL,
	[WorkCategoryId] [int] NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_JobWorkCategories] PRIMARY KEY CLUSTERED 
(
	[JobWorkCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locations](
	[LocationId] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](max) NULL,
	[AddressId] [int] NOT NULL,
	[LocationName] [nvarchar](max) NULL,
	[Latitude] [real] NULL,
	[Longitude] [real] NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
	[IsGeocoded] [bit] NOT NULL,
 CONSTRAINT [PK_Locations] PRIMARY KEY CLUSTERED 
(
	[LocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MonthlySubscriptions]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonthlySubscriptions](
	[MonthlySubscriptionId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[Username] [nvarchar](max) NULL,
	[FundiProfileId] [int] NULL,
	[HasPaid] [bit] NOT NULL,
	[SubscriptionName] [nvarchar](max) NULL,
	[SubscriptionFee] [decimal](18, 2) NOT NULL,
	[SubscriptionDescription] [nvarchar](max) NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_MonthlySubscriptions] PRIMARY KEY CLUSTERED 
(
	[MonthlySubscriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[RoleId] [uniqueidentifier] NOT NULL,
	[RoleName] [nvarchar](450) NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRoles]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoles](
	[UserRoleId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED 
(
	[UserRoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserId] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](max) NULL,
	[LastName] [nvarchar](max) NULL,
	[Username] [nvarchar](450) NOT NULL,
	[Password] [nvarchar](max) NULL,
	[Email] [nvarchar](450) NULL,
	[MobileNumber] [nvarchar](max) NULL,
	[Token] [nvarchar](max) NULL,
	[CompanyId] [int] NULL,
	[CreateTime] [datetime2](7) NOT NULL,
	[LastLogInTime] [datetime2](7) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsLockedOut] [bit] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkCategories]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkCategories](
	[WorkCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[WorkCategoryType] [nvarchar](max) NULL,
	[WorkCategoryDescription] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_WorkCategories] PRIMARY KEY CLUSTERED 
(
	[WorkCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkSubCategories]    Script Date: 22/11/2022 05:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkSubCategories](
	[WorkSubCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[WorkSubCategoryType] [nvarchar](max) NULL,
	[WorkSubCategoryDescription] [nvarchar](max) NULL,
	[WorkCategoryId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_WorkSubCategories] PRIMARY KEY CLUSTERED 
(
	[WorkSubCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20221029103912_initDb', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20221030130403_addFundiProfileLocation', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20221116020841_addWorkSubCategoryTable', N'3.1.22')
GO
SET IDENTITY_INSERT [dbo].[Addresses] ON 
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (1, N'MartinLayooInc Software Ltd.', N'Unit 3, 2 St. Johns Terrace', N'United Kingdom', N'London', N'W10', N'07809773365', CAST(N'2022-07-21T21:15:54.6440210' AS DateTime2), CAST(N'2022-07-21T21:15:54.6440687' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (2, N'Speke Hotel', N'Buganda Road', N'Uganda', N'Kampala', N'Kampala', NULL, CAST(N'2022-07-09T18:50:00.8488803' AS DateTime2), CAST(N'2022-10-27T03:17:27.5946547' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (3, N'Acacia Mall Hotel', N'Acacia Avenue', N'Uganda', N'Kampala', N'Plot  55', NULL, CAST(N'2022-07-28T08:36:23.8454936' AS DateTime2), CAST(N'2022-10-27T01:01:59.5698802' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (4, N'Flat 3', N'13D Lanhill Road', N'UK', N'London ', N'W9', NULL, CAST(N'2022-10-26T11:37:37.5365098' AS DateTime2), CAST(N'2022-10-26T11:52:16.6561740' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (5, N'Custom Corner', N'Lira Road', N'Uganda', N'Gulu', N'Plot 46', NULL, CAST(N'2022-10-28T00:25:11.1014425' AS DateTime2), CAST(N'2022-10-28T00:25:11.1014430' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (6, N'Flat 13', N'Steve Biko Court', N'United Kingdom', N'London', N'w10', NULL, CAST(N'2022-10-28T00:27:21.9400951' AS DateTime2), CAST(N'2022-10-28T03:48:24.7446393' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Addresses] OFF
GO
SET IDENTITY_INSERT [dbo].[Certifications] ON 
GO
INSERT [dbo].[Certifications] ([CertificationId], [CertificationName], [CertificationDescription], [DateCreated], [DateUpdated]) VALUES (1, N'Power Drills', N'Power Drills Usage', CAST(N'2022-01-23T13:37:57.7302271' AS DateTime2), CAST(N'2022-01-23T13:37:57.7302345' AS DateTime2))
GO
INSERT [dbo].[Certifications] ([CertificationId], [CertificationName], [CertificationDescription], [DateCreated], [DateUpdated]) VALUES (2, N'JBC Loader', N'JBC Loader Truck Usage', CAST(N'2022-01-23T13:40:19.2417035' AS DateTime2), CAST(N'2022-01-23T13:40:19.2417092' AS DateTime2))
GO
INSERT [dbo].[Certifications] ([CertificationId], [CertificationName], [CertificationDescription], [DateCreated], [DateUpdated]) VALUES (3, N'Defensive Driving Certification', N'Advanced Driving Course for those with standard licences, this gives you status with defensve driving.

You are required to hold a full driving licence,', CAST(N'2022-09-05T12:00:56.4919499' AS DateTime2), CAST(N'2022-09-05T12:06:12.4159232' AS DateTime2))
GO
INSERT [dbo].[Certifications] ([CertificationId], [CertificationName], [CertificationDescription], [DateCreated], [DateUpdated]) VALUES (4, N'BTec Civil/Structural Engineering', N'BTec Civil/Structural Engineering Certification', CAST(N'2022-10-29T06:08:28.3720831' AS DateTime2), CAST(N'2022-10-29T06:08:28.3720836' AS DateTime2))
GO
INSERT [dbo].[Certifications] ([CertificationId], [CertificationName], [CertificationDescription], [DateCreated], [DateUpdated]) VALUES (5, N'BEng Civil/Structural And Environmental Engineering', N'Degree Course allowing one to practice with indepth knowlege within the Civil Engnineering, and Transport sector for growth and Town Planning.', CAST(N'2022-11-06T02:11:49.9650998' AS DateTime2), CAST(N'2022-11-06T02:11:49.9651003' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Certifications] OFF
GO
SET IDENTITY_INSERT [dbo].[ClientProfiles] ON 
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (9, N'e9585393-5fd1-45e8-5487-08da6e1c1725', 1, N'I am a well rounded and friendly individual. Full of trust, I offer my Jobs to good handy men, who should be able to tell me anything in trust. My thoughts are that the Fundi would know better since it is their skills and profession. Give me a well done, job, and I am happy and will refer you to other jobs especially within my community. I always rate efficiency, and honesty as the 2 most important things, let alone friendly Fundis.', N'', CAST(N'2022-10-29T21:41:41.9192250' AS DateTime2), CAST(N'2022-10-29T21:41:41.9192312' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (10, N'e9585393-5fd1-45e8-5487-08da6e1c1725', 1, N'I am a well rounded and friendly individual. Full of trust, I offer my Jobs to good handy men, who should be able to tell me anything in trust. My thoughts are that the Fundi would know better since it is their skills and profession. Give me a well done, job, and I am happy and will refer you to other jobs especially within my community. I always rate efficiency, and honesty as the 2 most important things, let alone friendly Fundis.', N'', CAST(N'2022-10-29T22:02:48.9011722' AS DateTime2), CAST(N'2022-10-29T22:02:48.9011789' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (11, N'f15c12e4-2d54-4699-f639-08dab52801f8', 2, N'I am Martin Okello - some call me THE MEDALLION - and been working as an Investment Fund Manager within EMEA. Recently visited Africa, to gain business ideas, and I am of the heart and feel that African Cultural Materials Can be exploited for the their explicit quality. My intentions are to open up shop in Uganda, Tanzania, Kenya, Ghana and South Africa to start with. It is viatal I get the people to build this dream, across the engineering descipline - namely.', N'', CAST(N'2022-10-29T22:12:39.3036677' AS DateTime2), CAST(N'2022-10-29T22:12:39.3036723' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (12, N'f15c12e4-2d54-4699-f639-08dab52801f8', 2, N'I am Martin Okello - some call me THE MEDAllion - and been working as an Investment Fund Manager within EMEA. Recently visited Africa, to gain business ideas, and I am of the heart and feel that African Cultural Materials Can be exploited for the their explicit quality. My intentions are to open up shop in Uganda, Tanzania, Kenya, Ghana and South Africa to start with. It is viatal I get the people to build this dream, across the engineering descipline - namely:', N'', CAST(N'2022-10-29T22:19:36.0862862' AS DateTime2), CAST(N'2022-10-29T22:19:36.0862918' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (13, N'f15c12e4-2d54-4699-f639-08dab52801f8', 2, N'I am Martin Okello - some call me THE MEDAllION - and been working as an Investment Fund Manager within EMEA. Recently visited Africa, to gain business ideas, and I am of the heart and feel that African Cultural Materials Can be exploited for the their explicit quality. My intentions are to open up shop in Uganda, Tanzania, Kenya, Ghana and South Africa to start with. It is viatal I get the people to build this dream, across the engineering descipline - namely:', N'', CAST(N'2022-10-29T22:21:24.1703706' AS DateTime2), CAST(N'2022-10-29T22:21:24.1703761' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (14, N'fa717c21-75f4-4259-01bd-08dab9dcad80', 5, N'A Masters Degree Holder In Computer Science, and Bachelors (Hons) in Civil/Structural Engineer. My interests are to engage in the redevelopment of Gulu, and hence taken on Chief Technical Officer, which aids the progress of building Urban Development. All employee chaps will be headed directly by me, though in teams with Team Leads.', N'', CAST(N'2022-11-01T02:10:24.6975055' AS DateTime2), CAST(N'2022-11-01T02:10:24.6975060' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[ClientProfiles] OFF
GO
SET IDENTITY_INSERT [dbo].[Courses] ON 
GO
INSERT [dbo].[Courses] ([CourseId], [CourseName], [CourseDescription], [DateCreated], [DateUpdated]) VALUES (1, N'Health And Safety', N'Health And Safety on building sites and when working with heavy machinery', CAST(N'2022-01-23T13:56:46.7203024' AS DateTime2), CAST(N'2022-01-23T13:56:46.7203210' AS DateTime2))
GO
INSERT [dbo].[Courses] ([CourseId], [CourseName], [CourseDescription], [DateCreated], [DateUpdated]) VALUES (2, N'Infrastructure Plumbing', N'Course directed at plumbers, orgainising pipes across floorss with both lateral and vertical height pressure accurate estimates.

Also an optional apprenticeship for a week on site to apply learnt knowledge', CAST(N'2022-09-05T11:56:27.0117230' AS DateTime2), CAST(N'2022-09-05T11:56:27.0117240' AS DateTime2))
GO
INSERT [dbo].[Courses] ([CourseId], [CourseName], [CourseDescription], [DateCreated], [DateUpdated]) VALUES (3, N'Metal Wortk And Welding', N'Course geared towards metal welding and joining, as well as working witrh metals to build structural elements.

An optional 2 days on site at the end of the course to see theory being applied.', CAST(N'2022-09-05T11:58:57.7515369' AS DateTime2), CAST(N'2022-09-05T11:58:57.7515374' AS DateTime2))
GO
INSERT [dbo].[Courses] ([CourseId], [CourseName], [CourseDescription], [DateCreated], [DateUpdated]) VALUES (4, N'HGV Driving Course Plus Year''s experience', N'Heavy Goods Vehicle Driving Course, from inception, to going behind the wheel of a truck.

Certification as proof of course required plus a year''s experience.', CAST(N'2022-09-05T12:03:19.5716078' AS DateTime2), CAST(N'2022-09-05T12:03:19.5716088' AS DateTime2))
GO
INSERT [dbo].[Courses] ([CourseId], [CourseName], [CourseDescription], [DateCreated], [DateUpdated]) VALUES (5, N'BTec Civil/Structural Engineering ', N'BTec Civil/Structural Engineering of practical nature. ', CAST(N'2022-10-29T04:37:58.1344945' AS DateTime2), CAST(N'2022-10-29T04:37:58.1344950' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Courses] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiProfileCertifications] ON 
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (5, 2, 1, CAST(N'2022-10-29T20:00:23.9085425' AS DateTime2), CAST(N'2022-10-29T20:00:23.9085477' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (6, 2, 4, CAST(N'2022-10-29T20:00:32.3816875' AS DateTime2), CAST(N'2022-10-29T20:00:32.3816942' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (7, 3, 1, CAST(N'2022-10-29T21:57:56.0093623' AS DateTime2), CAST(N'2022-10-29T21:57:56.0093679' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (8, 3, 3, CAST(N'2022-10-29T21:58:03.7854453' AS DateTime2), CAST(N'2022-10-29T21:58:03.7854493' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (9, 3, 4, CAST(N'2022-10-29T21:58:09.3757880' AS DateTime2), CAST(N'2022-10-29T21:58:09.3757937' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[FundiProfileCertifications] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiProfileCourses] ON 
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (6, 3, 2, CAST(N'2022-10-29T20:00:42.9036264' AS DateTime2), CAST(N'2022-10-29T20:00:42.9036306' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (7, 5, 2, CAST(N'2022-10-29T20:00:51.7362643' AS DateTime2), CAST(N'2022-10-29T20:00:51.7362686' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (8, 1, 2, CAST(N'2022-10-29T20:01:28.0267150' AS DateTime2), CAST(N'2022-10-29T20:01:28.0267199' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (9, 2, 3, CAST(N'2022-10-29T21:58:15.4314589' AS DateTime2), CAST(N'2022-10-29T21:58:15.4314793' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (10, 3, 3, CAST(N'2022-10-29T21:58:24.1912329' AS DateTime2), CAST(N'2022-10-29T21:58:24.1912359' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (11, 5, 3, CAST(N'2022-10-29T21:58:31.5411904' AS DateTime2), CAST(N'2022-10-29T21:58:31.5411949' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[FundiProfileCourses] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiProfiles] ON 
GO
INSERT [dbo].[FundiProfiles] ([FundiProfileId], [UserId], [ProfileSummary], [ProfileImageUrl], [Skills], [UsedPowerTools], [LocationId], [FundiProfileCvUrl], [DateCreated], [DateUpdated]) VALUES (1, N'665bcf05-492a-4b94-2a22-08da940013e8', N'Simply an entrepreneur, engaging in bringing together software that makes a difference in the information age, with high security in mind. ', N'', N'MSc Computer Science
BEng Civil/Structural Engineering
Experience invthe IT domain', N'JCB Driver, Heavy Crane Driver, Heavy Vehicle Driver. Power Drills Usage', 1, N'', CAST(N'2022-01-23T18:52:45.2286492' AS DateTime2), CAST(N'2022-01-23T18:52:45.2286555' AS DateTime2))
GO
INSERT [dbo].[FundiProfiles] ([FundiProfileId], [UserId], [ProfileSummary], [ProfileImageUrl], [Skills], [UsedPowerTools], [LocationId], [FundiProfileCvUrl], [DateCreated], [DateUpdated]) VALUES (2, N'fa717c21-75f4-4259-01bd-08dab9dcad80', N'I am a skilled Electrician with over 25 years experience working of large infrastructure Profiles as the Lead Electrician.', N'', N'Power Tools, Full Circuitry fittings across different building floors, and fitting main board, and different electrical devices.', N'Power Drill, All electric accessories', 3, N'', CAST(N'2022-01-24T09:33:02.9456609' AS DateTime2), CAST(N'2022-01-24T09:33:02.9456661' AS DateTime2))
GO
INSERT [dbo].[FundiProfiles] ([FundiProfileId], [UserId], [ProfileSummary], [ProfileImageUrl], [Skills], [UsedPowerTools], [LocationId], [FundiProfileCvUrl], [DateCreated], [DateUpdated]) VALUES (3, N'505c6acf-074a-4a51-8f38-08dab4e94775', N'A Structural Engineer/Civil Engineer with Plenty Computer Science skills and Electronic Skills for Circuitry wiring.', N'', N'1) Structural Design
2) Computer Programming and Design
', N'Electronic Testing Tools
HGV Driver', 2, N'', CAST(N'2022-10-25T21:56:25.8295286' AS DateTime2), CAST(N'2022-10-25T21:56:25.8295286' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[FundiProfiles] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiWorkCategories] ON 
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (10, 2, 1, NULL, CAST(N'2022-10-29T19:58:25.0497769' AS DateTime2), CAST(N'2022-10-29T19:58:25.0497846' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (11, 2, 3, NULL, CAST(N'2022-10-29T19:58:36.3572626' AS DateTime2), CAST(N'2022-10-29T19:58:36.3572669' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (12, 3, 1, NULL, CAST(N'2022-10-29T21:56:46.9187369' AS DateTime2), CAST(N'2022-10-29T21:56:46.9187421' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (13, 3, 3, NULL, CAST(N'2022-10-29T21:56:53.5322016' AS DateTime2), CAST(N'2022-10-29T21:56:53.5322064' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (14, 3, 6, NULL, CAST(N'2022-10-29T21:57:05.3765442' AS DateTime2), CAST(N'2022-10-29T21:57:05.3765505' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (15, 3, 7, NULL, CAST(N'2022-10-29T21:57:12.5720701' AS DateTime2), CAST(N'2022-10-29T21:57:12.5720743' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (16, 3, 8, NULL, CAST(N'2022-10-29T21:57:20.1711082' AS DateTime2), CAST(N'2022-10-29T21:57:20.1711132' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (17, 3, 11, NULL, CAST(N'2022-10-29T21:57:36.7571873' AS DateTime2), CAST(N'2022-10-29T21:57:36.7571919' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[FundiWorkCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[Jobs] ON 
GO
INSERT [dbo].[Jobs] ([JobId], [JobName], [JobDescription], [LocationId], [ClientProfileId], [ClientUserId], [AssignedFundiUserId], [AssignedFundiProfileId], [HasBeenAssignedFundi], [HasCompleted], [ClientFundiContractId], [NumberOfDaysToComplete], [DateCreated], [DateUpdated]) VALUES (12, N'Jonathan Asante-Martel Lindo-Martel Lindo''s Maidavale Kitchen Refit', N'Currently refurbishing my kitchen in Maidavale. I need, an Electrician, Painter, Plasterer, Brick Layer for this job, and need it completed in 12 days from day of work commencing.', 2, 9, N'e9585393-5fd1-45e8-5487-08da6e1c1725', NULL, NULL, 0, 0, NULL, 15, CAST(N'2022-10-29T22:06:25.7466967' AS DateTime2), CAST(N'2022-10-29T22:06:25.7467022' AS DateTime2))
GO
INSERT [dbo].[Jobs] ([JobId], [JobName], [JobDescription], [LocationId], [ClientProfileId], [ClientUserId], [AssignedFundiUserId], [AssignedFundiProfileId], [HasBeenAssignedFundi], [HasCompleted], [ClientFundiContractId], [NumberOfDaysToComplete], [DateCreated], [DateUpdated]) VALUES (17, N'Martin Okello-Martin The Medallion - Shops Across Africa', N'(1) Brick Layers
(2) Painters and Plasterers
(3) Plumbing, both Sewage and Water Pipes to new buildings
(4) Carpenters to build structural internal storage
(5) Metal Workers to Secure Premises.
(6) Electricians
', 3, 11, N'f15c12e4-2d54-4699-f639-08dab52801f8', NULL, NULL, 0, 0, NULL, 365, CAST(N'2022-10-29T22:28:08.3834103' AS DateTime2), CAST(N'2022-10-29T22:28:08.3834150' AS DateTime2))
GO
INSERT [dbo].[Jobs] ([JobId], [JobName], [JobDescription], [LocationId], [ClientProfileId], [ClientUserId], [AssignedFundiUserId], [AssignedFundiProfileId], [HasBeenAssignedFundi], [HasCompleted], [ClientFundiContractId], [NumberOfDaysToComplete], [DateCreated], [DateUpdated]) VALUES (19, N'First Administrator-Gulu City Project Africa', N'The redevelopment of Gulu, and hence taken on Chief Technical Officer, which aids the progress of building Urban Development. All employee chaps will be headed directly by me, though in teams with Team Leads.', 172, 14, N'fa717c21-75f4-4259-01bd-08dab9dcad80', NULL, NULL, 0, 0, NULL, 730, CAST(N'2022-11-01T02:13:40.0244230' AS DateTime2), CAST(N'2022-11-01T02:13:40.0244245' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Jobs] OFF
GO
SET IDENTITY_INSERT [dbo].[JobWorkCategories] ON 
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (86, 12, 1, CAST(N'2022-10-29T22:06:25.7968423' AS DateTime2), CAST(N'2022-10-29T22:06:25.7968465' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (87, 12, 2, CAST(N'2022-10-29T22:06:25.8136003' AS DateTime2), CAST(N'2022-10-29T22:06:25.8136078' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (88, 12, 3, CAST(N'2022-10-29T22:06:25.8138526' AS DateTime2), CAST(N'2022-10-29T22:06:25.8138562' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (89, 12, 4, CAST(N'2022-10-29T22:06:25.8139574' AS DateTime2), CAST(N'2022-10-29T22:06:25.8139597' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (90, 12, 6, CAST(N'2022-10-29T22:06:25.8140660' AS DateTime2), CAST(N'2022-10-29T22:06:25.8140689' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (91, 12, 7, CAST(N'2022-10-29T22:06:25.8141525' AS DateTime2), CAST(N'2022-10-29T22:06:25.8141552' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (92, 12, 8, CAST(N'2022-10-29T22:06:25.8142363' AS DateTime2), CAST(N'2022-10-29T22:06:25.8142386' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (121, 19, 1, CAST(N'2022-11-01T02:13:40.0441609' AS DateTime2), CAST(N'2022-11-01T02:13:40.0441614' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (122, 19, 3, CAST(N'2022-11-01T02:13:40.0470759' AS DateTime2), CAST(N'2022-11-01T02:13:40.0470764' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (123, 19, 4, CAST(N'2022-11-01T02:13:40.0471291' AS DateTime2), CAST(N'2022-11-01T02:13:40.0471296' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (124, 19, 6, CAST(N'2022-11-01T02:13:40.0471637' AS DateTime2), CAST(N'2022-11-01T02:13:40.0471642' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (125, 19, 7, CAST(N'2022-11-01T02:13:40.0471925' AS DateTime2), CAST(N'2022-11-01T02:13:40.0471925' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (126, 19, 8, CAST(N'2022-11-01T02:13:40.0472188' AS DateTime2), CAST(N'2022-11-01T02:13:40.0472193' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (127, 19, 9, CAST(N'2022-11-01T02:13:40.0472471' AS DateTime2), CAST(N'2022-11-01T02:13:40.0472471' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (128, 19, 11, CAST(N'2022-11-01T02:13:40.0472798' AS DateTime2), CAST(N'2022-11-01T02:13:40.0472798' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (129, 17, 1, CAST(N'2022-11-01T10:37:29.4502523' AS DateTime2), CAST(N'2022-11-01T10:37:29.4502537' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (130, 17, 2, CAST(N'2022-11-01T10:37:29.4533262' AS DateTime2), CAST(N'2022-11-01T10:37:29.4533267' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (131, 17, 3, CAST(N'2022-11-01T10:37:29.4533794' AS DateTime2), CAST(N'2022-11-01T10:37:29.4533794' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (132, 17, 4, CAST(N'2022-11-01T10:37:29.4534033' AS DateTime2), CAST(N'2022-11-01T10:37:29.4534037' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (133, 17, 6, CAST(N'2022-11-01T10:37:29.4534242' AS DateTime2), CAST(N'2022-11-01T10:37:29.4534242' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (134, 17, 7, CAST(N'2022-11-01T10:37:29.4534452' AS DateTime2), CAST(N'2022-11-01T10:37:29.4534452' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (135, 17, 8, CAST(N'2022-11-01T10:37:29.4534642' AS DateTime2), CAST(N'2022-11-01T10:37:29.4534647' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[JobWorkCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[Locations] ON 
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (1, NULL, 3, N'55 Sixth St, Kampala, Uganda', 0.3170758, 32.6035652, CAST(N'2022-07-21T21:15:54.7493512' AS DateTime2), CAST(N'2022-10-27T03:24:18.6874700' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (2, NULL, 4, N'3, 13 Lanhill Rd, London W9, UK', 51.52658, -0.1963439, CAST(N'2022-07-09T18:52:11.3651260' AS DateTime2), CAST(N'2022-10-31T11:23:56.7621102' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (3, NULL, 2, N'Nile Avenue Kimathi Ave, Kampala, Uganda', 0.3151942, 32.58282, CAST(N'2022-07-28T08:39:23.3488502' AS DateTime2), CAST(N'2022-10-27T03:24:39.7725450' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (170, NULL, 1, N'3, 2 St John''s Terrace, London W10 4SB, UK', 51.52733, -0.2152936, CAST(N'2022-10-26T15:30:16.0614437' AS DateTime2), CAST(N'2022-10-27T03:24:49.3436887' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (171, NULL, 6, N'Lira Road-Customer Corner', NULL, NULL, CAST(N'2022-10-28T00:27:21.9385664' AS DateTime2), CAST(N'2022-10-28T00:27:21.9385669' AS DateTime2), 0)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (172, NULL, 5, N'46 Lira - Gulu Rd, Uganda', 2.29509139, 32.7446823, CAST(N'2022-10-28T00:27:24.3239915' AS DateTime2), CAST(N'2022-10-28T00:27:24.3239915' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (174, NULL, 6, N'Steve Biko Court, St John''s Terrace, London W10 4SB, UK', 51.52724, -0.2153939, CAST(N'2022-10-28T03:49:32.2619429' AS DateTime2), CAST(N'2022-10-28T03:49:32.2619434' AS DateTime2), 1)
GO
SET IDENTITY_INSERT [dbo].[Locations] OFF
GO
SET IDENTITY_INSERT [dbo].[MonthlySubscriptions] ON 
GO
INSERT [dbo].[MonthlySubscriptions] ([MonthlySubscriptionId], [UserId], [Username], [FundiProfileId], [HasPaid], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [StartDate], [EndDate], [DateUpdated]) VALUES (13, NULL, N'martin.okello@martinlayooinc.com', NULL, 0, NULL, CAST(0.00 AS Decimal(18, 2)), NULL, CAST(N'2022-10-23T20:32:13.8500000' AS DateTime2), CAST(N'2022-11-23T22:32:14.4679690' AS DateTime2), CAST(N'2022-10-23T22:32:14.4679964' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptions] ([MonthlySubscriptionId], [UserId], [Username], [FundiProfileId], [HasPaid], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [StartDate], [EndDate], [DateUpdated]) VALUES (14, N'fa717c21-75f4-4259-01bd-08dab9dcad80', N'administrator@martinlayooinc.com', 2, 0, N'Fundi User First Administrator Subscription for 31 days', CAST(2500.00 AS Decimal(18, 2)), N'Attempting Monthly Payment!', CAST(N'2022-11-06T00:47:04.7110000' AS DateTime2), CAST(N'2022-12-07T02:47:11.0080468' AS DateTime2), CAST(N'2022-11-06T02:47:11.0080698' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[MonthlySubscriptions] OFF
GO
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (N'70c207cd-32fe-4a4d-f121-08da6b55d0b5', N'Administrator')
GO
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (N'363c5eb4-d694-4f61-f122-08da6b55d0b5', N'Fundi')
GO
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (N'110f023f-6a45-4bb2-f123-08da6b55d0b5', N'Client')
GO
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (N'1e2e8d83-9f49-45a4-f124-08da6b55d0b5', N'Guest')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'6023812b-9524-43f5-a837-7b5c98e8d384', N'e9585393-5fd1-45e8-5487-08da6e1c1725', N'110f023f-6a45-4bb2-f123-08da6b55d0b5')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'07867c09-c5b0-4bcb-be70-faf2aed339e2', N'665bcf05-492a-4b94-2a22-08da940013e8', N'110f023f-6a45-4bb2-f123-08da6b55d0b5')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'90d5025b-b6fa-4978-84b7-5bccf1f920b9', N'505c6acf-074a-4a51-8f38-08dab4e94775', N'363c5eb4-d694-4f61-f122-08da6b55d0b5')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'8d1a8e31-4f4a-4bbc-963c-1233807859ff', N'f15c12e4-2d54-4699-f639-08dab52801f8', N'110f023f-6a45-4bb2-f123-08da6b55d0b5')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'88263e9d-9d88-4360-bdc9-5feb388eabfb', N'fa717c21-75f4-4259-01bd-08dab9dcad80', N'70c207cd-32fe-4a4d-f121-08da6b55d0b5')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'f06242f4-f7e5-463a-ebfb-08dab9dcada0', N'fa717c21-75f4-4259-01bd-08dab9dcad80', N'363c5eb4-d694-4f61-f122-08da6b55d0b5')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'8787a27f-700b-4063-a59f-49130ceeb21b', N'fa717c21-75f4-4259-01bd-08dab9dcad80', N'110f023f-6a45-4bb2-f123-08da6b55d0b5')
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'e9585393-5fd1-45e8-5487-08da6e1c1725', N'Jonathan', N'Asante', N'Jonathan.asante@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'Jonathan.asante@martinlayooinc.com', N'07809773333', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDplJMlRK8KSSGoUDpuAFClmzsh1y9e9jY5QD6br00K8BZZIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxZSXCIDCDTVYRWjJlDGnHxWCnWwueNWBZQd8nh5ZHObT+bAm5FswOiMkaMaL8uTtFMMwbqUPOy1LWfIUDL52JbIHTR6BAyf4Kx57Bae9xbepbPdvVe6JIBlVbKwSjwMsI14cqRzAf7PjGD7UqRACJTOhz9+v8QTfQdDvzOYN7Tai7RQkJrbeBXZ1nCEwSEqN8d8nTm6ibgvOIgzVDklZnvbuBmsQX0rxFcAtGmE1ncUEjcOBKO8UtAYq4kg7Oi3lOdDK9hYi46h7XB7YnAaxpzUqifWTFULaqekFi6+xVbR8yH5KgnsSvTD8puKLbaUc8qbnjHBYgCwYAYe4DWqLl1Pva009zM9oSbjvb8XmT98cAc9p2roho0WoGIixWsYL5zv+VLUSbxUhMKKCMUCJ6LneD1bkpdJPGY1gEir+6esWwG7poBfqcjRHThCBDZLEOCafEygtAYd6qwQ5T2WKDFKkUiHTO+W9OC3tPNCKzZCzI8sPJQA/qjzYlvrydbGKA/hq+KTqVds0IdQumH2qsNRGadL/aNt1P1GJbhRMtumjNjaBygo3P3DXJYLHfHblpqr9WTDWhKbsiCpPs13sxGkMp3hp2Me5yRd3UeEycpQt3MQqwJLQQAHJzJzAXgxZ0Y9zl0os0oGU8xrMawFdUBu', NULL, CAST(N'2022-07-25T10:00:15.2484206' AS DateTime2), CAST(N'2022-11-04T11:40:39.4627173' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'665bcf05-492a-4b94-2a22-08da940013e8', N'Test', N'Test', N'test@test.com', N'pJ7MG0Vr0qvHA8Pue2Jjhw==', N'test@test.com', N'112', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpkq32ko3Z4Slp+fz44rO9B/8D3L4OLbpwV+KWPs712nj5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxYe1lzzRUKD6/JDAgcJOUGvd2HFwAquP13IZjbb+dHbJFGnCiKDci/0En+F8+64z+5rD5CgRM+NKTikVJfXp5l9GXd8UrhNq5gsVDUGVoMOalLSK8TrTEJBvXCvR6FeIYNGLpacZbargsRpK9+IzHmikax9GZur0bvf0nwtAakhAO1ADkcCNUkVXDBqW7smwAY/WW+gIBy7ZuCp6nRsNCW2C0LCThOuoUBlHhUACrzZrdr805GJMzXOgjDlhsyheTmS2qDZVTozKRLWjmEL44et7xqGoyS1RzRz3SYtewaPFV81bXLuBer8ymNi9lgZSIZTKu+Rz9P28CFhftAsEIeeGtQXUMkRpb7iWyuxKqrH72dsg+Qq2s7AtX8rcdcrkvNhFbVxYjsuOuB32Hw30jFvxwMi3KADpgfvogMM8TAsHyYUuVeCL+YNhJ4BkPS7oHqL34dCpbwQEYmIGPzUlXUmaRmAIiRRKacswMTGn4qc4VDt9d5SWEcUxz1zDRfsX7by8R1tA+0vnR2lyKVDBEfSLGQN8yQRV5ohQjegNE0HAD6KiXsxUYhxxCjmEaGG42t6P5Egx1/kckGZKNkOcXruY94WTcaNGz/hQk5dPmzEFQ==', NULL, CAST(N'2022-09-11T16:15:28.1067428' AS DateTime2), CAST(N'2022-09-11T16:15:47.0969135' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'505c6acf-074a-4a51-8f38-08dab4e94775', N'Martin', N'Okello', N'martin.okello@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'martin.okello@martinlayooinc.com', N'07655432156', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpmdfGLPh9WI5dvMYlndFmAdP91/za3Emi5W48rCOSiZEJIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxbX5j9L10UKiFPsV5hiqot0LS7amXwGSnpXl1xsxCQpFb0l7/8ABiWYl7IPoMOoW8Dp34LFQqks0C1LYhHmd0i0xbAwh6b3ai3wbhMRPZZ4hntYYgaxpa9QVymF9+NuFCzomMKA+/Paz7h/TUBEL0fgi9Mz2c3fU+TVpTwC6ZU7VGk/WGPmSFJiyNCRYJZYK6+WMpnRNqXGkGNPzzgqKobx8b6ryE96QcChNzKof3FrRAqeifE5/+KL9VJLGaZy5UGOVtjwWnbDX1LP5x0Hn9JRKdZ45I31Jr5tI2SWuz1VeZ76vQq6dejdm/W+tBDZALbMzhEqrboIufYX3D4tvO3IZkPGNXKFcrHcAoAu/GMnXf8UOy11fiTRIuO/4zHs3iXV0F3aTPTjCaJfe4F46VqJfL77Wy3CLieHMI5MFS/css5venzPG6r58q+1BrmU4+jUzeiQ081rzNeJm9mwYhrUa2k0GsAYdQe6hwa/H1ugX4tFf7UIuJOrc7AUksFo2PmKjlPdEnv0e582EBgKEt3n0rEzcDinF8Z1UeNUSEN84CIYStsDNBk8zt1ipyCH8/hVXGknhMS9M2SsVONW4xc32CoP0DV65oAmg8b/7Tgpaty6xZZdUTvULJ3ZYGhBEho=', NULL, CAST(N'2022-10-23T13:25:24.5566409' AS DateTime2), CAST(N'2022-11-20T17:06:02.0746945' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'f15c12e4-2d54-4699-f639-08dab52801f8', N'Martin', N'Okello', N'martin.okello@gmail.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'martin.okello@gmail.com', N'07898989765', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpk0HFF1pvjZcPTPVlhtzzONy01WJymQD73j1ajZqtLdaZIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxbX5j9L10UKiFPsV5hiqot0llCznzEyf0j0jdtIoOsrG41TkII5hndPTx7BRUGiWpl5VvozijetA3goxtUIpgh6iQ51Ogez5/Kog5PpwvldrRO1YCDi2CD0VSmnqYdUp1D1ZIzVHg7cuvlziug6JPeTjOWBrgDjuFrWN+/1+/TtCimEkb8lgnQwR384qBwgeODI3EFEiGxzL4cVzsV8m6FfGNUyS9kDUZru7MMS8z6wN6dMYiRyQpgNW9aM4gFcNYW1fgsxLqcFvpFtCCaSvGiYXOGQlnSV+FeA8kNHp5nSvBW9ygiSyku0jtV2oNDlBjyFXNnPYUxstInvTVVpgty4Ymk7hbqTKHBplGw30u/ieokiYCPfzFbmVLxooTvD8r0RKkekAQ9Eu9jIr6+Buall6A9m4msd60xbft9HmZSK3MdOF4ln0UwUaaPAHemH6TJ26YlnggE1hztSpNbLaNYLYgKRFRxjqVXjpN9r8f/T+fqSpN7AV2PEXIsEhjV8EK4EVWPtG10hdB8C2E+nqC7EmnxMoLQGHeqsEOU9ligxShoSaxbMtHdUmfoBtCJNx8VnBSeh1M1IgTiFYxeu8z+5POnRcvMmrwVE1HNAdSFszDuisGrWFcNRkgnuxNS9BdI=', NULL, CAST(N'2022-10-23T20:54:26.2711942' AS DateTime2), CAST(N'2022-11-01T10:34:26.9679236' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'fa717c21-75f4-4259-01bd-08dab9dcad80', N'First', N'Administrator', N'administrator@martinlayooinc.com', N'3YFoEKPCH7RRX7LG30XMxw==', N'administrator@martinlayooinc.com', N'07809773365', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpl1spus7RbBydwIoQqovR8UNDBTaiQKIIDOX4ixlRCqvpIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxZeroDY/XzFWei5nErTq5dpFeZJ8dkqnRn+LDceM2OcR70l7/8ABiWYl7IPoMOoW8DcDLzmOlFJDkCGGEDhW3BrAcntfi8U3xlAuC10JXcqqwYosmbCqKzLl76vLfZoMv6hegFqAlLsWH6EG/Mh+JQG2bCkf5wjNp87/b9Whv6AMMdVuqN1o00aFqj1o7UYD8proYzdGx/Ux0ntdZTyfbOKGXd8UrhNq5gsVDUGVoMOaqUiYjOHwcVi6Co/ZxpB4i8a6W8l/3KYRvK8KnmGiOfHHTR6BAyf4Kx57Bae9xbepbPdvVe6JIBlVbKwSjwMsI14cqRzAf7PjGD7UqRACJTOhz9+v8QTfQdDvzOYN7Tai9a+/mUa1GrA8nSHeT499MXyA0LYnl9ozsLZGQ7XQT0jjbOqq4/k7bBkWkuabO/is4somDQjqLc7prG7SLdibZTBIAJxgIMamw8XJ9vQX2HMllOlZu7fpZ75UqV1r6n5eDbTDFnByEn4Zm6b3HECGwrdjvIKoDhcGVSytE2HCmSHRIkjj+nonqtDJ6LW4+uP8NTSdPFbvA1XTS3hTBWDRiwpJC693TtifkhOuKqMqmb1Cq8X7nhU68M/VZD3MoA6nKGwJEaBMvf2mM0TQsSENAGt7O1Jo5y8pd0SpcTxsnSr9XV0FKoIpPIr7pou/NBSQGH8ivwT/P6uCc6K4Fzu0wt6P5Egx1/kckGZKNkOcXruB+UwO64JU6l62utG5h9X9+F+p54JzhQ7dv5bSADipFD3/h9iKUHjxag3op3RHPfYzsvbbg0rcZLD85EHTLfmnvF90ghZ/TWHsQaRmCf3JbMenIYVOeimNogu9XRlDrFo', NULL, CAST(N'2022-10-29T19:37:48.1036263' AS DateTime2), CAST(N'2022-11-09T07:26:48.3949060' AS DateTime2), 1, 0)
GO
SET IDENTITY_INSERT [dbo].[WorkCategories] ON 
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (1, N'Electrician', N'Dealing with Electric elements of Building and Infrastructure Projects', CAST(N'2022-01-23T13:50:28.2254776' AS DateTime2), CAST(N'2022-01-23T13:50:28.2254824' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (2, N'Carpenter', N'Dealing with Wood and fixing problems related to wood work.', CAST(N'2022-01-23T13:51:35.1039438' AS DateTime2), CAST(N'2022-01-23T13:51:35.1039511' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (3, N'Metal Work', N'Working with metals and alloys, with great finishes of metal joins. Welding and ensuring that the molten metal holds together fully. Filing metals for great finishes. ', CAST(N'2022-07-01T16:14:28.5001609' AS DateTime2), CAST(N'2022-07-01T16:14:28.5001619' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (4, N'Plumbing', N'Being able to confidently put together pipe works, for both sewage and domestic water works in both renovated and new buildings. Hands on and confident applying the required skills', CAST(N'2022-07-01T16:16:37.7993191' AS DateTime2), CAST(N'2022-07-01T16:16:37.7993201' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (5, N'Gardening', N'Gardening has become popular as people need their gardens exquisite looking. This gives a depth of character to any properties. Cutting edges, cutting lawns, and providing an array of beautiful flowers around is great these days. You can register as a gardener with this in mind ', CAST(N'2022-07-01T17:38:05.3049046' AS DateTime2), CAST(N'2022-07-01T17:38:05.3049056' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (6, N'Brick Layer', N'Laying bricks in straight lines, and with fine finishings. Mix 9f concrete and sand should be good to ensure adhesive mix content. ', CAST(N'2022-07-09T19:10:22.9559297' AS DateTime2), CAST(N'2022-07-09T19:10:22.9559307' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (7, N'Plasterer', N'Effective plastering of walls and ceilings, with great finishings. Care not to damage existing finishes. ', CAST(N'2022-07-09T19:12:03.9416488' AS DateTime2), CAST(N'2022-07-09T19:12:03.9416493' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (8, N'Painters', N'Able to quickly paint and double over the initial work, ensuring the paint work completion is as expected. Able to work unsupervised, and effectively. ', CAST(N'2022-07-09T19:13:52.9853648' AS DateTime2), CAST(N'2022-07-09T19:13:52.9853663' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (9, N'HGV Drivers', N'Heavy Goods Vehicle Drivers, that work in shifts. ', CAST(N'2022-07-09T19:22:54.3459479' AS DateTime2), CAST(N'2022-07-09T19:22:54.3459489' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (10, N'Car Mechanics', N'Car Mechanics with proven history of dealing with mechanical devices in car systems. ', CAST(N'2022-07-09T19:23:58.4493768' AS DateTime2), CAST(N'2022-07-09T19:23:58.4493778' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (11, N'Road Works - Civil Engineering', N'Road Works & Civil Engineering', CAST(N'2022-10-29T03:13:20.9373095' AS DateTime2), CAST(N'2022-10-29T03:13:20.9373100' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[WorkCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[WorkSubCategories] ON 
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (1, N'Electrical Wiring', N'Electrical Wiring Of Buildiings', 1, CAST(N'2022-11-20T17:07:15.4730190' AS DateTime2), CAST(N'2022-11-20T17:07:15.4730249' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (2, N'Circuitry Installments', N'Installing new and revamps of old Circuit Boards', 1, CAST(N'2022-11-20T17:08:05.4916027' AS DateTime2), CAST(N'2022-11-20T17:08:05.4916083' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[WorkSubCategories] OFF
GO
/****** Object:  Index [AK_UserRoles_UserId_RoleId]    Script Date: 22/11/2022 05:06:47 ******/
ALTER TABLE [dbo].[UserRoles] ADD  CONSTRAINT [AK_UserRoles_UserId_RoleId] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [AK_Users_Username]    Script Date: 22/11/2022 05:06:47 ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [AK_Users_Username] UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientFundiContracts]  WITH CHECK ADD  CONSTRAINT [FK_ClientFundiContracts_Users_ClientUserId] FOREIGN KEY([ClientUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[ClientFundiContracts] CHECK CONSTRAINT [FK_ClientFundiContracts_Users_ClientUserId]
GO
ALTER TABLE [dbo].[ClientFundiContracts]  WITH CHECK ADD  CONSTRAINT [FK_ClientFundiContracts_Users_FundiUserId] FOREIGN KEY([FundiUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[ClientFundiContracts] CHECK CONSTRAINT [FK_ClientFundiContracts_Users_FundiUserId]
GO
ALTER TABLE [dbo].[ClientProfiles]  WITH CHECK ADD  CONSTRAINT [FK_ClientProfiles_Addresses_AddressId] FOREIGN KEY([AddressId])
REFERENCES [dbo].[Addresses] ([AddressId])
GO
ALTER TABLE [dbo].[ClientProfiles] CHECK CONSTRAINT [FK_ClientProfiles_Addresses_AddressId]
GO
ALTER TABLE [dbo].[ClientProfiles]  WITH CHECK ADD  CONSTRAINT [FK_ClientProfiles_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[ClientProfiles] CHECK CONSTRAINT [FK_ClientProfiles_Users_UserId]
GO
ALTER TABLE [dbo].[Companies]  WITH CHECK ADD  CONSTRAINT [FK_Companies_Locations_LocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Locations] ([LocationId])
GO
ALTER TABLE [dbo].[Companies] CHECK CONSTRAINT [FK_Companies_Locations_LocationId]
GO
ALTER TABLE [dbo].[FundiProfileAndReviewRatings]  WITH CHECK ADD  CONSTRAINT [FK_FundiProfileAndReviewRatings_FundiProfiles_FundiProfileId] FOREIGN KEY([FundiProfileId])
REFERENCES [dbo].[FundiProfiles] ([FundiProfileId])
GO
ALTER TABLE [dbo].[FundiProfileAndReviewRatings] CHECK CONSTRAINT [FK_FundiProfileAndReviewRatings_FundiProfiles_FundiProfileId]
GO
ALTER TABLE [dbo].[FundiProfileAndReviewRatings]  WITH CHECK ADD  CONSTRAINT [FK_FundiProfileAndReviewRatings_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[FundiProfileAndReviewRatings] CHECK CONSTRAINT [FK_FundiProfileAndReviewRatings_Users_UserId]
GO
ALTER TABLE [dbo].[FundiProfileCertifications]  WITH CHECK ADD  CONSTRAINT [FK_FundiProfileCertifications_Certifications_CertificationId] FOREIGN KEY([CertificationId])
REFERENCES [dbo].[Certifications] ([CertificationId])
GO
ALTER TABLE [dbo].[FundiProfileCertifications] CHECK CONSTRAINT [FK_FundiProfileCertifications_Certifications_CertificationId]
GO
ALTER TABLE [dbo].[FundiProfileCertifications]  WITH CHECK ADD  CONSTRAINT [FK_FundiProfileCertifications_FundiProfiles_FundiProfileId] FOREIGN KEY([FundiProfileId])
REFERENCES [dbo].[FundiProfiles] ([FundiProfileId])
GO
ALTER TABLE [dbo].[FundiProfileCertifications] CHECK CONSTRAINT [FK_FundiProfileCertifications_FundiProfiles_FundiProfileId]
GO
ALTER TABLE [dbo].[FundiProfileCourses]  WITH CHECK ADD  CONSTRAINT [FK_FundiProfileCourses_Courses_CourseId] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
GO
ALTER TABLE [dbo].[FundiProfileCourses] CHECK CONSTRAINT [FK_FundiProfileCourses_Courses_CourseId]
GO
ALTER TABLE [dbo].[FundiProfileCourses]  WITH CHECK ADD  CONSTRAINT [FK_FundiProfileCourses_FundiProfiles_FundiProfileId] FOREIGN KEY([FundiProfileId])
REFERENCES [dbo].[FundiProfiles] ([FundiProfileId])
GO
ALTER TABLE [dbo].[FundiProfileCourses] CHECK CONSTRAINT [FK_FundiProfileCourses_FundiProfiles_FundiProfileId]
GO
ALTER TABLE [dbo].[FundiProfiles]  WITH CHECK ADD  CONSTRAINT [FK_FundiProfiles_Locations_LocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Locations] ([LocationId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FundiProfiles] CHECK CONSTRAINT [FK_FundiProfiles_Locations_LocationId]
GO
ALTER TABLE [dbo].[FundiProfiles]  WITH CHECK ADD  CONSTRAINT [FK_FundiProfiles_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[FundiProfiles] CHECK CONSTRAINT [FK_FundiProfiles_Users_UserId]
GO
ALTER TABLE [dbo].[FundiWorkCategories]  WITH CHECK ADD  CONSTRAINT [FK_FundiWorkCategories_FundiProfiles_FundiProfileId] FOREIGN KEY([FundiProfileId])
REFERENCES [dbo].[FundiProfiles] ([FundiProfileId])
GO
ALTER TABLE [dbo].[FundiWorkCategories] CHECK CONSTRAINT [FK_FundiWorkCategories_FundiProfiles_FundiProfileId]
GO
ALTER TABLE [dbo].[FundiWorkCategories]  WITH CHECK ADD  CONSTRAINT [FK_FundiWorkCategories_WorkCategories_WorkCategoryId] FOREIGN KEY([WorkCategoryId])
REFERENCES [dbo].[WorkCategories] ([WorkCategoryId])
GO
ALTER TABLE [dbo].[FundiWorkCategories] CHECK CONSTRAINT [FK_FundiWorkCategories_WorkCategories_WorkCategoryId]
GO
ALTER TABLE [dbo].[Invoices]  WITH CHECK ADD  CONSTRAINT [FK_Invoices_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Invoices] CHECK CONSTRAINT [FK_Invoices_Users_UserId]
GO
ALTER TABLE [dbo].[Items]  WITH CHECK ADD  CONSTRAINT [FK_Items_Invoices_InvoiceId] FOREIGN KEY([InvoiceId])
REFERENCES [dbo].[Invoices] ([InvoiceId])
GO
ALTER TABLE [dbo].[Items] CHECK CONSTRAINT [FK_Items_Invoices_InvoiceId]
GO
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Jobs_ClientProfiles_ClientProfileId] FOREIGN KEY([ClientProfileId])
REFERENCES [dbo].[ClientProfiles] ([ClientProfileId])
GO
ALTER TABLE [dbo].[Jobs] CHECK CONSTRAINT [FK_Jobs_ClientProfiles_ClientProfileId]
GO
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Jobs_FundiProfiles_AssignedFundiProfileId] FOREIGN KEY([AssignedFundiProfileId])
REFERENCES [dbo].[FundiProfiles] ([FundiProfileId])
GO
ALTER TABLE [dbo].[Jobs] CHECK CONSTRAINT [FK_Jobs_FundiProfiles_AssignedFundiProfileId]
GO
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Jobs_Locations_LocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Locations] ([LocationId])
GO
ALTER TABLE [dbo].[Jobs] CHECK CONSTRAINT [FK_Jobs_Locations_LocationId]
GO
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Jobs_Users_AssignedFundiUserId] FOREIGN KEY([AssignedFundiUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Jobs] CHECK CONSTRAINT [FK_Jobs_Users_AssignedFundiUserId]
GO
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Jobs_Users_ClientUserId] FOREIGN KEY([ClientUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Jobs] CHECK CONSTRAINT [FK_Jobs_Users_ClientUserId]
GO
ALTER TABLE [dbo].[JobWorkCategories]  WITH CHECK ADD  CONSTRAINT [FK_JobWorkCategories_Jobs_JobId] FOREIGN KEY([JobId])
REFERENCES [dbo].[Jobs] ([JobId])
GO
ALTER TABLE [dbo].[JobWorkCategories] CHECK CONSTRAINT [FK_JobWorkCategories_Jobs_JobId]
GO
ALTER TABLE [dbo].[JobWorkCategories]  WITH CHECK ADD  CONSTRAINT [FK_JobWorkCategories_WorkCategories_WorkCategoryId] FOREIGN KEY([WorkCategoryId])
REFERENCES [dbo].[WorkCategories] ([WorkCategoryId])
GO
ALTER TABLE [dbo].[JobWorkCategories] CHECK CONSTRAINT [FK_JobWorkCategories_WorkCategories_WorkCategoryId]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_Locations_Addresses_AddressId] FOREIGN KEY([AddressId])
REFERENCES [dbo].[Addresses] ([AddressId])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_Locations_Addresses_AddressId]
GO
ALTER TABLE [dbo].[MonthlySubscriptions]  WITH CHECK ADD  CONSTRAINT [FK_MonthlySubscriptions_FundiProfiles_FundiProfileId] FOREIGN KEY([FundiProfileId])
REFERENCES [dbo].[FundiProfiles] ([FundiProfileId])
GO
ALTER TABLE [dbo].[MonthlySubscriptions] CHECK CONSTRAINT [FK_MonthlySubscriptions_FundiProfiles_FundiProfileId]
GO
ALTER TABLE [dbo].[MonthlySubscriptions]  WITH CHECK ADD  CONSTRAINT [FK_MonthlySubscriptions_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MonthlySubscriptions] CHECK CONSTRAINT [FK_MonthlySubscriptions_Users_UserId]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_Roles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([RoleId])
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_Roles_RoleId]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_Users_UserId]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Companies_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Companies] ([CompanyId])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Companies_CompanyId]
GO
ALTER TABLE [dbo].[WorkSubCategories]  WITH CHECK ADD  CONSTRAINT [FK_WorkSubCategories_WorkCategories_WorkCategoryId] FOREIGN KEY([WorkCategoryId])
REFERENCES [dbo].[WorkCategories] ([WorkCategoryId])
GO
ALTER TABLE [dbo].[WorkSubCategories] CHECK CONSTRAINT [FK_WorkSubCategories_WorkCategories_WorkCategoryId]
GO
/****** Object:  StoredProcedure [dbo].[GetFundiAverageRatingByProfileId]    Script Date: 22/11/2022 05:06:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetFundiAverageRatingByProfileId](@fundiProfileId int)
AS
SELECT [FundiProfileId]
      ,Avg([Rating]) as FundiAverageRating
  FROM [myfundiv2].[dbo].[FundiProfileAndReviewRatings]
  where [FundiProfileId]=@fundiProfileId
  group by [FundiProfileId]
GO
/****** Object:  StoredProcedure [dbo].[GetFundiByLocationVsJobLocation]    Script Date: 22/11/2022 05:06:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetFundiByLocationVsJobLocation](@distanceApart float, @fundiProfileId int, @workCategories nvarchar, @skip int=0, @take int=5)
AS
BEGIN
	begin
	With Results as(
		select fn.FundiProfileId as FundiProfileId, fn.UserId as FundiUserId, fn.ProfileSummary as FundiProfileSummary, fn.LocationId as FundiLocationId, us.Username as FundiUsername,us.FirstName as FundiFirstName, us.LastName as FundiLastName,
		fn.Skills as FundiSkills, fn.UsedPowerTools as FundiUsedPowerTools, lc.LocationName as FundiLocationName, us.MobileNumber as FundiMobileNumber,
		lc.Latitude as FundiLocationLat, lc.Longitude as FundiLocationLong,jlc.LocationId as JobLocationId, jlc.Latitude as JobLocationLatitude,
		jwCats.JobWorkCategoryId as JobWorkCategoryId,wcats.WorkCategoryId as WorkCategoryId, wCats.WorkCategoryType as WorkCategoryType, wCats.WorkCategoryDescription,
		jlc.Longitude as JobLocationLongitude,j.JobId as JobId, j.JobName as JobName, j.JobDescription as JobDescription, jlc.LocationName as JobLocationName, cp.UserId as ClientUserId, cp.ClientProfileId as ClientProfileId, 
		clUser.FirstName as ClientFirstName,clUser.LastName as ClientLastName,clUser.Username as ClientUsername,clUser.MobileNumber as ClientMobileNumber,cp.AddressId as ClientAddressId,cp.ProfileSummary as ClientProfileSummary,
		(select distanceApart from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart)) as distanceApart
		from FundiProfiles fn 
		join Users us on
		fn.UserId = us.UserId
		join Locations lc on fn.LocationId = lc.LocationId
		cross join Jobs j
		join JobWorkCategories jwCats on
		j.JobId = jwCats.JobId join
		WorkCategories wcats on
		jwCats.WorkCategoryId = wcats.WorkCategoryId join
		Locations jlc on
		j.LocationId = jlc.LocationId
		join ClientProfiles cp on 
		j.ClientProfileId = cp.ClientProfileId
		join Users clUser on
		cp.UserId = clUser.UserId
		left join FundiProfileAndReviewRatings fpAndRvRatings
		on cp.UserId = fpAndRvRatings.UserId
		where fn.FundiProfileId = @fundiProfileId and wcats.WorkCategoryType in (/*select item from dbo.[fnSplit](@workCategories,',')*/N'Electrician') and (select IsWithinDistance from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart)) = 1
		Group By 
			fn.FundiProfileId, fn.UserId, fn.ProfileSummary, fn.LocationId, us.Username,us.FirstName,us.LastName,
			fn.Skills, fn.UsedPowerTools, lc.LocationName, us.MobileNumber,
			lc.Latitude, lc.Longitude,jlc.LocationId, jlc.Latitude,j.JobId, j.JobName, j.JobDescription,
			jlc.Longitude, jlc.LocationName, cp.UserId, cp.ClientProfileId,wcats.WorkCategoryId, 
			clUser.Username, clUser.FirstName, clUser.LastName, clUser.MobileNumber,cp.AddressId,cp.ProfileSummary,
			jwCats.JobWorkCategoryId, wcats.WorkCategoryType, wcats.WorkCategoryDescription
		ORDER BY (select distanceApart from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart))
		OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY
		)
		select distinct *
		from Results
	end
END
GO
/****** Object:  StoredProcedure [dbo].[GetFundiRatings]    Script Date: 22/11/2022 05:06:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetFundiRatings](@distanceApart float, @workCategories nvarchar, @skip int=0, @take int=5)
AS
BEGIN
With Results as(
	select fn.FundiProfileId as FundiProfileId, fn.UserId as FundiUserId, fn.ProfileSummary as FundiProfileSummary, fn.LocationId as FundiLocationId, us.Username as FundiUsername,us.FirstName as FundiFirstName, us.LastName as FundiLastName,
	fn.Skills as FundiSkills, fn.UsedPowerTools as FundiUsedPowerTools, lc.LocationName as FundiLocationName, us.MobileNumber as FundiMobileNumber,
	lc.Latitude as FundiLocationLat, lc.Longitude as FundiLocationLong,jlc.LocationId as JobLocationId, jlc.Latitude as JobLocationLatitude,
	jwCats.JobWorkCategoryId as JobWorkCategoryId,wCats.WorkCategoryId as WorkCategoryId, wCats.WorkCategoryType as WorkCategoryType, wCats.WorkCategoryDescription,
	jlc.Longitude as JobLocationLongitude,j.JobId as JobId, j.JobName as JobName, j.JobDescription as JobDescription, jlc.LocationName as JobLocationName, cp.UserId as ClientUserId, cp.ClientProfileId as ClientProfileId, 
	clUser.Username as ClientUsername,clUser.FirstName as ClientFirstName, clUser.LastName as ClientLastName ,clUser.MobileNumber as ClientMobileNumber,cp.AddressId as ClientAddressId,cp.ProfileSummary as ClientProfileSummary,
	(select distanceApart from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart)) as distanceApart,fpAndRvRatings.Review as ClientReview, fpAndRvRatings.Rating as FundiRating
	from FundiProfiles fn 
	join Users us on
	fn.UserId = us.UserId
	join Locations lc on fn.LocationId = lc.LocationId
	cross join Jobs j
	join JobWorkCategories jwCats on
	j.JobId = jwCats.JobId join
	WorkCategories wcats on
	jwCats.WorkCategoryId = wcats.WorkCategoryId join
	Locations jlc on
	j.LocationId = jlc.LocationId
	join ClientProfiles cp on 
	j.ClientProfileId = cp.ClientProfileId
	join Users clUser on
	cp.UserId = clUser.UserId
	left join FundiProfileAndReviewRatings fpAndRvRatings
	on cp.UserId = fpAndRvRatings.UserId
	where wcats.WorkCategoryType in (/*select item from dbo.[fnSplit](@workCategories,',')*/N'Electrician') and (select IsWithinDistance from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart)) = 1
	Group By 
			fn.FundiProfileId, fn.UserId, fn.ProfileSummary, fn.LocationId, us.Username,us.FirstName,us.LastName,
			fn.Skills, fn.UsedPowerTools, lc.LocationName, us.MobileNumber,
			lc.Latitude, lc.Longitude,jlc.LocationId, jlc.Latitude,j.JobId, j.JobName, j.JobDescription,
			jlc.Longitude, jlc.LocationName, cp.UserId, cp.ClientProfileId,wcats.WorkCategoryId, 
			clUser.Username, clUser.FirstName, clUser.LastName, clUser.MobileNumber,cp.AddressId,cp.ProfileSummary,
			JobWorkCategoryId, wcats.WorkCategoryType, wcats.WorkCategoryDescription,
			jwCats.JobWorkCategoryId, wCats.WorkCategoryType, wCats.WorkCategoryDescription,fpAndRvRatings.Rating, fpAndRvRatings.Review
		ORDER BY (select distanceApart from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart))
		OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY
	)
	select distinct *
	from Results
END
GO
/****** Object:  StoredProcedure [dbo].[GetWorkSubCategoriesByWorkCategoryId]    Script Date: 22/11/2022 05:06:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetWorkSubCategoriesByWorkCategoryId](@workCategoryId int)
AS
select wsc.WorkSubCategoryType as WorkSubCategoryType,wsc.WorkSubCategoryId as WorkSubCategoryId ,wsc.WorkCategoryId as WorkCategoryId ,wsc.WorkSubCategoryDescription as WorkSubCategoryDescription
From WorkCategories as wc
join WorkSubCategories as wsc
on wc.WorkCategoryId = wsc.WorkCategoryId
where wc.WorkCategoryId = @workCategoryId
GO
