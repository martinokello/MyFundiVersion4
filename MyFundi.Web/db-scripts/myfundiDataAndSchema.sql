USE [myfundi]
GO
/****** Object:  UserDefinedFunction [dbo].[ArePointsNearEnough]    Script Date: 08/05/2023 20:07:02 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fncGetCoordinatesFromSequentialStringValues]    Script Date: 08/05/2023 20:07:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fncGetCoordinatesFromSequentialStringValues](@profaryCord nvarchar(Max))
returns @tab Table(profileId nvarchar(10), lat nvarchar(10), lng nvarchar(10))
as
begin

	declare @tProfCordary Table(item nvarchar(10));
	declare @tabTmp Table(id int, profileId nvarchar(10), lat nvarchar(10), lng nvarchar(10));

	declare @noOfrows int = 0;

	insert into @tProfCordary
	select * from dbo.Split(@profaryCord,N',');

	set @noOfrows = (select count(1) from @tProfCordary)/3;

	With tb as(
	select distinct row_number() over(order by (select 1)) as id,
	t1.item as profileId,
	lead(t1.item,1) over(order by (select 1)) as lat,lead(t1.Item,2) over(order by (select 1)) as lng 
	from @tProfCordary t1
	)
	insert into @tabTmp
	select top(@noOfrows)id,profileId, lat,lng
	from tb
	WHERE profileId is not null and lat is not null and lng is not null 
	and id%3=1;

	With qres as(
		select profileId, lat, lng
		from @tabTmp
	)
	insert into @tab
	select profileId, lat,lng
	from qres;
	return;
end
GO
/****** Object:  UserDefinedFunction [dbo].[fncGetFundiSubScriptionAmountToPay]    Script Date: 08/05/2023 20:07:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE function [dbo].[fncGetFundiSubScriptionAmountToPay](@fundiUserId [uniqueidentifier], @baseFundiSubsFee decimal = 25000.00, @secondFundiSubsFee decimal = 23000.00, 
@thirdFundiSubsFee decimal = 20000.00)
returns decimal
AS
BEGIN
	declare @fundiAmountToPay decimal, @fundiProfileId int, @numberOfPaymentsMade int;
	declare @Last4Subs table(
	[SubscriptionFee] decimal(18,2));
	
	declare @2ndSubs table(
	[SubscriptionFee] decimal(18,2));

	select top(1) @fundiProfileId = fp.fundiProfileId 
	from dbo.Users u 
	join dbo.FundiProfiles fp
	on u.UserId = fp.UserId
	where u.UserId = @fundiUserId

	if @fundiProfileId > 0
	begin
		With Subsc as (
			select top(4) fs.[SubscriptionFee]  as fee
			from dbo.FundiSubscriptionQueues fs 
			join dbo.MonthlySubscriptionQueues ms 
			on fs.MonthlySubscriptionQueueId = ms.MonthlySubscriptionQueueId
			join dbo.FundiProfiles fp
			on ms.FundiProfileId = fp.FundiProfileId
			where fp.FundiProfileId = @fundiProfileId and
		 (datepart(d,getDate()) -  datepart(d,fs.DateCreated)) <= 30 and fs.SubscriptionFee = @baseFundiSubsFee
			order by  fs.SubscriptionFee, fs.DateCreated  desc
		)
		insert into @Last4Subs
		select top (1) fee from Subsc;
		declare @numberOfBaseSubs int;
		select @numberOfBaseSubs = count(1) from @Last4Subs;
		if(@numberOfBaseSubs is NULL or @numberOfBaseSubs = 0) return @baseFundiSubsFee
		else if(@numberOfBaseSubs = 1)
		begin
			With Subsc2 as (
				select top(1) fs.[SubscriptionFee] as fee
			from dbo.FundiSubscriptionQueues fs 
			join dbo.MonthlySubscriptionQueues ms 
			on fs.MonthlySubscriptionQueueId = ms.MonthlySubscriptionQueueId
			join dbo.FundiProfiles fp
			on ms.FundiProfileId = fp.FundiProfileId
			where fp.FundiProfileId = @fundiProfileId and
			(datepart(d,getDate()) -  datepart(d,fs.DateCreated)) <= 30 and fs.SubscriptionFee = @secondFundiSubsFee
			order by  fs.SubscriptionFee, fs.DateCreated  desc
			)
			insert into @2ndSubs
			select top (1) fee from Subsc2;

			declare @numberOf2ndSubs int;
			select @numberOf2ndSubs = count(1) from @2ndSubs;
			if (@numberOf2ndSubs is NULL or @numberOf2ndSubs = 0) return @secondFundiSubsFee
			return @thirdFundiSubsFee 
		end
	end
	return  @baseFundiSubsFee;
END
GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 08/05/2023 20:07:02 ******/
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
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 08/05/2023 20:07:02 ******/
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
/****** Object:  Table [dbo].[Addresses]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[Answers]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Answers](
	[AnswerId] [int] IDENTITY(1,1) NOT NULL,
	[QuestionId] [int] NOT NULL,
	[AnswerContent] [nvarchar](max) NULL,
	[FundiProfileId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Answers] PRIMARY KEY CLUSTERED 
(
	[AnswerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Blogs]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Blogs](
	[BlogId] [int] IDENTITY(1,1) NOT NULL,
	[BlogName] [nvarchar](max) NULL,
	[BlogContent] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Blogs] PRIMARY KEY CLUSTERED 
(
	[BlogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Certifications]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[ClientFundiContracts]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientFundiContracts](
	[ClientFundiContractId] [int] IDENTITY(1,1) NOT NULL,
	[ClientProfileId] [int] NOT NULL,
	[FundiProfileId] [int] NOT NULL,
	[JobId] [int] NULL,
	[FundiAddressId] [int] NULL,
	[ClientAddressId] [int] NULL,
	[ClientUsername] [nvarchar](max) NULL,
	[ClientFirstName] [nvarchar](max) NULL,
	[ClientLastName] [nvarchar](max) NULL,
	[FundiUsername] [nvarchar](max) NULL,
	[FundiFirstName] [nvarchar](max) NULL,
	[FundiLastName] [nvarchar](max) NULL,
	[NumberOfDaysToComplete] [decimal](18, 2) NOT NULL,
	[ContractualDescription] [nvarchar](max) NULL,
	[AgreedStartDate] [datetime2](7) NOT NULL,
	[AgreedEndDate] [datetime2](7) NOT NULL,
	[IsCompleted] [bit] NOT NULL,
	[IsSignedByClient] [bit] NOT NULL,
	[IsSignedByFundi] [bit] NOT NULL,
	[IsSignedOffByClient] [bit] NOT NULL,
	[NotesForNotice] [nvarchar](max) NULL,
	[AgreedCost] [decimal](18, 2) NOT NULL,
	[Date1stPayment] [datetime2](7) NOT NULL,
	[FirstPaymentAmount] [decimal](18, 2) NOT NULL,
	[Date2ndPayment] [datetime2](7) NOT NULL,
	[SecondPaymentAmount] [decimal](18, 2) NOT NULL,
	[Date3rdPayment] [datetime2](7) NOT NULL,
	[ThirdPaymentAmount] [decimal](18, 2) NOT NULL,
	[Date4thPayment] [datetime2](7) NOT NULL,
	[ForthPaymentAmount] [decimal](18, 2) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ClientFundiContracts] PRIMARY KEY CLUSTERED 
(
	[ClientFundiContractId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClientProfiles]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[ClientSubscriptions]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientSubscriptions](
	[SubscriptionId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[Username] [nvarchar](max) NULL,
	[SubscriptionName] [nvarchar](max) NULL,
	[SubscriptionDescription] [nvarchar](max) NULL,
	[ClientProfileId] [int] NULL,
	[HasPaid] [bit] NOT NULL,
	[SubscriptionFee] [decimal](18, 2) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ClientSubscriptions] PRIMARY KEY CLUSTERED 
(
	[SubscriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Companies]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[Courses]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[FundiLocations]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundiLocations](
	[FundiLocationId] [int] IDENTITY(1,1) NOT NULL,
	[FundiProfileId] [int] NOT NULL,
	[Latitude] [float] NOT NULL,
	[Longitude] [float] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FundiLocations] PRIMARY KEY CLUSTERED 
(
	[FundiLocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundiProfileAndReviewRatings]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[FundiProfileCertifications]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[FundiProfileCourses]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[FundiProfiles]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[FundiSubscriptionQueues]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundiSubscriptionQueues](
	[FundiSubscriptionQueueId] [int] IDENTITY(1,1) NOT NULL,
	[HasPaid] [bit] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[SubscriptionName] [nvarchar](max) NULL,
	[SubscriptionFee] [decimal](18, 2) NOT NULL,
	[SubscriptionDescription] [nvarchar](max) NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[MonthlySubscriptionQueueId] [int] NOT NULL,
	[MonthlySubscriptionId] [int] NULL,
	[FundiWorkCategoryId] [int] NOT NULL,
	[FundiWorkSubCategoryId] [int] NOT NULL,
 CONSTRAINT [PK_FundiSubscriptionQueues] PRIMARY KEY CLUSTERED 
(
	[FundiSubscriptionQueueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundiSubscriptions]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundiSubscriptions](
	[FundiSubscriptionId] [int] IDENTITY(1,1) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[SubscriptionName] [nvarchar](max) NULL,
	[SubscriptionFee] [decimal](18, 2) NOT NULL,
	[SubscriptionDescription] [nvarchar](max) NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[MonthlySubscriptionId] [int] NOT NULL,
	[FundiWorkCategoryId] [int] NOT NULL,
	[FundiWorkSubCategoryId] [int] NOT NULL,
 CONSTRAINT [PK_FundiSubscriptions] PRIMARY KEY CLUSTERED 
(
	[FundiSubscriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundiWorkCategories]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundiWorkCategories](
	[FundiWorkCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[FundiProfileId] [int] NOT NULL,
	[WorkCategoryId] [int] NOT NULL,
	[WorkSubCategoryId] [int] NULL,
	[JobId] [int] NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FundiWorkCategories] PRIMARY KEY CLUSTERED 
(
	[FundiWorkCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Invoices]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[Items]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[Jobs]    Script Date: 08/05/2023 20:07:03 ******/
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
	[NumberOfDaysToComplete] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Jobs] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobWorkCategories]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobWorkCategories](
	[JobWorkCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[JobId] [int] NULL,
	[WorkCategoryId] [int] NULL,
	[WorkSubCategoryId] [int] NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_JobWorkCategories] PRIMARY KEY CLUSTERED 
(
	[JobWorkCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[MonthlySubscriptionQueues]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonthlySubscriptionQueues](
	[MonthlySubscriptionQueueId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[Username] [nvarchar](max) NULL,
	[SubscriptionName] [nvarchar](max) NULL,
	[SubscriptionDescription] [nvarchar](max) NULL,
	[FundiProfileId] [int] NULL,
	[HasPaid] [bit] NOT NULL,
	[HasExpired] [bit] NOT NULL,
	[SubscriptionFee] [decimal](18, 2) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_MonthlySubscriptionQueues] PRIMARY KEY CLUSTERED 
(
	[MonthlySubscriptionQueueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MonthlySubscriptions]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonthlySubscriptions](
	[MonthlySubscriptionId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[Username] [nvarchar](max) NULL,
	[SubscriptionName] [nvarchar](max) NULL,
	[SubscriptionDescription] [nvarchar](max) NULL,
	[FundiProfileId] [int] NULL,
	[HasPaid] [bit] NOT NULL,
	[HasExpired] [bit] NOT NULL,
	[SubscriptionFee] [decimal](18, 2) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_MonthlySubscriptions] PRIMARY KEY CLUSTERED 
(
	[MonthlySubscriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Questions]    Script Date: 08/05/2023 20:07:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Questions](
	[QuestionId] [int] IDENTITY(1,1) NOT NULL,
	[QuestionContent] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Questions] PRIMARY KEY CLUSTERED 
(
	[QuestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[UserRoles]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[Users]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[WorkCategories]    Script Date: 08/05/2023 20:07:03 ******/
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
/****** Object:  Table [dbo].[WorkSubCategories]    Script Date: 08/05/2023 20:07:03 ******/
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
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20221126043811_addSubCategories', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20221210033800_subscriptionsAdd', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20221210175309_hasEpiredColToSubscriptionTable', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20221211160432_addHasExpiredCol', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20221211164646_FundiSubscriptionIdentityKey', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20230131152807_AddFundiLocations', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20230210141217_databaseInit', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20230210142005_initDB', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20230210191423_redressClientFundiContract', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20230305032929_newDbInit', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20230321102246_newBlogsTable', N'3.1.22')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20230410110239_initDB', N'3.1.22')
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
SET IDENTITY_INSERT [dbo].[Blogs] ON 
GO
INSERT [dbo].[Blogs] ([BlogId], [BlogName], [BlogContent], [DateCreated], [DateUpdated]) VALUES (1, N'TauElastica 3D Virtual Space Software', N'TauElastica 3D Virtual Space
New Release: The Elastic Analysis Of Structural Steel Frameworks in 3D Space with Inclusion Of Torque and Torsion. Structural Steel Software Design frameworks in Civil/Structural Engineering and can be downloaded here. It comes with predefined solutions in the installation directory. Using the Finite Element analysis Methods, Solutions Of Structures Can be determined in seconds. Meant for Professionals.

RSA Enterprise Premium Suite 3.0

Rsa Premium enterprise Suite is a whole array of RSA Strengths of industrial Nature serving both File and Folder Recursive encryption according to user discretion. It uses the standard key lengths or strengths of RSA 512, RSA 1024, RSA 2048 and RSA 4096, with each increment in key length of double size, enabling high security. The best in RSA Encryption and Decryption procedures. Lightening fast and accurate with mutating padding Algorithm reinstated. File and Folder Encryption of files of any type.

The algorithm that was used to implement the core engine is versatile and using mutating padding, even if the key was broken – which they can not – the element of mutating padding further secures the message, which adopts the RSA 316 algorithm of bit injection randomly into the message prior to encrypting.

This has ascertained RSA Enterprise Premium Security to new heights, and safe to say it has been tested against GCHQ and NSA agencies, with good measure and the results an impacting pleasure to share. The agencies failed to break the messages, leaving them stunned. Naturally with the concept of Security at heart.', CAST(N'2023-03-21T16:05:56.2880610' AS DateTime2), CAST(N'2023-03-21T16:05:56.2880622' AS DateTime2))
GO
INSERT [dbo].[Blogs] ([BlogId], [BlogName], [BlogContent], [DateCreated], [DateUpdated]) VALUES (4, N'Tau Elastica 2D Virtual Space', N'<p>This software is for Structural Engineering professionals, used to design High rise structures.<br><br>It is used to model high rise structures, and analyses bending moments, shear force distributions and rotations and displacements of relative structural joints depending on a defined structure.<br><br>Printing facilities, and Views have been integrated: this software is geared towards professional structure engineers.<br><br><img src="https://myfundiv2.martinlayooinc.com/images/tauelastica.jpg"><br><br>FEM (finite element analysis methods of modelling structures) is key as a Civil/Structural Engineering Software. Also example Solutions included in product - in the directory ProblemSolutions where they can be loaded from the installation directory. Capability for Database SQL Server Express and Oracle10g XE incorporated Plus any ADO.NET DBs. This allows Steel properties to be persisted in DB and acquired from DB. All you need is a properties table in your DB with the steel properties as columns. You should also set a primary key (propertyNumber) in DB.<br><br>It solves structural problems in building design of huge dimensions. Printing, DB Integration are part of the package.<br><br>With clarity, a problem is defined, and can be altered from loading it and saving it against a name. Very reliable, solutions and quick mathematical problems are rendered perfectly over a range of functions: Joint translations, rotations in radians, bending moment distrubutions and shear force distributions with safety factors are accrued as a result of a solution.<br><br>Depending on the screen size, problems of high magnitude can be resolved instantly with ultimate accuracy and definition.</p><p><br></p>', CAST(N'2023-03-30T21:03:32.3166603' AS DateTime2), CAST(N'2023-03-30T21:03:32.3166614' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Blogs] OFF
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
SET IDENTITY_INSERT [dbo].[ClientFundiContracts] ON 
GO
INSERT [dbo].[ClientFundiContracts] ([ClientFundiContractId], [ClientProfileId], [FundiProfileId], [JobId], [FundiAddressId], [ClientAddressId], [ClientUsername], [ClientFirstName], [ClientLastName], [FundiUsername], [FundiFirstName], [FundiLastName], [NumberOfDaysToComplete], [ContractualDescription], [AgreedStartDate], [AgreedEndDate], [IsCompleted], [IsSignedByClient], [IsSignedByFundi], [IsSignedOffByClient], [NotesForNotice], [AgreedCost], [Date1stPayment], [FirstPaymentAmount], [Date2ndPayment], [SecondPaymentAmount], [Date3rdPayment], [ThirdPaymentAmount], [Date4thPayment], [ForthPaymentAmount], [DateCreated], [DateUpdated]) VALUES (1, 7, 14, 8, NULL, NULL, N'administrator@martinlayooinc.com', N'Administrator', N'Administrator', N'joseph.lee@martinlayooinc.com', N'Joseph', N'Lee', CAST(0.00 AS Decimal(18, 2)), N'Gulu City Project Rebuild And Renovations Project Africa, Revamp Of Project Gulu Town rebuild 365 days.', CAST(N'2023-02-11T00:00:00.0000000' AS DateTime2), CAST(N'2023-02-11T00:00:00.0000000' AS DateTime2), 0, 1, 1, 0, N'A quarter of the payment in the first week, another quarter during mid-term, and the remaining bill at the end of the contract.', CAST(650000.00 AS Decimal(18, 2)), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(0.00 AS Decimal(18, 2)), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(0.00 AS Decimal(18, 2)), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(0.00 AS Decimal(18, 2)), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(0.00 AS Decimal(18, 2)), CAST(N'2023-02-11T21:52:30.9641863' AS DateTime2), CAST(N'2023-02-11T22:25:08.2039186' AS DateTime2))
GO
INSERT [dbo].[ClientFundiContracts] ([ClientFundiContractId], [ClientProfileId], [FundiProfileId], [JobId], [FundiAddressId], [ClientAddressId], [ClientUsername], [ClientFirstName], [ClientLastName], [FundiUsername], [FundiFirstName], [FundiLastName], [NumberOfDaysToComplete], [ContractualDescription], [AgreedStartDate], [AgreedEndDate], [IsCompleted], [IsSignedByClient], [IsSignedByFundi], [IsSignedOffByClient], [NotesForNotice], [AgreedCost], [Date1stPayment], [FirstPaymentAmount], [Date2ndPayment], [SecondPaymentAmount], [Date3rdPayment], [ThirdPaymentAmount], [Date4thPayment], [ForthPaymentAmount], [DateCreated], [DateUpdated]) VALUES (3, 7, 15, NULL, 5, 1, N'administrator@martinlayooinc.com', N'Administrator', N'Administrator', N'mart42uk@hotmail.com', N'Martin', N'Okello', CAST(0.00 AS Decimal(18, 2)), N'', CAST(N'2023-04-11T00:00:00.0000000' AS DateTime2), CAST(N'2023-04-11T00:00:00.0000000' AS DateTime2), 0, 1, 1, 0, N'No extra notes. Payments should be on schedule', CAST(160000.00 AS Decimal(18, 2)), CAST(N'2023-04-11T00:00:00.0000000' AS DateTime2), CAST(30000.00 AS Decimal(18, 2)), CAST(N'2023-04-30T00:00:00.0000000' AS DateTime2), CAST(30000.00 AS Decimal(18, 2)), CAST(N'2023-05-11T00:00:00.0000000' AS DateTime2), CAST(30000.00 AS Decimal(18, 2)), CAST(N'2023-04-30T14:13:00.0000000' AS DateTime2), CAST(30000.00 AS Decimal(18, 2)), CAST(N'2023-04-11T14:14:31.8483506' AS DateTime2), CAST(N'2023-04-11T14:14:31.8483508' AS DateTime2))
GO
INSERT [dbo].[ClientFundiContracts] ([ClientFundiContractId], [ClientProfileId], [FundiProfileId], [JobId], [FundiAddressId], [ClientAddressId], [ClientUsername], [ClientFirstName], [ClientLastName], [FundiUsername], [FundiFirstName], [FundiLastName], [NumberOfDaysToComplete], [ContractualDescription], [AgreedStartDate], [AgreedEndDate], [IsCompleted], [IsSignedByClient], [IsSignedByFundi], [IsSignedOffByClient], [NotesForNotice], [AgreedCost], [Date1stPayment], [FirstPaymentAmount], [Date2ndPayment], [SecondPaymentAmount], [Date3rdPayment], [ThirdPaymentAmount], [Date4thPayment], [ForthPaymentAmount], [DateCreated], [DateUpdated]) VALUES (4, 7, 15, NULL, 11, 1, N'administrator@martinlayooinc.com', N'Administrator', N'Administrator', N'mart42uk@hotmail.com', N'Martin', N'Okello', CAST(0.00 AS Decimal(18, 2)), N'', CAST(N'2023-02-11T00:00:00.0000000' AS DateTime2), CAST(N'2023-12-30T00:00:00.0000000' AS DateTime2), 0, 1, 1, 0, N'The details of date of pay are still going to be confirmed, but there are in equal evened out intervals', CAST(1209000.00 AS Decimal(18, 2)), CAST(N'2023-04-30T00:00:00.0000000' AS DateTime2), CAST(500000.00 AS Decimal(18, 2)), CAST(N'2023-04-30T00:00:00.0000000' AS DateTime2), CAST(100000.00 AS Decimal(18, 2)), CAST(N'2023-04-30T00:00:00.0000000' AS DateTime2), CAST(200000.00 AS Decimal(18, 2)), CAST(N'2023-04-30T00:00:00.0000000' AS DateTime2), CAST(409000.00 AS Decimal(18, 2)), CAST(N'2023-04-30T22:52:51.4657495' AS DateTime2), CAST(N'2023-04-30T22:52:51.4657496' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[ClientFundiContracts] OFF
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
SET IDENTITY_INSERT [dbo].[ClientSubscriptions] ON 
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (4, N'd03c5756-413d-49de-5230-08db18645547', N'james.haddock@martinlayooinc.com', N'Paid 7 day Subscription', N'Paid 7 day Subscription', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-02-27T00:00:00.0000000' AS DateTime2), CAST(N'2023-02-27T22:13:18.5581060' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (5, N'e5581e6b-65b2-485b-85f3-08db18ff4b59', N'hellena.jewel@martinlayooinc.com', N'Paid 7 day Subscription', N'Paid 7 day Subscription', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-02-27T00:00:00.0000000' AS DateTime2), CAST(N'2023-02-28T00:29:28.6597560' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (6, N'e9585393-5fd1-45e8-5487-08da6e1c1725', N'Jonathan.asante@martinlayooinc.com', N'Paid 7 day Subscription', N'Paid 7 day Subscription', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-02-28T00:00:00.0000000' AS DateTime2), CAST(N'2023-02-28T13:10:27.0541367' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (7, N'a50985b6-6cbc-4091-179e-08db185cacea', N'grace.hadler@martinlayooinc.com', N'Paid 7 day Subscription', N'Paid 7 day Subscription', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-03-01T00:00:00.0000000' AS DateTime2), CAST(N'2023-03-01T18:29:18.1412979' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (8, N'd6387f29-93c3-4c77-a470-08db1f5ae830', N'getrude.witch@martinlayooinc.com', N'Initial Registration', N'Initial Registration', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-03-07T22:25:50.7745944' AS DateTime2), CAST(N'2023-03-07T22:25:50.7742129' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (9, N'f5373163-dad2-47cb-a472-08db1f5ae830', N'janet.okello@martinlayooinc.com', N'Initial Registration', N'Initial Registration', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-03-07T22:29:54.3538603' AS DateTime2), CAST(N'2023-03-07T22:29:54.3537996' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (10, N'949c09d9-fd9a-440a-0b4f-08db1f5cf41f', N'getrude.lanek@martinlayooinc.com', N'Initial Registration', N'Initial Registration', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-03-07T22:40:29.8576910' AS DateTime2), CAST(N'2023-03-07T22:40:29.8571687' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (11, N'4f35a0b6-c43c-498b-3726-08db1f5e4bf5', N'rhys.gabia@martinlayooinc.com', N'Initial Registration', N'Initial Registration', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-03-07T22:50:06.6156426' AS DateTime2), CAST(N'2023-03-07T22:50:06.6154005' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (12, N'767d2eab-8778-40e0-672c-08db1f5f93a7', N'medal.honour', N'Initial Registration', N'Initial Registration', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-03-07T22:59:16.5469709' AS DateTime2), CAST(N'2023-03-07T22:59:16.5464470' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (13, N'a40524a5-8293-47dd-4dbe-08db1f609d5d', N'heather.murlow2@martinlayooinc.com', N'Paid 7 day Subscription', N'Paid 7 day Subscription', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-03-07T23:06:42.1910709' AS DateTime2), CAST(N'2023-03-07T23:07:35.3054202' AS DateTime2))
GO
INSERT [dbo].[ClientSubscriptions] ([SubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [ClientProfileId], [HasPaid], [SubscriptionFee], [StartDate], [DateUpdated]) VALUES (14, N'c457d9ff-9223-430a-b54c-08db240866f6', N'matty.mats@martinlayooinc.com', N'Paid 7 day Subscription', N'Paid 7 day Subscription', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), CAST(N'2023-03-13T21:18:00.5766211' AS DateTime2), CAST(N'2023-03-13T21:19:05.6610285' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[ClientSubscriptions] OFF
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
SET IDENTITY_INSERT [dbo].[FundiProfileAndReviewRatings] ON 
GO
INSERT [dbo].[FundiProfileAndReviewRatings] ([FundiRatingAndReviewId], [UserId], [Rating], [Review], [FundiProfileId], [DateCreated], [DateUpdated], [WorkCategoryType]) VALUES (1, N'e9585393-5fd1-45e8-5487-08da6e1c1725', 5, N'Admibistrator is a very highly professional Fundi, with vast experience which allows him to estimate and deliver a job whilst prioritising his work load. He has a great job ethic, and exceeds most''s capacity of established Electricians. Very recommendable work he did at my establishment.', 4, CAST(N'2022-12-02T14:27:05.5839178' AS DateTime2), CAST(N'2022-12-02T14:27:05.5839183' AS DateTime2), N'8')
GO
INSERT [dbo].[FundiProfileAndReviewRatings] ([FundiRatingAndReviewId], [UserId], [Rating], [Review], [FundiProfileId], [DateCreated], [DateUpdated], [WorkCategoryType]) VALUES (2, N'e9585393-5fd1-45e8-5487-08da6e1c1725', 4, N'Martin is a great Electician, however his overtly usage of theory tends to annoy clients, who expect work to be accomplished with experience gained. Overall he isn''t a bad Electrician, and estimates and finishes work effectively. I should say the theoretical knowledge he has measures up to his practical knowledge. I just like the practical aspects more leaning my bias to give him a 4 star rather than 5 star. All in all he is a great guy.', 3, CAST(N'2022-12-02T14:30:33.3683662' AS DateTime2), CAST(N'2022-12-02T14:30:33.3683667' AS DateTime2), N'8')
GO
INSERT [dbo].[FundiProfileAndReviewRatings] ([FundiRatingAndReviewId], [UserId], [Rating], [Review], [FundiProfileId], [DateCreated], [DateUpdated], [WorkCategoryType]) VALUES (4, N'bd390c76-989f-4200-3234-08dacfb4f3b5', 5, N'Martin Okello is a professional, and used him a couple of times for both plumbing and Electrical wiring of properties. 

A genuinely friendly chap and always willing to help.', 15, CAST(N'2023-04-11T14:16:28.1712809' AS DateTime2), CAST(N'2023-04-11T14:16:28.1712825' AS DateTime2), N'8')
GO
INSERT [dbo].[FundiProfileAndReviewRatings] ([FundiRatingAndReviewId], [UserId], [Rating], [Review], [FundiProfileId], [DateCreated], [DateUpdated], [WorkCategoryType]) VALUES (5, N'bd390c76-989f-4200-3234-08dacfb4f3b5', 5, N'Martin Okello is a well established Civil Engineer, and calculates material costs effectively. His designs of Structures are excellent, and will keep in touch for other development work in other towns across Uganda. A very great man, worth the recommendations on all grounds', 15, CAST(N'2023-04-30T22:54:52.4653618' AS DateTime2), CAST(N'2023-04-30T22:54:52.4653627' AS DateTime2), N'8')
GO
SET IDENTITY_INSERT [dbo].[FundiProfileAndReviewRatings] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiProfileCertifications] ON 
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (1, 4, 1, CAST(N'2022-11-29T15:30:44.2141903' AS DateTime2), CAST(N'2022-11-29T15:30:44.2141908' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (2, 4, 3, CAST(N'2022-11-29T15:30:49.5317719' AS DateTime2), CAST(N'2022-11-29T15:30:49.5317724' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (3, 4, 5, CAST(N'2022-11-29T15:30:55.1010709' AS DateTime2), CAST(N'2022-11-29T15:30:55.1010709' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (4, 14, 1, CAST(N'2023-01-25T20:24:57.7823929' AS DateTime2), CAST(N'2023-01-25T20:24:57.7823938' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (5, 14, 2, CAST(N'2023-01-25T20:25:02.8886871' AS DateTime2), CAST(N'2023-01-25T20:25:02.8886876' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (6, 15, 1, CAST(N'2023-03-26T00:24:59.9744439' AS DateTime2), CAST(N'2023-03-26T00:24:59.9744447' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (7, 15, 3, CAST(N'2023-03-26T00:25:06.6672443' AS DateTime2), CAST(N'2023-03-26T00:25:06.6672447' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (8, 15, 5, CAST(N'2023-03-26T00:25:13.6366401' AS DateTime2), CAST(N'2023-03-26T00:25:13.6366407' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (9, 17, 1, CAST(N'2023-03-27T19:38:31.6704076' AS DateTime2), CAST(N'2023-03-27T19:38:31.6704080' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCertifications] ([FundiProfileCertificationId], [FundiProfileId], [CertificationId], [DateCreated], [DateUpdated]) VALUES (10, 17, 3, CAST(N'2023-03-27T19:39:11.5430449' AS DateTime2), CAST(N'2023-03-27T19:39:11.5430453' AS DateTime2))
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
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (4, 2, 14, CAST(N'2023-01-25T20:25:14.5406871' AS DateTime2), CAST(N'2023-01-25T20:25:14.5406881' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (5, 3, 14, CAST(N'2023-01-25T20:25:35.7777213' AS DateTime2), CAST(N'2023-01-25T20:25:35.7777218' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (6, 4, 14, CAST(N'2023-01-25T20:25:42.8049941' AS DateTime2), CAST(N'2023-01-25T20:25:42.8049950' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (7, 1, 15, CAST(N'2023-03-26T00:25:26.2156178' AS DateTime2), CAST(N'2023-03-26T00:25:26.2156185' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (8, 5, 15, CAST(N'2023-03-26T00:25:37.3016496' AS DateTime2), CAST(N'2023-03-26T00:25:37.3016505' AS DateTime2))
GO
INSERT [dbo].[FundiProfileCourses] ([FundiProfileCourseTakenId], [CourseId], [FundiProfileId], [DateCreated], [DateUpdated]) VALUES (9, 4, 17, CAST(N'2023-03-27T19:39:20.5755031' AS DateTime2), CAST(N'2023-03-27T19:39:20.5755035' AS DateTime2))
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
4) Leveler', 8, N'', CAST(N'2022-11-29T15:30:11.2447816' AS DateTime2), CAST(N'2022-11-29T15:30:11.2447821' AS DateTime2))
GO
INSERT [dbo].[FundiProfiles] ([FundiProfileId], [UserId], [ProfileSummary], [ProfileImageUrl], [Skills], [UsedPowerTools], [LocationId], [FundiProfileCvUrl], [DateCreated], [DateUpdated]) VALUES (14, N'd3b2c31e-581c-4dcf-07d7-08dafebcbb6f', N'I am a well established Electrical Installations Engineeering, and also work across most of the fields, including electrical fittings, repairs, plumbing, infrastructure engineering to normal handy man expectations, with a good professional outlook. Over 35 years experience as an Electrician.
', N'', N'1) Electrical work and fittings from circuitry to large voltage and pylon installations
2) Plumbing, both internal and external
3) Carpentry
4) Power Tools and Electrical Tools Repairs.', N'1) Electrical Drills
2) Crane Driving
3) JBC Driving
4) Wood work drills and power tools
5) Levels', 5, N'', CAST(N'2023-01-25T20:21:24.7790776' AS DateTime2), CAST(N'2023-01-25T20:21:24.7790781' AS DateTime2))
GO
INSERT [dbo].[FundiProfiles] ([FundiProfileId], [UserId], [ProfileSummary], [ProfileImageUrl], [Skills], [UsedPowerTools], [LocationId], [FundiProfileCvUrl], [DateCreated], [DateUpdated]) VALUES (15, N'928409e1-d068-4576-5a1d-08db2c7a4269', N'Self-motivated web developer and Software Engineer; who strives for total efficiency. Works well under pressure and able to priorities workload to deliver positive results within tight deadlines; a quick learner with strong written and verbal communication skills. Personal Site: https://www.martinlayooinc.com
', N'', N'1) Computer Programming
2) Computer Repairs - hardware and software builds', N'1) Ammeter to test current
2) Levelers for leveling horizontal work.
3) Voltage Meters', 2, N'', CAST(N'2023-03-26T00:24:46.7006243' AS DateTime2), CAST(N'2023-03-26T00:24:46.7006256' AS DateTime2))
GO
INSERT [dbo].[FundiProfiles] ([FundiProfileId], [UserId], [ProfileSummary], [ProfileImageUrl], [Skills], [UsedPowerTools], [LocationId], [FundiProfileCvUrl], [DateCreated], [DateUpdated]) VALUES (17, N'a0bd8159-f351-4868-6f4e-08db2ee9aa64', N'My Profile', N'', N'My Skills', N'My power tools', 1, N'', CAST(N'2023-03-27T19:38:23.4989767' AS DateTime2), CAST(N'2023-03-27T19:38:23.4989773' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[FundiProfiles] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiSubscriptionQueues] ON 
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (4, 0, CAST(N'2023-03-27T19:41:57.8766565' AS DateTime2), CAST(N'2023-03-27T19:41:57.8766567' AS DateTime2), CAST(N'2023-03-27T17:41:56.6140000' AS DateTime2), N'High Voltage installations', CAST(25000.00 AS Decimal(18, 2)), N'High Voltage installations
', CAST(N'2023-04-27T19:41:57.8766546' AS DateTime2), 2, NULL, 2, 8)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (5, 0, CAST(N'2023-03-27T19:41:57.8766565' AS DateTime2), CAST(N'2023-03-27T19:41:57.8766567' AS DateTime2), CAST(N'2023-03-27T17:41:56.6140000' AS DateTime2), N'Low Voltage installations', CAST(23000.00 AS Decimal(18, 2)), N'Low Voltage installation
', CAST(N'2023-04-27T19:41:57.8766546' AS DateTime2), 2, NULL, 2, 9)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (6, 0, CAST(N'2023-03-27T19:41:57.8766565' AS DateTime2), CAST(N'2023-03-27T19:41:57.8766567' AS DateTime2), CAST(N'2023-03-27T17:41:56.6140000' AS DateTime2), N'Repair - Household Appliances', CAST(20000.00 AS Decimal(18, 2)), N'Repair - Household Appliances
', CAST(N'2023-04-27T19:41:57.8766546' AS DateTime2), 2, NULL, 2, 10)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (7, 0, CAST(N'2023-03-27T19:41:57.8766565' AS DateTime2), CAST(N'2023-03-27T19:41:57.8766567' AS DateTime2), CAST(N'2023-03-27T17:41:56.6140000' AS DateTime2), N'Repair - Power Tools', CAST(20000.00 AS Decimal(18, 2)), N'Repair - Power Tools
', CAST(N'2023-04-27T19:41:57.8766546' AS DateTime2), 2, NULL, 2, 11)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (8, 0, CAST(N'2023-04-20T18:15:23.8651040' AS DateTime2), CAST(N'2023-04-20T18:15:23.8651043' AS DateTime2), CAST(N'2023-04-20T17:15:23.8390000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(25000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-05-21T18:15:23.8651025' AS DateTime2), 3, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (9, 0, CAST(N'2023-04-20T18:15:23.8651040' AS DateTime2), CAST(N'2023-04-20T18:15:23.8651043' AS DateTime2), CAST(N'2023-04-20T17:15:23.8390000' AS DateTime2), N'Internal Timber Joinery', CAST(23000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-05-21T18:15:23.8651025' AS DateTime2), 3, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (10, 0, CAST(N'2023-04-20T18:15:23.8651040' AS DateTime2), CAST(N'2023-04-20T18:15:23.8651043' AS DateTime2), CAST(N'2023-04-20T17:15:23.8390000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-05-21T18:15:23.8651025' AS DateTime2), 3, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (11, 0, CAST(N'2023-04-20T18:15:23.8651040' AS DateTime2), CAST(N'2023-04-20T18:15:23.8651043' AS DateTime2), CAST(N'2023-04-20T17:15:23.8390000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-05-21T18:15:23.8651025' AS DateTime2), 3, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (12, 0, CAST(N'2023-04-20T18:15:23.8651040' AS DateTime2), CAST(N'2023-04-20T18:15:23.8651043' AS DateTime2), CAST(N'2023-04-20T17:15:23.8390000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-05-21T18:15:23.8651025' AS DateTime2), 3, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (13, 0, CAST(N'2023-04-20T18:15:23.8651040' AS DateTime2), CAST(N'2023-04-20T18:15:23.8651043' AS DateTime2), CAST(N'2023-04-20T17:15:23.8390000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-05-21T18:15:23.8651025' AS DateTime2), 3, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (14, 0, CAST(N'2023-04-20T18:15:48.1351146' AS DateTime2), CAST(N'2023-04-20T18:15:48.1351149' AS DateTime2), CAST(N'2023-04-20T17:15:48.1170000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(20000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-05-21T18:15:48.1351129' AS DateTime2), 4, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (15, 0, CAST(N'2023-04-20T18:15:48.1351146' AS DateTime2), CAST(N'2023-04-20T18:15:48.1351149' AS DateTime2), CAST(N'2023-04-20T17:15:48.1170000' AS DateTime2), N'Internal Timber Joinery', CAST(20000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-05-21T18:15:48.1351129' AS DateTime2), 4, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (16, 0, CAST(N'2023-04-20T18:15:48.1351146' AS DateTime2), CAST(N'2023-04-20T18:15:48.1351149' AS DateTime2), CAST(N'2023-04-20T17:15:48.1170000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-05-21T18:15:48.1351129' AS DateTime2), 4, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (17, 0, CAST(N'2023-04-20T18:15:48.1351146' AS DateTime2), CAST(N'2023-04-20T18:15:48.1351149' AS DateTime2), CAST(N'2023-04-20T17:15:48.1170000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-05-21T18:15:48.1351129' AS DateTime2), 4, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (18, 0, CAST(N'2023-04-20T18:15:48.1351146' AS DateTime2), CAST(N'2023-04-20T18:15:48.1351149' AS DateTime2), CAST(N'2023-04-20T17:15:48.1170000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-05-21T18:15:48.1351129' AS DateTime2), 4, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (19, 0, CAST(N'2023-04-20T18:15:48.1351146' AS DateTime2), CAST(N'2023-04-20T18:15:48.1351149' AS DateTime2), CAST(N'2023-04-20T17:15:48.1170000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-05-21T18:15:48.1351129' AS DateTime2), 4, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (20, 0, CAST(N'2023-04-21T23:20:20.1008547' AS DateTime2), CAST(N'2023-04-21T23:20:20.1008549' AS DateTime2), CAST(N'2023-04-21T22:20:20.0700000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(20000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-05-22T23:20:20.1008533' AS DateTime2), 5, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (21, 0, CAST(N'2023-04-21T23:20:20.1008547' AS DateTime2), CAST(N'2023-04-21T23:20:20.1008549' AS DateTime2), CAST(N'2023-04-21T22:20:20.0700000' AS DateTime2), N'Internal Timber Joinery', CAST(20000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-05-22T23:20:20.1008533' AS DateTime2), 5, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (22, 0, CAST(N'2023-04-21T23:20:20.1008547' AS DateTime2), CAST(N'2023-04-21T23:20:20.1008549' AS DateTime2), CAST(N'2023-04-21T22:20:20.0700000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-05-22T23:20:20.1008533' AS DateTime2), 5, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (23, 0, CAST(N'2023-04-21T23:20:20.1008547' AS DateTime2), CAST(N'2023-04-21T23:20:20.1008549' AS DateTime2), CAST(N'2023-04-21T22:20:20.0700000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-05-22T23:20:20.1008533' AS DateTime2), 5, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (24, 0, CAST(N'2023-04-21T23:20:20.1008547' AS DateTime2), CAST(N'2023-04-21T23:20:20.1008549' AS DateTime2), CAST(N'2023-04-21T22:20:20.0700000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-05-22T23:20:20.1008533' AS DateTime2), 5, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (25, 0, CAST(N'2023-04-21T23:20:20.1008547' AS DateTime2), CAST(N'2023-04-21T23:20:20.1008549' AS DateTime2), CAST(N'2023-04-21T22:20:20.0700000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-05-22T23:20:20.1008533' AS DateTime2), 5, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (26, 0, CAST(N'2023-04-21T23:30:53.5857305' AS DateTime2), CAST(N'2023-04-21T23:30:53.5857308' AS DateTime2), CAST(N'2023-04-21T22:30:53.5660000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(20000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-05-22T23:30:53.5857285' AS DateTime2), 6, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (27, 0, CAST(N'2023-04-21T23:30:53.5857305' AS DateTime2), CAST(N'2023-04-21T23:30:53.5857308' AS DateTime2), CAST(N'2023-04-21T22:30:53.5660000' AS DateTime2), N'Internal Timber Joinery', CAST(20000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-05-22T23:30:53.5857285' AS DateTime2), 6, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (28, 0, CAST(N'2023-04-21T23:30:53.5857305' AS DateTime2), CAST(N'2023-04-21T23:30:53.5857308' AS DateTime2), CAST(N'2023-04-21T22:30:53.5660000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-05-22T23:30:53.5857285' AS DateTime2), 6, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (29, 0, CAST(N'2023-04-21T23:30:53.5857305' AS DateTime2), CAST(N'2023-04-21T23:30:53.5857308' AS DateTime2), CAST(N'2023-04-21T22:30:53.5660000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-05-22T23:30:53.5857285' AS DateTime2), 6, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (30, 0, CAST(N'2023-04-21T23:30:53.5857305' AS DateTime2), CAST(N'2023-04-21T23:30:53.5857308' AS DateTime2), CAST(N'2023-04-21T22:30:53.5660000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-05-22T23:30:53.5857285' AS DateTime2), 6, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (31, 0, CAST(N'2023-04-21T23:30:53.5857305' AS DateTime2), CAST(N'2023-04-21T23:30:53.5857308' AS DateTime2), CAST(N'2023-04-21T22:30:53.5660000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-05-22T23:30:53.5857285' AS DateTime2), 6, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (32, 0, CAST(N'2023-04-21T23:30:56.6433422' AS DateTime2), CAST(N'2023-04-21T23:30:56.6433425' AS DateTime2), CAST(N'2023-04-21T22:30:56.6290000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(20000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-05-22T23:30:56.6433407' AS DateTime2), 7, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (33, 0, CAST(N'2023-04-21T23:30:56.6433422' AS DateTime2), CAST(N'2023-04-21T23:30:56.6433425' AS DateTime2), CAST(N'2023-04-21T22:30:56.6290000' AS DateTime2), N'Internal Timber Joinery', CAST(20000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-05-22T23:30:56.6433407' AS DateTime2), 7, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (34, 0, CAST(N'2023-04-21T23:30:56.6433422' AS DateTime2), CAST(N'2023-04-21T23:30:56.6433425' AS DateTime2), CAST(N'2023-04-21T22:30:56.6290000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-05-22T23:30:56.6433407' AS DateTime2), 7, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (35, 0, CAST(N'2023-04-21T23:30:56.6433422' AS DateTime2), CAST(N'2023-04-21T23:30:56.6433425' AS DateTime2), CAST(N'2023-04-21T22:30:56.6290000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-05-22T23:30:56.6433407' AS DateTime2), 7, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (36, 0, CAST(N'2023-04-21T23:30:56.6433422' AS DateTime2), CAST(N'2023-04-21T23:30:56.6433425' AS DateTime2), CAST(N'2023-04-21T22:30:56.6290000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-05-22T23:30:56.6433407' AS DateTime2), 7, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (37, 0, CAST(N'2023-04-21T23:30:56.6433422' AS DateTime2), CAST(N'2023-04-21T23:30:56.6433425' AS DateTime2), CAST(N'2023-04-21T22:30:56.6290000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-05-22T23:30:56.6433407' AS DateTime2), 7, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (38, 0, CAST(N'2023-04-21T23:34:25.7247983' AS DateTime2), CAST(N'2023-04-21T23:34:25.7247985' AS DateTime2), CAST(N'2023-04-21T22:34:25.7010000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(20000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-05-22T23:34:25.7247969' AS DateTime2), 8, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (39, 0, CAST(N'2023-04-21T23:34:25.7247983' AS DateTime2), CAST(N'2023-04-21T23:34:25.7247985' AS DateTime2), CAST(N'2023-04-21T22:34:25.7010000' AS DateTime2), N'Internal Timber Joinery', CAST(20000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-05-22T23:34:25.7247969' AS DateTime2), 8, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (40, 0, CAST(N'2023-04-21T23:34:25.7247983' AS DateTime2), CAST(N'2023-04-21T23:34:25.7247985' AS DateTime2), CAST(N'2023-04-21T22:34:25.7010000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-05-22T23:34:25.7247969' AS DateTime2), 8, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (41, 0, CAST(N'2023-04-21T23:34:25.7247983' AS DateTime2), CAST(N'2023-04-21T23:34:25.7247985' AS DateTime2), CAST(N'2023-04-21T22:34:25.7010000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-05-22T23:34:25.7247969' AS DateTime2), 8, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (42, 0, CAST(N'2023-04-21T23:34:25.7247983' AS DateTime2), CAST(N'2023-04-21T23:34:25.7247985' AS DateTime2), CAST(N'2023-04-21T22:34:25.7010000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-05-22T23:34:25.7247969' AS DateTime2), 8, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (43, 0, CAST(N'2023-04-21T23:34:25.7247983' AS DateTime2), CAST(N'2023-04-21T23:34:25.7247985' AS DateTime2), CAST(N'2023-04-21T22:34:25.7010000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-05-22T23:34:25.7247969' AS DateTime2), 8, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (44, 0, CAST(N'2023-04-21T23:39:11.4973991' AS DateTime2), CAST(N'2023-04-21T23:39:11.4973994' AS DateTime2), CAST(N'2023-04-21T22:39:11.4800000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(20000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-05-22T23:39:11.4973969' AS DateTime2), 9, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (45, 0, CAST(N'2023-04-21T23:39:11.4973991' AS DateTime2), CAST(N'2023-04-21T23:39:11.4973994' AS DateTime2), CAST(N'2023-04-21T22:39:11.4800000' AS DateTime2), N'Internal Timber Joinery', CAST(20000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-05-22T23:39:11.4973969' AS DateTime2), 9, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (46, 0, CAST(N'2023-04-21T23:39:11.4973991' AS DateTime2), CAST(N'2023-04-21T23:39:11.4973994' AS DateTime2), CAST(N'2023-04-21T22:39:11.4800000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-05-22T23:39:11.4973969' AS DateTime2), 9, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (47, 0, CAST(N'2023-04-21T23:39:11.4973991' AS DateTime2), CAST(N'2023-04-21T23:39:11.4973994' AS DateTime2), CAST(N'2023-04-21T22:39:11.4800000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-05-22T23:39:11.4973969' AS DateTime2), 9, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (48, 0, CAST(N'2023-04-21T23:39:11.4973991' AS DateTime2), CAST(N'2023-04-21T23:39:11.4973994' AS DateTime2), CAST(N'2023-04-21T22:39:11.4800000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-05-22T23:39:11.4973969' AS DateTime2), 9, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (49, 0, CAST(N'2023-04-21T23:39:11.4973991' AS DateTime2), CAST(N'2023-04-21T23:39:11.4973994' AS DateTime2), CAST(N'2023-04-21T22:39:11.4800000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-05-22T23:39:11.4973969' AS DateTime2), 9, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (50, 0, CAST(N'2023-04-21T23:40:04.1213429' AS DateTime2), CAST(N'2023-04-21T23:40:04.1213434' AS DateTime2), CAST(N'2023-04-21T22:39:46.2190000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(20000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-05-22T23:40:04.1213395' AS DateTime2), 10, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (51, 0, CAST(N'2023-04-21T23:40:04.1213429' AS DateTime2), CAST(N'2023-04-21T23:40:04.1213434' AS DateTime2), CAST(N'2023-04-21T22:39:46.2190000' AS DateTime2), N'Internal Timber Joinery', CAST(20000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-05-22T23:40:04.1213395' AS DateTime2), 10, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (52, 0, CAST(N'2023-04-21T23:40:04.1213429' AS DateTime2), CAST(N'2023-04-21T23:40:04.1213434' AS DateTime2), CAST(N'2023-04-21T22:39:46.2190000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-05-22T23:40:04.1213395' AS DateTime2), 10, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (53, 0, CAST(N'2023-04-21T23:40:04.1213429' AS DateTime2), CAST(N'2023-04-21T23:40:04.1213434' AS DateTime2), CAST(N'2023-04-21T22:39:46.2190000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-05-22T23:40:04.1213395' AS DateTime2), 10, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (54, 0, CAST(N'2023-04-21T23:40:04.1213429' AS DateTime2), CAST(N'2023-04-21T23:40:04.1213434' AS DateTime2), CAST(N'2023-04-21T22:39:46.2190000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-05-22T23:40:04.1213395' AS DateTime2), 10, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (55, 0, CAST(N'2023-04-21T23:40:04.1213429' AS DateTime2), CAST(N'2023-04-21T23:40:04.1213434' AS DateTime2), CAST(N'2023-04-21T22:39:46.2190000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-05-22T23:40:04.1213395' AS DateTime2), 10, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (56, 0, CAST(N'2023-04-21T23:40:42.6121927' AS DateTime2), CAST(N'2023-04-21T23:40:42.6121930' AS DateTime2), CAST(N'2023-04-21T22:40:42.5880000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(20000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-05-22T23:40:42.6121912' AS DateTime2), 11, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (57, 0, CAST(N'2023-04-21T23:40:42.6121927' AS DateTime2), CAST(N'2023-04-21T23:40:42.6121930' AS DateTime2), CAST(N'2023-04-21T22:40:42.5880000' AS DateTime2), N'Internal Timber Joinery', CAST(20000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-05-22T23:40:42.6121912' AS DateTime2), 11, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (58, 0, CAST(N'2023-04-21T23:40:42.6121927' AS DateTime2), CAST(N'2023-04-21T23:40:42.6121930' AS DateTime2), CAST(N'2023-04-21T22:40:42.5880000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-05-22T23:40:42.6121912' AS DateTime2), 11, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (59, 0, CAST(N'2023-04-21T23:40:42.6121927' AS DateTime2), CAST(N'2023-04-21T23:40:42.6121930' AS DateTime2), CAST(N'2023-04-21T22:40:42.5880000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-05-22T23:40:42.6121912' AS DateTime2), 11, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (60, 0, CAST(N'2023-04-21T23:40:42.6121927' AS DateTime2), CAST(N'2023-04-21T23:40:42.6121930' AS DateTime2), CAST(N'2023-04-21T22:40:42.5880000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-05-22T23:40:42.6121912' AS DateTime2), 11, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (61, 0, CAST(N'2023-04-21T23:40:42.6121927' AS DateTime2), CAST(N'2023-04-21T23:40:42.6121930' AS DateTime2), CAST(N'2023-04-21T22:40:42.5880000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-05-22T23:40:42.6121912' AS DateTime2), 11, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (62, 0, CAST(N'2023-05-03T08:55:57.2771767' AS DateTime2), CAST(N'2023-05-03T08:55:57.2771769' AS DateTime2), CAST(N'2023-05-03T06:55:57.1570000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(5.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-03T08:55:57.2771694' AS DateTime2), 12, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (63, 0, CAST(N'2023-05-03T08:55:57.2771767' AS DateTime2), CAST(N'2023-05-03T08:55:57.2771769' AS DateTime2), CAST(N'2023-05-03T06:55:57.1570000' AS DateTime2), N'Internal Timber Joinery', CAST(3.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-03T08:55:57.2771694' AS DateTime2), 12, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (64, 0, CAST(N'2023-05-03T08:55:57.2771767' AS DateTime2), CAST(N'2023-05-03T08:55:57.2771769' AS DateTime2), CAST(N'2023-05-03T06:55:57.1570000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-03T08:55:57.2771694' AS DateTime2), 12, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (65, 0, CAST(N'2023-05-03T08:55:57.2771767' AS DateTime2), CAST(N'2023-05-03T08:55:57.2771769' AS DateTime2), CAST(N'2023-05-03T06:55:57.1570000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-03T08:55:57.2771694' AS DateTime2), 12, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (66, 0, CAST(N'2023-05-03T08:55:57.2771767' AS DateTime2), CAST(N'2023-05-03T08:55:57.2771769' AS DateTime2), CAST(N'2023-05-03T06:55:57.1570000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-03T08:55:57.2771694' AS DateTime2), 12, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (67, 0, CAST(N'2023-05-03T08:55:57.2771767' AS DateTime2), CAST(N'2023-05-03T08:55:57.2771769' AS DateTime2), CAST(N'2023-05-03T06:55:57.1570000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-03T08:55:57.2771694' AS DateTime2), 12, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (68, 0, CAST(N'2023-05-04T19:19:02.7826247' AS DateTime2), CAST(N'2023-05-04T19:19:02.7826249' AS DateTime2), CAST(N'2023-05-04T17:19:02.5970000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-04T19:19:02.7826165' AS DateTime2), 13, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (69, 0, CAST(N'2023-05-04T19:19:02.7826247' AS DateTime2), CAST(N'2023-05-04T19:19:02.7826249' AS DateTime2), CAST(N'2023-05-04T17:19:02.5970000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-04T19:19:02.7826165' AS DateTime2), 13, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (70, 0, CAST(N'2023-05-04T19:19:02.7826247' AS DateTime2), CAST(N'2023-05-04T19:19:02.7826249' AS DateTime2), CAST(N'2023-05-04T17:19:02.5970000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-04T19:19:02.7826165' AS DateTime2), 13, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (71, 0, CAST(N'2023-05-04T19:19:02.7826247' AS DateTime2), CAST(N'2023-05-04T19:19:02.7826249' AS DateTime2), CAST(N'2023-05-04T17:19:02.5970000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-04T19:19:02.7826165' AS DateTime2), 13, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (72, 0, CAST(N'2023-05-04T19:19:02.7826247' AS DateTime2), CAST(N'2023-05-04T19:19:02.7826249' AS DateTime2), CAST(N'2023-05-04T17:19:02.5970000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-04T19:19:02.7826165' AS DateTime2), 13, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (73, 0, CAST(N'2023-05-04T19:19:02.7826247' AS DateTime2), CAST(N'2023-05-04T19:19:02.7826249' AS DateTime2), CAST(N'2023-05-04T17:19:02.5970000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-04T19:19:02.7826165' AS DateTime2), 13, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (74, 0, CAST(N'2023-05-04T19:26:23.7860408' AS DateTime2), CAST(N'2023-05-04T19:26:23.7860409' AS DateTime2), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), 14, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (75, 0, CAST(N'2023-05-04T19:26:23.7860408' AS DateTime2), CAST(N'2023-05-04T19:26:23.7860409' AS DateTime2), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), N'Waterproofing', CAST(1.00 AS Decimal(18, 2)), N'Waterproofing
', CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), 14, NULL, 9, 46)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (76, 0, CAST(N'2023-05-04T19:26:23.7860408' AS DateTime2), CAST(N'2023-05-04T19:26:23.7860409' AS DateTime2), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), N'Terrazzo and Concrete polishing', CAST(1.00 AS Decimal(18, 2)), N'Terrazzo and Concrete polishing
', CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), 14, NULL, 9, 44)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (77, 0, CAST(N'2023-05-04T19:26:23.7860408' AS DateTime2), CAST(N'2023-05-04T19:26:23.7860409' AS DateTime2), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), N'High Voltage installations', CAST(1.00 AS Decimal(18, 2)), N'High Voltage installations
', CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), 14, NULL, 2, 8)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (78, 0, CAST(N'2023-05-04T19:26:23.7860408' AS DateTime2), CAST(N'2023-05-04T19:26:23.7860409' AS DateTime2), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), N'Low Voltage installations', CAST(1.00 AS Decimal(18, 2)), N'Low Voltage installation
', CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), 14, NULL, 2, 9)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (79, 0, CAST(N'2023-05-04T19:26:23.7860408' AS DateTime2), CAST(N'2023-05-04T19:26:23.7860409' AS DateTime2), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), N'Repair - Household Appliances', CAST(1.00 AS Decimal(18, 2)), N'Repair - Household Appliances
', CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), 14, NULL, 2, 10)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (80, 0, CAST(N'2023-05-04T19:26:23.7860408' AS DateTime2), CAST(N'2023-05-04T19:26:23.7860409' AS DateTime2), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), N'Pumps and Pumping Systems', CAST(1.00 AS Decimal(18, 2)), N'Pumps and Pumping Systems
', CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), 14, NULL, 10, 47)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (81, 0, CAST(N'2023-05-04T19:26:23.7860408' AS DateTime2), CAST(N'2023-05-04T19:26:23.7860409' AS DateTime2), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), N'Internal Plumbing', CAST(1.00 AS Decimal(18, 2)), N'Internal Plumbing
', CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), 14, NULL, 10, 48)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (82, 0, CAST(N'2023-05-04T19:26:23.7860408' AS DateTime2), CAST(N'2023-05-04T19:26:23.7860409' AS DateTime2), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), N'External Plumbing', CAST(1.00 AS Decimal(18, 2)), N'External Plumbing
', CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), 14, NULL, 10, 49)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (83, 0, CAST(N'2023-05-04T19:27:28.8018443' AS DateTime2), CAST(N'2023-05-04T19:27:28.8018444' AS DateTime2), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), 15, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (84, 0, CAST(N'2023-05-04T19:27:28.8018443' AS DateTime2), CAST(N'2023-05-04T19:27:28.8018444' AS DateTime2), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), N'Waterproofing', CAST(1.00 AS Decimal(18, 2)), N'Waterproofing
', CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), 15, NULL, 9, 46)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (85, 0, CAST(N'2023-05-04T19:27:28.8018443' AS DateTime2), CAST(N'2023-05-04T19:27:28.8018444' AS DateTime2), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), N'Terrazzo and Concrete polishing', CAST(1.00 AS Decimal(18, 2)), N'Terrazzo and Concrete polishing
', CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), 15, NULL, 9, 44)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (86, 0, CAST(N'2023-05-04T19:27:28.8018443' AS DateTime2), CAST(N'2023-05-04T19:27:28.8018444' AS DateTime2), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), N'High Voltage installations', CAST(1.00 AS Decimal(18, 2)), N'High Voltage installations
', CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), 15, NULL, 2, 8)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (87, 0, CAST(N'2023-05-04T19:27:28.8018443' AS DateTime2), CAST(N'2023-05-04T19:27:28.8018444' AS DateTime2), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), N'Low Voltage installations', CAST(1.00 AS Decimal(18, 2)), N'Low Voltage installation
', CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), 15, NULL, 2, 9)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (88, 0, CAST(N'2023-05-04T19:27:28.8018443' AS DateTime2), CAST(N'2023-05-04T19:27:28.8018444' AS DateTime2), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), N'Repair - Household Appliances', CAST(1.00 AS Decimal(18, 2)), N'Repair - Household Appliances
', CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), 15, NULL, 2, 10)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (89, 0, CAST(N'2023-05-04T19:27:28.8018443' AS DateTime2), CAST(N'2023-05-04T19:27:28.8018444' AS DateTime2), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), N'Pumps and Pumping Systems', CAST(1.00 AS Decimal(18, 2)), N'Pumps and Pumping Systems
', CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), 15, NULL, 10, 47)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (90, 0, CAST(N'2023-05-04T19:27:28.8018443' AS DateTime2), CAST(N'2023-05-04T19:27:28.8018444' AS DateTime2), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), N'Internal Plumbing', CAST(1.00 AS Decimal(18, 2)), N'Internal Plumbing
', CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), 15, NULL, 10, 48)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (91, 0, CAST(N'2023-05-04T19:27:28.8018443' AS DateTime2), CAST(N'2023-05-04T19:27:28.8018444' AS DateTime2), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), N'External Plumbing', CAST(1.00 AS Decimal(18, 2)), N'External Plumbing
', CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), 15, NULL, 10, 49)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (92, 0, CAST(N'2023-05-04T20:29:59.2328092' AS DateTime2), CAST(N'2023-05-04T20:29:59.2328093' AS DateTime2), CAST(N'2023-05-04T18:29:59.4940000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-04T20:29:59.2328000' AS DateTime2), 16, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (93, 0, CAST(N'2023-05-04T20:29:59.2328092' AS DateTime2), CAST(N'2023-05-04T20:29:59.2328093' AS DateTime2), CAST(N'2023-05-04T18:29:59.4940000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-04T20:29:59.2328000' AS DateTime2), 16, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (94, 0, CAST(N'2023-05-04T20:29:59.2328092' AS DateTime2), CAST(N'2023-05-04T20:29:59.2328093' AS DateTime2), CAST(N'2023-05-04T18:29:59.4940000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-04T20:29:59.2328000' AS DateTime2), 16, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (95, 0, CAST(N'2023-05-04T20:29:59.2328092' AS DateTime2), CAST(N'2023-05-04T20:29:59.2328093' AS DateTime2), CAST(N'2023-05-04T18:29:59.4940000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-04T20:29:59.2328000' AS DateTime2), 16, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (96, 0, CAST(N'2023-05-04T20:29:59.2328092' AS DateTime2), CAST(N'2023-05-04T20:29:59.2328093' AS DateTime2), CAST(N'2023-05-04T18:29:59.4940000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-04T20:29:59.2328000' AS DateTime2), 16, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (97, 0, CAST(N'2023-05-04T20:29:59.2328092' AS DateTime2), CAST(N'2023-05-04T20:29:59.2328093' AS DateTime2), CAST(N'2023-05-04T18:29:59.4940000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-04T20:29:59.2328000' AS DateTime2), 16, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (98, 0, CAST(N'2023-05-04T20:31:58.7419597' AS DateTime2), CAST(N'2023-05-04T20:31:58.7419598' AS DateTime2), CAST(N'2023-05-04T18:31:59.1550000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-04T20:31:58.7419520' AS DateTime2), 17, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (99, 0, CAST(N'2023-05-04T20:31:58.7419597' AS DateTime2), CAST(N'2023-05-04T20:31:58.7419598' AS DateTime2), CAST(N'2023-05-04T18:31:59.1550000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-04T20:31:58.7419520' AS DateTime2), 17, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (100, 0, CAST(N'2023-05-04T20:31:58.7419597' AS DateTime2), CAST(N'2023-05-04T20:31:58.7419598' AS DateTime2), CAST(N'2023-05-04T18:31:59.1550000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-04T20:31:58.7419520' AS DateTime2), 17, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (101, 0, CAST(N'2023-05-04T20:31:58.7419597' AS DateTime2), CAST(N'2023-05-04T20:31:58.7419598' AS DateTime2), CAST(N'2023-05-04T18:31:59.1550000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-04T20:31:58.7419520' AS DateTime2), 17, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (102, 0, CAST(N'2023-05-04T20:31:58.7419597' AS DateTime2), CAST(N'2023-05-04T20:31:58.7419598' AS DateTime2), CAST(N'2023-05-04T18:31:59.1550000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-04T20:31:58.7419520' AS DateTime2), 17, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (103, 0, CAST(N'2023-05-04T20:31:58.7419597' AS DateTime2), CAST(N'2023-05-04T20:31:58.7419598' AS DateTime2), CAST(N'2023-05-04T18:31:59.1550000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-04T20:31:58.7419520' AS DateTime2), 17, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (104, 0, CAST(N'2023-05-05T02:51:15.1527444' AS DateTime2), CAST(N'2023-05-05T02:51:15.1527446' AS DateTime2), CAST(N'2023-05-05T00:51:15.2290000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-05T02:51:15.1527360' AS DateTime2), 18, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (105, 0, CAST(N'2023-05-05T02:51:15.1527444' AS DateTime2), CAST(N'2023-05-05T02:51:15.1527446' AS DateTime2), CAST(N'2023-05-05T00:51:15.2290000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-05T02:51:15.1527360' AS DateTime2), 18, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (106, 0, CAST(N'2023-05-05T02:51:15.1527444' AS DateTime2), CAST(N'2023-05-05T02:51:15.1527446' AS DateTime2), CAST(N'2023-05-05T00:51:15.2290000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-05T02:51:15.1527360' AS DateTime2), 18, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (107, 0, CAST(N'2023-05-05T02:51:15.1527444' AS DateTime2), CAST(N'2023-05-05T02:51:15.1527446' AS DateTime2), CAST(N'2023-05-05T00:51:15.2290000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-05T02:51:15.1527360' AS DateTime2), 18, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (108, 0, CAST(N'2023-05-05T02:51:15.1527444' AS DateTime2), CAST(N'2023-05-05T02:51:15.1527446' AS DateTime2), CAST(N'2023-05-05T00:51:15.2290000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-05T02:51:15.1527360' AS DateTime2), 18, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (109, 0, CAST(N'2023-05-05T02:51:15.1527444' AS DateTime2), CAST(N'2023-05-05T02:51:15.1527446' AS DateTime2), CAST(N'2023-05-05T00:51:15.2290000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-05T02:51:15.1527360' AS DateTime2), 18, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (110, 0, CAST(N'2023-05-05T22:46:15.4700300' AS DateTime2), CAST(N'2023-05-05T22:46:15.4700302' AS DateTime2), CAST(N'2023-05-05T20:46:14.2560000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-05T22:46:15.4700216' AS DateTime2), 19, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (111, 0, CAST(N'2023-05-05T22:46:15.4700300' AS DateTime2), CAST(N'2023-05-05T22:46:15.4700302' AS DateTime2), CAST(N'2023-05-05T20:46:14.2560000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-05T22:46:15.4700216' AS DateTime2), 19, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (112, 0, CAST(N'2023-05-05T22:46:15.4700300' AS DateTime2), CAST(N'2023-05-05T22:46:15.4700302' AS DateTime2), CAST(N'2023-05-05T20:46:14.2560000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-05T22:46:15.4700216' AS DateTime2), 19, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (113, 0, CAST(N'2023-05-05T22:46:15.4700300' AS DateTime2), CAST(N'2023-05-05T22:46:15.4700302' AS DateTime2), CAST(N'2023-05-05T20:46:14.2560000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-05T22:46:15.4700216' AS DateTime2), 19, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (114, 0, CAST(N'2023-05-05T22:46:15.4700300' AS DateTime2), CAST(N'2023-05-05T22:46:15.4700302' AS DateTime2), CAST(N'2023-05-05T20:46:14.2560000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-05T22:46:15.4700216' AS DateTime2), 19, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (115, 0, CAST(N'2023-05-05T22:46:15.4700300' AS DateTime2), CAST(N'2023-05-05T22:46:15.4700302' AS DateTime2), CAST(N'2023-05-05T20:46:14.2560000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-05T22:46:15.4700216' AS DateTime2), 19, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (116, 0, CAST(N'2023-05-05T23:37:33.8823408' AS DateTime2), CAST(N'2023-05-05T23:37:33.8823409' AS DateTime2), CAST(N'2023-05-05T21:37:32.5710000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-05T23:37:33.8823335' AS DateTime2), 20, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (117, 0, CAST(N'2023-05-05T23:37:33.8823408' AS DateTime2), CAST(N'2023-05-05T23:37:33.8823409' AS DateTime2), CAST(N'2023-05-05T21:37:32.5710000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-05T23:37:33.8823335' AS DateTime2), 20, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (118, 0, CAST(N'2023-05-05T23:37:33.8823408' AS DateTime2), CAST(N'2023-05-05T23:37:33.8823409' AS DateTime2), CAST(N'2023-05-05T21:37:32.5710000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-05T23:37:33.8823335' AS DateTime2), 20, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (119, 0, CAST(N'2023-05-05T23:37:33.8823408' AS DateTime2), CAST(N'2023-05-05T23:37:33.8823409' AS DateTime2), CAST(N'2023-05-05T21:37:32.5710000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-05T23:37:33.8823335' AS DateTime2), 20, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (120, 0, CAST(N'2023-05-05T23:37:33.8823408' AS DateTime2), CAST(N'2023-05-05T23:37:33.8823409' AS DateTime2), CAST(N'2023-05-05T21:37:32.5710000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-05T23:37:33.8823335' AS DateTime2), 20, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (121, 0, CAST(N'2023-05-05T23:37:33.8823408' AS DateTime2), CAST(N'2023-05-05T23:37:33.8823409' AS DateTime2), CAST(N'2023-05-05T21:37:32.5710000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-05T23:37:33.8823335' AS DateTime2), 20, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (122, 0, CAST(N'2023-05-05T23:37:39.5417377' AS DateTime2), CAST(N'2023-05-05T23:37:39.5417378' AS DateTime2), CAST(N'2023-05-05T21:37:38.2410000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-05T23:37:39.5417321' AS DateTime2), 21, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (123, 0, CAST(N'2023-05-05T23:37:39.5417377' AS DateTime2), CAST(N'2023-05-05T23:37:39.5417378' AS DateTime2), CAST(N'2023-05-05T21:37:38.2410000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-05T23:37:39.5417321' AS DateTime2), 21, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (124, 0, CAST(N'2023-05-05T23:37:39.5417377' AS DateTime2), CAST(N'2023-05-05T23:37:39.5417378' AS DateTime2), CAST(N'2023-05-05T21:37:38.2410000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-05T23:37:39.5417321' AS DateTime2), 21, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (125, 0, CAST(N'2023-05-05T23:37:39.5417377' AS DateTime2), CAST(N'2023-05-05T23:37:39.5417378' AS DateTime2), CAST(N'2023-05-05T21:37:38.2410000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-05T23:37:39.5417321' AS DateTime2), 21, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (126, 0, CAST(N'2023-05-05T23:37:39.5417377' AS DateTime2), CAST(N'2023-05-05T23:37:39.5417378' AS DateTime2), CAST(N'2023-05-05T21:37:38.2410000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-05T23:37:39.5417321' AS DateTime2), 21, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (127, 0, CAST(N'2023-05-05T23:37:39.5417377' AS DateTime2), CAST(N'2023-05-05T23:37:39.5417378' AS DateTime2), CAST(N'2023-05-05T21:37:38.2410000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-05T23:37:39.5417321' AS DateTime2), 21, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (128, 0, CAST(N'2023-05-05T23:57:55.7932729' AS DateTime2), CAST(N'2023-05-05T23:57:55.7932730' AS DateTime2), CAST(N'2023-05-05T21:57:54.4600000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-05T23:57:55.7932654' AS DateTime2), 22, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (129, 0, CAST(N'2023-05-05T23:57:55.7932729' AS DateTime2), CAST(N'2023-05-05T23:57:55.7932730' AS DateTime2), CAST(N'2023-05-05T21:57:54.4600000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-05T23:57:55.7932654' AS DateTime2), 22, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (130, 0, CAST(N'2023-05-05T23:57:55.7932729' AS DateTime2), CAST(N'2023-05-05T23:57:55.7932730' AS DateTime2), CAST(N'2023-05-05T21:57:54.4600000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-05T23:57:55.7932654' AS DateTime2), 22, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (131, 0, CAST(N'2023-05-05T23:57:55.7932729' AS DateTime2), CAST(N'2023-05-05T23:57:55.7932730' AS DateTime2), CAST(N'2023-05-05T21:57:54.4600000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-05T23:57:55.7932654' AS DateTime2), 22, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (132, 0, CAST(N'2023-05-05T23:57:55.7932729' AS DateTime2), CAST(N'2023-05-05T23:57:55.7932730' AS DateTime2), CAST(N'2023-05-05T21:57:54.4600000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-05T23:57:55.7932654' AS DateTime2), 22, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (133, 0, CAST(N'2023-05-05T23:57:55.7932729' AS DateTime2), CAST(N'2023-05-05T23:57:55.7932730' AS DateTime2), CAST(N'2023-05-05T21:57:54.4600000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-05T23:57:55.7932654' AS DateTime2), 22, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (134, 0, CAST(N'2023-05-05T23:58:28.5443892' AS DateTime2), CAST(N'2023-05-05T23:58:28.5443893' AS DateTime2), CAST(N'2023-05-05T21:58:27.2050000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-05T23:58:28.5443831' AS DateTime2), 23, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (135, 0, CAST(N'2023-05-05T23:58:28.5443892' AS DateTime2), CAST(N'2023-05-05T23:58:28.5443893' AS DateTime2), CAST(N'2023-05-05T21:58:27.2050000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-05T23:58:28.5443831' AS DateTime2), 23, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (136, 0, CAST(N'2023-05-05T23:58:28.5443892' AS DateTime2), CAST(N'2023-05-05T23:58:28.5443893' AS DateTime2), CAST(N'2023-05-05T21:58:27.2050000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-05T23:58:28.5443831' AS DateTime2), 23, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (137, 0, CAST(N'2023-05-05T23:58:28.5443892' AS DateTime2), CAST(N'2023-05-05T23:58:28.5443893' AS DateTime2), CAST(N'2023-05-05T21:58:27.2050000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-05T23:58:28.5443831' AS DateTime2), 23, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (138, 0, CAST(N'2023-05-05T23:58:28.5443892' AS DateTime2), CAST(N'2023-05-05T23:58:28.5443893' AS DateTime2), CAST(N'2023-05-05T21:58:27.2050000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-05T23:58:28.5443831' AS DateTime2), 23, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (139, 0, CAST(N'2023-05-05T23:58:28.5443892' AS DateTime2), CAST(N'2023-05-05T23:58:28.5443893' AS DateTime2), CAST(N'2023-05-05T21:58:27.2050000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-05T23:58:28.5443831' AS DateTime2), 23, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (140, 0, CAST(N'2023-05-06T00:15:32.8215880' AS DateTime2), CAST(N'2023-05-06T00:15:32.8215881' AS DateTime2), CAST(N'2023-05-05T22:15:31.4520000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T00:15:32.8215815' AS DateTime2), 24, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (141, 0, CAST(N'2023-05-06T00:15:32.8215880' AS DateTime2), CAST(N'2023-05-06T00:15:32.8215881' AS DateTime2), CAST(N'2023-05-05T22:15:31.4520000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T00:15:32.8215815' AS DateTime2), 24, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (142, 0, CAST(N'2023-05-06T00:15:32.8215880' AS DateTime2), CAST(N'2023-05-06T00:15:32.8215881' AS DateTime2), CAST(N'2023-05-05T22:15:31.4520000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T00:15:32.8215815' AS DateTime2), 24, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (143, 0, CAST(N'2023-05-06T00:15:32.8215880' AS DateTime2), CAST(N'2023-05-06T00:15:32.8215881' AS DateTime2), CAST(N'2023-05-05T22:15:31.4520000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T00:15:32.8215815' AS DateTime2), 24, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (144, 0, CAST(N'2023-05-06T00:15:32.8215880' AS DateTime2), CAST(N'2023-05-06T00:15:32.8215881' AS DateTime2), CAST(N'2023-05-05T22:15:31.4520000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T00:15:32.8215815' AS DateTime2), 24, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (145, 0, CAST(N'2023-05-06T00:15:32.8215880' AS DateTime2), CAST(N'2023-05-06T00:15:32.8215881' AS DateTime2), CAST(N'2023-05-05T22:15:31.4520000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T00:15:32.8215815' AS DateTime2), 24, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (146, 0, CAST(N'2023-05-06T00:56:58.2136894' AS DateTime2), CAST(N'2023-05-06T00:56:58.2136895' AS DateTime2), CAST(N'2023-05-05T22:56:56.7180000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T00:56:58.2136814' AS DateTime2), 25, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (147, 0, CAST(N'2023-05-06T00:56:58.2136894' AS DateTime2), CAST(N'2023-05-06T00:56:58.2136895' AS DateTime2), CAST(N'2023-05-05T22:56:56.7180000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T00:56:58.2136814' AS DateTime2), 25, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (148, 0, CAST(N'2023-05-06T00:56:58.2136894' AS DateTime2), CAST(N'2023-05-06T00:56:58.2136895' AS DateTime2), CAST(N'2023-05-05T22:56:56.7180000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T00:56:58.2136814' AS DateTime2), 25, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (149, 0, CAST(N'2023-05-06T00:56:58.2136894' AS DateTime2), CAST(N'2023-05-06T00:56:58.2136895' AS DateTime2), CAST(N'2023-05-05T22:56:56.7180000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T00:56:58.2136814' AS DateTime2), 25, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (150, 0, CAST(N'2023-05-06T00:56:58.2136894' AS DateTime2), CAST(N'2023-05-06T00:56:58.2136895' AS DateTime2), CAST(N'2023-05-05T22:56:56.7180000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T00:56:58.2136814' AS DateTime2), 25, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (151, 0, CAST(N'2023-05-06T00:56:58.2136894' AS DateTime2), CAST(N'2023-05-06T00:56:58.2136895' AS DateTime2), CAST(N'2023-05-05T22:56:56.7180000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T00:56:58.2136814' AS DateTime2), 25, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (152, 0, CAST(N'2023-05-06T00:59:05.9119620' AS DateTime2), CAST(N'2023-05-06T00:59:05.9119621' AS DateTime2), CAST(N'2023-05-05T22:59:04.4250000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T00:59:05.9119540' AS DateTime2), 26, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (153, 0, CAST(N'2023-05-06T00:59:05.9119620' AS DateTime2), CAST(N'2023-05-06T00:59:05.9119621' AS DateTime2), CAST(N'2023-05-05T22:59:04.4250000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T00:59:05.9119540' AS DateTime2), 26, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (154, 0, CAST(N'2023-05-06T00:59:05.9119620' AS DateTime2), CAST(N'2023-05-06T00:59:05.9119621' AS DateTime2), CAST(N'2023-05-05T22:59:04.4250000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T00:59:05.9119540' AS DateTime2), 26, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (155, 0, CAST(N'2023-05-06T00:59:05.9119620' AS DateTime2), CAST(N'2023-05-06T00:59:05.9119621' AS DateTime2), CAST(N'2023-05-05T22:59:04.4250000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T00:59:05.9119540' AS DateTime2), 26, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (156, 0, CAST(N'2023-05-06T00:59:05.9119620' AS DateTime2), CAST(N'2023-05-06T00:59:05.9119621' AS DateTime2), CAST(N'2023-05-05T22:59:04.4250000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T00:59:05.9119540' AS DateTime2), 26, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (157, 0, CAST(N'2023-05-06T00:59:05.9119620' AS DateTime2), CAST(N'2023-05-06T00:59:05.9119621' AS DateTime2), CAST(N'2023-05-05T22:59:04.4250000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T00:59:05.9119540' AS DateTime2), 26, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (158, 0, CAST(N'2023-05-06T01:46:50.7805362' AS DateTime2), CAST(N'2023-05-06T01:46:50.7805363' AS DateTime2), CAST(N'2023-05-05T23:46:49.1960000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T01:46:50.7805298' AS DateTime2), 27, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (159, 0, CAST(N'2023-05-06T01:46:50.7805362' AS DateTime2), CAST(N'2023-05-06T01:46:50.7805363' AS DateTime2), CAST(N'2023-05-05T23:46:49.1960000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T01:46:50.7805298' AS DateTime2), 27, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (160, 0, CAST(N'2023-05-06T01:46:50.7805362' AS DateTime2), CAST(N'2023-05-06T01:46:50.7805363' AS DateTime2), CAST(N'2023-05-05T23:46:49.1960000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T01:46:50.7805298' AS DateTime2), 27, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (161, 0, CAST(N'2023-05-06T01:46:50.7805362' AS DateTime2), CAST(N'2023-05-06T01:46:50.7805363' AS DateTime2), CAST(N'2023-05-05T23:46:49.1960000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T01:46:50.7805298' AS DateTime2), 27, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (162, 0, CAST(N'2023-05-06T01:46:50.7805362' AS DateTime2), CAST(N'2023-05-06T01:46:50.7805363' AS DateTime2), CAST(N'2023-05-05T23:46:49.1960000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T01:46:50.7805298' AS DateTime2), 27, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (163, 0, CAST(N'2023-05-06T01:46:50.7805362' AS DateTime2), CAST(N'2023-05-06T01:46:50.7805363' AS DateTime2), CAST(N'2023-05-05T23:46:49.1960000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T01:46:50.7805298' AS DateTime2), 27, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (164, 0, CAST(N'2023-05-06T02:33:33.5767480' AS DateTime2), CAST(N'2023-05-06T02:33:33.5767481' AS DateTime2), CAST(N'2023-05-06T00:33:31.8940000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T02:33:33.5767397' AS DateTime2), 28, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (165, 0, CAST(N'2023-05-06T02:33:33.5767480' AS DateTime2), CAST(N'2023-05-06T02:33:33.5767481' AS DateTime2), CAST(N'2023-05-06T00:33:31.8940000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T02:33:33.5767397' AS DateTime2), 28, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (166, 0, CAST(N'2023-05-06T02:33:33.5767480' AS DateTime2), CAST(N'2023-05-06T02:33:33.5767481' AS DateTime2), CAST(N'2023-05-06T00:33:31.8940000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T02:33:33.5767397' AS DateTime2), 28, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (167, 0, CAST(N'2023-05-06T02:33:33.5767480' AS DateTime2), CAST(N'2023-05-06T02:33:33.5767481' AS DateTime2), CAST(N'2023-05-06T00:33:31.8940000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T02:33:33.5767397' AS DateTime2), 28, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (168, 0, CAST(N'2023-05-06T02:33:33.5767480' AS DateTime2), CAST(N'2023-05-06T02:33:33.5767481' AS DateTime2), CAST(N'2023-05-06T00:33:31.8940000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T02:33:33.5767397' AS DateTime2), 28, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (169, 0, CAST(N'2023-05-06T02:33:33.5767480' AS DateTime2), CAST(N'2023-05-06T02:33:33.5767481' AS DateTime2), CAST(N'2023-05-06T00:33:31.8940000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T02:33:33.5767397' AS DateTime2), 28, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (170, 0, CAST(N'2023-05-06T02:50:44.4881881' AS DateTime2), CAST(N'2023-05-06T02:50:44.4881883' AS DateTime2), CAST(N'2023-05-06T00:50:42.7860000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T02:50:44.4881813' AS DateTime2), 29, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (171, 0, CAST(N'2023-05-06T02:50:44.4881881' AS DateTime2), CAST(N'2023-05-06T02:50:44.4881883' AS DateTime2), CAST(N'2023-05-06T00:50:42.7860000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T02:50:44.4881813' AS DateTime2), 29, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (172, 0, CAST(N'2023-05-06T02:50:44.4881881' AS DateTime2), CAST(N'2023-05-06T02:50:44.4881883' AS DateTime2), CAST(N'2023-05-06T00:50:42.7860000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T02:50:44.4881813' AS DateTime2), 29, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (173, 0, CAST(N'2023-05-06T02:50:44.4881881' AS DateTime2), CAST(N'2023-05-06T02:50:44.4881883' AS DateTime2), CAST(N'2023-05-06T00:50:42.7860000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T02:50:44.4881813' AS DateTime2), 29, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (174, 0, CAST(N'2023-05-06T02:50:44.4881881' AS DateTime2), CAST(N'2023-05-06T02:50:44.4881883' AS DateTime2), CAST(N'2023-05-06T00:50:42.7860000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T02:50:44.4881813' AS DateTime2), 29, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (175, 0, CAST(N'2023-05-06T02:50:44.4881881' AS DateTime2), CAST(N'2023-05-06T02:50:44.4881883' AS DateTime2), CAST(N'2023-05-06T00:50:42.7860000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T02:50:44.4881813' AS DateTime2), 29, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (176, 0, CAST(N'2023-05-06T02:50:58.1489545' AS DateTime2), CAST(N'2023-05-06T02:50:58.1489546' AS DateTime2), CAST(N'2023-05-06T00:50:56.3910000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T02:50:58.1489455' AS DateTime2), 30, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (177, 0, CAST(N'2023-05-06T02:50:58.1489545' AS DateTime2), CAST(N'2023-05-06T02:50:58.1489546' AS DateTime2), CAST(N'2023-05-06T00:50:56.3910000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T02:50:58.1489455' AS DateTime2), 30, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (178, 0, CAST(N'2023-05-06T02:50:58.1489545' AS DateTime2), CAST(N'2023-05-06T02:50:58.1489546' AS DateTime2), CAST(N'2023-05-06T00:50:56.3910000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T02:50:58.1489455' AS DateTime2), 30, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (179, 0, CAST(N'2023-05-06T02:50:58.1489545' AS DateTime2), CAST(N'2023-05-06T02:50:58.1489546' AS DateTime2), CAST(N'2023-05-06T00:50:56.3910000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T02:50:58.1489455' AS DateTime2), 30, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (180, 0, CAST(N'2023-05-06T02:50:58.1489545' AS DateTime2), CAST(N'2023-05-06T02:50:58.1489546' AS DateTime2), CAST(N'2023-05-06T00:50:56.3910000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T02:50:58.1489455' AS DateTime2), 30, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (181, 0, CAST(N'2023-05-06T02:50:58.1489545' AS DateTime2), CAST(N'2023-05-06T02:50:58.1489546' AS DateTime2), CAST(N'2023-05-06T00:50:56.3910000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T02:50:58.1489455' AS DateTime2), 30, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (182, 0, CAST(N'2023-05-06T12:28:45.7484547' AS DateTime2), CAST(N'2023-05-06T12:28:45.7484548' AS DateTime2), CAST(N'2023-05-06T10:28:45.5080000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T12:28:45.7484476' AS DateTime2), 31, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (183, 0, CAST(N'2023-05-06T12:28:45.7484547' AS DateTime2), CAST(N'2023-05-06T12:28:45.7484548' AS DateTime2), CAST(N'2023-05-06T10:28:45.5080000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T12:28:45.7484476' AS DateTime2), 31, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (184, 0, CAST(N'2023-05-06T12:28:45.7484547' AS DateTime2), CAST(N'2023-05-06T12:28:45.7484548' AS DateTime2), CAST(N'2023-05-06T10:28:45.5080000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T12:28:45.7484476' AS DateTime2), 31, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (185, 0, CAST(N'2023-05-06T12:28:45.7484547' AS DateTime2), CAST(N'2023-05-06T12:28:45.7484548' AS DateTime2), CAST(N'2023-05-06T10:28:45.5080000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T12:28:45.7484476' AS DateTime2), 31, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (186, 0, CAST(N'2023-05-06T12:28:45.7484547' AS DateTime2), CAST(N'2023-05-06T12:28:45.7484548' AS DateTime2), CAST(N'2023-05-06T10:28:45.5080000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T12:28:45.7484476' AS DateTime2), 31, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (187, 0, CAST(N'2023-05-06T12:28:45.7484547' AS DateTime2), CAST(N'2023-05-06T12:28:45.7484548' AS DateTime2), CAST(N'2023-05-06T10:28:45.5080000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T12:28:45.7484476' AS DateTime2), 31, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (188, 0, CAST(N'2023-05-06T12:29:38.3248613' AS DateTime2), CAST(N'2023-05-06T12:29:38.3248614' AS DateTime2), CAST(N'2023-05-06T10:29:38.0750000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T12:29:38.3248565' AS DateTime2), 32, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (189, 0, CAST(N'2023-05-06T12:29:38.3248613' AS DateTime2), CAST(N'2023-05-06T12:29:38.3248614' AS DateTime2), CAST(N'2023-05-06T10:29:38.0750000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T12:29:38.3248565' AS DateTime2), 32, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (190, 0, CAST(N'2023-05-06T12:29:38.3248613' AS DateTime2), CAST(N'2023-05-06T12:29:38.3248614' AS DateTime2), CAST(N'2023-05-06T10:29:38.0750000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T12:29:38.3248565' AS DateTime2), 32, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (191, 0, CAST(N'2023-05-06T12:29:38.3248613' AS DateTime2), CAST(N'2023-05-06T12:29:38.3248614' AS DateTime2), CAST(N'2023-05-06T10:29:38.0750000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T12:29:38.3248565' AS DateTime2), 32, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (192, 0, CAST(N'2023-05-06T12:29:38.3248613' AS DateTime2), CAST(N'2023-05-06T12:29:38.3248614' AS DateTime2), CAST(N'2023-05-06T10:29:38.0750000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T12:29:38.3248565' AS DateTime2), 32, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (193, 0, CAST(N'2023-05-06T12:29:38.3248613' AS DateTime2), CAST(N'2023-05-06T12:29:38.3248614' AS DateTime2), CAST(N'2023-05-06T10:29:38.0750000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T12:29:38.3248565' AS DateTime2), 32, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (194, 0, CAST(N'2023-05-06T13:19:14.8599234' AS DateTime2), CAST(N'2023-05-06T13:19:14.8599236' AS DateTime2), CAST(N'2023-05-06T11:19:14.5330000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T13:19:14.8599157' AS DateTime2), 33, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (195, 0, CAST(N'2023-05-06T13:19:14.8599234' AS DateTime2), CAST(N'2023-05-06T13:19:14.8599236' AS DateTime2), CAST(N'2023-05-06T11:19:14.5330000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T13:19:14.8599157' AS DateTime2), 33, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (196, 0, CAST(N'2023-05-06T13:19:14.8599234' AS DateTime2), CAST(N'2023-05-06T13:19:14.8599236' AS DateTime2), CAST(N'2023-05-06T11:19:14.5330000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T13:19:14.8599157' AS DateTime2), 33, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (197, 0, CAST(N'2023-05-06T13:19:14.8599234' AS DateTime2), CAST(N'2023-05-06T13:19:14.8599236' AS DateTime2), CAST(N'2023-05-06T11:19:14.5330000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T13:19:14.8599157' AS DateTime2), 33, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (198, 0, CAST(N'2023-05-06T13:19:14.8599234' AS DateTime2), CAST(N'2023-05-06T13:19:14.8599236' AS DateTime2), CAST(N'2023-05-06T11:19:14.5330000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T13:19:14.8599157' AS DateTime2), 33, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (199, 0, CAST(N'2023-05-06T13:19:14.8599234' AS DateTime2), CAST(N'2023-05-06T13:19:14.8599236' AS DateTime2), CAST(N'2023-05-06T11:19:14.5330000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T13:19:14.8599157' AS DateTime2), 33, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (200, 0, CAST(N'2023-05-06T13:59:38.7991478' AS DateTime2), CAST(N'2023-05-06T13:59:38.7991479' AS DateTime2), CAST(N'2023-05-06T11:59:38.3640000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T13:59:38.7991403' AS DateTime2), 34, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (201, 0, CAST(N'2023-05-06T13:59:38.7991478' AS DateTime2), CAST(N'2023-05-06T13:59:38.7991479' AS DateTime2), CAST(N'2023-05-06T11:59:38.3640000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T13:59:38.7991403' AS DateTime2), 34, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (202, 0, CAST(N'2023-05-06T13:59:38.7991478' AS DateTime2), CAST(N'2023-05-06T13:59:38.7991479' AS DateTime2), CAST(N'2023-05-06T11:59:38.3640000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T13:59:38.7991403' AS DateTime2), 34, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (203, 0, CAST(N'2023-05-06T13:59:38.7991478' AS DateTime2), CAST(N'2023-05-06T13:59:38.7991479' AS DateTime2), CAST(N'2023-05-06T11:59:38.3640000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T13:59:38.7991403' AS DateTime2), 34, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (204, 0, CAST(N'2023-05-06T13:59:38.7991478' AS DateTime2), CAST(N'2023-05-06T13:59:38.7991479' AS DateTime2), CAST(N'2023-05-06T11:59:38.3640000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T13:59:38.7991403' AS DateTime2), 34, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (205, 0, CAST(N'2023-05-06T13:59:38.7991478' AS DateTime2), CAST(N'2023-05-06T13:59:38.7991479' AS DateTime2), CAST(N'2023-05-06T11:59:38.3640000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T13:59:38.7991403' AS DateTime2), 34, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (206, 0, CAST(N'2023-05-06T16:39:08.8693304' AS DateTime2), CAST(N'2023-05-06T16:39:08.8693306' AS DateTime2), CAST(N'2023-05-06T14:39:08.1790000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T16:39:08.8693210' AS DateTime2), 35, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (207, 0, CAST(N'2023-05-06T16:39:08.8693304' AS DateTime2), CAST(N'2023-05-06T16:39:08.8693306' AS DateTime2), CAST(N'2023-05-06T14:39:08.1790000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T16:39:08.8693210' AS DateTime2), 35, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (208, 0, CAST(N'2023-05-06T16:39:08.8693304' AS DateTime2), CAST(N'2023-05-06T16:39:08.8693306' AS DateTime2), CAST(N'2023-05-06T14:39:08.1790000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T16:39:08.8693210' AS DateTime2), 35, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (209, 0, CAST(N'2023-05-06T16:39:08.8693304' AS DateTime2), CAST(N'2023-05-06T16:39:08.8693306' AS DateTime2), CAST(N'2023-05-06T14:39:08.1790000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T16:39:08.8693210' AS DateTime2), 35, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (210, 0, CAST(N'2023-05-06T16:39:08.8693304' AS DateTime2), CAST(N'2023-05-06T16:39:08.8693306' AS DateTime2), CAST(N'2023-05-06T14:39:08.1790000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T16:39:08.8693210' AS DateTime2), 35, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (211, 0, CAST(N'2023-05-06T16:39:08.8693304' AS DateTime2), CAST(N'2023-05-06T16:39:08.8693306' AS DateTime2), CAST(N'2023-05-06T14:39:08.1790000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T16:39:08.8693210' AS DateTime2), 35, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (212, 0, CAST(N'2023-05-06T16:39:52.0286322' AS DateTime2), CAST(N'2023-05-06T16:39:52.0286324' AS DateTime2), CAST(N'2023-05-06T14:39:51.3490000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-06T16:39:52.0286238' AS DateTime2), 36, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (213, 0, CAST(N'2023-05-06T16:39:52.0286322' AS DateTime2), CAST(N'2023-05-06T16:39:52.0286324' AS DateTime2), CAST(N'2023-05-06T14:39:51.3490000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-06T16:39:52.0286238' AS DateTime2), 36, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (214, 0, CAST(N'2023-05-06T16:39:52.0286322' AS DateTime2), CAST(N'2023-05-06T16:39:52.0286324' AS DateTime2), CAST(N'2023-05-06T14:39:51.3490000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-06T16:39:52.0286238' AS DateTime2), 36, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (215, 0, CAST(N'2023-05-06T16:39:52.0286322' AS DateTime2), CAST(N'2023-05-06T16:39:52.0286324' AS DateTime2), CAST(N'2023-05-06T14:39:51.3490000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-06T16:39:52.0286238' AS DateTime2), 36, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (216, 0, CAST(N'2023-05-06T16:39:52.0286322' AS DateTime2), CAST(N'2023-05-06T16:39:52.0286324' AS DateTime2), CAST(N'2023-05-06T14:39:51.3490000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-06T16:39:52.0286238' AS DateTime2), 36, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (217, 0, CAST(N'2023-05-06T16:39:52.0286322' AS DateTime2), CAST(N'2023-05-06T16:39:52.0286324' AS DateTime2), CAST(N'2023-05-06T14:39:51.3490000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-06T16:39:52.0286238' AS DateTime2), 36, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (218, 0, CAST(N'2023-05-07T16:34:51.2226894' AS DateTime2), CAST(N'2023-05-07T16:34:51.2226896' AS DateTime2), CAST(N'2023-05-07T14:34:50.0120000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T16:34:51.2226818' AS DateTime2), 37, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (219, 0, CAST(N'2023-05-07T16:34:51.2226894' AS DateTime2), CAST(N'2023-05-07T16:34:51.2226896' AS DateTime2), CAST(N'2023-05-07T14:34:50.0120000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T16:34:51.2226818' AS DateTime2), 37, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (220, 0, CAST(N'2023-05-07T16:34:51.2226894' AS DateTime2), CAST(N'2023-05-07T16:34:51.2226896' AS DateTime2), CAST(N'2023-05-07T14:34:50.0120000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T16:34:51.2226818' AS DateTime2), 37, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (221, 0, CAST(N'2023-05-07T16:34:51.2226894' AS DateTime2), CAST(N'2023-05-07T16:34:51.2226896' AS DateTime2), CAST(N'2023-05-07T14:34:50.0120000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T16:34:51.2226818' AS DateTime2), 37, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (222, 0, CAST(N'2023-05-07T16:34:51.2226894' AS DateTime2), CAST(N'2023-05-07T16:34:51.2226896' AS DateTime2), CAST(N'2023-05-07T14:34:50.0120000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T16:34:51.2226818' AS DateTime2), 37, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (223, 0, CAST(N'2023-05-07T16:34:51.2226894' AS DateTime2), CAST(N'2023-05-07T16:34:51.2226896' AS DateTime2), CAST(N'2023-05-07T14:34:50.0120000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T16:34:51.2226818' AS DateTime2), 37, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (224, 0, CAST(N'2023-05-07T16:35:08.2008348' AS DateTime2), CAST(N'2023-05-07T16:35:08.2008349' AS DateTime2), CAST(N'2023-05-07T14:35:07.0360000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T16:35:08.2008290' AS DateTime2), 38, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (225, 0, CAST(N'2023-05-07T16:35:08.2008348' AS DateTime2), CAST(N'2023-05-07T16:35:08.2008349' AS DateTime2), CAST(N'2023-05-07T14:35:07.0360000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T16:35:08.2008290' AS DateTime2), 38, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (226, 0, CAST(N'2023-05-07T16:35:08.2008348' AS DateTime2), CAST(N'2023-05-07T16:35:08.2008349' AS DateTime2), CAST(N'2023-05-07T14:35:07.0360000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T16:35:08.2008290' AS DateTime2), 38, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (227, 0, CAST(N'2023-05-07T16:35:08.2008348' AS DateTime2), CAST(N'2023-05-07T16:35:08.2008349' AS DateTime2), CAST(N'2023-05-07T14:35:07.0360000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T16:35:08.2008290' AS DateTime2), 38, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (228, 0, CAST(N'2023-05-07T16:35:08.2008348' AS DateTime2), CAST(N'2023-05-07T16:35:08.2008349' AS DateTime2), CAST(N'2023-05-07T14:35:07.0360000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T16:35:08.2008290' AS DateTime2), 38, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (229, 0, CAST(N'2023-05-07T16:35:08.2008348' AS DateTime2), CAST(N'2023-05-07T16:35:08.2008349' AS DateTime2), CAST(N'2023-05-07T14:35:07.0360000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T16:35:08.2008290' AS DateTime2), 38, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (230, 0, CAST(N'2023-05-07T16:35:25.4975775' AS DateTime2), CAST(N'2023-05-07T16:35:25.4975776' AS DateTime2), CAST(N'2023-05-07T14:35:24.3300000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T16:35:25.4975697' AS DateTime2), 39, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (231, 0, CAST(N'2023-05-07T16:35:25.4975775' AS DateTime2), CAST(N'2023-05-07T16:35:25.4975776' AS DateTime2), CAST(N'2023-05-07T14:35:24.3300000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T16:35:25.4975697' AS DateTime2), 39, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (232, 0, CAST(N'2023-05-07T16:35:25.4975775' AS DateTime2), CAST(N'2023-05-07T16:35:25.4975776' AS DateTime2), CAST(N'2023-05-07T14:35:24.3300000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T16:35:25.4975697' AS DateTime2), 39, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (233, 0, CAST(N'2023-05-07T16:35:25.4975775' AS DateTime2), CAST(N'2023-05-07T16:35:25.4975776' AS DateTime2), CAST(N'2023-05-07T14:35:24.3300000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T16:35:25.4975697' AS DateTime2), 39, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (234, 0, CAST(N'2023-05-07T16:35:25.4975775' AS DateTime2), CAST(N'2023-05-07T16:35:25.4975776' AS DateTime2), CAST(N'2023-05-07T14:35:24.3300000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T16:35:25.4975697' AS DateTime2), 39, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (235, 0, CAST(N'2023-05-07T16:35:25.4975775' AS DateTime2), CAST(N'2023-05-07T16:35:25.4975776' AS DateTime2), CAST(N'2023-05-07T14:35:24.3300000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T16:35:25.4975697' AS DateTime2), 39, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (236, 0, CAST(N'2023-05-07T17:35:34.5349655' AS DateTime2), CAST(N'2023-05-07T17:35:34.5349657' AS DateTime2), CAST(N'2023-05-07T15:35:35.3950000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T17:35:34.5349591' AS DateTime2), 40, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (237, 0, CAST(N'2023-05-07T17:35:34.5349655' AS DateTime2), CAST(N'2023-05-07T17:35:34.5349657' AS DateTime2), CAST(N'2023-05-07T15:35:35.3950000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T17:35:34.5349591' AS DateTime2), 40, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (238, 0, CAST(N'2023-05-07T17:35:34.5349655' AS DateTime2), CAST(N'2023-05-07T17:35:34.5349657' AS DateTime2), CAST(N'2023-05-07T15:35:35.3950000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T17:35:34.5349591' AS DateTime2), 40, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (239, 0, CAST(N'2023-05-07T17:35:34.5349655' AS DateTime2), CAST(N'2023-05-07T17:35:34.5349657' AS DateTime2), CAST(N'2023-05-07T15:35:35.3950000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T17:35:34.5349591' AS DateTime2), 40, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (240, 0, CAST(N'2023-05-07T17:35:34.5349655' AS DateTime2), CAST(N'2023-05-07T17:35:34.5349657' AS DateTime2), CAST(N'2023-05-07T15:35:35.3950000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T17:35:34.5349591' AS DateTime2), 40, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (241, 0, CAST(N'2023-05-07T17:35:34.5349655' AS DateTime2), CAST(N'2023-05-07T17:35:34.5349657' AS DateTime2), CAST(N'2023-05-07T15:35:35.3950000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T17:35:34.5349591' AS DateTime2), 40, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (242, 0, CAST(N'2023-05-07T17:35:55.0408443' AS DateTime2), CAST(N'2023-05-07T17:35:55.0408444' AS DateTime2), CAST(N'2023-05-07T15:35:55.9090000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T17:35:55.0408378' AS DateTime2), 41, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (243, 0, CAST(N'2023-05-07T17:35:55.0408443' AS DateTime2), CAST(N'2023-05-07T17:35:55.0408444' AS DateTime2), CAST(N'2023-05-07T15:35:55.9090000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T17:35:55.0408378' AS DateTime2), 41, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (244, 0, CAST(N'2023-05-07T17:35:55.0408443' AS DateTime2), CAST(N'2023-05-07T17:35:55.0408444' AS DateTime2), CAST(N'2023-05-07T15:35:55.9090000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T17:35:55.0408378' AS DateTime2), 41, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (245, 0, CAST(N'2023-05-07T17:35:55.0408443' AS DateTime2), CAST(N'2023-05-07T17:35:55.0408444' AS DateTime2), CAST(N'2023-05-07T15:35:55.9090000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T17:35:55.0408378' AS DateTime2), 41, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (246, 0, CAST(N'2023-05-07T17:35:55.0408443' AS DateTime2), CAST(N'2023-05-07T17:35:55.0408444' AS DateTime2), CAST(N'2023-05-07T15:35:55.9090000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T17:35:55.0408378' AS DateTime2), 41, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (247, 0, CAST(N'2023-05-07T17:35:55.0408443' AS DateTime2), CAST(N'2023-05-07T17:35:55.0408444' AS DateTime2), CAST(N'2023-05-07T15:35:55.9090000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T17:35:55.0408378' AS DateTime2), 41, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (248, 0, CAST(N'2023-05-07T17:38:23.2470136' AS DateTime2), CAST(N'2023-05-07T17:38:23.2470137' AS DateTime2), CAST(N'2023-05-07T15:38:24.1130000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T17:38:23.2470073' AS DateTime2), 42, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (249, 0, CAST(N'2023-05-07T17:38:23.2470136' AS DateTime2), CAST(N'2023-05-07T17:38:23.2470137' AS DateTime2), CAST(N'2023-05-07T15:38:24.1130000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T17:38:23.2470073' AS DateTime2), 42, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (250, 0, CAST(N'2023-05-07T17:38:23.2470136' AS DateTime2), CAST(N'2023-05-07T17:38:23.2470137' AS DateTime2), CAST(N'2023-05-07T15:38:24.1130000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T17:38:23.2470073' AS DateTime2), 42, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (251, 0, CAST(N'2023-05-07T17:38:23.2470136' AS DateTime2), CAST(N'2023-05-07T17:38:23.2470137' AS DateTime2), CAST(N'2023-05-07T15:38:24.1130000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T17:38:23.2470073' AS DateTime2), 42, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (252, 0, CAST(N'2023-05-07T17:38:23.2470136' AS DateTime2), CAST(N'2023-05-07T17:38:23.2470137' AS DateTime2), CAST(N'2023-05-07T15:38:24.1130000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T17:38:23.2470073' AS DateTime2), 42, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (253, 0, CAST(N'2023-05-07T17:38:23.2470136' AS DateTime2), CAST(N'2023-05-07T17:38:23.2470137' AS DateTime2), CAST(N'2023-05-07T15:38:24.1130000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T17:38:23.2470073' AS DateTime2), 42, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (254, 0, CAST(N'2023-05-07T17:48:25.7976542' AS DateTime2), CAST(N'2023-05-07T17:48:25.7976543' AS DateTime2), CAST(N'2023-05-07T15:48:24.2560000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T17:48:25.7976458' AS DateTime2), 43, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (255, 0, CAST(N'2023-05-07T17:48:25.7976542' AS DateTime2), CAST(N'2023-05-07T17:48:25.7976543' AS DateTime2), CAST(N'2023-05-07T15:48:24.2560000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T17:48:25.7976458' AS DateTime2), 43, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (256, 0, CAST(N'2023-05-07T17:48:25.7976542' AS DateTime2), CAST(N'2023-05-07T17:48:25.7976543' AS DateTime2), CAST(N'2023-05-07T15:48:24.2560000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T17:48:25.7976458' AS DateTime2), 43, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (257, 0, CAST(N'2023-05-07T17:48:25.7976542' AS DateTime2), CAST(N'2023-05-07T17:48:25.7976543' AS DateTime2), CAST(N'2023-05-07T15:48:24.2560000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T17:48:25.7976458' AS DateTime2), 43, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (258, 0, CAST(N'2023-05-07T17:48:25.7976542' AS DateTime2), CAST(N'2023-05-07T17:48:25.7976543' AS DateTime2), CAST(N'2023-05-07T15:48:24.2560000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T17:48:25.7976458' AS DateTime2), 43, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (259, 0, CAST(N'2023-05-07T17:48:25.7976542' AS DateTime2), CAST(N'2023-05-07T17:48:25.7976543' AS DateTime2), CAST(N'2023-05-07T15:48:24.2560000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T17:48:25.7976458' AS DateTime2), 43, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (260, 0, CAST(N'2023-05-07T18:59:52.6851733' AS DateTime2), CAST(N'2023-05-07T18:59:52.6851734' AS DateTime2), CAST(N'2023-05-07T16:59:51.0220000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T18:59:52.6851677' AS DateTime2), 44, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (261, 0, CAST(N'2023-05-07T18:59:52.6851733' AS DateTime2), CAST(N'2023-05-07T18:59:52.6851734' AS DateTime2), CAST(N'2023-05-07T16:59:51.0220000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T18:59:52.6851677' AS DateTime2), 44, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (262, 0, CAST(N'2023-05-07T18:59:52.6851733' AS DateTime2), CAST(N'2023-05-07T18:59:52.6851734' AS DateTime2), CAST(N'2023-05-07T16:59:51.0220000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T18:59:52.6851677' AS DateTime2), 44, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (263, 0, CAST(N'2023-05-07T18:59:52.6851733' AS DateTime2), CAST(N'2023-05-07T18:59:52.6851734' AS DateTime2), CAST(N'2023-05-07T16:59:51.0220000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T18:59:52.6851677' AS DateTime2), 44, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (264, 0, CAST(N'2023-05-07T18:59:52.6851733' AS DateTime2), CAST(N'2023-05-07T18:59:52.6851734' AS DateTime2), CAST(N'2023-05-07T16:59:51.0220000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T18:59:52.6851677' AS DateTime2), 44, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (265, 0, CAST(N'2023-05-07T18:59:52.6851733' AS DateTime2), CAST(N'2023-05-07T18:59:52.6851734' AS DateTime2), CAST(N'2023-05-07T16:59:51.0220000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T18:59:52.6851677' AS DateTime2), 44, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (266, 0, CAST(N'2023-05-07T19:00:08.1438476' AS DateTime2), CAST(N'2023-05-07T19:00:08.1438477' AS DateTime2), CAST(N'2023-05-07T17:00:06.4780000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T19:00:08.1438412' AS DateTime2), 45, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (267, 0, CAST(N'2023-05-07T19:00:08.1438476' AS DateTime2), CAST(N'2023-05-07T19:00:08.1438477' AS DateTime2), CAST(N'2023-05-07T17:00:06.4780000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T19:00:08.1438412' AS DateTime2), 45, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (268, 0, CAST(N'2023-05-07T19:00:08.1438476' AS DateTime2), CAST(N'2023-05-07T19:00:08.1438477' AS DateTime2), CAST(N'2023-05-07T17:00:06.4780000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T19:00:08.1438412' AS DateTime2), 45, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (269, 0, CAST(N'2023-05-07T19:00:08.1438476' AS DateTime2), CAST(N'2023-05-07T19:00:08.1438477' AS DateTime2), CAST(N'2023-05-07T17:00:06.4780000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T19:00:08.1438412' AS DateTime2), 45, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (270, 0, CAST(N'2023-05-07T19:00:08.1438476' AS DateTime2), CAST(N'2023-05-07T19:00:08.1438477' AS DateTime2), CAST(N'2023-05-07T17:00:06.4780000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T19:00:08.1438412' AS DateTime2), 45, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (271, 0, CAST(N'2023-05-07T19:00:08.1438476' AS DateTime2), CAST(N'2023-05-07T19:00:08.1438477' AS DateTime2), CAST(N'2023-05-07T17:00:06.4780000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T19:00:08.1438412' AS DateTime2), 45, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (272, 0, CAST(N'2023-05-07T19:00:26.9062560' AS DateTime2), CAST(N'2023-05-07T19:00:26.9062561' AS DateTime2), CAST(N'2023-05-07T17:00:25.2440000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T19:00:26.9062503' AS DateTime2), 46, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (273, 0, CAST(N'2023-05-07T19:00:26.9062560' AS DateTime2), CAST(N'2023-05-07T19:00:26.9062561' AS DateTime2), CAST(N'2023-05-07T17:00:25.2440000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T19:00:26.9062503' AS DateTime2), 46, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (274, 0, CAST(N'2023-05-07T19:00:26.9062560' AS DateTime2), CAST(N'2023-05-07T19:00:26.9062561' AS DateTime2), CAST(N'2023-05-07T17:00:25.2440000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T19:00:26.9062503' AS DateTime2), 46, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (275, 0, CAST(N'2023-05-07T19:00:26.9062560' AS DateTime2), CAST(N'2023-05-07T19:00:26.9062561' AS DateTime2), CAST(N'2023-05-07T17:00:25.2440000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T19:00:26.9062503' AS DateTime2), 46, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (276, 0, CAST(N'2023-05-07T19:00:26.9062560' AS DateTime2), CAST(N'2023-05-07T19:00:26.9062561' AS DateTime2), CAST(N'2023-05-07T17:00:25.2440000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T19:00:26.9062503' AS DateTime2), 46, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (277, 0, CAST(N'2023-05-07T19:00:26.9062560' AS DateTime2), CAST(N'2023-05-07T19:00:26.9062561' AS DateTime2), CAST(N'2023-05-07T17:00:25.2440000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T19:00:26.9062503' AS DateTime2), 46, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (278, 0, CAST(N'2023-05-07T19:00:28.5241342' AS DateTime2), CAST(N'2023-05-07T19:00:28.5241344' AS DateTime2), CAST(N'2023-05-07T17:00:26.8630000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T19:00:28.5241289' AS DateTime2), 47, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (279, 0, CAST(N'2023-05-07T19:00:28.5241342' AS DateTime2), CAST(N'2023-05-07T19:00:28.5241344' AS DateTime2), CAST(N'2023-05-07T17:00:26.8630000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T19:00:28.5241289' AS DateTime2), 47, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (280, 0, CAST(N'2023-05-07T19:00:28.5241342' AS DateTime2), CAST(N'2023-05-07T19:00:28.5241344' AS DateTime2), CAST(N'2023-05-07T17:00:26.8630000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T19:00:28.5241289' AS DateTime2), 47, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (281, 0, CAST(N'2023-05-07T19:00:28.5241342' AS DateTime2), CAST(N'2023-05-07T19:00:28.5241344' AS DateTime2), CAST(N'2023-05-07T17:00:26.8630000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T19:00:28.5241289' AS DateTime2), 47, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (282, 0, CAST(N'2023-05-07T19:00:28.5241342' AS DateTime2), CAST(N'2023-05-07T19:00:28.5241344' AS DateTime2), CAST(N'2023-05-07T17:00:26.8630000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T19:00:28.5241289' AS DateTime2), 47, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (283, 0, CAST(N'2023-05-07T19:00:28.5241342' AS DateTime2), CAST(N'2023-05-07T19:00:28.5241344' AS DateTime2), CAST(N'2023-05-07T17:00:26.8630000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T19:00:28.5241289' AS DateTime2), 47, NULL, 9, 45)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (284, 0, CAST(N'2023-05-07T19:00:35.6570743' AS DateTime2), CAST(N'2023-05-07T19:00:35.6570744' AS DateTime2), CAST(N'2023-05-07T17:00:33.9350000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(1.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-06-07T19:00:35.6570674' AS DateTime2), 48, NULL, 1, 1)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (285, 0, CAST(N'2023-05-07T19:00:35.6570743' AS DateTime2), CAST(N'2023-05-07T19:00:35.6570744' AS DateTime2), CAST(N'2023-05-07T17:00:33.9350000' AS DateTime2), N'Internal Timber Joinery', CAST(1.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-06-07T19:00:35.6570674' AS DateTime2), 48, NULL, 1, 4)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (286, 0, CAST(N'2023-05-07T19:00:35.6570743' AS DateTime2), CAST(N'2023-05-07T19:00:35.6570744' AS DateTime2), CAST(N'2023-05-07T17:00:33.9350000' AS DateTime2), N'Machine work', CAST(1.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-06-07T19:00:35.6570674' AS DateTime2), 48, NULL, 1, 5)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (287, 0, CAST(N'2023-05-07T19:00:35.6570743' AS DateTime2), CAST(N'2023-05-07T19:00:35.6570744' AS DateTime2), CAST(N'2023-05-07T17:00:33.9350000' AS DateTime2), N'Roofing and Roof Coverings', CAST(1.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-06-07T19:00:35.6570674' AS DateTime2), 48, NULL, 1, 7)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (288, 0, CAST(N'2023-05-07T19:00:35.6570743' AS DateTime2), CAST(N'2023-05-07T19:00:35.6570744' AS DateTime2), CAST(N'2023-05-07T17:00:33.9350000' AS DateTime2), N'Spray Painting', CAST(1.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-06-07T19:00:35.6570674' AS DateTime2), 48, NULL, 9, 43)
GO
INSERT [dbo].[FundiSubscriptionQueues] ([FundiSubscriptionQueueId], [HasPaid], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionQueueId], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (289, 0, CAST(N'2023-05-07T19:00:35.6570743' AS DateTime2), CAST(N'2023-05-07T19:00:35.6570744' AS DateTime2), CAST(N'2023-05-07T17:00:33.9350000' AS DateTime2), N'Textured Paint', CAST(1.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-06-07T19:00:35.6570674' AS DateTime2), 48, NULL, 9, 45)
GO
SET IDENTITY_INSERT [dbo].[FundiSubscriptionQueues] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiSubscriptions] ON 
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (283, CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T16:18:13.6180000' AS DateTime2), N'Board Fittings and Cabinetry', CAST(20000.00 AS Decimal(18, 2)), N'Board Fittings and Cabinetry
', CAST(N'2023-03-29T18:18:07.3896758' AS DateTime2), 99, 1, 1)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (284, CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T16:18:13.6180000' AS DateTime2), N'Internal Timber Joinery', CAST(20000.00 AS Decimal(18, 2)), N'Internal Timber Joinery
', CAST(N'2023-03-29T18:18:07.3896758' AS DateTime2), 99, 1, 4)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (285, CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T16:18:13.6180000' AS DateTime2), N'Machine work', CAST(20000.00 AS Decimal(18, 2)), N'Machine work
', CAST(N'2023-03-29T18:18:07.3896758' AS DateTime2), 99, 1, 5)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (286, CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T16:18:13.6180000' AS DateTime2), N'Roofing and Roof Coverings', CAST(20000.00 AS Decimal(18, 2)), N'Roofing and Roof Coverings
', CAST(N'2023-03-29T18:18:07.3896758' AS DateTime2), 99, 1, 7)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (287, CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T16:18:13.6180000' AS DateTime2), N'Spray Painting', CAST(20000.00 AS Decimal(18, 2)), N'Spray Painting
', CAST(N'2023-03-29T18:18:07.3896758' AS DateTime2), 99, 9, 43)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (288, CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T18:18:07.3896767' AS DateTime2), CAST(N'2023-02-26T16:18:13.6180000' AS DateTime2), N'Textured Paint', CAST(20000.00 AS Decimal(18, 2)), N'Textured Paint
', CAST(N'2023-03-29T18:18:07.3896758' AS DateTime2), 99, 9, 45)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (301, CAST(N'2023-02-26T20:25:12.2684624' AS DateTime2), CAST(N'2023-02-26T19:48:41.1496817' AS DateTime2), CAST(N'2023-02-26T14:02:17.4730000' AS DateTime2), N'Low Voltage installations', CAST(25000.00 AS Decimal(18, 2)), N'Low Voltage installation
', CAST(N'2023-03-29T14:02:17.5128951' AS DateTime2), 95, 2, 9)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (302, CAST(N'2023-02-26T20:25:12.2684624' AS DateTime2), CAST(N'2023-02-26T19:48:41.1496817' AS DateTime2), CAST(N'2023-02-26T14:02:17.4730000' AS DateTime2), N'High Voltage installations', CAST(23000.00 AS Decimal(18, 2)), N'High Voltage installations
', CAST(N'2023-03-29T14:02:17.5128951' AS DateTime2), 95, 2, 8)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (303, CAST(N'2023-02-26T20:25:12.2684624' AS DateTime2), CAST(N'2023-02-26T19:48:41.1496817' AS DateTime2), CAST(N'2023-02-26T14:02:17.4730000' AS DateTime2), N'Pumps and Pumping Systems', CAST(20000.00 AS Decimal(18, 2)), N'Pumps and Pumping Systems
', CAST(N'2023-03-29T14:02:17.5128951' AS DateTime2), 95, 10, 47)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (304, CAST(N'2023-02-26T20:25:12.2684624' AS DateTime2), CAST(N'2023-02-26T19:48:41.1496817' AS DateTime2), CAST(N'2023-02-26T14:02:17.4730000' AS DateTime2), N'Internal Plumbing', CAST(20000.00 AS Decimal(18, 2)), N'Internal Plumbing
', CAST(N'2023-03-29T14:02:17.5128951' AS DateTime2), 95, 10, 48)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (305, CAST(N'2023-02-26T20:25:12.2684624' AS DateTime2), CAST(N'2023-02-26T19:48:41.1496817' AS DateTime2), CAST(N'2023-02-26T14:02:17.4730000' AS DateTime2), N'External Plumbing', CAST(20000.00 AS Decimal(18, 2)), N'External Plumbing
', CAST(N'2023-03-29T14:02:17.5128951' AS DateTime2), 95, 10, 49)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (306, CAST(N'2023-02-26T20:25:12.2684624' AS DateTime2), CAST(N'2023-02-26T19:48:41.1496817' AS DateTime2), CAST(N'2023-02-26T14:02:17.4730000' AS DateTime2), N'Brick layer', CAST(20000.00 AS Decimal(18, 2)), N'Brick layer
', CAST(N'2023-03-29T14:02:17.5128951' AS DateTime2), 95, 6, 30)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (322, CAST(N'2023-03-04T04:44:14.2871166' AS DateTime2), CAST(N'2023-03-04T04:44:14.2871166' AS DateTime2), CAST(N'2023-03-04T02:44:09.4980000' AS DateTime2), N'Repair - Household Appliances', CAST(20000.00 AS Decimal(18, 2)), N'Repair - Household Appliances
', CAST(N'2023-04-04T04:44:14.2871123' AS DateTime2), 102, 2, 10)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (323, CAST(N'2023-03-04T04:44:14.2871166' AS DateTime2), CAST(N'2023-03-04T04:44:14.2871166' AS DateTime2), CAST(N'2023-03-04T02:44:09.4980000' AS DateTime2), N'Repair - Power Tools', CAST(20000.00 AS Decimal(18, 2)), N'Repair - Power Tools
', CAST(N'2023-04-04T04:44:14.2871123' AS DateTime2), 102, 2, 11)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (325, CAST(N'2023-03-26T02:16:10.6945988' AS DateTime2), CAST(N'2023-03-26T02:16:10.6945989' AS DateTime2), CAST(N'2023-03-26T00:16:10.6190000' AS DateTime2), N'High Voltage installations', CAST(25000.00 AS Decimal(18, 2)), N'High Voltage installations
', CAST(N'2023-04-26T02:16:10.6945706' AS DateTime2), 102, 2, 8)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (326, CAST(N'2023-03-26T02:16:10.6945988' AS DateTime2), CAST(N'2023-03-26T02:16:10.6945989' AS DateTime2), CAST(N'2023-03-26T00:16:10.6190000' AS DateTime2), N'Low Voltage installations', CAST(23000.00 AS Decimal(18, 2)), N'Low Voltage installation
', CAST(N'2023-04-26T02:16:10.6945706' AS DateTime2), 102, 2, 9)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (327, CAST(N'2023-03-26T02:16:10.6945988' AS DateTime2), CAST(N'2023-03-26T02:16:10.6945989' AS DateTime2), CAST(N'2023-03-26T00:16:10.6190000' AS DateTime2), N'Repair - Household Appliances', CAST(20000.00 AS Decimal(18, 2)), N'Repair - Household Appliances
', CAST(N'2023-04-26T02:16:10.6945706' AS DateTime2), 102, 2, 10)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (328, CAST(N'2023-03-26T02:16:10.6945988' AS DateTime2), CAST(N'2023-03-26T02:16:10.6945989' AS DateTime2), CAST(N'2023-03-26T00:16:10.6190000' AS DateTime2), N'High Voltage installations', CAST(25000.00 AS Decimal(18, 2)), N'High Voltage installations
', CAST(N'2023-04-26T02:16:10.6945706' AS DateTime2), 103, 2, 8)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (329, CAST(N'2023-03-26T02:16:10.6945988' AS DateTime2), CAST(N'2023-03-26T02:16:10.6945989' AS DateTime2), CAST(N'2023-03-26T00:16:10.6190000' AS DateTime2), N'Low Voltage installations', CAST(23000.00 AS Decimal(18, 2)), N'Low Voltage installation
', CAST(N'2023-04-26T02:16:10.6945706' AS DateTime2), 103, 2, 9)
GO
INSERT [dbo].[FundiSubscriptions] ([FundiSubscriptionId], [DateCreated], [DateUpdated], [StartDate], [SubscriptionName], [SubscriptionFee], [SubscriptionDescription], [EndDate], [MonthlySubscriptionId], [FundiWorkCategoryId], [FundiWorkSubCategoryId]) VALUES (330, CAST(N'2023-03-26T02:16:10.6945988' AS DateTime2), CAST(N'2023-03-26T02:16:10.6945989' AS DateTime2), CAST(N'2023-03-26T00:16:10.6190000' AS DateTime2), N'Repair - Household Appliances', CAST(20000.00 AS Decimal(18, 2)), N'Repair - Household Appliances
', CAST(N'2023-04-26T02:16:10.6945706' AS DateTime2), 103, 2, 10)
GO
SET IDENTITY_INSERT [dbo].[FundiSubscriptions] OFF
GO
SET IDENTITY_INSERT [dbo].[FundiWorkCategories] ON 
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (2, 3, 2, 9, NULL, CAST(N'2022-11-29T13:37:55.1028459' AS DateTime2), CAST(N'2022-11-29T13:37:55.1028463' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (4, 4, 2, 9, NULL, CAST(N'2022-11-29T15:30:26.2721126' AS DateTime2), CAST(N'2022-11-29T15:30:26.2721126' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (5, 3, 10, 48, NULL, CAST(N'2022-12-03T11:34:42.9611842' AS DateTime2), CAST(N'2022-12-03T11:34:42.9611847' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (6, 14, 1, 1, NULL, CAST(N'2023-01-25T20:21:58.1503893' AS DateTime2), CAST(N'2023-01-25T20:21:58.1503898' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (7, 14, 2, 8, NULL, CAST(N'2023-01-25T20:22:13.1691006' AS DateTime2), CAST(N'2023-01-25T20:22:13.1691011' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (8, 14, 5, 29, NULL, CAST(N'2023-01-25T20:23:32.0248554' AS DateTime2), CAST(N'2023-01-25T20:23:32.0248564' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (9, 14, 6, 30, NULL, CAST(N'2023-01-25T20:23:55.0796703' AS DateTime2), CAST(N'2023-01-25T20:23:55.0796708' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (10, 14, 8, 38, NULL, CAST(N'2023-01-25T20:24:14.4760866' AS DateTime2), CAST(N'2023-01-25T20:24:14.4760871' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (11, 14, 10, 47, NULL, CAST(N'2023-01-25T20:24:26.1566441' AS DateTime2), CAST(N'2023-01-25T20:24:26.1566446' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (12, 4, 10, 47, NULL, CAST(N'2023-02-20T11:07:24.0940508' AS DateTime2), CAST(N'2023-02-20T11:07:24.0940513' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (13, 4, 12, 70, NULL, CAST(N'2023-02-20T23:17:43.7761396' AS DateTime2), CAST(N'2023-02-20T23:17:43.7761401' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (14, 15, 2, 8, NULL, CAST(N'2023-03-26T00:25:53.1451448' AS DateTime2), CAST(N'2023-03-26T00:25:53.1451453' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (15, 17, 2, 9, NULL, CAST(N'2023-03-27T19:38:46.3555109' AS DateTime2), CAST(N'2023-03-27T19:38:46.3555113' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (16, 4, 2, 8, NULL, CAST(N'2023-04-30T17:11:41.9978745' AS DateTime2), CAST(N'2023-04-30T17:11:41.9978754' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (17, 4, 2, 10, NULL, CAST(N'2023-04-30T17:11:53.0407836' AS DateTime2), CAST(N'2023-04-30T17:11:53.0407842' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (18, 4, 10, 48, NULL, CAST(N'2023-04-30T17:12:09.4938536' AS DateTime2), CAST(N'2023-04-30T17:12:09.4938541' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (19, 4, 10, 49, NULL, CAST(N'2023-04-30T17:12:23.1352073' AS DateTime2), CAST(N'2023-04-30T17:12:23.1352079' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (20, 15, 2, 9, NULL, CAST(N'2023-04-30T22:41:05.0383423' AS DateTime2), CAST(N'2023-04-30T22:41:05.0383429' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (22, 15, 9, 46, NULL, CAST(N'2023-04-30T22:41:44.7358853' AS DateTime2), CAST(N'2023-04-30T22:41:44.7358858' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (23, 15, 9, 45, NULL, CAST(N'2023-04-30T22:41:54.2270466' AS DateTime2), CAST(N'2023-04-30T22:41:54.2270471' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (24, 15, 8, 39, NULL, CAST(N'2023-04-30T22:42:07.3591643' AS DateTime2), CAST(N'2023-04-30T22:42:07.3591649' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (25, 15, 4, 16, NULL, CAST(N'2023-04-30T22:42:27.0393121' AS DateTime2), CAST(N'2023-04-30T22:42:27.0393128' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (26, 15, 10, 48, NULL, CAST(N'2023-04-30T22:42:39.5829734' AS DateTime2), CAST(N'2023-04-30T22:42:39.5829739' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (29, 15, 6, 31, NULL, CAST(N'2023-04-30T22:43:39.6744149' AS DateTime2), CAST(N'2023-04-30T22:43:39.6744154' AS DateTime2))
GO
INSERT [dbo].[FundiWorkCategories] ([FundiWorkCategoryId], [FundiProfileId], [WorkCategoryId], [WorkSubCategoryId], [JobId], [DateCreated], [DateUpdated]) VALUES (30, 15, 6, 30, NULL, CAST(N'2023-04-30T22:43:56.4389605' AS DateTime2), CAST(N'2023-04-30T22:43:56.4389611' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[FundiWorkCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[Jobs] ON 
GO
INSERT [dbo].[Jobs] ([JobId], [JobName], [JobDescription], [LocationId], [ClientProfileId], [ClientUserId], [AssignedFundiUserId], [AssignedFundiProfileId], [HasBeenAssignedFundi], [HasCompleted], [NumberOfDaysToComplete], [DateCreated], [DateUpdated]) VALUES (6, N'Jonathan Asante-Jonathan'' Gulu Development Project - Asante-Jonathan Asante-Gulu City Project Africa', N'Revamp Of Project Gulu Town rebuild 365 days. ', 8, 1, N'e9585393-5fd1-45e8-5487-08da6e1c1725', NULL, 3, 1, 0, 365, CAST(N'2022-11-30T12:48:43.9984951' AS DateTime2), CAST(N'2023-02-28T13:13:05.6536340' AS DateTime2))
GO
INSERT [dbo].[Jobs] ([JobId], [JobName], [JobDescription], [LocationId], [ClientProfileId], [ClientUserId], [AssignedFundiUserId], [AssignedFundiProfileId], [HasBeenAssignedFundi], [HasCompleted], [NumberOfDaysToComplete], [DateCreated], [DateUpdated]) VALUES (7, N'Martin Okello-Lira City Project Africa', N'Rebuild of Lira Town and Suburbs, connecting infrastructure including Transport, Civil, and Environment. Building Renewable Energy Supplies like Wind Driven Generators', 8, 3, N'f15c12e4-2d54-4699-f639-08dab52801f8', NULL, 4, 0, 0, 0, CAST(N'2022-12-03T11:41:03.2290272' AS DateTime2), CAST(N'2022-12-03T11:41:03.2290272' AS DateTime2))
GO
INSERT [dbo].[Jobs] ([JobId], [JobName], [JobDescription], [LocationId], [ClientProfileId], [ClientUserId], [AssignedFundiUserId], [AssignedFundiProfileId], [HasBeenAssignedFundi], [HasCompleted], [NumberOfDaysToComplete], [DateCreated], [DateUpdated]) VALUES (8, N'Administrator Administrator-Gulu City Project Rebuild And Renovations', N'Gulu City Project Rebuild And Renovations Project Africa, Revamp Of Project Gulu Town rebuild 365 days.', 8, 7, N'bd390c76-989f-4200-3234-08dacfb4f3b5', NULL, 14, 1, 0, 365, CAST(N'2023-02-03T05:58:57.4698346' AS DateTime2), CAST(N'2023-04-30T22:46:50.2641469' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Jobs] OFF
GO
SET IDENTITY_INSERT [dbo].[JobWorkCategories] ON 
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (89, 7, 2, 8, CAST(N'2022-12-03T11:41:03.2520331' AS DateTime2), CAST(N'2022-12-03T11:41:03.2520336' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (90, 7, 2, 9, CAST(N'2022-12-03T11:41:03.2521559' AS DateTime2), CAST(N'2022-12-03T11:41:03.2521559' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (91, 7, 4, 15, CAST(N'2022-12-03T11:41:03.2521901' AS DateTime2), CAST(N'2022-12-03T11:41:03.2521901' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (92, 7, 4, 16, CAST(N'2022-12-03T11:41:03.2522120' AS DateTime2), CAST(N'2022-12-03T11:41:03.2522120' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (93, 7, 5, 21, CAST(N'2022-12-03T11:41:03.2522379' AS DateTime2), CAST(N'2022-12-03T11:41:03.2522379' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (94, 7, 1, 6, CAST(N'2022-12-03T11:41:03.2522583' AS DateTime2), CAST(N'2022-12-03T11:41:03.2522583' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (95, 7, 5, 19, CAST(N'2022-12-03T11:41:03.2522778' AS DateTime2), CAST(N'2022-12-03T11:41:03.2522783' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (96, 7, 2, 11, CAST(N'2022-12-03T11:41:03.2523032' AS DateTime2), CAST(N'2022-12-03T11:41:03.2523032' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (97, 7, 10, 49, CAST(N'2022-12-03T11:41:03.2523232' AS DateTime2), CAST(N'2022-12-03T11:41:03.2523232' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (98, 7, 10, 47, CAST(N'2022-12-03T11:41:03.2523471' AS DateTime2), CAST(N'2022-12-03T11:41:03.2523476' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (131, 6, 1, 1, CAST(N'2023-02-28T13:13:05.6515801' AS DateTime2), CAST(N'2023-02-28T13:13:05.6515811' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (132, 6, 1, 4, CAST(N'2023-02-28T13:13:05.6524920' AS DateTime2), CAST(N'2023-02-28T13:13:05.6524920' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (133, 6, 1, 6, CAST(N'2023-02-28T13:13:05.6525101' AS DateTime2), CAST(N'2023-02-28T13:13:05.6525101' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (134, 6, 1, 7, CAST(N'2023-02-28T13:13:05.6525340' AS DateTime2), CAST(N'2023-02-28T13:13:05.6525340' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (135, 6, 2, 9, CAST(N'2023-02-28T13:13:05.6525530' AS DateTime2), CAST(N'2023-02-28T13:13:05.6525530' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (136, 6, 2, 8, CAST(N'2023-02-28T13:13:05.6526583' AS DateTime2), CAST(N'2023-02-28T13:13:05.6526583' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (137, 6, 3, 12, CAST(N'2023-02-28T13:13:05.6526827' AS DateTime2), CAST(N'2023-02-28T13:13:05.6526832' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (138, 6, 14, 68, CAST(N'2023-02-28T13:13:05.6527022' AS DateTime2), CAST(N'2023-02-28T13:13:05.6527022' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (139, 6, 1, 2, CAST(N'2023-02-28T13:13:05.6524721' AS DateTime2), CAST(N'2023-02-28T13:13:05.6524725' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (140, 6, 4, 15, CAST(N'2023-02-28T13:13:05.6527451' AS DateTime2), CAST(N'2023-02-28T13:13:05.6527456' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (141, 6, 5, 24, CAST(N'2023-02-28T13:13:05.6527856' AS DateTime2), CAST(N'2023-02-28T13:13:05.6527861' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (142, 6, 5, 28, CAST(N'2023-02-28T13:13:05.6528109' AS DateTime2), CAST(N'2023-02-28T13:13:05.6528109' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (143, 6, 5, 29, CAST(N'2023-02-28T13:13:05.6528304' AS DateTime2), CAST(N'2023-02-28T13:13:05.6528309' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (144, 6, 6, 30, CAST(N'2023-02-28T13:13:05.6528582' AS DateTime2), CAST(N'2023-02-28T13:13:05.6528587' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (145, 6, 6, 32, CAST(N'2023-02-28T13:13:05.6528797' AS DateTime2), CAST(N'2023-02-28T13:13:05.6528797' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (146, 6, 6, 33, CAST(N'2023-02-28T13:13:05.6528992' AS DateTime2), CAST(N'2023-02-28T13:13:05.6528997' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (147, 6, 5, 19, CAST(N'2023-02-28T13:13:05.6529289' AS DateTime2), CAST(N'2023-02-28T13:13:05.6529289' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (148, 6, 5, 23, CAST(N'2023-02-28T13:13:05.6527661' AS DateTime2), CAST(N'2023-02-28T13:13:05.6527661' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (149, 6, 10, 47, CAST(N'2023-02-28T13:13:05.6529489' AS DateTime2), CAST(N'2023-02-28T13:13:05.6529489' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (150, 6, 6, 34, CAST(N'2023-02-28T13:13:05.6524384' AS DateTime2), CAST(N'2023-02-28T13:13:05.6524384' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (151, 6, 7, 37, CAST(N'2023-02-28T13:13:05.6523945' AS DateTime2), CAST(N'2023-02-28T13:13:05.6523945' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (152, 6, 10, 47, CAST(N'2023-02-28T13:13:05.6519649' AS DateTime2), CAST(N'2023-02-28T13:13:05.6519654' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (153, 6, 10, 48, CAST(N'2023-02-28T13:13:05.6520234' AS DateTime2), CAST(N'2023-02-28T13:13:05.6520234' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (154, 6, 10, 49, CAST(N'2023-02-28T13:13:05.6520527' AS DateTime2), CAST(N'2023-02-28T13:13:05.6520527' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (155, 6, 11, 51, CAST(N'2023-02-28T13:13:05.6520898' AS DateTime2), CAST(N'2023-02-28T13:13:05.6520902' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (156, 6, 11, 52, CAST(N'2023-02-28T13:13:05.6521141' AS DateTime2), CAST(N'2023-02-28T13:13:05.6521141' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (157, 6, 11, 54, CAST(N'2023-02-28T13:13:05.6521341' AS DateTime2), CAST(N'2023-02-28T13:13:05.6521341' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (158, 6, 11, 55, CAST(N'2023-02-28T13:13:05.6521532' AS DateTime2), CAST(N'2023-02-28T13:13:05.6521532' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (159, 6, 7, 35, CAST(N'2023-02-28T13:13:05.6524189' AS DateTime2), CAST(N'2023-02-28T13:13:05.6524189' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (160, 6, 11, 60, CAST(N'2023-02-28T13:13:05.6521775' AS DateTime2), CAST(N'2023-02-28T13:13:05.6521775' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (161, 6, 11, 62, CAST(N'2023-02-28T13:13:05.6522204' AS DateTime2), CAST(N'2023-02-28T13:13:05.6522209' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (162, 6, 11, 63, CAST(N'2023-02-28T13:13:05.6522399' AS DateTime2), CAST(N'2023-02-28T13:13:05.6522399' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (163, 6, 11, 64, CAST(N'2023-02-28T13:13:05.6522794' AS DateTime2), CAST(N'2023-02-28T13:13:05.6522794' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (164, 6, 11, 65, CAST(N'2023-02-28T13:13:05.6523082' AS DateTime2), CAST(N'2023-02-28T13:13:05.6523087' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (165, 6, 13, 66, CAST(N'2023-02-28T13:13:05.6523321' AS DateTime2), CAST(N'2023-02-28T13:13:05.6523321' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (166, 6, 14, 67, CAST(N'2023-02-28T13:13:05.6523511' AS DateTime2), CAST(N'2023-02-28T13:13:05.6523511' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (167, 6, 9, 43, CAST(N'2023-02-28T13:13:05.6523755' AS DateTime2), CAST(N'2023-02-28T13:13:05.6523760' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (168, 6, 11, 61, CAST(N'2023-02-28T13:13:05.6521970' AS DateTime2), CAST(N'2023-02-28T13:13:05.6521970' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (238, 8, 2, 8, CAST(N'2023-04-30T22:46:50.2588160' AS DateTime2), CAST(N'2023-04-30T22:46:50.2588166' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (239, 8, 10, 47, CAST(N'2023-04-30T22:46:50.2617780' AS DateTime2), CAST(N'2023-04-30T22:46:50.2617784' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (240, 8, 9, 46, CAST(N'2023-04-30T22:46:50.2617470' AS DateTime2), CAST(N'2023-04-30T22:46:50.2617472' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (241, 8, 11, 55, CAST(N'2023-04-30T22:46:50.2617268' AS DateTime2), CAST(N'2023-04-30T22:46:50.2617271' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (242, 8, 11, 54, CAST(N'2023-04-30T22:46:50.2616963' AS DateTime2), CAST(N'2023-04-30T22:46:50.2616965' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (243, 8, 11, 52, CAST(N'2023-04-30T22:46:50.2616765' AS DateTime2), CAST(N'2023-04-30T22:46:50.2616767' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (244, 8, 11, 51, CAST(N'2023-04-30T22:46:50.2616504' AS DateTime2), CAST(N'2023-04-30T22:46:50.2616506' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (245, 8, 5, 28, CAST(N'2023-04-30T22:46:50.2616309' AS DateTime2), CAST(N'2023-04-30T22:46:50.2616311' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (246, 8, 5, 27, CAST(N'2023-04-30T22:46:50.2616109' AS DateTime2), CAST(N'2023-04-30T22:46:50.2616112' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (247, 8, 5, 24, CAST(N'2023-04-30T22:46:50.2615447' AS DateTime2), CAST(N'2023-04-30T22:46:50.2615450' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (248, 8, 10, 48, CAST(N'2023-04-30T22:46:50.2615207' AS DateTime2), CAST(N'2023-04-30T22:46:50.2615210' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (249, 8, 5, 23, CAST(N'2023-04-30T22:46:50.2614894' AS DateTime2), CAST(N'2023-04-30T22:46:50.2614897' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (250, 8, 5, 21, CAST(N'2023-04-30T22:46:50.2614658' AS DateTime2), CAST(N'2023-04-30T22:46:50.2614660' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (251, 8, 5, 20, CAST(N'2023-04-30T22:46:50.2614411' AS DateTime2), CAST(N'2023-04-30T22:46:50.2614415' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (252, 8, 5, 19, CAST(N'2023-04-30T22:46:50.2614061' AS DateTime2), CAST(N'2023-04-30T22:46:50.2614064' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (253, 8, 3, 14, CAST(N'2023-04-30T22:46:50.2613815' AS DateTime2), CAST(N'2023-04-30T22:46:50.2613818' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (254, 8, 3, 13, CAST(N'2023-04-30T22:46:50.2613493' AS DateTime2), CAST(N'2023-04-30T22:46:50.2613495' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (255, 8, 3, 12, CAST(N'2023-04-30T22:46:50.2613250' AS DateTime2), CAST(N'2023-04-30T22:46:50.2613252' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (256, 8, 2, 11, CAST(N'2023-04-30T22:46:50.2612982' AS DateTime2), CAST(N'2023-04-30T22:46:50.2612986' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (257, 8, 2, 10, CAST(N'2023-04-30T22:46:50.2612431' AS DateTime2), CAST(N'2023-04-30T22:46:50.2612434' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (258, 8, 2, 9, CAST(N'2023-04-30T22:46:50.2611924' AS DateTime2), CAST(N'2023-04-30T22:46:50.2611930' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (259, 8, 5, 22, CAST(N'2023-04-30T22:46:50.2609519' AS DateTime2), CAST(N'2023-04-30T22:46:50.2609527' AS DateTime2))
GO
INSERT [dbo].[JobWorkCategories] ([JobWorkCategoryId], [JobId], [WorkCategoryId], [WorkSubCategoryId], [DateCreated], [DateUpdated]) VALUES (260, 8, 10, 49, CAST(N'2023-04-30T22:46:50.2617993' AS DateTime2), CAST(N'2023-04-30T22:46:50.2617995' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[JobWorkCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[Locations] ON 
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (1, N'UK', 1, N'3, 2 St John''s Terrace, London W10 4SB, UK', 51.52733, -0.2152936, CAST(N'2022-11-26T15:48:51.5801924' AS DateTime2), CAST(N'2022-11-29T15:53:59.4137855' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (2, NULL, 6, N'42 Queen''s Gardens, London W2 3AA, UK', 51.5133171, -0.1827191, CAST(N'2022-11-26T20:51:51.3381244' AS DateTime2), CAST(N'2022-11-29T15:54:15.9275301' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (4, NULL, 7, N'55 Sixth St, Kampala, Uganda', 0.3170758, 32.6035652, CAST(N'2022-11-26T20:52:37.2442694' AS DateTime2), CAST(N'2022-11-29T15:54:48.1213076' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (5, NULL, 8, N'Kimathi Ave, Kampala, Uganda', 0.3144982, 32.58499, CAST(N'2022-11-26T20:52:37.4248671' AS DateTime2), CAST(N'2023-01-25T12:24:05.2697740' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (6, NULL, 5, N'3, 13 Lanhill Rd, London W9, UK', 51.52658, -0.1963439, CAST(N'2022-11-26T20:53:20.3008587' AS DateTime2), CAST(N'2022-11-29T15:55:41.9633072' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (7, NULL, 3, N'Steve Biko Court, St John''s Terrace, London W10 4SB, UK', 51.52724, -0.2153939, CAST(N'2022-11-26T20:53:20.4772344' AS DateTime2), CAST(N'2022-11-29T15:56:05.9485475' AS DateTime2), 1)
GO
INSERT [dbo].[Locations] ([LocationId], [Country], [AddressId], [LocationName], [Latitude], [Longitude], [DateCreated], [DateUpdated], [IsGeocoded]) VALUES (8, NULL, 11, N'46 Lira - Gulu Rd, Uganda', 2.29509163, 32.74466, CAST(N'2022-11-26T20:53:45.7030617' AS DateTime2), CAST(N'2022-11-30T12:30:22.0931440' AS DateTime2), 1)
GO
SET IDENTITY_INSERT [dbo].[Locations] OFF
GO
SET IDENTITY_INSERT [dbo].[MonthlySubscriptionQueues] ON 
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (2, N'a0bd8159-f351-4868-6f4e-08db2ee9aa64', N'helga.franklyn@martinlayooinc.com', N'helga.franklyn@martinlayooinc.com-Fundi User Helga Franklyn Subscription for 31 days', N'Attempting Monthly Payment!', 17, 0, 0, CAST(88000.00 AS Decimal(18, 2)), CAST(N'2023-03-27T17:41:56.6140000' AS DateTime2), CAST(N'2023-04-27T19:41:57.8766546' AS DateTime2), CAST(N'2023-03-27T19:41:58.0098700' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (3, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'administrator@martinlayooinc.com-Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(128000.00 AS Decimal(18, 2)), CAST(N'2023-04-20T17:15:23.8390000' AS DateTime2), CAST(N'2023-05-21T18:15:23.8651025' AS DateTime2), CAST(N'2023-04-20T18:15:31.0095065' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (4, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2023-04-20T17:15:48.1170000' AS DateTime2), CAST(N'2023-05-21T18:15:48.1351129' AS DateTime2), CAST(N'2023-04-20T18:16:15.6073841' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (5, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2023-04-21T22:20:20.0700000' AS DateTime2), CAST(N'2023-05-22T23:20:20.1008533' AS DateTime2), CAST(N'2023-04-21T23:20:20.3124711' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (6, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2023-04-21T22:30:53.5660000' AS DateTime2), CAST(N'2023-05-22T23:30:53.5857285' AS DateTime2), CAST(N'2023-04-21T23:30:53.6404502' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (7, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2023-04-21T22:30:56.6290000' AS DateTime2), CAST(N'2023-05-22T23:30:56.6433407' AS DateTime2), CAST(N'2023-04-21T23:30:56.6753002' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (8, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'administrator@martinlayooinc.com-Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2023-04-21T22:34:25.7010000' AS DateTime2), CAST(N'2023-05-22T23:34:25.7247969' AS DateTime2), CAST(N'2023-04-21T23:34:25.9213683' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (9, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2023-04-21T22:39:11.4800000' AS DateTime2), CAST(N'2023-05-22T23:39:11.4973969' AS DateTime2), CAST(N'2023-04-21T23:39:11.5449221' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (10, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2023-04-21T22:39:46.2190000' AS DateTime2), CAST(N'2023-05-22T23:40:04.1213395' AS DateTime2), CAST(N'2023-04-21T23:40:04.1821864' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (11, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2023-04-21T22:40:42.5880000' AS DateTime2), CAST(N'2023-05-22T23:40:42.6121912' AS DateTime2), CAST(N'2023-04-21T23:40:42.6593946' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (12, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(12.00 AS Decimal(18, 2)), CAST(N'2023-05-03T06:55:57.1570000' AS DateTime2), CAST(N'2023-06-03T08:55:57.2771694' AS DateTime2), CAST(N'2023-05-03T08:55:57.4504215' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (13, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-04T17:19:02.5970000' AS DateTime2), CAST(N'2023-06-04T19:19:02.7826165' AS DateTime2), CAST(N'2023-05-04T19:19:02.9280197' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (14, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(9.00 AS Decimal(18, 2)), CAST(N'2023-05-04T17:26:23.2240000' AS DateTime2), CAST(N'2023-06-04T19:26:23.7860346' AS DateTime2), CAST(N'2023-05-04T19:26:23.8419547' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (15, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(9.00 AS Decimal(18, 2)), CAST(N'2023-05-04T17:27:28.6270000' AS DateTime2), CAST(N'2023-06-04T19:27:28.8018372' AS DateTime2), CAST(N'2023-05-04T19:27:28.8594569' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (16, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-04T18:29:59.4940000' AS DateTime2), CAST(N'2023-06-04T20:29:59.2328000' AS DateTime2), CAST(N'2023-05-04T20:29:59.4954598' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (17, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-04T18:31:59.1550000' AS DateTime2), CAST(N'2023-06-04T20:31:58.7419520' AS DateTime2), CAST(N'2023-05-04T20:31:58.7897744' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (18, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T00:51:15.2290000' AS DateTime2), CAST(N'2023-06-05T02:51:15.1527360' AS DateTime2), CAST(N'2023-05-05T02:51:15.2921528' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (19, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T20:46:14.2560000' AS DateTime2), CAST(N'2023-06-05T22:46:15.4700216' AS DateTime2), CAST(N'2023-05-05T22:46:15.6146186' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (20, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T21:37:32.5710000' AS DateTime2), CAST(N'2023-06-05T23:37:33.8823335' AS DateTime2), CAST(N'2023-05-05T23:37:34.0200616' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (21, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T21:37:38.2410000' AS DateTime2), CAST(N'2023-06-05T23:37:39.5417321' AS DateTime2), CAST(N'2023-05-05T23:37:39.5881065' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (22, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T21:57:54.4600000' AS DateTime2), CAST(N'2023-06-05T23:57:55.7932654' AS DateTime2), CAST(N'2023-05-05T23:57:55.8413812' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (23, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T21:58:27.2050000' AS DateTime2), CAST(N'2023-06-05T23:58:28.5443831' AS DateTime2), CAST(N'2023-05-05T23:58:28.5864905' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (24, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T22:15:31.4520000' AS DateTime2), CAST(N'2023-06-06T00:15:32.8215815' AS DateTime2), CAST(N'2023-05-06T00:15:32.8783528' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (25, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T22:56:56.7180000' AS DateTime2), CAST(N'2023-06-06T00:56:58.2136814' AS DateTime2), CAST(N'2023-05-06T00:56:58.3504938' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (26, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T22:59:04.4250000' AS DateTime2), CAST(N'2023-06-06T00:59:05.9119540' AS DateTime2), CAST(N'2023-05-06T00:59:05.9578692' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (27, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-05T23:46:49.1960000' AS DateTime2), CAST(N'2023-06-06T01:46:50.7805298' AS DateTime2), CAST(N'2023-05-06T01:46:50.9129982' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (28, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-06T00:33:31.8940000' AS DateTime2), CAST(N'2023-06-06T02:33:33.5767397' AS DateTime2), CAST(N'2023-05-06T02:33:33.7126625' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (29, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-06T00:50:42.7860000' AS DateTime2), CAST(N'2023-06-06T02:50:44.4881813' AS DateTime2), CAST(N'2023-05-06T02:50:44.5329238' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (30, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-06T00:50:56.3910000' AS DateTime2), CAST(N'2023-06-06T02:50:58.1489455' AS DateTime2), CAST(N'2023-05-06T02:50:58.1949610' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (31, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-06T10:28:45.5080000' AS DateTime2), CAST(N'2023-06-06T12:28:45.7484476' AS DateTime2), CAST(N'2023-05-06T12:28:45.8931998' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (32, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-06T10:29:38.0750000' AS DateTime2), CAST(N'2023-06-06T12:29:38.3248565' AS DateTime2), CAST(N'2023-05-06T12:29:38.3723319' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (33, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-06T11:19:14.5330000' AS DateTime2), CAST(N'2023-06-06T13:19:14.8599157' AS DateTime2), CAST(N'2023-05-06T13:19:14.9995287' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (34, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-06T11:59:38.3640000' AS DateTime2), CAST(N'2023-06-06T13:59:38.7991403' AS DateTime2), CAST(N'2023-05-06T13:59:38.9521396' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (35, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-06T14:39:08.1790000' AS DateTime2), CAST(N'2023-06-06T16:39:08.8693210' AS DateTime2), CAST(N'2023-05-06T16:39:09.0062429' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (36, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-06T14:39:51.3490000' AS DateTime2), CAST(N'2023-06-06T16:39:52.0286238' AS DateTime2), CAST(N'2023-05-06T16:39:52.0708060' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (37, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T14:34:50.0120000' AS DateTime2), CAST(N'2023-06-07T16:34:51.2226818' AS DateTime2), CAST(N'2023-05-07T16:34:51.3639650' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (38, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T14:35:07.0360000' AS DateTime2), CAST(N'2023-06-07T16:35:08.2008290' AS DateTime2), CAST(N'2023-05-07T16:35:08.2420828' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (39, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T14:35:24.3300000' AS DateTime2), CAST(N'2023-06-07T16:35:25.4975697' AS DateTime2), CAST(N'2023-05-07T16:35:25.5364979' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (40, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T15:35:35.3950000' AS DateTime2), CAST(N'2023-06-07T17:35:34.5349591' AS DateTime2), CAST(N'2023-05-07T17:35:34.6817329' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (41, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T15:35:55.9090000' AS DateTime2), CAST(N'2023-06-07T17:35:55.0408378' AS DateTime2), CAST(N'2023-05-07T17:35:55.0870084' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (42, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T15:38:24.1130000' AS DateTime2), CAST(N'2023-06-07T17:38:23.2470073' AS DateTime2), CAST(N'2023-05-07T17:38:23.3020153' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (43, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T15:48:24.2560000' AS DateTime2), CAST(N'2023-06-07T17:48:25.7976458' AS DateTime2), CAST(N'2023-05-07T17:48:25.8390428' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (44, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'administrator@martinlayooinc.com-Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T16:59:51.0220000' AS DateTime2), CAST(N'2023-06-07T18:59:52.6851677' AS DateTime2), CAST(N'2023-05-07T18:59:52.8210190' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (45, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T17:00:06.4780000' AS DateTime2), CAST(N'2023-06-07T19:00:08.1438412' AS DateTime2), CAST(N'2023-05-07T19:00:08.1970598' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (46, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T17:00:25.2440000' AS DateTime2), CAST(N'2023-06-07T19:00:26.9062503' AS DateTime2), CAST(N'2023-05-07T19:00:26.9509861' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (47, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T17:00:26.8630000' AS DateTime2), CAST(N'2023-06-07T19:00:28.5241289' AS DateTime2), CAST(N'2023-05-07T19:00:28.5645577' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptionQueues] ([MonthlySubscriptionQueueId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (48, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(6.00 AS Decimal(18, 2)), CAST(N'2023-05-07T17:00:33.9350000' AS DateTime2), CAST(N'2023-06-07T19:00:35.6570674' AS DateTime2), CAST(N'2023-05-07T19:00:35.6940731' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[MonthlySubscriptionQueues] OFF
GO
SET IDENTITY_INSERT [dbo].[MonthlySubscriptions] ON 
GO
INSERT [dbo].[MonthlySubscriptions] ([MonthlySubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (95, N'd3b2c31e-581c-4dcf-07d7-08dafebcbb6f', N'joseph.lee@martinlayooinc.com', N'joseph.lee@martinlayooinc.com-Fundi User Joseph Lee Subscription for 31 days', N'Attempting Monthly Payment!', 14, 1, 0, CAST(128000.00 AS Decimal(18, 2)), CAST(N'2023-02-26T14:02:17.4730000' AS DateTime2), CAST(N'2023-03-29T14:02:17.5128951' AS DateTime2), CAST(N'2023-02-26T20:25:42.1394066' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptions] ([MonthlySubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (99, N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'administrator@martinlayooinc.com', N'administrator@martinlayooinc.com-Fundi User Administrator Administrator Subscription for 31 days', N'Attempting Monthly Payment!', 4, 0, 0, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2023-02-26T16:18:13.6180000' AS DateTime2), CAST(N'2023-03-29T18:18:07.3896758' AS DateTime2), CAST(N'2023-02-26T18:18:07.4296180' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptions] ([MonthlySubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (102, N'd3b2c31e-581c-4dcf-07d7-08dafebcbb6f', N'joseph.lee@martinlayooinc.com', N'joseph.lee@martinlayooinc.com-Fundi User Joseph Lee Subscription for 31 days', N'Attempting Monthly Payment!', 14, 0, 0, CAST(40000.00 AS Decimal(18, 2)), CAST(N'2023-03-04T02:44:09.4980000' AS DateTime2), CAST(N'2023-04-04T04:44:14.2871123' AS DateTime2), CAST(N'2023-03-04T04:44:14.3871648' AS DateTime2))
GO
INSERT [dbo].[MonthlySubscriptions] ([MonthlySubscriptionId], [UserId], [Username], [SubscriptionName], [SubscriptionDescription], [FundiProfileId], [HasPaid], [HasExpired], [SubscriptionFee], [StartDate], [EndDate], [DateUpdated]) VALUES (103, N'928409e1-d068-4576-5a1d-08db2c7a4269', N'mart42uk@hotmail.com', N'mart42uk@hotmail.com-Fundi User Martin Okello Subscription for 31 days', N'Attempting Monthly Payment!', 15, 1, 0, CAST(68000.00 AS Decimal(18, 2)), CAST(N'2023-03-26T00:16:10.6190000' AS DateTime2), CAST(N'2023-04-26T02:16:10.6945706' AS DateTime2), CAST(N'2023-03-26T02:16:10.8768073' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[MonthlySubscriptions] OFF
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
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'ea13a247-eb40-492d-9a68-08dae382bfd1', N'505c6acf-074a-4a51-8f38-08dab4e94775', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'd4b87809-2ea7-4659-03f8-08dacffbbabe', N'f15c12e4-2d54-4699-f639-08dab52801f8', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'f27e73ee-4dc3-4751-9856-08dacfb4f3b9', N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'db86d768-e437-465c-abd7-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'6d030c5f-fded-47bd-a905-08dae384fb26', N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'9624c69f-fc23-4134-abd8-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'c21965d6-af64-4dcc-9858-08dacfb4f3b9', N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'7eb0be04-2efe-431d-9859-08dacfb4f3b9', N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'8c9a3b4b-80dd-4156-5bb8-08db165490ba', N'd3b2c31e-581c-4dcf-07d7-08dafebcbb6f', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'9fe2134d-2e50-408f-5613-08db14417522', N'425a51e8-1175-4111-804c-08db1441751b', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'f418f367-fe0a-4830-aee3-08db14498269', N'1cc83b21-fb06-4191-cd83-08db14498266', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'9fb78eb7-2bf5-4fa2-aee4-08db14498269', N'2c948711-3df5-4509-cd85-08db14498266', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'668ab2b7-69d4-4c0d-e81a-08db145bdaaf', N'70af754f-ae93-4877-89d0-08db145bdaa9', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'e9081602-691d-4c0d-1b32-08db18544474', N'e3622191-a442-420d-878f-08db1854446f', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'87ad069c-5c8e-47d5-b375-08db185842a9', N'5d253de6-853f-425b-a331-08db185842a2', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'3b3cceef-d8ab-4084-75e2-08db185cacf1', N'a50985b6-6cbc-4091-179e-08db185cacea', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'fef5ee50-9b31-4993-e45c-08db1864554e', N'd03c5756-413d-49de-5230-08db18645547', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'bb3dda7c-5792-4346-b0ff-08db18ff4b5c', N'e5581e6b-65b2-485b-85f3-08db18ff4b59', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'1d1a46e0-c153-4dd1-6c30-08db1f5ae846', N'd6387f29-93c3-4c77-a470-08db1f5ae830', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'1de2aa01-5473-47b6-6c31-08db1f5ae846', N'f5373163-dad2-47cb-a472-08db1f5ae830', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'62bfde89-61e0-48eb-abe5-08db1f5cf434', N'949c09d9-fd9a-440a-0b4f-08db1f5cf41f', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'6790e38c-f3b4-4c02-3810-08db1f5e4c06', N'4f35a0b6-c43c-498b-3726-08db1f5e4bf5', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'6d54a77f-39ac-4e72-5c72-08db1f5f93be', N'767d2eab-8778-40e0-672c-08db1f5f93a7', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'71b187ce-0d04-4322-5188-08db1f609d6e', N'a40524a5-8293-47dd-4dbe-08db1f609d5d', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'b5beff0e-94cb-45d0-afe0-08db24086983', N'c457d9ff-9223-430a-b54c-08db240866f6', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'a261c5f8-fc0d-4a9a-fd9a-08db2c7a4271', N'928409e1-d068-4576-5a1d-08db2c7a4269', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'328c19c0-8470-43d4-fcf7-08db2f695d24', N'a0bd8159-f351-4868-6f4e-08db2ee9aa64', N'db86d768-e437-465c-abd7-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'ccc1698f-7f4e-47f5-fcf8-08db2f695d24', N'a0bd8159-f351-4868-6f4e-08db2ee9aa64', N'9624c69f-fc23-4134-abd8-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'de802817-5300-43ef-fcfa-08db2f695d24', N'a0bd8159-f351-4868-6f4e-08db2ee9aa64', N'5c362732-ee5c-4ce6-abd9-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'9270732f-a887-48f2-81d4-08db2ee564f8', N'a0bd8159-f351-4868-6f4e-08db2ee9aa64', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'e1bd02f0-827d-4ea8-48c8-08db327f2e08', N'e0e7526d-bd9a-4914-2ae9-08db327f2e04', N'9624c69f-fc23-4134-abd8-08dacfb4f3a9')
GO
INSERT [dbo].[UserRoles] ([UserRoleId], [UserId], [RoleId]) VALUES (N'1b75dfa6-bc0f-44c2-7978-08db328491ab', N'172e73c2-3183-4cde-fb18-08db328491a2', N'57736af1-c7fe-40fe-abda-08dacfb4f3a9')
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'e9585393-5fd1-45e8-5487-08da6e1c1725', N'Jonathan', N'Asante', N'Jonathan.asante@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'Jonathan.asante@martinlayooinc.com', N'07809773333', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDplVzczITTmNAslRStdmZvw2X+Kq86N4FUYntuBb85UBm5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxZSXCIDCDTVYRWjJlDGnHxWCnWwueNWBZQd8nh5ZHObT+bAm5FswOiMkaMaL8uTtFPo0SkP5IkyOovu79rPGQY8bc1xGc2fdfpd3tWzTk9JgcBA724hjkIisEfQ787R4Fp4cqRzAf7PjGD7UqRACJTOhz9+v8QTfQdDvzOYN7Tai7RQkJrbeBXZ1nCEwSEqN8d8nTm6ibgvOIgzVDklZnvbuBmsQX0rxFcAtGmE1ncUEjcOBKO8UtAYq4kg7Oi3lOdDK9hYi46h7XB7YnAaxpzUqifWTFULaqekFi6+xVbR8yH5KgnsSvTD8puKLbaUc8qbnjHBYgCwYAYe4DWqLl1Pva009zM9oSbjvb8XmT98cAc9p2roho0WoGIixWsYL5zv+VLUSbxUhMKKCMUCJ6LneD1bkpdJPGY1gEir+6esWwG7poBfqcjRHThCBDZLEOCafEygtAYd6qwQ5T2WKDFKkUiHTO+W9OC3tPNCKzZCzI8sPJQA/qjzYlvrydbGKA/hq+KTqVds0IdQumH2qsNRGadL/aNt1P1GJbhRMtumjNjaBygo3P3DXJYLHfHblpqr9WTDWhKbsiCpPs13sxGkMp3hp2Me5yRd3UeEycpQt3MQqwJLQQAHJzJzAXgxZ0Y9zl0os0oGU8xrMawFdUBu', NULL, CAST(N'2022-07-25T10:00:15.2484206' AS DateTime2), CAST(N'2023-03-23T12:42:52.5450175' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'665bcf05-492a-4b94-2a22-08da940013e8', N'Test', N'Test', N'test@test.com', N'pJ7MG0Vr0qvHA8Pue2Jjhw==', N'test@test.com', N'112', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpkq32ko3Z4Slp+fz44rO9B/8D3L4OLbpwV+KWPs712nj5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxYe1lzzRUKD6/JDAgcJOUGvd2HFwAquP13IZjbb+dHbJFGnCiKDci/0En+F8+64z+5rD5CgRM+NKTikVJfXp5l9GXd8UrhNq5gsVDUGVoMOalLSK8TrTEJBvXCvR6FeIYNGLpacZbargsRpK9+IzHmikax9GZur0bvf0nwtAakhAO1ADkcCNUkVXDBqW7smwAY/WW+gIBy7ZuCp6nRsNCW2C0LCThOuoUBlHhUACrzZrdr805GJMzXOgjDlhsyheTmS2qDZVTozKRLWjmEL44et7xqGoyS1RzRz3SYtewaPFV81bXLuBer8ymNi9lgZSIZTKu+Rz9P28CFhftAsEIeeGtQXUMkRpb7iWyuxKqrH72dsg+Qq2s7AtX8rcdcrkvNhFbVxYjsuOuB32Hw30jFvxwMi3KADpgfvogMM8TAsHyYUuVeCL+YNhJ4BkPS7oHqL34dCpbwQEYmIGPzUlXUmaRmAIiRRKacswMTGn4qc4VDt9d5SWEcUxz1zDRfsX7by8R1tA+0vnR2lyKVDBEfSLGQN8yQRV5ohQjegNE0HAD6KiXsxUYhxxCjmEaGG42t6P5Egx1/kckGZKNkOcXruY94WTcaNGz/hQk5dPmzEFQ==', NULL, CAST(N'2022-09-11T16:15:28.1067428' AS DateTime2), CAST(N'2022-09-11T16:15:47.0969135' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'505c6acf-074a-4a51-8f38-08dab4e94775', N'Alex', N'Okello', N'martin.okello@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'martin.okello@martinlayooinc.com', N'07655432156', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpnjj2sSacTC1mrdlHEUM8f53nAMBl4hYKaAf3czkCORzpIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxbX5j9L10UKiFPsV5hiqot0LS7amXwGSnpXl1xsxCQpFb0l7/8ABiWYl7IPoMOoW8AXMRIamc6ynZZl4lFsKhh5oq2IwNynrefbwJR+4W3ZI9FzoY75WX/88/MLl2+nxy5GDwNiRF+UZdeSHgUeRa6V4qetCZPXg93LzVBkVMAx2Wk/WGPmSFJiyNCRYJZYK6+WMpnRNqXGkGNPzzgqKobx8b6ryE96QcChNzKof3FrRAqeifE5/+KL9VJLGaZy5UGOVtjwWnbDX1LP5x0Hn9JRKdZ45I31Jr5tI2SWuz1VeZ76vQq6dejdm/W+tBDZALbMzhEqrboIufYX3D4tvO3IZkPGNXKFcrHcAoAu/GMnXf8UOy11fiTRIuO/4zHs3iXV0F3aTPTjCaJfe4F46VqJfL77Wy3CLieHMI5MFS/css5venzPG6r58q+1BrmU4+jUzeiQ081rzNeJm9mwYhrUa2k0GsAYdQe6hwa/H1ugX4tFf7UIuJOrc7AUksFo2PmKjlPdEnv0e582EBgKEt3n0rEzcDinF8Z1UeNUSEN84CIYStsDNBk8zt1ipyCH8/hVXGknhMS9M2SsVONW4xc32CoP0DV65oAmg8b/7Tgpaty6xZZdUTvULJ3ZYGhBEho=', NULL, CAST(N'2022-10-23T13:25:24.5566409' AS DateTime2), CAST(N'2022-12-21T18:42:49.0639130' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'f15c12e4-2d54-4699-f639-08dab52801f8', N'Martin', N'Okello', N'martin.okello@gmail.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'martin.okello@gmail.com', N'07898989765', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpnyWJW238Dt+8/lZV2wIggHOYsuhtwHCKEgu0KCOTAtGZIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxbX5j9L10UKiFPsV5hiqot0llCznzEyf0j0jdtIoOsrG41TkII5hndPTx7BRUGiWpnvaK+jKTkffoI0T2zem4n12OLQVeKuz8DNkbew0LxmQ3io+zp8fLL41J5SKZtdijz1ZIzVHg7cuvlziug6JPeTjOWBrgDjuFrWN+/1+/TtCimEkb8lgnQwR384qBwgeODI3EFEiGxzL4cVzsV8m6FfGNUyS9kDUZru7MMS8z6wN6dMYiRyQpgNW9aM4gFcNYW1fgsxLqcFvpFtCCaSvGiYXOGQlnSV+FeA8kNHp5nSvBW9ygiSyku0jtV2oNDlBjyFXNnPYUxstInvTVVpgty4Ymk7hbqTKHBplGw30u/ieokiYCPfzFbmVLxooTvD8r0RKkekAQ9Eu9jIr6+Buall6A9m4msd60xbft9HmZSK3MdOF4ln0UwUaaPAHemH6TJ26YlnggE1hztSpNbLaNYLYgKRFRxjqVXjpN9r8f/T+fqSpN7AV2PEXIsEhjV8EK4EVWPtG10hdB8C2E+nqC7EmnxMoLQGHeqsEOU9ligxShoSaxbMtHdUmfoBtCJNx8VnBSeh1M1IgTiFYxeu8z+5POnRcvMmrwVE1HNAdSFszDuisGrWFcNRkgnuxNS9BdI=', NULL, CAST(N'2022-10-23T20:54:26.2711942' AS DateTime2), CAST(N'2022-12-03T21:59:10.0176694' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'bd390c76-989f-4200-3234-08dacfb4f3b5', N'Administrator', N'Administrator', N'administrator@martinlayooinc.com', N'3YFoEKPCH7RRX7LG30XMxw==', N'administrator@martinlayooinc.com', N'07809773365', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpnGX4eUiyht5yjZxSLFdn2WK8KYE6JFesL8QnEvBCKP65IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxZeroDY/XzFWei5nErTq5dpFeZJ8dkqnRn+LDceM2OcR70l7/8ABiWYl7IPoMOoW8Dtf1hlX87b555xLekLfL6CVFRgjorFJXjYbi3XyMInbuYXYxaj2GbdV/pVnxDWMkKhegFqAlLsWH6EG/Mh+JQG2bCkf5wjNp87/b9Whv6AMC9OXWzG3zwNdEMdsgSmnTocjzHHqij3/hHlQ9gtHAYNJQK7vZqIKvyslfNlJon2wKUiYjOHwcVi6Co/ZxpB4i/zAmmN5d0taVkx+AA7Umzlbc1xGc2fdfpd3tWzTk9JgcBA724hjkIisEfQ787R4Fp4cqRzAf7PjGD7UqRACJTONlEjIUOfhNmZ/jMFe9rkmLycWuNngDh9v9+KDFvELQqayXLpprZb5+zNqUPv+wCKOMsT2Nd91LO9x+mgZjoR04+HtFPA6TssDkygKzWvJcQQkIjbHY7lPSmXU+pC+/MNzNMfgeLFSh/jLUzkuDvLWUM8VBB02f3iLpEgQHF42SdJbOlcjJU3EZV3fKtQZSfqe2bLxFqco6Bq7UVvV8a4KilsVCB36r8Fxp/0olFpfbBuoz3A2uyHCWCQaAunnmjEtmvv/i8946AgOSzUHsIW/IkLQ3A46naH85/mwWNOZL82vojqDhwpeT2VSswO523Rm4AC5IQEjhz2yXwnC4MHrvHZJzTIF/FjUkZMzvNnBVjE+Jo8dIAIk/qS3xz94O8VDEChH6h1Jg63wu6teYNlUuF+p54JzhQ7dv5bSADipFDlFe/9owXQaGa66OnLj3psWdwwmX8q1NOhljB7yMdMnOMtqyrYRwQR/ZXgCdgePVN7l9YYPQhOjScDE5Froj+PCYb162B/ur4jRn4oF6XMZsjsxC/8sw9RMvTQHSsUKISGt2HzhXo5kHxk7iNBnvCZg7ihCS8R8+c3MkTbgom74wWxKD0c4d5u6ijzRxPozYM=', 1, CAST(N'2022-11-26T15:48:51.6073259' AS DateTime2), CAST(N'2023-05-08T12:09:06.8067984' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'd3b2c31e-581c-4dcf-07d7-08dafebcbb6f', N'Joseph', N'Lee', N'joseph.lee@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'joseph.lee@martinlayooinc.com', N'07984221186', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpli++CKA7YwghjBZOmMT1QlOguWni79VMhBdPjl4S2dKNdCgUUbrxNsOiXfu/jFfw4TfMaQW59WYBRs0tL99xt5lRh4uhbhGI7EITYVsuNR4UQPrEBnme/gjjZtVjEpAr6MHeEvwwJ4wEDQI6/um8gI1HjVEgZOP5GQ2cMLfGosWW2QkbhVq0Tb478tb1UTV+iK38jWH8fjdHuobqolOJ+RGP5xmGh56V4WUkLaBBBi9nBVbmx25ZSQqea6OhPIqjav0+MvyvMCPQ10D+bnaxH7vGDlIhm6anbRjoiDjhpsBL8TQmvY0K5FD5wvhiv72ltuiVRUmySni7+G2ym9dVoAiyiYNCOotzumsbtIt2JtlMEgAnGAgxqbDxcn29BfYcyWU6Vm7t+lnvlSpXWvqfl4NtMMWcHISfhmbpvccQIbCt2O8gqgOFwZVLK0TYcKZIdEiSOP6eieq0Mnotbj64/w1NJ08Vu8DVdNLeFMFYNGLCkkLr3dO2J+SE64qoyqZvUKrxfueFTrwz9VkPcygDqcobAkRoEy9/aYzRNCxIQ0Aa3s7UmjnLyl3RKlxPGydKv1dXQUqgik8ivumi780FJAYfyK/BP8/q4JzorgXO7TC3o/kSDHX+RyQZko2Q5xeu4H5TA7rglTqXra60bmH1f34X6nngnOFDt2/ltIAOKkUPf+H2IpQePFqDeindEc99jOy9tuDStxksPzkQdMt+ae8X3SCFn9NYexBpGYJ/clsx6chhU56KY2iC71dGUOsWg=', NULL, CAST(N'2023-01-25T12:12:57.8170438' AS DateTime2), CAST(N'2023-04-11T14:33:14.6329228' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'425a51e8-1175-4111-804c-08db1441751b', N'Robin', N'Veal', N'robin.veal@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'robin.veal@martinlayooinc.com', N'07239685685', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpm6i6jaVTChYWvLt9XrO6QMkyE4KWm3Qbnr8w/K2i+eApIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxZGCWEG1A6kOYSbm9eoWj3Kf4O/Sqkwob7ApVl1TysLAHdhxcAKrj9dyGY22/nR2yQvTl1sxt88DXRDHbIEpp06HI8xx6oo9/4R5UPYLRwGDSUCu72aiCr8rJXzZSaJ9sClImIzh8HFYugqP2caQeIveTzADxyOoTf5ZGKfC0BzUEmTnDnEAsEYhOTsinl7R4+gJaU6sueSadp+S3NVEndsxGqOCdBk+eYkMKu61rlKHcjlkecKm/5O01o/s4nfdLPZjpg2Bjljbz2D7RGCYjkDp92/0sGb9A6vnL960QjX0vj+H0AvfxLi64SnyBBILhY0c6Sh/3YKCt0bJYFR2DcqTpm5QFdnLrDdZ9Ik3tDWK1ztFbGsJVrRrSeXMeEAFoh8Ua3kdJU2cNg0BnoLmizRPqKJQ5+fe0DcXSWTX8XKdk8/9ivEKcDuGAShkAHCt9zJAF6x4zBHlJYyu/jXzUeRLW86Pij5mUUKSPStAq3efGN/u5KlMpwBBU5g+lzWqq3MSAN5+bU7ZrJVuWcs0FDReWV9uI6/zP9fXP6VW8gUGgImeZ22L4HTWdJRVCk6tnwRP+2mPllP2r39Xp3sgHYfuyAXBfyCqJ4LdDzezxbqdPUmskVl1YuvGTjPIwreaCLOUrSWdoeU8TcI6cDsXQtMWvVL/9pQ4X2cdupD+Jl2oXqmEQpfF+GkGE5jbpshIifsL7ukmQuS1oqlMeswEoB4', NULL, CAST(N'2023-02-21T21:25:57.3270261' AS DateTime2), CAST(N'2023-02-21T21:26:23.6794735' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'1cc83b21-fb06-4191-cd83-08db14498266', N'Chris', N'Matthews', N'chris.matthews@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'chris.matthews@martinlayooinc.com', N'07239685681', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpmNNb+BoLxZnVTuW4Yv4Wo7juadgnUXV7wjkkDgCopBiJIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxYa9MWbtv/PHWWpN8+GocoLaxpahOOJBbJwO9vEBWAitVoOnynvS/SeAoyW7nCSm/oOAMS52sxuQXok22RTQ4vhD/wrJriuBJfB2W7pCr6cKh/4s+X4D0gTk2ENgvpT1dY1dtsvvYJEPQrnMqokQ6sboZpT/PDin1ZF5Swb3TgFdlXBCrYKiN2brSx7LGdiI1clyXvD8B2JECrrbyiqrNWWSSjMBzcy010RmGlTN3L14SXmS+WgXrbBO6dZXOEdQ356/5CmYpUXLt/BHuil23AdnGqBEptjGzoXGiaWQ79trCYq3gOmV+xamsx32v+fF3AduWSo2TfSohMA2JoUmvsn7g7p4oDqskyDgNw+FaxzbfhsZ5/VtRKGohDZyafWX3OS1AgYq6vI229Xp9oU4BIUgrWcgXAl27dz190AjPExLg8DMPH0/ulo4t46IBLitbTY2gcoKNz9w1yWCx3x25aaB93XDUXGEG2jxP9G9+L5NTwLtQdoaMpMyNLYkt5YC28EhqYueZgNTsB3/+E7zE4sytLiiL2H4owYca+xHq0yLvallbCforlegOjVYYLn13h3C9hHeisi34A5LGxUKH5PdqvuHoi7h0Pe60Bk+Rkg2wh29kRWuY64Kf40/ZRpaRg=', NULL, CAST(N'2023-02-21T22:23:35.5958053' AS DateTime2), CAST(N'2023-03-01T18:18:03.2802598' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'2c948711-3df5-4509-cd85-08db14498266', N'Tim', N'Kruger', N'tim.kruger@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'tim.kruger@martinlayooinc.com', N'07812373365', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpm6i6jaVTChYWvLt9XrO6QMxCZSlyhFXJogeMtRwYEfi5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxZu11JzdXrqJxJA+kG7ZOouf4O/Sqkwob7ApVl1TysLAHdhxcAKrj9dyGY22/nR2yTABekZjk3uImkGcfOG43gLvNAeiMFLU2dY2W93l8EGsCUCu72aiCr8rJXzZSaJ9sBS0ivE60xCQb1wr0ehXiGDRi6WnGW2q4LEaSvfiMx5okVrATuPxeiWv0M1tQp34dburWy6IXu+4JLiKk7XVAs0cxUAASq5YiH4yS20xVtsqSroky7oHmt8OGS/z4P7CTKfeMqLIe7PUXChSGltUwZracdaotybBM6Erc2In5JyxB2buAlqT45nSRfb3wCrpfPSzdj8NtfpitIZrnbbMG/lXincs7lmK2pL5LYcZi2ZAKa/JVEya8LLfFe47xtFo+4Dz8HVHP9sqY5Fcr0bpCctgWonBZ/GB563hOIZXiORzi+TBw3D/hSTWqgKX0Yu8BSQtAuP0HXhrqhysBUujhMQK3v/uk/icsyO1DMB+sDeqHgSymo2pIHwlRwLRDqc+RnCuZS005CR3GEfsdY9dMHMx04XiWfRTBRpo8Ad6YfpMrODhklmpVZp7ku2r9Lws4oPBkczNV95iDEhDa8mc/L9aRmAIiRRKacswMTGn4qc4RG8CLvyHc939LnNZ4DY3Fo=', NULL, CAST(N'2023-02-21T22:25:35.6723577' AS DateTime2), CAST(N'2023-02-21T22:26:20.0546966' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'70af754f-ae93-4877-89d0-08db145bdaa9', N'Alfonso', N'Curter', N'alfonso.curter@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'alfonso.curter@martinlayooinc.com', N'07976221186', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpm6i6jaVTChYWvLt9XrO6QM8cUbEAoT9D3RGC0mc5vCE5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxZ3RgT91S1aC6/Ed0zxsYhZJaCYR1U//Q2DZRxhmvQFlVoOnynvS/SeAoyW7nCSm/qCfNTJ3kOZK0bh2A7fY2kMnHRzP1A4g6Q3WQRVMEMnxomL6SeA/3lGVx5SBmUki/A07XC5ne4Az1Odik3OijoMrahxFXtnRtSyb+8OnSIRPOM+nsRtPso8x/HSv9onbEdtorleq4vWsnN7wYM/9DwfHA58coXHoQYOp7zzze4NgkRYp7Cx0vazgerMABclGBjdz0eFlacYz9UDFNjaASuQlIBiO09RivPaW4eHVRrhhNqKwbfigug5W0cEn8W/AZe0RQ472H0vXY8fx0u9W29WP/J0jraBLxseHTR/+jSlXX5TpuAs3+Qsa4JytZUoW3QfbdSIMO91lM+0flS0ITCizar+GaCmIEW2gAUM96sIDr4e8q8i0LHggWCum7Ue57GROMrCFTZnqIQnqcKKUO4vRGIZqb2qwlaxbhPpsE+Iz3eNRKRnqGRWs3n1Qi21rg8gqlGCIQH9JOXJSGqSKjcf8vEdbQPtL50dpcilQwRH0g6RkUlQ+jsyXGcyyRZ0c3if4n26d73IEsXE+PeD1Bxj/mmYT0AluIjIEHDsVh3wSxQ3u+w61jR+xVLk6mquOCcLcMbYby6tBABtyf4/Os5WsE9WCFXvddEa98HIgxkr8GURb6CeoFh4cG9VYoMpt5A57gXIAfX5BRBNTnVEjgIWWyRQOCtZMtMCylx806RJHg==', NULL, CAST(N'2023-02-22T00:34:54.6099663' AS DateTime2), CAST(N'2023-02-22T00:35:05.6387348' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'e3622191-a442-420d-878f-08db1854446f', N'Marge', N'Getrudes', N'marge.getrudes@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'marge.getrudes@martinlayooinc.com', N'07809774456', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpljr2URH5eZkzpTeG5qNMjtWGmEpYX8k+OWQQgLEnHRc9dCgUUbrxNsOiXfu/jFfw4TfMaQW59WYBRs0tL99xt5lRh4uhbhGI7EITYVsuNR4UQPrEBnme/gjjZtVjEpAr5WvHIj2S3+2rULWhf8fcvy+3Am/e2YpQ544APADDtNIb0l7/8ABiWYl7IPoMOoW8ALRkkfZhS0sxFef+JjYtRTQe1jGbVBTF6rjI2cj4Mh+4foOawmWgAraiYWwEswGX0Ms1Yh3q+AJHpffvVaP0UvPGpqpShYJiZ1Rwl/zKdQXRQAzjCl3r3pVUunAhvKUQDy6pFXIc8E3Qdf6UutWZv7SSjMBzcy010RmGlTN3L14SXmS+WgXrbBO6dZXOEdQ356/5CmYpUXLt/BHuil23AdnGqBEptjGzoXGiaWQ79trCYq3gOmV+xamsx32v+fF3AduWSo2TfSohMA2JoUmvsn7g7p4oDqskyDgNw+FaxzbfhsZ5/VtRKGohDZyafWX3OS1AgYq6vI229Xp9oU4BIUgrWcgXAl27dz190AjPExLg8DMPH0/ulo4t46IBLitbTY2gcoKNz9w1yWCx3x25aaB93XDUXGEG2jxP9G9+L5NTwLtQdoaMpMyNLYkt5YC28EhqYueZgNTsB3/+E7zE4sytLiiL2H4owYca+xHq0yLvallbCforlegOjVYYLn13h3C9hHeisi34A5LGxUKH5PdqvuHoi7h0Pe60Bk+Rkg2wh29kRWuY64Kf40/ZRpaRg=', NULL, CAST(N'2023-02-27T01:50:40.7479938' AS DateTime2), CAST(N'2023-02-27T01:50:57.5268217' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'5d253de6-853f-425b-a331-08db185842a2', N'tim', N'strazer', N'tim.strazer@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'tim.strazer@martinlayooinc.com', N'07699553365', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpnbbz5D1uHL4YNpwuqKEtnd5jezT54PmMOR1ajRqXjuGddCgUUbrxNsOiXfu/jFfw4TfMaQW59WYBRs0tL99xt5lRh4uhbhGI7EITYVsuNR4UQPrEBnme/gjjZtVjEpAr6ti5Yfrm7nTG6RYEzfDRCTf4O/Sqkwob7ApVl1TysLAHdhxcAKrj9dyGY22/nR2yTABekZjk3uImkGcfOG43gLvNAeiMFLU2dY2W93l8EGsCUCu72aiCr8rJXzZSaJ9sBS0ivE60xCQb1wr0ehXiGDRi6WnGW2q4LEaSvfiMx5os34xJ2V2rjhD+iH7aw3s/+XXu3dyjlzxRIrGXHytpIf/ZZ43H4x+pVY7C18bHi4AtZDUtNEb5B54YgqBVLXT68RBJfwi62RG1xsKdfEDdXhJ8oRlfSkIpOvmv+ezTQZpWmM9/+5JgZim+sVy781FISewL/KqKMz139vzQtA1jl8kvNehyqYRqAOmWjaSaNgaEghAP/HD4mBslinCFQK+mYBlKpw16T+reXvxinmTkTPn2HSALkIWyWtve8mxLaWhvUmskVl1YuvGTjPIwreaCImo9VHJoK0BW5dcSecByTYkaqr+qA/49hhLolKN5k2YzaTAY26c7AF0FxtWCtpJpF1cnVqwEmb4Zmg0ieJJkTUreztSaOcvKXdEqXE8bJ0q6u7ED4UD8gQoi1KTuxqQJGhcasL7XkvjGkvoFqiDeUxtU+wT3AyLms7DZjokeiIIDVIFSoHhoCjU0rMdrOKP/Y=', NULL, CAST(N'2023-02-27T02:19:15.7106606' AS DateTime2), CAST(N'2023-02-27T02:19:40.2423964' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'a50985b6-6cbc-4091-179e-08db185cacea', N'Grace', N'Hadler', N'grace.hadler@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'grace.hadler@martinlayooinc.com', N'0768786574', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpmNNb+BoLxZnVTuW4Yv4Wo7+ZRfr1JEfFbhpIZ36HZEEJIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxZZspS0KlLmDB20VBa89SzPooFK9e09eU6LM8rikv+3qSKWbjXLC6/6CeRbRX1KM0EOO+ZNVfnX+nSyXFfoWbqGz13rkuUOEqrh0zF2bbW/vfoFZ8OTB7ltcuN+lp/kC5n7TcxCSiPWe0D0U8klvn/i4qetCZPXg93LzVBkVMAx2byuNnTfBq+kJEKubd1v+7U+nFzEbsrIaz/a4NyppXrK+P4fQC9/EuLrhKfIEEguFjRzpKH/dgoK3RslgVHYNypOmblAV2cusN1n0iTe0NYrXO0VsawlWtGtJ5cx4QAWiHxRreR0lTZw2DQGeguaLNE+oolDn597QNxdJZNfxcp2Tz/2K8QpwO4YBKGQAcK33MkAXrHjMEeUljK7+NfNR5Etbzo+KPmZRQpI9K0Crd58Y3+7kqUynAEFTmD6XNaqrcxIA3n5tTtmslW5ZyzQUNF5ZX24jr/M/19c/pVbyBQaAiZ5nbYvgdNZ0lFUKTq2fBE/7aY+WU/avf1eneyAdh+7IBcF/IKongt0PN7PFup09SayRWXVi68ZOM8jCt5oIs5StJZ2h5TxNwjpwOxdC0xa9Uv/2lDhfZx26kP4mXaheqYRCl8X4aQYTmNumyEiJ+wvu6SZC5LWiqUx6zASgHg=', NULL, CAST(N'2023-02-27T02:50:52.0048954' AS DateTime2), CAST(N'2023-03-01T20:24:07.1670280' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'd03c5756-413d-49de-5230-08db18645547', N'James', N'Haddock', N'james.haddock@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'james.haddock@martinlayooinc.com', N'07984221843', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpnbbz5D1uHL4YNpwuqKEtndQNW1bVUFfZUGBBBFtP2SU5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxaYhcundPu1DH6xoxURWLeHc06tEU1lO0oKz6KR4Fifx70l7/8ABiWYl7IPoMOoW8ALRkkfZhS0sxFef+JjYtRTQe1jGbVBTF6rjI2cj4Mh+4foOawmWgAraiYWwEswGX0Ms1Yh3q+AJHpffvVaP0UvPGpqpShYJiZ1Rwl/zKdQXfZxJKGP8WDk/HhAoOl8MPDb0TGMSBPNwzrDAFobn0nCr+zEtVhLGOuleyvlrDv9SJJZCUT2udyxUvlSMUMw6Avykxy0wxxMpVPny+SQscSPF3Wi1d4zuC8OQVHrpMZvOA+3FqlmYT/9hcTeVpFc95VzInGPvsq8Jtldns74zj4U8oXrYYkpv5UpZkTAguWDoj3lble89Qa+OG9kgV452bhttTOYtk7um2cq6mcXw3CNK2Nh3bbJiFm1vgqDkWBYGZWtC3Te9oHrel9znmCwsZvJyPV2KV1ZL1cgRhRrbwq/ls1IrIO43+e8peqttbOgTJUAyZ3oZlS7dnC+tlKozRZsIYSCBunHxUnz7GxK6unEpVoqMTTnEEjxh0KqXnYnucZbioaCokGj0qAJsIczYxHY2aY7Amt/spoyKY4mn7dRM8qqwojXnB5JX5C6UtxtzSRnFXlXAE2m3AARGIcVPRM=', NULL, CAST(N'2023-02-27T03:45:40.9506653' AS DateTime2), CAST(N'2023-02-27T22:13:12.6064997' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'e5581e6b-65b2-485b-85f3-08db18ff4b59', N'Hellena', N'Jewel', N'hellena.jewel@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'hellena.jewel@martinlayooinc.com', N'07809774435', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpnbbz5D1uHL4YNpwuqKEtndm0xr0GPMCFLzplLUIh4tu5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxadxHK4599zaX83nhc1tihdr0xb8X7k2igTS23qVeEskb0l7/8ABiWYl7IPoMOoW8ALRkkfZhS0sxFef+JjYtRTQe1jGbVBTF6rjI2cj4Mh+4foOawmWgAraiYWwEswGX0Ms1Yh3q+AJHpffvVaP0UvPGpqpShYJiZ1Rwl/zKdQXRgHgCE5DdKfoolH5zdtpw8YcupAxrI4tm3qXXuhUANnr+zEtVhLGOuleyvlrDv9SJJZCUT2udyxUvlSMUMw6Avykxy0wxxMpVPny+SQscSPF3Wi1d4zuC8OQVHrpMZvOA+3FqlmYT/9hcTeVpFc95VzInGPvsq8Jtldns74zj4U8oXrYYkpv5UpZkTAguWDoj3lble89Qa+OG9kgV452bhttTOYtk7um2cq6mcXw3CNK2Nh3bbJiFm1vgqDkWBYGZWtC3Te9oHrel9znmCwsZvJyPV2KV1ZL1cgRhRrbwq/ls1IrIO43+e8peqttbOgTJUAyZ3oZlS7dnC+tlKozRZsIYSCBunHxUnz7GxK6unEpVoqMTTnEEjxh0KqXnYnucZbioaCokGj0qAJsIczYxHY2aY7Amt/spoyKY4mn7dRM8qqwojXnB5JX5C6UtxtzSRnFXlXAE2m3AARGIcVPRM=', NULL, CAST(N'2023-02-27T22:14:56.2904005' AS DateTime2), CAST(N'2023-02-28T00:29:20.8411070' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'd6387f29-93c3-4c77-a470-08db1f5ae830', N'getrude', N'witch', N'getrude.witch@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'getrude.witch@martinlayooinc.com', N'07809556696', NULL, NULL, CAST(N'2023-03-07T22:25:50.5879489' AS DateTime2), CAST(N'2023-03-07T22:25:50.5880648' AS DateTime2), 0, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'f5373163-dad2-47cb-a472-08db1f5ae830', N'janet', N'okello', N'janet.okello@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'janet.okello@martinlayooinc.com', N'0712345678', NULL, NULL, CAST(N'2023-03-07T22:29:54.3338657' AS DateTime2), CAST(N'2023-03-07T22:29:54.3338660' AS DateTime2), 0, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'949c09d9-fd9a-440a-0b4f-08db1f5cf41f', N'getrude', N'lanek', N'getrude.lanek@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'getrude.lanek@martinlayooinc.com', N'07123412349', NULL, NULL, CAST(N'2023-03-07T22:40:29.5993828' AS DateTime2), CAST(N'2023-03-07T22:40:29.5995020' AS DateTime2), 0, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'4f35a0b6-c43c-498b-3726-08db1f5e4bf5', N'Rhys', N'Gambia', N'rhys.gabia@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'rhys.gabia@martinlayooinc.com', N'07984221111', NULL, NULL, CAST(N'2023-03-07T22:50:06.4638253' AS DateTime2), CAST(N'2023-03-07T22:50:06.4638362' AS DateTime2), 0, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'767d2eab-8778-40e0-672c-08db1f5f93a7', N'Medal', N'honour', N'medal.honour', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'medal.honour', N'07809121212', NULL, NULL, CAST(N'2023-03-07T22:59:16.2449942' AS DateTime2), CAST(N'2023-03-07T22:59:16.2449953' AS DateTime2), 0, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'a40524a5-8293-47dd-4dbe-08db1f609d5d', N'Heather', N'Mutlow', N'heather.murlow2@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'heather.murlow2@martinlayooinc.com', N'07979797979', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpld0bHmPUkFgF89rXTeLY6IO2zW9OeTQDR7uB1+LuBp75IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxbPvjsv0agfbRymHKiEe1DEIsSRqb/p9okT51q494xwKebAm5FswOiMkaMaL8uTtFPo0SkP5IkyOovu79rPGQY8bc1xGc2fdfpd3tWzTk9JgcBA724hjkIisEfQ787R4Fp4cqRzAf7PjGD7UqRACJTOhz9+v8QTfQdDvzOYN7Tai578+IPeDfcq1Pj/s9V0KEeI3BWlBPhdrPENT1t024j9UTH8mv195TYFdeGBCsK5sfpRpWK0l32KXbghZT/cdTRKt59EXEZRE5KHatzfHngdxATordsS6R27bjSs+qmAIjTzIwy6DkdZdK6f4ciNLLvREVImzXZ/owsexSgr7u5UJFdVE2af9Vbt9sXYtbbUbRybztwgZwdjQeZ3Z3NUMY/VNKtrvZyN+fjhDo+0AlFJScUPr4xA9towj0ETf7CI+K/rvK87PVc1NIzHNIlLLcMLcMbYby6tBABtyf4/Os5WyJR3qCu+jYwD1iP2J/e3sLayBG4KkVbUIlhh/Scu9TICNdEGWkbAVM+YoUjp6W5CKqd7VLHnNDms98u0BSRaosnI9XYpXVkvVyBGFGtvCr/Vnz43JLncoF9/+YNIUM9LzDS5mE63zorAg4zuPg93PcRo/egeggI2lLz8hFVB4/tVTvQDjkEaDl6a/2/5aFHV', NULL, CAST(N'2023-03-07T23:06:42.0326052' AS DateTime2), CAST(N'2023-03-07T23:09:28.2729667' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'c457d9ff-9223-430a-b54c-08db240866f6', N'matty', N'mats', N'matty.mats@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'matty.mats@martinlayooinc.com', N'08746573645', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpldQRKaIhrsHsNTGMJPmqS5EWjbLeHyxYEoEhGS5J4ccJIPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxadEsaEUEidemQSTKjGjotEf4O/Sqkwob7ApVl1TysLAHdhxcAKrj9dyGY22/nR2yTABekZjk3uImkGcfOG43gLvNAeiMFLU2dY2W93l8EGsCUCu72aiCr8rJXzZSaJ9sBS0ivE60xCQb1wr0ehXiGDRi6WnGW2q4LEaSvfiMx5op8Bi5bS4spwO03mtD+LKwbWS8Z/wBhbw0OdYoVoyqHzcxUAASq5YiH4yS20xVtsqSroky7oHmt8OGS/z4P7CTKfeMqLIe7PUXChSGltUwZracdaotybBM6Erc2In5JyxB2buAlqT45nSRfb3wCrpfPSzdj8NtfpitIZrnbbMG/lXincs7lmK2pL5LYcZi2ZAKa/JVEya8LLfFe47xtFo+4Dz8HVHP9sqY5Fcr0bpCctgWonBZ/GB563hOIZXiORzi+TBw3D/hSTWqgKX0Yu8BSQtAuP0HXhrqhysBUujhMQK3v/uk/icsyO1DMB+sDeqHgSymo2pIHwlRwLRDqc+RnCuZS005CR3GEfsdY9dMHMx04XiWfRTBRpo8Ad6YfpMrODhklmpVZp7ku2r9Lws4oPBkczNV95iDEhDa8mc/L9aRmAIiRRKacswMTGn4qc4RG8CLvyHc939LnNZ4DY3Fo=', NULL, CAST(N'2023-03-13T21:17:50.8649696' AS DateTime2), CAST(N'2023-03-13T21:19:14.6406912' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'928409e1-d068-4576-5a1d-08db2c7a4269', N'Martin', N'Okello', N'mart42uk@hotmail.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'mart42uk@hotmail.com', N'07809773365', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpnTIFHQbZb63EpeO3Fex2Yc+Ce6ZcYdpp1+2BRzGfsjR5IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxbcnMAPTKrfXKEzwzK1N2snHJnUfTqYlAGHXgUp1uam9t21N6yMZdIiwUGQPn0IgJkE0NrobLkGwFXJhjnkdYcv+/LB39r06DAY3BN0QlW4jS0QDOAndPDdol+WEm99sBC+g2xgw9SlL219iYotPnCuZKG3k6GHHra6WbZgI39LDeu3zBVFQDBWWe9DbHlZhcNRMfya/X3lNgV14YEKwrmx+lGlYrSXfYpduCFlP9x1NEq3n0RcRlETkodq3N8eeB3EBOit2xLpHbtuNKz6qYAiNPMjDLoOR1l0rp/hyI0su9ERUibNdn+jCx7FKCvu7lQkV1UTZp/1Vu32xdi1ttRtHJvO3CBnB2NB5ndnc1Qxj9U0q2u9nI35+OEOj7QCUUlJxQ+vjED22jCPQRN/sIj4r+u8rzs9VzU0jMc0iUstwwtwxthvLq0EAG3J/j86zlbIlHeoK76NjAPWI/Yn97ewtrIEbgqRVtQiWGH9Jy71MgI10QZaRsBUz5ihSOnpbkIqp3tUsec0Oaz3y7QFJFqiycj1dildWS9XIEYUa28Kv9WfPjckudygX3/5g0hQz0vMNLmYTrfOisCDjO4+D3c9xGj96B6CAjaUvPyEVUHj+1VO9AOOQRoOXpr/b/loUdU=', NULL, CAST(N'2023-03-24T17:13:01.4784248' AS DateTime2), CAST(N'2023-05-01T11:58:31.2606015' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'a0bd8159-f351-4868-6f4e-08db2ee9aa64', N'Helga', N'Franklyn', N'helga.franklyn@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'helga.franklyn@martinlayooinc.com', N'07978790797', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpm7W+IBUzEfcrb2Ph+WMOvvSCdNfTy2Tx06MwbicS4P15IPYc+k5wYQd1afeA06EWNMufFwyQCEAL5MdJPWfCVoUDyphBCyHJ+iSA+II2jgICDzU19HiVeql2KEtt4HcxaQqmYJP8eX2zM7QPDx3BiW+b43rg7LR3cr0guP6Qj9RVoOnynvS/SeAoyW7nCSm/r2v/yPbCv8YMTLjgquKC6eyKemgvufCYfuB5wPEnqVYB4zbj1yjlXUdG4bNqXj47wvX1sTCfaATCDqRfDCU22vXFm9rOeHo6Slkw2FFgHavcsGlU0Kk6TUa8ZFHNXAPJ1gTqFE9mTMzv5Sl03WIaiiLyKRFi9OpgtLu6yY1V4sbo9wSvEECsqIkhKXk90DCO4CN8wDeX6313mILAe02O1/CMCVoMvDY4FsnhPNZzpEXJZhwcwHGVk9Jx8mNctF6cvnXBeZkq4HBMSW3bqFN3G1vsUR2LXp+xd5nY6delFHW5zoN9XtdmFqfVIW2mm2DMpUjTYK2qBELkgDSxd8LHPZks5oXvyhnV0tm6BVHMy2oGSVnItMyIjejQOkFE3fxV59QgZbd1eG6pNAbmB99LUl3Gmxw9cc8T0MRKKoMgAOqAGQMAFWs3FBBNHMDGaZxQ4/WW+gIBy7ZuCp6nRsNCW2C0LCThOuoUBlHhUACrzZrdr805GJMzXOgjDlhsyheTmS2qDZVTozKRLWjmEL44et7xqGoyS1RzRz3SYtewaPFV81bXLuBer8ymNi9lgZSIZTKu+Rz9P28CFhftAsEIeeGtQXUMkRpb7iWyuxKqrH72dsg+Qq2s7AtX8rcdcrkvNhFbVxYjsuOuB32Hw30jFvxwMi3KADpgfvogMM8TAsHyYUuVeCL+YNhJ4BkPS7oHqL34dCpbwQEYmIGPzUlXUmaRmAIiRRKacswMTGn4qc4VDt9d5SWEcUxz1zDRfsX7by8R1tA+0vnR2lyKVDBEfSLGQN8yQRV5ohQjegNE0HAD6KiXsxUYhxxCjmEaGG42t6P5Egx1/kckGZKNkOcXruY94WTcaNGz/hQk5dPmzEFQ==', NULL, CAST(N'2023-03-27T19:35:32.4011311' AS DateTime2), CAST(N'2023-04-05T12:05:21.0948021' AS DateTime2), 1, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'e0e7526d-bd9a-4914-2ae9-08db327f2e04', N'Matheus', N'Gregs', N'matheus.gregs@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'matheus.gregs@martinlayooinc.com', N'07809556733', NULL, NULL, CAST(N'2023-04-01T09:03:21.7269107' AS DateTime2), CAST(N'2023-04-01T09:03:21.7269233' AS DateTime2), 0, 0)
GO
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Username], [Password], [Email], [MobileNumber], [Token], [CompanyId], [CreateTime], [LastLogInTime], [IsActive], [IsLockedOut]) VALUES (N'172e73c2-3183-4cde-fb18-08db328491a2', N'Rogers', N'Mccmaffin', N'rogers.mccmaffin@martinlayooinc.com', N'/qoGLh0s7Ii3+H6ftcrqrA==', N'rogers.mccmaffin@martinlayooinc.com', N'07890443374', N'lNQGWQ/eqt6iWU4iG0A2mgNMt/OKY4HTMQf31+9z0iQSXkpqP8Pj98VLLFJiNAYUpAvFVXQqKGlf+dm7iuYumKw9GxQfdNDBoTFaMrxDDpkMz38V3Oj9+N4ihfy2wURKl/xxaTGOagVjvvPwpIXsbddCgUUbrxNsOiXfu/jFfw4TfMaQW59WYBRs0tL99xt5lRh4uhbhGI7EITYVsuNR4UQPrEBnme/gjjZtVjEpAr74HYts7z9+Q2pQ/e0Rje60gpdc4NxhPf+f+/ygpIEt8ubAm5FswOiMkaMaL8uTtFNmJVl7akAS5G0JFbBuEnT6Yz/V4XNcpbMHk9RgFSUsvDDPAc7bVkARCxjISLYuUmI0plKSl5cqihiHZ3Tf2OjlQHu0oxIFwmkhMWnEkmi176aRoUQLlSmpCpKrspi9w55jeoFG/d0ycVL3sa303jTcXfwxXFZkLjfEH9lUlFMbEzcOBKO8UtAYq4kg7Oi3lOdDK9hYi46h7XB7YnAaxpzUqifWTFULaqekFi6+xVbR8yH5KgnsSvTD8puKLbaUc8qbnjHBYgCwYAYe4DWqLl1Pva009zM9oSbjvb8XmT98cAc9p2roho0WoGIixWsYL5zv+VLUSbxUhMKKCMUCJ6LneD1bkpdJPGY1gEir+6esWwG7poBfqcjRHThCBDZLEOCafEygtAYd6qwQ5T2WKDFKkUiHTO+W9OC3tPNCKzZCzI8sPJQA/qjzYlvrydbGKA/hq+KTqVds0IdQumH2qsNRGadL/aNt1P1GJbhRMtumjNjaBygo3P3DXJYLHfHblpqr9WTDWhKbsiCpPs13sxGkMp3hp2Me5yRd3UeEycpQt3MQqwJLQQAHJzJzAXgxZ0Y9zl0os0oGU8xrMawFdUBu', NULL, CAST(N'2023-04-01T09:41:56.3390340' AS DateTime2), CAST(N'2023-04-01T09:42:27.9737636' AS DateTime2), 1, 0)
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
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (9, N'Low Voltage installations', N'Low Voltage installation
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
INSERT [dbo].[WorkSubCategories] ([WorkSubCategoryId], [WorkSubCategoryType], [WorkSubCategoryDescription], [WorkCategoryId], [DateCreated], [DateUpdated]) VALUES (70, N'Site Supervisor', N'Site Supervisors', 12, CAST(N'2023-02-04T17:47:29.8806304' AS DateTime2), CAST(N'2023-02-04T17:47:29.8806309' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[WorkSubCategories] OFF
GO
/****** Object:  Index [AK_UserRoles_UserId_RoleId]    Script Date: 08/05/2023 20:07:33 ******/
ALTER TABLE [dbo].[UserRoles] ADD  CONSTRAINT [AK_UserRoles_UserId_RoleId] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [AK_Users_Username]    Script Date: 08/05/2023 20:07:33 ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [AK_Users_Username] UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientFundiContracts]  WITH CHECK ADD  CONSTRAINT [FK_ClientFundiContracts_Addresses_ClientAddressId] FOREIGN KEY([ClientAddressId])
REFERENCES [dbo].[Addresses] ([AddressId])
GO
ALTER TABLE [dbo].[ClientFundiContracts] CHECK CONSTRAINT [FK_ClientFundiContracts_Addresses_ClientAddressId]
GO
ALTER TABLE [dbo].[ClientFundiContracts]  WITH CHECK ADD  CONSTRAINT [FK_ClientFundiContracts_Addresses_FundiAddressId] FOREIGN KEY([FundiAddressId])
REFERENCES [dbo].[Addresses] ([AddressId])
GO
ALTER TABLE [dbo].[ClientFundiContracts] CHECK CONSTRAINT [FK_ClientFundiContracts_Addresses_FundiAddressId]
GO
ALTER TABLE [dbo].[ClientFundiContracts]  WITH CHECK ADD  CONSTRAINT [FK_ClientFundiContracts_ClientProfiles_ClientProfileId] FOREIGN KEY([ClientProfileId])
REFERENCES [dbo].[ClientProfiles] ([ClientProfileId])
GO
ALTER TABLE [dbo].[ClientFundiContracts] CHECK CONSTRAINT [FK_ClientFundiContracts_ClientProfiles_ClientProfileId]
GO
ALTER TABLE [dbo].[ClientFundiContracts]  WITH CHECK ADD  CONSTRAINT [FK_ClientFundiContracts_FundiProfiles_FundiProfileId] FOREIGN KEY([FundiProfileId])
REFERENCES [dbo].[FundiProfiles] ([FundiProfileId])
GO
ALTER TABLE [dbo].[ClientFundiContracts] CHECK CONSTRAINT [FK_ClientFundiContracts_FundiProfiles_FundiProfileId]
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
ALTER TABLE [dbo].[ClientSubscriptions]  WITH CHECK ADD  CONSTRAINT [FK_ClientSubscriptions_ClientProfiles_ClientProfileId] FOREIGN KEY([ClientProfileId])
REFERENCES [dbo].[ClientProfiles] ([ClientProfileId])
GO
ALTER TABLE [dbo].[ClientSubscriptions] CHECK CONSTRAINT [FK_ClientSubscriptions_ClientProfiles_ClientProfileId]
GO
ALTER TABLE [dbo].[ClientSubscriptions]  WITH CHECK ADD  CONSTRAINT [FK_ClientSubscriptions_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[ClientSubscriptions] CHECK CONSTRAINT [FK_ClientSubscriptions_Users_UserId]
GO
ALTER TABLE [dbo].[Companies]  WITH CHECK ADD  CONSTRAINT [FK_Companies_Locations_LocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Locations] ([LocationId])
GO
ALTER TABLE [dbo].[Companies] CHECK CONSTRAINT [FK_Companies_Locations_LocationId]
GO
ALTER TABLE [dbo].[FundiLocations]  WITH CHECK ADD  CONSTRAINT [FK_FundiLocations_FundiProfiles_FundiProfileId] FOREIGN KEY([FundiProfileId])
REFERENCES [dbo].[FundiProfiles] ([FundiProfileId])
GO
ALTER TABLE [dbo].[FundiLocations] CHECK CONSTRAINT [FK_FundiLocations_FundiProfiles_FundiProfileId]
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
GO
ALTER TABLE [dbo].[FundiProfiles] CHECK CONSTRAINT [FK_FundiProfiles_Locations_LocationId]
GO
ALTER TABLE [dbo].[FundiProfiles]  WITH CHECK ADD  CONSTRAINT [FK_FundiProfiles_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[FundiProfiles] CHECK CONSTRAINT [FK_FundiProfiles_Users_UserId]
GO
ALTER TABLE [dbo].[FundiSubscriptionQueues]  WITH CHECK ADD  CONSTRAINT [FK_FundiSubscriptionQueues_MonthlySubscriptions_MonthlySubscriptionId] FOREIGN KEY([MonthlySubscriptionId])
REFERENCES [dbo].[MonthlySubscriptions] ([MonthlySubscriptionId])
GO
ALTER TABLE [dbo].[FundiSubscriptionQueues] CHECK CONSTRAINT [FK_FundiSubscriptionQueues_MonthlySubscriptions_MonthlySubscriptionId]
GO
ALTER TABLE [dbo].[FundiSubscriptionQueues]  WITH CHECK ADD  CONSTRAINT [FK_FundiSubscriptionQueues_WorkSubCategories_FundiWorkSubCategoryId] FOREIGN KEY([FundiWorkSubCategoryId])
REFERENCES [dbo].[WorkSubCategories] ([WorkSubCategoryId])
GO
ALTER TABLE [dbo].[FundiSubscriptionQueues] CHECK CONSTRAINT [FK_FundiSubscriptionQueues_WorkSubCategories_FundiWorkSubCategoryId]
GO
ALTER TABLE [dbo].[FundiSubscriptions]  WITH CHECK ADD  CONSTRAINT [FK_FundiSubscriptions_MonthlySubscriptions_MonthlySubscriptionId] FOREIGN KEY([MonthlySubscriptionId])
REFERENCES [dbo].[MonthlySubscriptions] ([MonthlySubscriptionId])
GO
ALTER TABLE [dbo].[FundiSubscriptions] CHECK CONSTRAINT [FK_FundiSubscriptions_MonthlySubscriptions_MonthlySubscriptionId]
GO
ALTER TABLE [dbo].[FundiSubscriptions]  WITH CHECK ADD  CONSTRAINT [FK_FundiSubscriptions_WorkSubCategories_FundiWorkSubCategoryId] FOREIGN KEY([FundiWorkSubCategoryId])
REFERENCES [dbo].[WorkSubCategories] ([WorkSubCategoryId])
GO
ALTER TABLE [dbo].[FundiSubscriptions] CHECK CONSTRAINT [FK_FundiSubscriptions_WorkSubCategories_FundiWorkSubCategoryId]
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
ALTER TABLE [dbo].[MonthlySubscriptionQueues]  WITH CHECK ADD  CONSTRAINT [FK_MonthlySubscriptionQueues_FundiProfiles_FundiProfileId] FOREIGN KEY([FundiProfileId])
REFERENCES [dbo].[FundiProfiles] ([FundiProfileId])
GO
ALTER TABLE [dbo].[MonthlySubscriptionQueues] CHECK CONSTRAINT [FK_MonthlySubscriptionQueues_FundiProfiles_FundiProfileId]
GO
ALTER TABLE [dbo].[MonthlySubscriptionQueues]  WITH CHECK ADD  CONSTRAINT [FK_MonthlySubscriptionQueues_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MonthlySubscriptionQueues] CHECK CONSTRAINT [FK_MonthlySubscriptionQueues_Users_UserId]
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
/****** Object:  StoredProcedure [dbo].[CheckClientIsDueSubscriptionPayment]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CheckClientIsDueSubscriptionPayment] @clientUsername nvarchar(200), @durationInDays int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	select count(1) as IsDuePayment from dbo.Users us
	join dbo.ClientSubscriptions csub
	on us.UserId = csub.UserId
	where (us.Username = @clientUsername
	and (DATEDIFF(d, csub.DateUpdated, us.CreateTime) % 7) = 0) or
	((select count(*) from dbo.ClientSubScriptions where Username = @clientUsername) = 0 and 
	 csub.HasPaid = 0)
END
GO
/****** Object:  StoredProcedure [dbo].[FundiLevelOfEngagement]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[FundiLevelOfEngagement](@fundiProfileId int)
As
  select fn.FundiProfileId, u.FirstName, u.LastName, Count(*) NumberOfAssignments
  from dbo.FundiProfiles fn join
  dbo.ClientFundiContracts cfc on fn.FundiProfileId = cfc.FundiProfileId join
  dbo.Users u on fn.UserId = u.UserId
  where DateDiff(d,cfc.AgreedStartDate, getDate())>=0 and  DateDiff(d,cfc.AgreedEndDate, getDate())<=0 
  and fn.FundiProfileId = @fundiProfileId
  group by fn.FundiProfileId,u.FirstName,u.LastName
GO
/****** Object:  StoredProcedure [dbo].[GetAbsoluteFundiFee]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--This is the fee that fundi is next going to pay for a subcategory
CREATE procedure [dbo].[GetAbsoluteFundiFee](@fundiUserId varchar(max), @baseFundiSubsFee decimal = 25000.00, @secondFundiSubsFee decimal = 23000.00, 
@thirdFundiSubsFee decimal = 20000.00)
as
begin
	select dbo.[fncGetFundiSubScriptionAmountToPay](@fundiUserId,@baseFundiSubsFee,@secondFundiSubsFee,@thirdFundiSubsFee)
end
GO
/****** Object:  StoredProcedure [dbo].[GetAllFundiRatingByProfileId]    Script Date: 08/05/2023 20:07:33 ******/
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
  FROM [myfundi].[dbo].[FundiProfileAndReviewRatings] fr
  join [Users] u 
  on fr.UserId = u.UserId
  where fr.[FundiProfileId]=@fundiProfileId

GO
/****** Object:  StoredProcedure [dbo].[GetAllFundiWorkCategoriesForJobId]    Script Date: 08/05/2023 20:07:33 ******/
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
/****** Object:  StoredProcedure [dbo].[GetCoordinatesFromSequentialStringValues]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetCoordinatesFromSequentialStringValues](@coordinates NVarChar(Max))
as
begin
	select * into #tmpTable
	from dbo.Split(@coordinates,N',');
	declare @noOfrows int = 0;

	set @noOfrows = (select count(1) from #tmpTable)/2;

	With tb as(
	select distinct ROW_NUMBER() OVER(order by (SELECT 1)) as id,
	t1.item as lat,lead(t1.Item)  OVER(order by (SELECT 1)) as lng 
	from #tmpTable t1
	cross join 
	#tmpTable t2
	)
	select top(@noOfrows) id, lat,lng
	from tb
	WHERE lat is not null and lng is not null 
	and id%2=1;
end
GO
/****** Object:  StoredProcedure [dbo].[GetFundiAverageRatingByProfileId]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  Procedure [dbo].[GetFundiAverageRatingByProfileId](@fundiProfileId int)
AS
SELECT [FundiProfileId]
      ,Avg([Rating]) as FundiAverageRating
  FROM [myfundi].[dbo].[FundiProfileAndReviewRatings]
  where [FundiProfileId]=@fundiProfileId and Rating is not null
  group by [FundiProfileId]
GO
/****** Object:  StoredProcedure [dbo].[GetFundiByLocationVsJobLocation]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
		join Users us 
		on fn.UserId = us.UserId
		join MonthlySubscriptions msubs 
		on fn.FundiProfileId = msubs.FundiProfileId
		join FundiSubscriptions fsubs 
		on msubs.MonthlySubscriptionId = fsubs.MonthlySubscriptionId
		join Locations lc 
		on fn.LocationId = lc.LocationId
		join JobWorkCategories jwCats on
		fsubs.FundiWorkCategoryId = jwCats.WorkCategoryId
		and fsubs.FundiWorkSubCategoryId = jwCats.WorkSubCategoryId
		join WorkCategories workCat
		on jwCats.WorkCategoryId = workCat.WorkCategoryId
		join WorkSubCategories wsc on
		jwCats.WorkSubCategoryId = wsc.WorkSubCategoryId
		cross join Jobs j 
		join Locations jlc on
		j.LocationId = jlc.LocationId
		join ClientProfiles cp on 
		j.ClientProfileId = cp.ClientProfileId
		join Users clUser on
		cp.UserId = clUser.UserId		
		where (workCat.WorkCategoryType in (select item from dbo.Split(@workCategories,','))) and
		(wsc.WorkSubCategoryType in (select item from dbo.Split(@workSubCategories,',')))  
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
/****** Object:  StoredProcedure [dbo].[GetFundiByLocationVsJobLocationGeoLocation]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetFundiByLocationVsJobLocationGeoLocation](@distanceApart float, @workCategories nvarchar(4000),@coordinates varchar(max), @workSubCategories nvarchar(4000), @skip int=0, @take int=5)
AS
BEGIN
	With Results as(
		select fn.FundiProfileId as FundiProfileId, fn.UserId as FundiUserId, fn.ProfileSummary as FundiProfileSummary, fn.LocationId as FundiLocationId, us.Username as FundiUsername,us.FirstName as FundiFirstName, us.LastName as FundiLastName,
		fn.Skills as FundiSkills, fn.UsedPowerTools as FundiUsedPowerTools, Concat(lc.lat,',',lc.lng) as FundiLocationName, us.MobileNumber as FundiMobileNumber,
		Cast(lc.lat as float) as FundiLocationLat, Cast(lc.lng as float) as FundiLocationLong,jlc.LocationId as JobLocationId, jlc.Latitude as JobLocationLatitude,
		jlc.Longitude as JobLocationLongitude,j.JobId as JobId, j.JobName as JobName, j.JobDescription as JobDescription, jlc.LocationName as JobLocationName, cp.UserId as ClientUserId, cp.ClientProfileId as ClientProfileId, 
		clUser.FirstName as ClientFirstName,clUser.LastName as ClientLastName,clUser.Username as ClientUsername,clUser.MobileNumber as ClientMobileNumber,cp.AddressId as ClientAddressId,cp.ProfileSummary as ClientProfileSummary,
		(select distanceApart from dbo.ArePointsNearEnough(Cast(lc.lat as float),Cast(lc.lng as float),jlc.Latitude,jlc.Longitude,@distanceApart)) as distanceApart
		from FundiProfiles fn 
		join Users us 
		on fn.UserId = us.UserId
		join MonthlySubscriptions msubs 
		on fn.FundiProfileId = msubs.FundiProfileId
		join FundiSubscriptions fsubs 
		on msubs.MonthlySubscriptionId = fsubs.MonthlySubscriptionId
		join [dbo].[fncGetCoordinatesFromSequentialStringValues](@coordinates) lc
		on fn.FundiProfileId = lc.profileId
		join JobWorkCategories jwCats on
		fsubs.FundiWorkCategoryId = jwCats.WorkCategoryId
		and fsubs.FundiWorkSubCategoryId = jwCats.WorkSubCategoryId
		join WorkCategories workCat
		on jwCats.WorkCategoryId = workCat.WorkCategoryId
		join WorkSubCategories wsc on
		jwCats.WorkSubCategoryId = wsc.WorkSubCategoryId
		cross join Jobs j 
		join Locations jlc on
		j.LocationId = jlc.LocationId
		join ClientProfiles cp on 
		j.ClientProfileId = cp.ClientProfileId
		join Users clUser on
		cp.UserId = clUser.UserId		
		where (workCat.WorkCategoryType in (select item from dbo.Split(@workCategories,','))) and
		(wsc.WorkSubCategoryType in (select item from dbo.Split(@workSubCategories,',')))  
		and (select IsWithinDistance from dbo.ArePointsNearEnough(Cast(lc.lat as float),Cast(lc.lng as float),jlc.Latitude,jlc.Longitude,@distanceApart)) = 1
		Group By 
			fn.FundiProfileId, fn.UserId, fn.ProfileSummary, fn.LocationId, us.Username,us.FirstName,us.LastName,
			fn.Skills, fn.UsedPowerTools, us.MobileNumber,
			lc.lat, lc.lng,jlc.LocationId, jlc.Latitude,j.JobId, j.JobName, j.JobDescription,
			jlc.Longitude, jlc.LocationName, cp.UserId, cp.ClientProfileId, 
			clUser.Username, clUser.FirstName, clUser.LastName, clUser.MobileNumber,cp.AddressId,cp.ProfileSummary
		ORDER BY (select distanceApart from dbo.ArePointsNearEnough(Cast(lc.lat as float),Cast(lc.lng as float),jlc.Latitude,jlc.Longitude,@distanceApart))
		OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY
		)
		select distinct *
		from Results
END
GO
/****** Object:  StoredProcedure [dbo].[GetFundiProfileDatedOnSubscription]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE procedure [dbo].[GetFundiProfileDatedOnSubscription](@fundiProfileId int)
AS
SELECT fu.UserId,fp.FundiProfileId,ms.MonthlySubscriptionId, ms.SubscriptionName,ms.EndDate
  FROM [dbo].FundiProfiles fp 
  left join [myfundi].[dbo].[MonthlySubscriptions] ms on
  ms.FundiProfileId = fp.FundiProfileId join
  dbo.Users fu on fp.UserId = fu.UserId
  where fp.FundiProfileId = @fundiProfileId and  ((ms.EndDate < getDate()  or ms.EndDate is null) /*or ms.HasPaid <> 1*/)
  group by fu.UserId,fp.FundiProfileId,ms.MonthlySubscriptionId, ms.SubscriptionName,ms.EndDate
GO
/****** Object:  StoredProcedure [dbo].[GetFundiProfileDatedWithinDaysOfSubscriptionEnd]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetFundiProfileDatedWithinDaysOfSubscriptionEnd](@fundiProfileId int, @daysWithin int)
AS
SELECT fu.UserId,fp.FundiProfileId,ms.MonthlySubscriptionId, ms.SubscriptionName,ms.EndDate
  FROM [dbo].FundiProfiles fp 
  left join [myfundi].[dbo].[MonthlySubscriptions] ms on
  ms.FundiProfileId = fp.FundiProfileId join
  dbo.Users fu on fp.UserId = fu.UserId
  where fp.FundiProfileId = @fundiProfileId and (DatePart(yyyy,ms.EndDate) = DatePart(yyyy,getDate()) and 
  DatePart(m,ms.EndDate) = DatePart(m,getDate()) and (DateDiff(d,ms.EndDate,getDate()) <= @daysWithin
  or ms.EndDate is null) or ms.HasPaid <> 1)
  group by fu.UserId,fp.FundiProfileId,ms.MonthlySubscriptionId, ms.SubscriptionName,ms.EndDate
GO
/****** Object:  StoredProcedure [dbo].[GetFundiRatings]    Script Date: 08/05/2023 20:07:33 ******/
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
		join Users us 
		on fn.UserId = us.UserId
		join FundiWorkCategories fwcats1 
		on fn.FundiProfileId = fwcats1.FundiProfileId
		join Locations lc 
		on fn.LocationId = lc.LocationId
		join JobWorkCategories jwCats on
		fwcats1.WorkCategoryId = jwCats.WorkCategoryId
		and fwcats1.WorkSubCategoryId = jwCats.WorkSubCategoryId
		join WorkCategories workCat
		on fwcats1.WorkCategoryId = workCat.WorkCategoryId
		join WorkSubCategories wsc on
		fwcats1.WorkSubCategoryId = wsc.WorkSubCategoryId
		cross join Jobs j 
		join Locations jlc on
		j.LocationId = jlc.LocationId
		join ClientProfiles cp on 
		j.ClientProfileId = cp.ClientProfileId
		join Users clUser on
		cp.UserId = clUser.UserId
		where (workCat.WorkCategoryType in (select item from dbo.Split(@workCategories,','))) and
		(wsc.WorkSubCategoryType in (select item from dbo.Split(@workSubCategories,',')))  
		and  j.JobId = @jobId and cp.ClientProfileId = @clientProfileId and (select IsWithinDistance from dbo.ArePointsNearEnough(lc.Latitude,lc.Longitude,jlc.Latitude,jlc.Longitude,@distanceApart)) = 1
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
/****** Object:  StoredProcedure [dbo].[GetFundiRatingsGeoLocations]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetFundiRatingsGeoLocations](@clientProfileId int,@jobId int,@coordinates nvarchar(max), @distanceApart float, @workCategories nvarchar(4000), @workSubCategories nvarchar(4000), @skip int=0, @take int=5)
AS
BEGIN
	
With Results as(
		select fn.FundiProfileId as FundiProfileId, fn.UserId as FundiUserId, fn.ProfileSummary as FundiProfileSummary, fn.LocationId as FundiLocationId, us.Username as FundiUsername,us.FirstName as FundiFirstName, us.LastName as FundiLastName,
		fn.Skills as FundiSkills, fn.UsedPowerTools as FundiUsedPowerTools,  Concat(lc.lat,',',lc.lng) as FundiLocationName, us.MobileNumber as FundiMobileNumber,
		Cast(lc.lat as float) as FundiLocationLat, Cast(lc.lng as float) as FundiLocationLong,jlc.LocationId as JobLocationId, jlc.Latitude as JobLocationLatitude,
		jlc.Longitude as JobLocationLongitude,j.JobId as JobId, j.JobName as JobName, j.JobDescription as JobDescription, jlc.LocationName as JobLocationName, cp.UserId as ClientUserId, cp.ClientProfileId as ClientProfileId, 
		clUser.FirstName as ClientFirstName,clUser.LastName as ClientLastName,clUser.Username as ClientUsername,clUser.MobileNumber as ClientMobileNumber,cp.AddressId as ClientAddressId,cp.ProfileSummary as ClientProfileSummary,
		(select distanceApart from dbo.ArePointsNearEnough(Cast(lc.lat as float),Cast(lc.lng as float),jlc.Latitude,jlc.Longitude,@distanceApart)) as distanceApart
		from FundiProfiles fn 
		join Users us 
		on fn.UserId = us.UserId
		join FundiWorkCategories fwcats1 
		on fn.FundiProfileId = fwcats1.FundiProfileId
		join fncGetCoordinatesFromSequentialStringValues(@coordinates) lc
		on fn.FundiProfileId = lc.profileId
		join JobWorkCategories jwCats on
		fwcats1.WorkCategoryId = jwCats.WorkCategoryId
		and fwcats1.WorkSubCategoryId = jwCats.WorkSubCategoryId
		join WorkCategories workCat
		on fwcats1.WorkCategoryId = workCat.WorkCategoryId
		join WorkSubCategories wsc on
		fwcats1.WorkSubCategoryId = wsc.WorkSubCategoryId
		cross join Jobs j 
		join Locations jlc on
		j.LocationId = jlc.LocationId
		join ClientProfiles cp on 
		j.ClientProfileId = cp.ClientProfileId
		join Users clUser on
		cp.UserId = clUser.UserId
		where (workCat.WorkCategoryType in (select item from dbo.Split(@workCategories,','))) and
		(wsc.WorkSubCategoryType in (select item from dbo.Split(@workSubCategories,',')))  
		and  j.JobId = @jobId and cp.ClientProfileId = @clientProfileId and (select IsWithinDistance from dbo.ArePointsNearEnough(Cast(lc.lat as float),Cast(lc.lng as float),jlc.Latitude,jlc.Longitude,@distanceApart)) = 1
		Group By 
			fn.FundiProfileId, fn.UserId, fn.ProfileSummary, fn.LocationId, us.Username,us.FirstName,us.LastName,
			fn.Skills, fn.UsedPowerTools, Concat(lc.lat,',',lc.lng), us.MobileNumber,
			lc.Lat, lc.Lng,jlc.LocationId, jlc.Latitude,j.JobId, j.JobName, j.JobDescription,
			jlc.Longitude, jlc.LocationName, cp.UserId, cp.ClientProfileId, 
			clUser.Username, clUser.FirstName, clUser.LastName, clUser.MobileNumber,cp.AddressId,cp.ProfileSummary
		ORDER BY (select distanceApart from dbo.ArePointsNearEnough(Cast(lc.lat as float),Cast(lc.lng as float),jlc.Latitude,jlc.Longitude,@distanceApart))
		OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY
		)
		select distinct *
		from Results
END
GO
/****** Object:  StoredProcedure [dbo].[GetFundiWorkSubCategoriesForFundiByJobId]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetFundiWorkSubCategoriesForFundiByJobId](@jobId int, @fundiProfileId int)
As
Begin 
select distinct fwc.WorkCategoryId as WorkCategoryId, fwc.WorkSubCategoryId as WorkSubCategoryId, wc.WorkCategoryType as WorkCategoryType, wsc.WorkSubCategoryType as WorkSubCategoryType
from JobWorkCategories jwc
join WorkCategories wc on
wc.WorkCategoryId = jwc.WorkCategoryId
join WorkSubCategories wsc on
jwc.WorkSubCategoryId = wsc.WorkSubCategoryId
join FundiWorkCategories fwc on
wc.WorkCategoryId = fwc.WorkCategoryId and
fwc.WorkSubCategoryId = wsc.WorkSubCategoryId 
where jwc.JobId = @jobId and fwc.FundiProfileId = @fundiProfileId
group by fwc.WorkCategoryId, fwc.WorkSubCategoryId, wc.WorkCategoryType , wsc.WorkSubCategoryType
end
GO
/****** Object:  StoredProcedure [dbo].[GetLastSubscriptionExistingTotalAbsoluteFundiFee]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--This is the fee that fundi has already paid:
CREATE procedure [dbo].[GetLastSubscriptionExistingTotalAbsoluteFundiFee](@fundiUserId varchar(max))
as
BEGIN
	begin
		select sum(fs.SubscriptionFee) as AbsoluteExistingFee
		from dbo.FundiSubscriptions fs
		join dbo.MonthlySubscriptions ms 
		on fs.MonthlySubscriptionId = ms.MonthlySubscriptionId
		join dbo.FundiProfiles fp
		on ms.FundiProfileId = fp.FundiProfileId
			where fp.FundiProfileId = (select top(1) fp2.fundiProfileId 
				from dbo.Users u 
				join dbo.FundiProfiles fp2
				on u.UserId = fp2.UserId and u.UserId = @fundiUserId) and 
				ms.HasPaid = 1 and datediff(d,ms.startDate,getDate()) <= 31
	end
End
GO
/****** Object:  StoredProcedure [dbo].[GetWorkSubCategoriesByWorkCategoryId]    Script Date: 08/05/2023 20:07:33 ******/
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
/****** Object:  StoredProcedure [dbo].[GetWorkSubCategoriesForFundiByJobId]    Script Date: 08/05/2023 20:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetWorkSubCategoriesForFundiByJobId](@jobId int, @fundiProfileId int)
As
Begin
	select distinct fs.FundiWorkCategoryId as WorkCategoryId, fs.FundiWorkSubCategoryId as WorkSubCategoryId, wc.WorkCategoryType as WorkCategoryType, wsc.WorkSubCategoryType as WorkSubCategoryType
	from WorkCategories wc join
	JobWorkCategories jwc on
	wc.WorkCategoryId = jwc.WorkCategoryId join
	FundiSubscriptions fs on
	wc.WorkCategoryId = fs.FundiWorkCategoryId 
	join WorkSubCategories wsc on
	wsc.WorkSubCategoryId = fs.FundiWorkSubCategoryId
	join Jobs j on
	j.JobId = jwc.JobId
	join MonthlySubscriptions ms on
	fs.MonthlySubscriptionId = ms.MonthlySubscriptionId
	join FundiProfiles fp on fp.FundiProfileId = ms.FundiProfileId
	where j.JobId = @jobId and fp.FundiProfileId = @fundiProfileId
	and datediff(d,getDate(),fs.startDate) <= 30
	group by fs.FundiWorkCategoryId, fs.FundiWorkSubCategoryId, wc.WorkCategoryType , wsc.WorkSubCategoryType
end

GO
