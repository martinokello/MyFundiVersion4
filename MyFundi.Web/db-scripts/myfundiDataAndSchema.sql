USE [myfundiv2]
GO
/****** Object:  UserDefinedFunction [dbo].[ArePointsNearEnough]    Script Date: 30/11/2022 18:20:59 ******/
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
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 30/11/2022 18:20:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split] (
      @InputString                  NVARCHAR(4000),
      @Delimiter                    NVARCHAR(50)
)

RETURNS @Items TABLE (
      Item                          NVARCHAR(4000)
)

AS
BEGIN
      IF @Delimiter = ' '
      BEGIN
            SET @Delimiter = ','
            SET @InputString = REPLACE(@InputString, ' ', @Delimiter)
      END

      IF (@Delimiter IS NULL OR @Delimiter = '')
            SET @Delimiter = ','

--INSERT INTO @Items VALUES (@Delimiter) -- Diagnostic
--INSERT INTO @Items VALUES (@InputString) -- Diagnostic

      DECLARE @Item           NVARCHAR(4000)
      DECLARE @ItemList       NVARCHAR(4000)
      DECLARE @DelimIndex     INT

      SET @ItemList = @InputString
      SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      WHILE (@DelimIndex != 0)
      BEGIN
            SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex)
            INSERT INTO @Items VALUES (@Item)

            -- Set @ItemList = @ItemList minus one less item
            SET @ItemList = SUBSTRING(@ItemList, @DelimIndex+1, LEN(@ItemList)-@DelimIndex)
            SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      END -- End WHILE

      IF @Item IS NOT NULL -- At least one delimiter was encountered in @InputString
      BEGIN
            SET @Item = @ItemList
            INSERT INTO @Items VALUES (@Item)
      END

      -- No delimiters were encountered in @InputString, so just return @InputString
      ELSE INSERT INTO @Items VALUES (@InputString)

      RETURN

END -- End Function
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 30/11/2022 18:20:59 ******/
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
/****** Object:  Table [dbo].[Addresses]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[Certifications]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[ClientFundiContracts]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[ClientProfiles]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[Companies]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[Courses]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[FundiProfileAndReviewRatings]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[FundiProfileCertifications]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[FundiProfileCourses]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[FundiProfiles]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[FundiWorkCategories]    Script Date: 30/11/2022 18:21:00 ******/
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
	[WorkSubCategoryId] [int] NULL,
 CONSTRAINT [PK_FundiWorkCategories] PRIMARY KEY CLUSTERED 
(
	[FundiWorkCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Invoices]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[Items]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[Jobs]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[JobWorkCategories]    Script Date: 30/11/2022 18:21:00 ******/
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
	[WorkSubCategoryId] [int] NULL,
 CONSTRAINT [PK_JobWorkCategories] PRIMARY KEY CLUSTERED 
(
	[JobWorkCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[MonthlySubscriptions]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[Roles]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[UserRoles]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[Users]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[WorkCategories]    Script Date: 30/11/2022 18:21:00 ******/
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
/****** Object:  Table [dbo].[WorkSubCategories]    Script Date: 30/11/2022 18:21:00 ******/
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
SET IDENTITY_INSERT [dbo].[Addresses] ON 
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (1, N'MartinLayooInc Software Ltd.', N'Unit 3, 2 St. Johns Terrace', N'United Kingdom', N'London', N'W10', N'07809773365', CAST(N'2022-11-26T15:48:51.5586176' AS DateTime2), CAST(N'2022-11-26T15:48:51.5586176' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (2, N'Speke Hotel', N'Buganda Road', N'Uganda', N'Kampala', N'Kampala', NULL, CAST(N'2022-11-26T20:49:35.3574581' AS DateTime2), CAST(N'2022-11-26T20:49:35.3574586' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (3, N'Flat 13', N'Steve Biko Court', N'United Kingdom', N'London', N'w104SB', NULL, CAST(N'2022-11-26T20:49:55.1902446' AS DateTime2), CAST(N'2022-11-26T20:49:55.1902451' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (4, N'Acacia Mall Hotel', N'Acacia Avenue', N'Uganda', N'Kampala', N'Plot 55', NULL, CAST(N'2022-11-26T20:50:29.3538711' AS DateTime2), CAST(N'2022-11-26T20:50:29.3538716' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (5, N'Flat 3', N'13D Lanhill Road', N'United Kingdom', N'London', N'W9', NULL, CAST(N'2022-11-26T20:50:55.8168955' AS DateTime2), CAST(N'2022-11-26T20:50:55.8168960' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (6, N'42 Queens Gardens', N'London', N'United Kingdom', N'London', N'W2 3AA', NULL, CAST(N'2022-11-26T20:51:51.3394420' AS DateTime2), CAST(N'2022-11-27T00:27:27.1089458' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (7, N'55 Sixth St', N'Kampala', N'Uganda', N'Kampala', N'55 Sixth street', NULL, CAST(N'2022-11-26T20:52:37.2443074' AS DateTime2), CAST(N'2022-11-27T00:29:47.0853406' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (8, N'Nile Avenue Kimathi Ave', N'Kampala', N'Ugnada', N'Kampala', N'Kampala', NULL, CAST(N'2022-11-26T20:53:20.3008967' AS DateTime2), CAST(N'2022-11-27T00:31:26.7030832' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (9, N'46 Lira Road', N'Gulu', N'Uganda', N'Gulu', N'46 Lira Rd', NULL, CAST(N'2022-11-26T20:53:45.7030988' AS DateTime2), CAST(N'2022-11-27T00:33:56.1806400' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (10, N'Sheraton Hotel', N'Nakasero', N'Uganda', N'Kampala', N'Sheraton Hotel', NULL, CAST(N'2022-11-26T20:54:19.6455095' AS DateTime2), CAST(N'2022-11-27T00:35:24.6144720' AS DateTime2))
GO
INSERT [dbo].[Addresses] ([AddressId], [AddressLine1], [AddressLine2], [Country], [Town], [PostCode], [PhoneNumber], [DateCreated], [DateUpdated]) VALUES (11, N'Custom Corner', N'Lira Road', N'Uganda', N'Gulu', N'Plot 46', NULL, CAST(N'2022-10-28T00:25:11.1014425' AS DateTime2), CAST(N'2022-10-28T00:25:11.1014430' AS DateTime2))
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
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (1, N'e9585393-5fd1-45e8-5487-08da6e1c1725', 1, N'I am a well rounded and friendly individual. Full of trust, I offer my Jobs to good handy men, who should be able to tell me anything in trust. My thoughts are that the Fundi would know better since it is their skills and profession. Give me a well done, job, and I am happy and will refer you to other jobs especially within my community. I always rate efficiency, and honesty as the 2 most important things, let alone friendly Fundis.', N'', CAST(N'2022-10-29T21:41:41.9192250' AS DateTime2), CAST(N'2022-10-29T21:41:41.9192312' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (2, N'e9585393-5fd1-45e8-5487-08da6e1c1725', 1, N'I am a well rounded and friendly individual. Full of trust, I offer my Jobs to good handy men, who should be able to tell me anything in trust. My thoughts are that the Fundi would know better since it is their skills and profession. Give me a well done, job, and I am happy and will refer you to other jobs especially within my community. I always rate efficiency, and honesty as the 2 most important things, let alone friendly Fundis.', N'', CAST(N'2022-10-29T22:02:48.9011722' AS DateTime2), CAST(N'2022-10-29T22:02:48.9011789' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (3, N'f15c12e4-2d54-4699-f639-08dab52801f8', 2, N'I am Martin Okello - some call me THE MEDALLION - and been working as an Investment Fund Manager within EMEA. Recently visited Africa, to gain business ideas, and I am of the heart and feel that African Cultural Materials Can be exploited for the their explicit quality. My intentions are to open up shop in Uganda, Tanzania, Kenya, Ghana and South Africa to start with. It is viatal I get the people to build this dream, across the engineering descipline - namely.', N'', CAST(N'2022-10-29T22:12:39.3036677' AS DateTime2), CAST(N'2022-10-29T22:12:39.3036723' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (4, N'f15c12e4-2d54-4699-f639-08dab52801f8', 2, N'I am Martin Okello - some call me THE MEDAllion - and been working as an Investment Fund Manager within EMEA. Recently visited Africa, to gain business ideas, and I am of the heart and feel that African Cultural Materials Can be exploited for the their explicit quality. My intentions are to open up shop in Uganda, Tanzania, Kenya, Ghana and South Africa to start with. It is viatal I get the people to build this dream, across the engineering descipline - namely:', N'', CAST(N'2022-10-29T22:19:36.0862862' AS DateTime2), CAST(N'2022-10-29T22:19:36.0862918' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (5, N'f15c12e4-2d54-4699-f639-08dab52801f8', 2, N'I am Martin Okello - some call me THE MEDAllION - and been working as an Investment Fund Manager within EMEA. Recently visited Africa, to gain business ideas, and I am of the heart and feel that African Cultural Materials Can be exploited for the their explicit quality. My intentions are to open up shop in Uganda, Tanzania, Kenya, Ghana and South Africa to start with. It is viatal I get the people to build this dream, across the engineering descipline - namely:', N'', CAST(N'2022-10-29T22:21:24.1703706' AS DateTime2), CAST(N'2022-10-29T22:21:24.1703761' AS DateTime2))
GO
INSERT [dbo].[ClientProfiles] ([ClientProfileId], [UserId], [AddressId], [ProfileSummary], [ProfileImageUrl], [DateCreated], [DateUpdated]) VALUES (7, N'bd390c76-989f-4200-3234-08dacfb4f3b5', 4, N'I am a people person and enjoy hiring and getting work done perfectly. With a good knowlege base around properties, I know what needs doing and to what standard. So when I hire, there are traits I look for.', N'', CAST(N'2022-11-29T15:32:22.3969832' AS DateTime2), CAST(N'2022-11-29T15:32:22.3969837' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[ClientProfiles] OFF
GO
SET IDENTITY_INSERT [dbo].[Companies] ON 
GO
INSERT [dbo].[Companies] ([CompanyId], [CompanyName], [CompanyPhoneNUmber], [LocationId], [DateCreated], [DateUpdated]) VALUES (1, N'MartinLayooInc Software', N'07809773365', 1, CAST(N'2022-11-26T15:48:51.5930421' AS DateTime2), CAST(N'2022-11-26T15:48:51.5930421' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Companies] OFF
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
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (1, 4, 1, CAST(N'2022-11-29T15:30:44.2141903' AS DateTime2), CAST(N'2022-11-29T15:30:44.2141908' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (2, 4, 3, CAST(N'2022-11-29T15:30:49.5317719' AS DateTime2), CAST(N'2022-11-29T15:30:49.5317724' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (3, 4, 5, CAST(N'2022-11-29T15:30:55.1010709' AS DateTime2), CAST(N'2022-11-29T15:30:55.1010709' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[FundiProfileCertifications] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiProfileCourses] ON 
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (1, 1, 4, CAST(N'2022-11-29T15:30:59.4350262' AS DateTime2), CAST(N'2022-11-29T15:30:59.4350262' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (2, 2, 4, CAST(N'2022-11-29T15:31:04.5756162' AS DateTime2), CAST(N'2022-11-29T15:31:04.5756167' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (3, 4, 4, CAST(N'2022-11-29T15:31:10.1478214' AS DateTime2), CAST(N'2022-11-29T15:31:10.1478214' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[FundiProfileCourses] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiProfiles] ON 
GO
INSERT [dbo].[FundiProfiles] ([FundiProfileId], [UserId], [ProfileSummary], [ProfileImageUrl], [Skills], [UsedPowerTools], [LocationId], [FundiProfileCvUrl], [DateCreated], [DateUpdated]) VALUES (1, N'665bcf05-492a-4b94-2a22-08da940013e8', N'Simply an entrepreneur, engaging in bringing together software that makes a difference in the information age, with high security in mind. ', N'', N'MSc Computer Science
BEng Civil/Structural Engineering
Experience invthe IT domain', N'JCB Driver, Heavy Crane Driver, Heavy Vehicle Driver. Power Drills Usage', 1, N'', CAST(N'2022-01-23T18:52:45.2286492' AS DateTime2), CAST(N'2022-01-23T18:52:45.2286555' AS DateTime2))
GO
INSERT [dbo].[FundiProfiles] ([FundiProfileId], [UserId], [ProfileSummary], [ProfileImageUrl], [Skills], [UsedPowerTools], [LocationId], [FundiProfileCvUrl], [DateCreated], [DateUpdated]) VALUES (3, N'505c6acf-074a-4a51-8f38-08dab4e94775', N'A Structural Engineer/Civil Engineer with Plenty Computer Science skills and Electronic Skills for Circuitry wiring.', N'', N'1) Structural Design
2) Computer Programming and Design
', N'Electronic Testing Tools
HGV Driver', 2, N'', CAST(N'2022-10-25T21:56:25.8295286' AS DateTime2), CAST(N'2022-10-25T21:56:25.8295286' AS DateTime2))
GO
INSERT [dbo].[FundiProfiles] ([FundiProfileId], [UserId], [ProfileSummary], [ProfileImageUrl], [Skills], [UsedPowerTools], [LocationId], [FundiProfileCvUrl], [DateCreated], [DateUpdated]) VALUES (4, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'I am a whole rounder, Electrician, Carpenter, Plumber, Gas Fitter, and many more. Perhaps the Handy man of Choice as I work across many fields from experience. From setting up whole new renovations and Building works as Lead Electrician, using all maner of Power tools in the industry. Like I said, if there is a job, I will do it. Shows from my rating. If you need insight into a project, I consult as well, on all areas. My knowledge base is based upon my vast experience in the industry.
', N'', N'Electrician:
1) Electronic device Fundi,.
2) Computer Programming.
3) Electrical Circuitry Building.
4) Computer Programming', N'1) Electric Vibrator.
2) Power Drill
3) Ameter
4) Leveler', 2, N'', CAST(N'2022-11-29T15:30:11.2447816' AS DateTime2), CAST(N'2022-11-29T15:30:11.2447821' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[FundiProfiles] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiWorkCategories] ON 
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (2, 3, 2, NULL, CAST(N'2022-11-29T13:37:55.1028459' AS DateTime2), CAST(N'2022-11-29T13:37:55.1028463' AS DateTime2), 9)
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [JobId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (4, 4, 2, NULL, CAST(N'2022-11-29T15:30:26.2721126' AS DateTime2), CAST(N'2022-11-29T15:30:26.2721126' AS DateTime2), 9)
GO
SET IDENTITY_INSERT [dbo].[FundiWorkCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[Jobs] ON 
GO
INSERT [dbo].[Jobs] ([JobId], [JobName], [JobDescription], [LocationId], [ClientProfileId], [ClientUserId], [AssignedFundiUserId], [AssignedFundiProfileId], [HasBeenAssignedFundi], [HasCompleted], [ClientFundiContractId], [NumberOfDaysToComplete], [DateCreated], [DateUpdated]) VALUES (4, N'Administrator Administrator-Martel Lindo''s Maidavale Kitchen Refit', N'Need Kitchen refit. Looking for Plumbers, Brick Layers, Plasterers, and mostly Electricians as I intend to extend the width of my Kitchen.', 11, 7, N'bd390c76-989f-4200-3234-08dacfb4f3b5', NULL, 3, 0, 0, NULL, 28, CAST(N'2022-11-29T15:35:16.1525869' AS DateTime2), CAST(N'2022-11-29T15:35:16.1525874' AS DateTime2))
GO
INSERT [dbo].[Jobs] ([JobId], [JobName], [JobDescription], [LocationId], [ClientProfileId], [ClientUserId], [AssignedFundiUserId], [AssignedFundiProfileId], [HasBeenAssignedFundi], [HasCompleted], [ClientFundiContractId], [NumberOfDaysToComplete], [DateCreated], [DateUpdated]) VALUES (5, N'Jonathan Asante-Jonathan'' Gulu Development Project - Asante-Jonathan Asante-Gulu City Project Africa', N'Revamp Of Project Gulu Town rebuild 365 days. ', 8, 1, N'e9585393-5fd1-45e8-5487-08da6e1c1725', NULL, 3, 0, 0, NULL, 365, CAST(N'2022-11-30T12:29:07.6729165' AS DateTime2), CAST(N'2022-11-30T19:06:58.2334125' AS DateTime2))
GO
INSERT [dbo].[Jobs] ([JobId], [JobName], [JobDescription], [LocationId], [ClientProfileId], [ClientUserId], [AssignedFundiUserId], [AssignedFundiProfileId], [HasBeenAssignedFundi], [HasCompleted], [ClientFundiContractId], [NumberOfDaysToComplete], [DateCreated], [DateUpdated]) VALUES (6, N'Jonathan Asante-Jonathan Asante-Jonathan Asante-Jonathan Asante-Gulu City Project Africa', N'Project Gulu Town rebuild 365 days. ', 8, 1, N'e9585393-5fd1-45e8-5487-08da6e1c1725', NULL, 3, 0, 0, NULL, 365, CAST(N'2022-11-30T12:48:43.9984951' AS DateTime2), CAST(N'2022-11-30T12:48:43.9984956' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Jobs] OFF
GO
SET IDENTITY_INSERT [dbo].[JobWorkCategories] ON 
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (1, 4, 1, CAST(N'2022-11-29T15:35:16.2381884' AS DateTime2), CAST(N'2022-11-29T15:35:16.2381894' AS DateTime2), 1)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (2, 4, 1, CAST(N'2022-11-29T15:35:16.2469149' AS DateTime2), CAST(N'2022-11-29T15:35:16.2469149' AS DateTime2), 2)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (3, 4, 1, CAST(N'2022-11-29T15:35:16.2470061' AS DateTime2), CAST(N'2022-11-29T15:35:16.2470066' AS DateTime2), 3)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (4, 4, 1, CAST(N'2022-11-29T15:35:16.2470510' AS DateTime2), CAST(N'2022-11-29T15:35:16.2470510' AS DateTime2), 4)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (5, 4, 2, CAST(N'2022-11-29T15:35:16.2470861' AS DateTime2), CAST(N'2022-11-29T15:35:16.2470861' AS DateTime2), 8)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (6, 4, 2, CAST(N'2022-11-29T15:35:16.2471080' AS DateTime2), CAST(N'2022-11-29T15:35:16.2471080' AS DateTime2), 9)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (7, 4, 10, CAST(N'2022-11-29T15:35:16.2471295' AS DateTime2), CAST(N'2022-11-29T15:35:16.2471300' AS DateTime2), 47)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (8, 4, 10, CAST(N'2022-11-29T15:35:16.2471490' AS DateTime2), CAST(N'2022-11-29T15:35:16.2471495' AS DateTime2), 48)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (9, 4, 11, CAST(N'2022-11-29T15:35:16.2471758' AS DateTime2), CAST(N'2022-11-29T15:35:16.2471763' AS DateTime2), 52)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (10, 4, 11, CAST(N'2022-11-29T15:35:16.2471982' AS DateTime2), CAST(N'2022-11-29T15:35:16.2471987' AS DateTime2), 55)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (23, 6, 1, CAST(N'2022-11-30T12:48:44.0075658' AS DateTime2), CAST(N'2022-11-30T12:48:44.0075658' AS DateTime2), 1)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (24, 6, 10, CAST(N'2022-11-30T12:48:44.0080227' AS DateTime2), CAST(N'2022-11-30T12:48:44.0080227' AS DateTime2), 47)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (25, 6, 10, CAST(N'2022-11-30T12:48:44.0080388' AS DateTime2), CAST(N'2022-11-30T12:48:44.0080388' AS DateTime2), 48)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (26, 6, 10, CAST(N'2022-11-30T12:48:44.0080603' AS DateTime2), CAST(N'2022-11-30T12:48:44.0080603' AS DateTime2), 49)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (27, 6, 11, CAST(N'2022-11-30T12:48:44.0080773' AS DateTime2), CAST(N'2022-11-30T12:48:44.0080773' AS DateTime2), 51)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (28, 6, 11, CAST(N'2022-11-30T12:48:44.0080934' AS DateTime2), CAST(N'2022-11-30T12:48:44.0080934' AS DateTime2), 52)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (29, 6, 11, CAST(N'2022-11-30T12:48:44.0081139' AS DateTime2), CAST(N'2022-11-30T12:48:44.0081139' AS DateTime2), 54)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (30, 6, 11, CAST(N'2022-11-30T12:48:44.0081295' AS DateTime2), CAST(N'2022-11-30T12:48:44.0081300' AS DateTime2), 55)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (31, 6, 11, CAST(N'2022-11-30T12:48:44.0081451' AS DateTime2), CAST(N'2022-11-30T12:48:44.0081451' AS DateTime2), 60)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (32, 6, 11, CAST(N'2022-11-30T12:48:44.0081685' AS DateTime2), CAST(N'2022-11-30T12:48:44.0081685' AS DateTime2), 61)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (33, 6, 11, CAST(N'2022-11-30T12:48:44.0081841' AS DateTime2), CAST(N'2022-11-30T12:48:44.0081841' AS DateTime2), 62)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (34, 6, 11, CAST(N'2022-11-30T12:48:44.0082041' AS DateTime2), CAST(N'2022-11-30T12:48:44.0082046' AS DateTime2), 63)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (35, 6, 11, CAST(N'2022-11-30T12:48:44.0082207' AS DateTime2), CAST(N'2022-11-30T12:48:44.0082207' AS DateTime2), 64)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (36, 6, 11, CAST(N'2022-11-30T12:48:44.0082363' AS DateTime2), CAST(N'2022-11-30T12:48:44.0082363' AS DateTime2), 65)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (37, 6, 13, CAST(N'2022-11-30T12:48:44.0082568' AS DateTime2), CAST(N'2022-11-30T12:48:44.0082568' AS DateTime2), 66)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (38, 6, 14, CAST(N'2022-11-30T12:48:44.0082724' AS DateTime2), CAST(N'2022-11-30T12:48:44.0082729' AS DateTime2), 67)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (39, 6, 9, CAST(N'2022-11-30T12:48:44.0080022' AS DateTime2), CAST(N'2022-11-30T12:48:44.0080022' AS DateTime2), 43)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (40, 6, 7, CAST(N'2022-11-30T12:48:44.0079866' AS DateTime2), CAST(N'2022-11-30T12:48:44.0079866' AS DateTime2), 37)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (41, 6, 7, CAST(N'2022-11-30T12:48:44.0079701' AS DateTime2), CAST(N'2022-11-30T12:48:44.0079701' AS DateTime2), 35)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (42, 6, 6, CAST(N'2022-11-30T12:48:44.0079491' AS DateTime2), CAST(N'2022-11-30T12:48:44.0079491' AS DateTime2), 34)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (43, 6, 1, CAST(N'2022-11-30T12:48:44.0076253' AS DateTime2), CAST(N'2022-11-30T12:48:44.0076253' AS DateTime2), 2)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (44, 6, 1, CAST(N'2022-11-30T12:48:44.0076536' AS DateTime2), CAST(N'2022-11-30T12:48:44.0076536' AS DateTime2), 4)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (45, 6, 1, CAST(N'2022-11-30T12:48:44.0076716' AS DateTime2), CAST(N'2022-11-30T12:48:44.0076716' AS DateTime2), 6)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (46, 6, 1, CAST(N'2022-11-30T12:48:44.0077141' AS DateTime2), CAST(N'2022-11-30T12:48:44.0077141' AS DateTime2), 7)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (47, 6, 2, CAST(N'2022-11-30T12:48:44.0077311' AS DateTime2), CAST(N'2022-11-30T12:48:44.0077311' AS DateTime2), 9)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (48, 6, 2, CAST(N'2022-11-30T12:48:44.0077511' AS DateTime2), CAST(N'2022-11-30T12:48:44.0077516' AS DateTime2), 8)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (49, 6, 3, CAST(N'2022-11-30T12:48:44.0077682' AS DateTime2), CAST(N'2022-11-30T12:48:44.0077682' AS DateTime2), 12)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (50, 6, 14, CAST(N'2022-11-30T12:48:44.0082934' AS DateTime2), CAST(N'2022-11-30T12:48:44.0082934' AS DateTime2), 68)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (51, 6, 4, CAST(N'2022-11-30T12:48:44.0077853' AS DateTime2), CAST(N'2022-11-30T12:48:44.0077853' AS DateTime2), 15)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (52, 6, 5, CAST(N'2022-11-30T12:48:44.0078228' AS DateTime2), CAST(N'2022-11-30T12:48:44.0078228' AS DateTime2), 23)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (53, 6, 5, CAST(N'2022-11-30T12:48:44.0078428' AS DateTime2), CAST(N'2022-11-30T12:48:44.0078428' AS DateTime2), 24)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (54, 6, 5, CAST(N'2022-11-30T12:48:44.0078594' AS DateTime2), CAST(N'2022-11-30T12:48:44.0078594' AS DateTime2), 28)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (55, 6, 5, CAST(N'2022-11-30T12:48:44.0078755' AS DateTime2), CAST(N'2022-11-30T12:48:44.0078755' AS DateTime2), 29)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (56, 6, 6, CAST(N'2022-11-30T12:48:44.0078964' AS DateTime2), CAST(N'2022-11-30T12:48:44.0078964' AS DateTime2), 30)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (57, 6, 6, CAST(N'2022-11-30T12:48:44.0079120' AS DateTime2), CAST(N'2022-11-30T12:48:44.0079125' AS DateTime2), 32)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (58, 6, 6, CAST(N'2022-11-30T12:48:44.0079325' AS DateTime2), CAST(N'2022-11-30T12:48:44.0079325' AS DateTime2), 33)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (59, 6, 5, CAST(N'2022-11-30T12:48:44.0078067' AS DateTime2), CAST(N'2022-11-30T12:48:44.0078067' AS DateTime2), 19)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (60, 6, 10, CAST(N'2022-11-30T12:48:44.0083099' AS DateTime2), CAST(N'2022-11-30T12:48:44.0083099' AS DateTime2), 47)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (61, 5, 10, CAST(N'2022-11-30T19:06:58.2141667' AS DateTime2), CAST(N'2022-11-30T19:06:58.2141677' AS DateTime2), 49)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (62, 5, 10, CAST(N'2022-11-30T19:06:58.2315879' AS DateTime2), CAST(N'2022-11-30T19:06:58.2315889' AS DateTime2), 48)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (63, 5, 5, CAST(N'2022-11-30T19:06:58.2319390' AS DateTime2), CAST(N'2022-11-30T19:06:58.2319395' AS DateTime2), 29)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (64, 5, 5, CAST(N'2022-11-30T19:06:58.2320024' AS DateTime2), CAST(N'2022-11-30T19:06:58.2320024' AS DateTime2), 20)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (65, 5, 5, CAST(N'2022-11-30T19:06:58.2321004' AS DateTime2), CAST(N'2022-11-30T19:06:58.2321008' AS DateTime2), 19)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (66, 5, 5, CAST(N'2022-11-30T19:06:58.2321954' AS DateTime2), CAST(N'2022-11-30T19:06:58.2321959' AS DateTime2), 22)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (67, 5, 5, CAST(N'2022-11-30T19:06:58.2322481' AS DateTime2), CAST(N'2022-11-30T19:06:58.2322486' AS DateTime2), 21)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (68, 5, 2, CAST(N'2022-11-30T19:06:58.2322949' AS DateTime2), CAST(N'2022-11-30T19:06:58.2322949' AS DateTime2), 8)
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [DateCreated], [DateUpdated], [WorkSubCategoryId]) VALUES (69, 5, 2, CAST(N'2022-11-30T19:06:58.2323476' AS DateTime2), CAST(N'2022-11-30T19:06:58.2323481' AS DateTime2), 9)
GO
SET IDENTITY_INSERT [dbo].[JobWorkCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[Locations] ON 
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (1, N'UK', 1, N'3, 2 St John''s Terrace, London W10 4SB, UK', 51.52733, -0.2152936, CAST(N'2022-11-26T15:48:51.5801924' AS DateTime2), CAST(N'2022-11-29T15:53:59.4137855' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (2, NULL, 6, N'42 Queen''s Gardens, London W2 3AA, UK', 51.5133171, -0.1827191, CAST(N'2022-11-26T20:51:51.3381244' AS DateTime2), CAST(N'2022-11-29T15:54:15.9275301' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (3, NULL, 1, N'3, 2 St John''s Terrace, London W10 4SB, UK', 51.52733, -0.2152936, CAST(N'2022-11-26T20:51:51.6000609' AS DateTime2), CAST(N'2022-11-29T15:54:32.8708780' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (4, NULL, 7, N'55 Sixth St, Kampala, Uganda', 0.3170758, 32.6035652, CAST(N'2022-11-26T20:52:37.2442694' AS DateTime2), CAST(N'2022-11-29T15:54:48.1213076' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (5, NULL, 2, N'Nile Avenue Kimathi Ave, Kampala, Uganda', 0.3151942, 32.58282, CAST(N'2022-11-26T20:52:37.4248671' AS DateTime2), CAST(N'2022-11-29T15:55:01.4497017' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (6, NULL, 5, N'3, 13 Lanhill Rd, London W9, UK', 51.52658, -0.1963439, CAST(N'2022-11-26T20:53:20.3008587' AS DateTime2), CAST(N'2022-11-29T15:55:41.9633072' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (7, NULL, 3, N'Steve Biko Court, St John''s Terrace, London W10 4SB, UK', 51.52724, -0.2153939, CAST(N'2022-11-26T20:53:20.4772344' AS DateTime2), CAST(N'2022-11-29T15:56:05.9485475' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (8, NULL, 11, N'46 Lira - Gulu Rd, Uganda', 2.29509163, 32.74466, CAST(N'2022-11-26T20:53:45.7030617' AS DateTime2), CAST(N'2022-11-30T12:30:22.0931440' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (9, NULL, 7, N'55 Sixth St, Kampala, Uganda', 0.3170758, 32.6035652, CAST(N'2022-11-26T20:53:45.8699382' AS DateTime2), CAST(N'2022-11-29T15:56:52.7543716' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (10, NULL, 3, N'Steve Biko Court, St John''s Terrace, London W10 4SB, UK', 51.52724, -0.2153939, CAST(N'2022-11-26T20:54:19.6454710' AS DateTime2), CAST(N'2022-11-29T15:57:40.9751266' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (11, NULL, 5, N'3, 13 Lanhill Rd, London W9, UK', 51.52658, -0.1963439, CAST(N'2022-11-26T20:54:19.8130520' AS DateTime2), CAST(N'2022-11-26T20:54:19.8130525' AS DateTime2), 1)
GO
SET IDENTITY_INSERT [dbo].[Locations] OFF
GO
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (N'db86d768-e437-465c-abd7-08dacfb4f3a9', N'Administrator')
GO
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (N'9624c69f-fc23-4134-abd8-08dacfb4f3a9', N'Fundi')
GO
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9', N'Client')
GO
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (N'57736af1-c7fe-40fe-abda-08dacfb4f3a9', N'Guest')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'5cd3d088-e301-447e-03f6-08dacffbbabe', N'e9585393-5fd1-45e8-5487-08da6e1c1725', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'1e77324e-8f65-4797-03f7-08dacffbbabe', N'505c6acf-074a-4a51-8f38-08dab4e94775', N'9624c69f-fc23-4134-abd8-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'd4b87809-2ea7-4659-03f8-08dacffbbabe', N'f15c12e4-2d54-4699-f639-08dab52801f8', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'f27e73ee-4dc3-4751-9856-08dacfb4f3b9', N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'db86d768-e437-465c-abd7-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'c1ecdf93-9761-4be9-9857-08dacfb4f3b9', N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'9624c69f-fc23-4134-abd8-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'c21965d6-af64-4dcc-9858-08dacfb4f3b9', N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'7eb0be04-2efe-431d-9859-08dacfb4f3b9', N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'e9585393-5fd1-45e8-5487-08da6e1c1725', N'Jonathan', N'Asante', N'Jonathan.asante@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'Jonathan.asante@martinlayooinc.com', N'07809773333', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpmEN3jsbNHEoV4yBf1o79XZp4oqUlUe3wXRuBpN0EOvZ5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxZSXCIDCDTVYRWjJlDGnHxWCnWwueNWBZQd8nh5ZHObT+bAm5FswOiMkaMaL8uTtFPo0SkP5IkyOovu79rPGQY8bc1xGc2fdfpd3tWzTk9JgcBA724hjkIisEfQ787R4Fp4cqRzAf7PjGD7UqRACJTOhz9+v8QTfQdDvzOYN7Tai7RQkJrbeBXZ1nCEwSEqN8d8nTm6ibgvOIgzVDklZnvbuBmsQX0rxFcAtGmE1ncUEjcOBKO8UtAYq4kg7Oi3lOdDK9hYi46h7XB7YnAaxpzUqifWTFULaqekFi6+xVbR8yH5KgnsSvTD8puKLbaUc8qbnjHBYgCwYAYe4DWqLl1Pva009zM9oSbjvb8XmT98cAc9p2roho0WoGIixWsYL5zv+VLUSbxUhMKKCMUCJ6LneD1bkpdJPGY1gEir+6esWwG7poBfqcjRHThCBDZLEOCafEygtAYd6qwQ5T2WKDFKkUiHTO+W9OC3tPNCKzZCzI8sPJQA/qjzYlvrydbGKA/hq+KTqVds0IdQumH2qsNRGadL/aNt1P1GJbhRMtumjNjaBygo3P3DXJYLHfHblpqr9WTDWhKbsiCpPs13sxGkMp3hp2Me5yRd3UeEycpQt3MQqwJLQQAHJzJzAXgxZ0Y9zl0os0oGU8xrMawFdUBu', NULL, CAST(N'2022-07-25T10:00:15.2484206' AS DateTime2), CAST(N'2022-11-30T20:14:17.5050175' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'665bcf05-492a-4b94-2a22-08da940013e8', N'Test', N'Test', N'test@test.com', N'pJ7MG0Vr0qvHA8Pue2Jjhw==', N'test@test.com', N'112', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpkq32ko3Z4Slp+fz44rO9B/8D3L4OLbpwV+KWPs712nj5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxYe1lzzRUKD6/JDAgcJOUGvd2HFwAquP13IZjbb+dHbJFGnCiKDci/0En+F8+64z+5rD5CgRM+NKTikVJfXp5l9GXd8UrhNq5gsVDUGVoMOalLSK8TrTEJBvXCvR6FeIYNGLpacZbargsRpK9+IzHmikax9GZur0bvf0nwtAakhAO1ADkcCNUkVXDBqW7smwAY/WW+gIBy7ZuCp6nRsNCW2C0LCThOuoUBlHhUACrzZrdr805GJMzXOgjDlhsyheTmS2qDZVTozKRLWjmEL44et7xqGoyS1RzRz3SYtewaPFV81bXLuBer8ymNi9lgZSIZTKu+Rz9P28CFhftAsEIeeGtQXUMkRpb7iWyuxKqrH72dsg+Qq2s7AtX8rcdcrkvNhFbVxYjsuOuB32Hw30jFvxwMi3KADpgfvogMM8TAsHyYUuVeCL+YNhJ4BkPS7oHqL34dCpbwQEYmIGPzUlXUmaRmAIiRRKacswMTGn4qc4VDt9d5SWEcUxz1zDRfsX7by8R1tA+0vnR2lyKVDBEfSLGQN8yQRV5ohQjegNE0HAD6KiXsxUYhxxCjmEaGG42t6P5Egx1/kckGZKNkOcXruY94WTcaNGz/hQk5dPmzEFQ==', NULL, CAST(N'2022-09-11T16:15:28.1067428' AS DateTime2), CAST(N'2022-09-11T16:15:47.0969135' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'505c6acf-074a-4a51-8f38-08dab4e94775', N'Martin', N'Okello', N'martin.okello@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'martin.okello@martinlayooinc.com', N'07655432156', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpmEN3jsbNHEoV4yBf1o79XZdV396+nPF7l9SXpGK3l95YrHyMOR42AUkaddILeC97g2XChhvOhDGf0ib4zZWeUdst/zzOxTVuwP3oFLftLdKjesgpHHZcJo7jP41zQ2Ss6MEwgv4nM+ojOMi8G5W4bvxPiQBOdOHaw2PlecDVnyZ0OvCfIRkPUio4qzYYAA14TLBpVNCpOk1GvGRRzVwDydYE6hRPZkzM7+UpdN1iGooi8ikRYvTqYLS7usmNVeLG6PcErxBArKiJISl5PdAwjuRi6WnGW2q4LEaSvfiMx5ohl6GKlMDJ37IahnwsOnK9TZ4z+10qJztwLBLxXtqvKtmW1u+++dcnJgK19txI1yKmnIhhiIpNOtB4dxK9yTY92lUk3jxWDRBt1ACtQyE3voSWEIJACCEaDs74pnxJqrLU7/zq+MZsKp+H7Ukg01cvsSDER3XpBX7BAu0ED5MYahOUTJSR5brhyQVZjxZ1Y4s1IZHzPWOQGhaDBSKoF7g0inuKi/tllWw6RvzsQ48cV+oUh3LUTuxIR5eLdyVpKHnvzcXyEFBW1euoZ7Wam6W2wcKRR8/yD6ZUp/ArKo220xIk6JZ3U2lrZ8lxCfYz7sVb0Wvd1CuJtA8lB/ZDyr49xP6HHtIwW+guMIK7R0aXSeL5MHDcP+FJNaqApfRi7wFK/BENVM/av6Hmmierh6thoBtYZrkdrVVh6r6PvGkiErRp+CRGoHxg5zIt0KJ8pwt4YdPJYLVXep+7dq24I24JA=', NULL, CAST(N'2022-10-23T13:25:24.5566409' AS DateTime2), CAST(N'2022-11-30T13:00:23.4976803' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'f15c12e4-2d54-4699-f639-08dab52801f8', N'Martin', N'Okello', N'martin.okello@gmail.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'martin.okello@gmail.com', N'07898989765', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpkCQhQlfRhxRy37WsGiLanZSIba8w4njU5qP0lt/v61xJIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxbX5j9L10UKiFPsV5hiqot0llCznzEyf0j0jdtIoOsrG41TkII5hndPTx7BRUGiWpnvaK+jKTkffoI0T2zem4n12OLQVeKuz8DNkbew0LxmQ3io+zp8fLL41J5SKZtdijz1ZIzVHg7cuvlziug6JPeTjOWBrgDjuFrWN+/1+/TtCimEkb8lgnQwR384qBwgeODI3EFEiGxzL4cVzsV8m6FfGNUyS9kDUZru7MMS8z6wN6dMYiRyQpgNW9aM4gFcNYW1fgsxLqcFvpFtCCaSvGiYXOGQlnSV+FeA8kNHp5nSvBW9ygiSyku0jtV2oNDlBjyFXNnPYUxstInvTVVpgty4Ymk7hbqTKHBplGw30u/ieokiYCPfzFbmVLxooTvD8r0RKkekAQ9Eu9jIr6+Buall6A9m4msd60xbft9HmZSK3MdOF4ln0UwUaaPAHemH6TJ26YlnggE1hztSpNbLaNYLYgKRFRxjqVXjpN9r8f/T+fqSpN7AV2PEXIsEhjV8EK4EVWPtG10hdB8C2E+nqC7EmnxMoLQGHeqsEOU9ligxShoSaxbMtHdUmfoBtCJNx8VnBSeh1M1IgTiFYxeu8z+5POnRcvMmrwVE1HNAdSFszDuisGrWFcNRkgnuxNS9BdI=', NULL, CAST(N'2022-10-23T20:54:26.2711942' AS DateTime2), CAST(N'2022-11-27T01:29:41.5253625' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'Administrator', N'Administrator', N'administrator@martinlayooinc.com', N'3YFoEKPCH7RRX7LG30XMxw==', N'administrator@martinlayooinc.com', N'07809773365', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpmEN3jsbNHEoV4yBf1o79XZ5UD9KIBJ5155CJ8idcxfb9dCgUUbrxNsOiXfu/jFfw4TfMaQW59WYBRs0tL99xt5lRh4uhbhGI7EITYVsuNR4UQPrEBnme/gjjZtVjEpAr5vt6f5GWN9OfhhQQ3JsXLyooFK9e09eU6LM8rikv+3qSKWbjXLC6/6CeRbRX1KM0H6BidKtJ05q+nXcfsvDIsiBshd/mnBen5YsTFTDCej9foFZ8OTB7ltcuN+lp/kC5kkJjWmdV+BokjhfYT/Zoqo0LyOnPJadr/AXb52uI6KDaDrk5asL6FhIRGINB6By9LO/4Wm+id6Wx1jTN/Z4IygcFVubHbllJCp5ro6E8iqNqGvs6zd1h/Tcwlvz0Fe+624ESn7AtrCHPly1Vp8LBm6/JtZyCjYkC3AaVd6or0jn4H66sgMtBtJuqUdjwPzNR6h/7wb3lTc4sxCvR+O6GhAQq4XxYAG+zF4qmY6b/vstrDRwYdTg1zROdeK3a9GwqCL4aJRhBpiwfhDJKwRdwiNeKj7Onx8svjUnlIpm12KPMn5759MNs0uplwurtxPvX+xyzXjm4w9ySYkI4BgAQoVg702BFZxHfYMg+KLm+5koABH3mDJlzDuTLT5vSkxHoWfPvdH70lC49KXWTHzZvMYNw4Eo7xS0BiriSDs6LeU50Mr2FiLjqHtcHticBrGnNSqJ9ZMVQtqp6QWLr7FVtHzIfkqCexK9MPym4ottpRzypueMcFiALBgBh7gNaouXU+9rTT3Mz2hJuO9vxeZP3xwBz2nauiGjRagYiLFaxgvnO/5UtRJvFSEwooIxQInoud4PVuSl0k8ZjWASKv7p6xbAbumgF+pyNEdOEIENksQ4Jp8TKC0Bh3qrBDlPZYoMUqRSIdM75b04Le080IrNkLMjyw8lAD+qPNiW+vJ1sYoD+Gr4pOpV2zQh1C6Yfaqw1EZp0v9o23U/UYluFEy26aM2NoHKCjc/cNclgsd8duWmqv1ZMNaEpuyIKk+zXezEaQyneGnYx7nJF3dR4TJylC3cxCrAktBAAcnMnMBeDFnRj3OXSizSgZTzGsxrAV1QG4=', 1, CAST(N'2022-11-26T15:48:51.6073259' AS DateTime2), CAST(N'2022-11-30T17:38:32.7640014' AS DateTime2), 1, 0)
GO
SET IDENTITY_INSERT [dbo].[WorkCategories] ON 
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (1, N'Carpenters', N'Carpenters
', CAST(N'2022-11-26T21:02:08.8671671' AS DateTime2), CAST(N'2022-11-26T21:02:08.8671676' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (2, N'Electricians', N'Electricians
', CAST(N'2022-11-26T21:03:40.2385906' AS DateTime2), CAST(N'2022-11-26T21:03:40.2385911' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (3, N'Fire Installations', N'Fire Installations
', CAST(N'2022-11-26T21:06:04.0579754' AS DateTime2), CAST(N'2022-11-26T21:06:04.0579764' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (4, N'ICT Technician', N'ICT Technician
', CAST(N'2022-11-26T21:06:28.3839265' AS DateTime2), CAST(N'2022-11-26T21:06:28.3839275' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (5, N'Machine Operators', N'Machine Operators
', CAST(N'2022-11-26T21:07:04.2215103' AS DateTime2), CAST(N'2022-11-26T21:07:04.2215108' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (6, N'Masons Building', N'Masons Building
', CAST(N'2022-11-26T21:07:34.3848793' AS DateTime2), CAST(N'2022-11-26T21:07:34.3848793' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (7, N'Masons Finishing', N'Masons Finishing
', CAST(N'2022-11-26T21:08:02.8983625' AS DateTime2), CAST(N'2022-11-26T21:08:02.8983630' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (8, N'Mechanic', N'Mechanic
', CAST(N'2022-11-26T21:08:38.6901330' AS DateTime2), CAST(N'2022-11-26T21:08:38.6901335' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (9, N'Painters', N'Painters
', CAST(N'2022-11-26T21:09:06.9082792' AS DateTime2), CAST(N'2022-11-26T21:09:06.9082797' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (10, N'Plumbers', N'Plumbers
', CAST(N'2022-11-26T21:09:36.3737436' AS DateTime2), CAST(N'2022-11-26T21:09:36.3737441' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (11, N'Specialist', N'Specialist
', CAST(N'2022-11-26T21:10:12.2122051' AS DateTime2), CAST(N'2022-11-26T21:10:12.2122056' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (12, N'Site Supervisors', N'Site Supervisors
', CAST(N'2022-11-26T21:10:40.3015438' AS DateTime2), CAST(N'2022-11-26T21:10:40.3015443' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (13, N'Steel Fixers', N'Steel Fixers
', CAST(N'2022-11-26T21:11:08.2839607' AS DateTime2), CAST(N'2022-11-26T21:11:08.2839607' AS DateTime2))
GO
INSERT [dbo].[WorkCategories] ([WorkCategoryId], [WorkCategoryType], [WorkCategoryDescription], [DateCreated], [DateUpdated]) VALUES (14, N'Welders', N'Welders
', CAST(N'2022-11-26T21:11:32.3081358' AS DateTime2), CAST(N'2022-11-26T21:11:32.3081368' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[WorkCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[WorkSubCategories] ON 
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (1, N'Board Fittings and Cabinetry', N'Board Fittings and Cabinetry
', 1, CAST(N'2022-11-26T22:13:05.5359516' AS DateTime2), CAST(N'2022-11-26T22:13:05.5359526' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (2, N'Formwork and Shuttering', N'Formwork and Shuttering
', 1, CAST(N'2022-11-26T22:13:44.3458815' AS DateTime2), CAST(N'2022-11-26T22:13:44.3458820' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (3, N'Gutters and Roof surface Drainage', N'Gutters and Roof surface Drainage
', 1, CAST(N'2022-11-26T22:14:17.0105300' AS DateTime2), CAST(N'2022-11-26T22:14:17.0105305' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (4, N'Internal Timber Joinery', N'Internal Timber Joinery
', 1, CAST(N'2022-11-26T22:15:01.4773725' AS DateTime2), CAST(N'2022-11-26T22:15:01.4773729' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (5, N'Machine work', N'Machine work
', 1, CAST(N'2022-11-26T22:15:29.0189084' AS DateTime2), CAST(N'2022-11-26T22:15:29.0189084' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (6, N'PVC Windows and Doors', N'PVC Windows and Doors
', 1, CAST(N'2022-11-26T22:15:58.5500858' AS DateTime2), CAST(N'2022-11-26T22:15:58.5500863' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (7, N'Roofing and Roof Coverings', N'Roofing and Roof Coverings
', 1, CAST(N'2022-11-26T22:16:27.6577199' AS DateTime2), CAST(N'2022-11-26T22:16:27.6577204' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (8, N'High Voltage installations', N'High Voltage installations
', 2, CAST(N'2022-11-26T22:17:08.0252177' AS DateTime2), CAST(N'2022-11-26T22:17:08.0252177' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (9, N'Low Voltage installation', N'Low Voltage installation
', 2, CAST(N'2022-11-26T22:17:39.3423697' AS DateTime2), CAST(N'2022-11-26T22:17:39.3423702' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (10, N'Repair - Household Appliances', N'Repair - Household Appliances
', 2, CAST(N'2022-11-26T22:18:04.9065043' AS DateTime2), CAST(N'2022-11-26T22:18:04.9065048' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (11, N'Repair - Power Tools', N'Repair - Power Tools
', 2, CAST(N'2022-11-26T22:18:32.2122665' AS DateTime2), CAST(N'2022-11-26T22:18:32.2122665' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (12, N'Control Panels, Smoke and Heat Detectors', N'Control Panels, Smoke and Heat Detectors
', 3, CAST(N'2022-11-26T22:19:08.7966290' AS DateTime2), CAST(N'2022-11-26T22:19:08.7966295' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (13, N'Fire Extinguishers Installation and Service', N'Fire Extinguishers Installation and Service
', 3, CAST(N'2022-11-26T22:19:49.2735583' AS DateTime2), CAST(N'2022-11-26T22:19:49.2735583' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (14, N'Hydrants, Hose reels and Pumps and Sprinklers', N'Hydrants, Hose reels and Pumps and Sprinklers
', 3, CAST(N'2022-11-26T22:20:19.2787339' AS DateTime2), CAST(N'2022-11-26T22:20:19.2787344' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (15, N'CCTV and Security cameras', N'CCTV and Security cameras
', 4, CAST(N'2022-11-26T22:20:53.9215615' AS DateTime2), CAST(N'2022-11-26T22:20:53.9215620' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (16, N'Networking', N'Networking
', 4, CAST(N'2022-11-26T22:21:23.5535868' AS DateTime2), CAST(N'2022-11-26T22:21:23.5535868' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (17, N'Satellite TV', N'Satellite TV
', 4, CAST(N'2022-11-26T22:21:50.3436131' AS DateTime2), CAST(N'2022-11-26T22:21:50.3436136' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (18, N'Sound and Audio', N'Sound and Audio
', 4, CAST(N'2022-11-26T22:22:15.1500755' AS DateTime2), CAST(N'2022-11-26T22:22:15.1500760' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (19, N'Building Hoist', N'Building Hoist
', 5, CAST(N'2022-11-26T22:22:47.2468855' AS DateTime2), CAST(N'2022-11-26T22:22:47.2468865' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (20, N'Compressor and Jackhammer', N'Compressor and Jackhammer
', 5, CAST(N'2022-11-26T22:23:19.0460424' AS DateTime2), CAST(N'2022-11-26T22:23:19.0460424' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (21, N'Core Drill', N'Core Drill
', 5, CAST(N'2022-11-26T22:23:43.3455216' AS DateTime2), CAST(N'2022-11-26T22:23:43.3455221' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (22, N'Drum Mixers', N'Drum Mixers
', 5, CAST(N'2022-11-26T22:24:07.3337559' AS DateTime2), CAST(N'2022-11-26T22:24:07.3337564' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (23, N'Pedestrian Roller', N'Pedestrian Roller
', 5, CAST(N'2022-11-26T22:24:37.5337734' AS DateTime2), CAST(N'2022-11-26T22:24:37.5337734' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (24, N'Plate Compactor', N'Plate Compactor
', 5, CAST(N'2022-11-26T22:25:06.2008460' AS DateTime2), CAST(N'2022-11-26T22:25:06.2008460' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (25, N'Poker Vibrator', N'Poker Vibrator
', 5, CAST(N'2022-11-26T22:25:32.3977549' AS DateTime2), CAST(N'2022-11-26T22:25:32.3977549' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (26, N'Power Float', N'Power Float
', 5, CAST(N'2022-11-26T22:25:55.6815927' AS DateTime2), CAST(N'2022-11-26T22:25:55.6815932' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (27, N'Rammers', N'Rammers
', 5, CAST(N'2022-11-26T22:26:17.0017841' AS DateTime2), CAST(N'2022-11-26T22:26:17.0017846' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (28, N'Site Dumper', N'Site Dumper
', 5, CAST(N'2022-11-26T22:26:42.5815123' AS DateTime2), CAST(N'2022-11-26T22:26:42.5815128' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (29, N'Tower Crane', N'Tower Crane
', 5, CAST(N'2022-11-26T22:27:13.2440031' AS DateTime2), CAST(N'2022-11-26T22:27:13.2440031' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (30, N'Brick layer', N'Brick layer
', 6, CAST(N'2022-11-26T22:27:55.3156530' AS DateTime2), CAST(N'2022-11-26T22:27:55.3156535' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (31, N'Concrete', N'Concrete
', 6, CAST(N'2022-11-26T22:28:27.4511517' AS DateTime2), CAST(N'2022-11-26T22:28:27.4511517' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (32, N'Paving and Kerbs', N'Paving and Kerbs
', 6, CAST(N'2022-11-26T22:29:04.0706730' AS DateTime2), CAST(N'2022-11-26T22:29:04.0706730' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (33, N'Plasterer', N'Plasterer
', 6, CAST(N'2022-11-26T22:29:38.0255882' AS DateTime2), CAST(N'2022-11-26T22:29:38.0255887' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (34, N'Stonepitching and Drainage', N'Stonepitching and Drainage
', 6, CAST(N'2022-11-26T22:30:07.2877363' AS DateTime2), CAST(N'2022-11-26T22:30:07.2877368' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (35, N'Concrete Mouldings', N'Concrete Mouldings
', 7, CAST(N'2022-11-26T22:30:44.3511419' AS DateTime2), CAST(N'2022-11-26T22:30:44.3511424' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (36, N'Rubble Stonework', N'Rubble Stonework
', 7, CAST(N'2022-11-26T22:31:15.5737431' AS DateTime2), CAST(N'2022-11-26T22:31:15.5737436' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (37, N'Wall and Floor Tiling', N'Wall and Floor Tiling
', 7, CAST(N'2022-11-26T22:31:42.3488326' AS DateTime2), CAST(N'2022-11-26T22:31:42.3488326' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (38, N'Generators', N'Generators
', 8, CAST(N'2022-11-26T22:32:15.6122153' AS DateTime2), CAST(N'2022-11-26T22:32:15.6122153' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (39, N'Heavy Construction Machinery', N'Heavy Construction Machinery
', 8, CAST(N'2022-11-26T22:32:41.2004251' AS DateTime2), CAST(N'2022-11-26T22:32:41.2004256' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (40, N'Light Construction Machinery', N'Light Construction Machinery
', 8, CAST(N'2022-11-26T22:33:02.0500082' AS DateTime2), CAST(N'2022-11-26T22:33:02.0500087' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (41, N'Welding Machinery', N'Welding Machinery
', 8, CAST(N'2022-11-26T22:33:23.8429250' AS DateTime2), CAST(N'2022-11-26T22:33:23.8429255' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (42, N'Wood Working Machinery', N'Wood Working Machinery
', 8, CAST(N'2022-11-26T22:33:46.3069992' AS DateTime2), CAST(N'2022-11-26T22:33:46.3069997' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (43, N'Spray Painting', N'Spray Painting
', 9, CAST(N'2022-11-26T22:34:09.8881137' AS DateTime2), CAST(N'2022-11-26T22:34:09.8881142' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (44, N'Terrazzo and Concrete polishing', N'Terrazzo and Concrete polishing
', 9, CAST(N'2022-11-26T22:34:38.1132442' AS DateTime2), CAST(N'2022-11-26T22:34:38.1132446' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (45, N'Textured Paint', N'Textured Paint
', 9, CAST(N'2022-11-26T22:35:04.2270735' AS DateTime2), CAST(N'2022-11-26T22:35:04.2270735' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (46, N'Waterproofing', N'Waterproofing
', 9, CAST(N'2022-11-26T22:35:29.3543383' AS DateTime2), CAST(N'2022-11-26T22:35:29.3543388' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (47, N'Pumps and Pumping Systems', N'Pumps and Pumping Systems
', 10, CAST(N'2022-11-26T22:35:54.3632691' AS DateTime2), CAST(N'2022-11-26T22:35:54.3632696' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (48, N'Internal Plumbing', N'Internal Plumbing
', 10, CAST(N'2022-11-26T22:36:15.3709373' AS DateTime2), CAST(N'2022-11-26T22:36:15.3709373' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (49, N'External Plumbing', N'External Plumbing
', 10, CAST(N'2022-11-26T22:36:40.3902524' AS DateTime2), CAST(N'2022-11-26T22:36:40.3902524' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (50, N'Airconditioning', N'Airconditioning
', 11, CAST(N'2022-11-26T22:37:13.7271725' AS DateTime2), CAST(N'2022-11-26T22:37:13.7271725' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (51, N'Aluminium Windows Doors and Partitions', N'Aluminium Windows Doors and Partitions
', 11, CAST(N'2022-11-26T22:37:41.6015608' AS DateTime2), CAST(N'2022-11-26T22:37:41.6015608' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (52, N'Flooring', N'Flooring
', 11, CAST(N'2022-11-26T22:38:14.1762524' AS DateTime2), CAST(N'2022-11-26T22:38:14.1762529' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (53, N'Gas Installations', N'Gas Installations
', 11, CAST(N'2022-11-26T22:38:38.1842245' AS DateTime2), CAST(N'2022-11-26T22:38:38.1842259' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (54, N'Glass Fixing', N'Glass Fixing
', 11, CAST(N'2022-11-26T22:39:08.3709334' AS DateTime2), CAST(N'2022-11-26T22:39:08.3709339' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (55, N'Granite and Marble', N'Granite and Marble
', 11, CAST(N'2022-11-26T22:39:28.6650459' AS DateTime2), CAST(N'2022-11-26T22:39:28.6650459' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (56, N'Grass Thatching', N'Grass Thatching
', 11, CAST(N'2022-11-26T22:39:48.8058182' AS DateTime2), CAST(N'2022-11-26T22:39:48.8058187' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (57, N'Gypsum Walling and Ceilings', N'Gypsum Walling and Ceilings
', 11, CAST(N'2022-11-26T22:40:13.3777255' AS DateTime2), CAST(N'2022-11-26T22:40:13.3777255' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (58, N'Heating and Ventilation', N'Heating and Ventilation
', 11, CAST(N'2022-11-26T22:40:38.2179238' AS DateTime2), CAST(N'2022-11-26T22:40:38.2179238' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (59, N'Internal and External Paint', N'Internal and External Paint
', 11, CAST(N'2022-11-26T22:40:56.6186197' AS DateTime2), CAST(N'2022-11-26T22:40:56.6186202' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (60, N'Joints and Sealants', N'Joints and Sealants
', 11, CAST(N'2022-11-26T22:41:16.5845312' AS DateTime2), CAST(N'2022-11-26T22:41:16.5845317' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (61, N'Landscaping', N'Landscaping
', 11, CAST(N'2022-11-26T22:41:45.0510463' AS DateTime2), CAST(N'2022-11-26T22:42:42.3917850' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (62, N'Pressed steel Tanks', N'Pressed steel Tanks
', 11, CAST(N'2022-11-26T22:43:18.2999658' AS DateTime2), CAST(N'2022-11-26T22:43:18.2999663' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (63, N'Special wall coatings', N'Special wall coatings
', 11, CAST(N'2022-11-26T22:43:44.8162625' AS DateTime2), CAST(N'2022-11-26T22:43:44.8162630' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (64, N'Suspended Ceilings', N'Suspended Ceilings
', 11, CAST(N'2022-11-26T22:44:18.7689181' AS DateTime2), CAST(N'2022-11-26T22:44:18.7689186' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (65, N'Waterproofing', N'Waterproofing
', 11, CAST(N'2022-11-26T22:44:47.1422512' AS DateTime2), CAST(N'2022-11-26T22:44:47.1422512' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (66, N'Steel Fixer', N'Steel Fixer
', 13, CAST(N'2022-11-26T22:45:20.9195949' AS DateTime2), CAST(N'2022-11-26T22:45:20.9195954' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (67, N'Fabrication', N'Fabrication
', 14, CAST(N'2022-11-26T22:45:49.0308150' AS DateTime2), CAST(N'2022-11-26T22:45:49.0308150' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (68, N'Steel Erection', N'Steel Erection
', 14, CAST(N'2022-11-26T22:46:15.2800831' AS DateTime2), CAST(N'2022-11-26T22:46:15.2800836' AS DateTime2))
GO
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (69, N'Roofing and Rainwater Drainage', N'Roofing and Rainwater Drainage
', 14, CAST(N'2022-11-26T22:46:45.4191634' AS DateTime2), CAST(N'2022-11-26T22:46:45.4191639' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[WorkSubCategories] OFF
GO
/****** Object:  Index [AK_UserRoles_UserId_RoleId]    Script Date: 30/11/2022 18:21:22 ******/
ALTER TABLE [dbo].[UserRoles] ADD  CONSTRAINT [AK_UserRoles_UserId_RoleId] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [AK_Users_Username]    Script Date: 30/11/2022 18:21:22 ******/
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
ALTER TABLE [dbo].[FundiWorkCategories]  WITH CHECK ADD  CONSTRAINT [FK_FundiWorkCategories_WorkSubCategories_WorkSubCategoryId] FOREIGN KEY([WorkSubCategoryId])
REFERENCES [dbo].[WorkSubCategories] ([WorkSubCategoryId])
GO
ALTER TABLE [dbo].[FundiWorkCategories] CHECK CONSTRAINT [FK_FundiWorkCategories_WorkSubCategories_WorkSubCategoryId]
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
ALTER TABLE [dbo].[JobWorkCategories]  WITH CHECK ADD  CONSTRAINT [FK_JobWorkCategories_WorkSubCategories_WorkSubCategoryId] FOREIGN KEY([WorkSubCategoryId])
REFERENCES [dbo].[WorkSubCategories] ([WorkSubCategoryId])
GO
ALTER TABLE [dbo].[JobWorkCategories] CHECK CONSTRAINT [FK_JobWorkCategories_WorkSubCategories_WorkSubCategoryId]
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
/****** Object:  StoredProcedure [dbo].[GetAllFundiRatingByProfileId]    Script Date: 30/11/2022 18:21:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetAllFundiRatingByProfileId](@fundiProfileId int)
AS
SELECT distinct 
	  fr.[FundiProfileId],
      fr.[Rating] as FundiRating,
	  fr.[Review] as ClientReview,
	  fr.[UserId] as ClientUserId,
	  u.[FirstName] as FirstName,
	  u.[LastName] as LastName
  FROM [myfundiv2].[dbo].[FundiProfileAndReviewRatings] fr
  join [Users] u 
  on fr.UserId = u.UserId
  where fr.[FundiProfileId]=@fundiProfileId
GO
/****** Object:  StoredProcedure [dbo].[GetAllFundiWorkCategoriesForJobId]    Script Date: 30/11/2022 18:21:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetAllFundiWorkCategoriesForJobId](@jobId int)
As
Begin
	select distinct wc.WorkCategoryId as WorkCategoryId, wsc.WorkSubCategoryId as WorkSubCategoryId, wc.WorkCategoryType as WorkCategoryType, wsc.WorkSubCategoryType as WorkSubCategoryType
	from WorkCategories wc join
	JobWorkCategories jwc on
	wc.WorkCategoryId = jwc.WorkCategoryId join
	WorkSubCategories wsc on
	wc.WorkCategoryId = wsc.WorkCategoryId
	join Jobs j on
	j.JobId = jwc.JobId
	where j.JobId = @jobId
end
GO
/****** Object:  StoredProcedure [dbo].[GetFundiAverageRatingByProfileId]    Script Date: 30/11/2022 18:21:22 ******/
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
/****** Object:  StoredProcedure [dbo].[GetFundiByLocationVsJobLocation]    Script Date: 30/11/2022 18:21:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetFundiByLocationVsJobLocation](@distanceApart float, @fundiProfileId int, @workCategories nvarchar(4000), @workSubCategories nvarchar(4000), @skip int=0, @take int=5)
AS
BEGIN
	With Results as(
		select fn.FundiProfileId as FundiProfileId, fn.UserId as FundiUserId, fn.ProfileSummary as FundiProfileSummary, fn.LocationId as FundiLocationId, us.Username as FundiUsername,us.FirstName as FundiFirstName, us.LastName as FundiLastName,
		fn.Skills as FundiSkills, fn.UsedPowerTools as FundiUsedPowerTools, lc.LocationName as FundiLocationName, us.MobileNumber as FundiMobileNumber,
		lc.Latitude as FundiLocationLat, lc.Longitude as FundiLocationLong,jlc.LocationId as JobLocationId, jlc.Latitude as JobLocationLatitude,
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
		WorkSubCategories wsc on
		wcats.WorkCategoryId = wsc.WorkCategoryId join
		Locations jlc on
		j.LocationId = jlc.LocationId
		join ClientProfiles cp on 
		j.ClientProfileId = cp.ClientProfileId
		join Users clUser on
		cp.UserId = clUser.UserId
		left join FundiProfileAndReviewRatings fpAndRvRatings
		on cp.UserId = fpAndRvRatings.UserId
		where (wsc.WorkSubCategoryType in (select item from dbo.Split(@workSubCategories,','))) 
		and (wcats.WorkCategoryType in (select item from dbo.Split(@workCategories,','))) 
		and  fn.FundiProfileId = @fundiProfileId and (select IsWithinDistance from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart)) = 1
		Group By 
			fn.FundiProfileId, fn.UserId, fn.ProfileSummary, fn.LocationId, us.Username,us.FirstName,us.LastName,
			fn.Skills, fn.UsedPowerTools, lc.LocationName, us.MobileNumber,
			lc.Latitude, lc.Longitude,jlc.LocationId, jlc.Latitude,j.JobId, j.JobName, j.JobDescription,
			jlc.Longitude, jlc.LocationName, cp.UserId, cp.ClientProfileId, 
			clUser.Username, clUser.FirstName, clUser.LastName, clUser.MobileNumber,cp.AddressId,cp.ProfileSummary
		ORDER BY (select distanceApart from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart))
		OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY
		)
		select distinct *
		from Results
END
GO
/****** Object:  StoredProcedure [dbo].[GetFundiRatings]    Script Date: 30/11/2022 18:21:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetFundiRatings](@clientProfileId int,@jobId int, @distanceApart float, @workCategories nvarchar(4000), @workSubCategories nvarchar(4000), @skip int=0, @take int=5)
AS
BEGIN
With Results as(
		select fn.FundiProfileId as FundiProfileId, fn.UserId as FundiUserId, fn.ProfileSummary as FundiProfileSummary, fn.LocationId as FundiLocationId, us.Username as FundiUsername,us.FirstName as FundiFirstName, us.LastName as FundiLastName,
		fn.Skills as FundiSkills, fn.UsedPowerTools as FundiUsedPowerTools, lc.LocationName as FundiLocationName, us.MobileNumber as FundiMobileNumber,
		lc.Latitude as FundiLocationLat, lc.Longitude as FundiLocationLong,jlc.LocationId as JobLocationId, jlc.Latitude as JobLocationLatitude,
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
	WorkSubCategories wsc on
	wcats.WorkCategoryId = wsc.WorkCategoryId join
	Locations jlc on
	j.LocationId = jlc.LocationId
	join ClientProfiles cp on 
	j.ClientProfileId = cp.ClientProfileId
	join Users clUser on
	cp.UserId = clUser.UserId
	left join FundiProfileAndReviewRatings fpAndRvRatings
	on cp.UserId = fpAndRvRatings.UserId
	where (wsc.WorkSubCategoryType in (select item from dbo.Split(@workSubCategories,','))) 
	and (wcats.WorkCategoryType in (select item from dbo.Split(@workCategories,',')))  
	and j.jobId = @jobId and cp.ClientProfileId = @clientProfileId and 
	(select IsWithinDistance from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart)) = 1
	Group By 
			fn.FundiProfileId, fn.UserId, fn.ProfileSummary, fn.LocationId, us.Username,us.FirstName,us.LastName,
			fn.Skills, fn.UsedPowerTools, lc.LocationName, us.MobileNumber,
			lc.Latitude, lc.Longitude,jlc.LocationId, jlc.Latitude,j.JobId, j.JobName, j.JobDescription,
			jlc.Longitude, jlc.LocationName, cp.UserId, cp.ClientProfileId,
			clUser.Username, clUser.FirstName, clUser.LastName, clUser.MobileNumber,cp.AddressId,cp.ProfileSummary
		ORDER BY (select distanceApart from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart))
		OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY
	)
	select distinct *
	from Results
END
GO
/****** Object:  StoredProcedure [dbo].[GetWorkSubCategoriesByWorkCategoryId]    Script Date: 30/11/2022 18:21:22 ******/
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
/****** Object:  StoredProcedure [dbo].[GetWorkSubCategoriesForFundiByJobId]    Script Date: 30/11/2022 18:21:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetWorkSubCategoriesForFundiByJobId](@jobId int, @fundiProfileId int)
As
Begin
	select distinct fwc.WorkCategoryId as WorkCategoryId, wsc.WorkSubCategoryId as WorkSubCategoryId, wc.WorkCategoryType as WorkCategoryType, wsc.WorkSubCategoryType as WorkSubCategoryType
	from WorkCategories wc join
	JobWorkCategories jwc on
	wc.WorkCategoryId = jwc.WorkCategoryId join
	FundiWorkCategories fwc on
	wc.WorkCategoryId = fwc.WorkCategoryId join
	WorkSubCategories wsc on
	wc.WorkCategoryId = wsc.WorkCategoryId
	join Jobs j on
	j.JobId = jwc.JobId
	where j.JobId = @jobId and fwc.FundiProfileId = @fundiProfileId
	group by fwc.WorkCategoryId, wsc.WorkSubCategoryId, wc.WorkCategoryType , wsc.WorkSubCategoryType
end
GO
