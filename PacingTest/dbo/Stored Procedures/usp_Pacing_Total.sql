CREATE PROCEDURE [dbo].[usp_Pacing_Total]
	
  	@QueryType varchar(20) = 'total',
	@FY_YN int,
	@SY_YN int,
	@FY_MN int,
	@SY_MN int
AS
	
  DECLARE @MonthAssign TABLE (FirstYear_YearNumber int, SecondYear_YearNumber int, FirstYear_MonthNumber int, SecondYear_MonthNumber int)

  DECLARE @TotalStaging TABLE(
	[ReportingTactic] [nvarchar](255),
	[Vendor] [nvarchar](255),
	[Segment] [nvarchar](255),
	[MarketArea] [nvarchar](255),
	[MediaState] [nvarchar](255),
	[AssociateID] [nvarchar](255),
	[STCode] [nvarchar](255),
	[Type2019] [nvarchar](255),
	[AGENTNAME] [nvarchar](255),
	[TerminationDate] [datetime],
	[Radius] [int],
	[NumberOfTargetedZips] int,
	[TotalPlannedImpressions] decimal(18,2),
	[PlannedMonths] int,
	[ImpressionsPerMonth] decimal(18,2),
	[SBMSBudget] [decimal](18, 2),
	[ImpressionsToDate] decimal(18,2),
	[ClicksToDate] decimal(18,2),
	SpendToDate decimal(18,2),
	CompletedMonths int,
	[PaymentDeactivationDate] [datetime],
	[TargetDemo] [nvarchar](255),
	[CreatedOn] datetime null,
	[CreatedBy] nvarchar(255) null,
	[ProcessSource] nvarchar(255))

	insert into @MonthAssign Values (@FY_YN, @SY_YN, @FY_MN, @SY_MN);

	insert into @TotalStaging
	exec usp_Pacing_AsianIBA @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_AutoTargeting @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_Broadcast @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_Cinema @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_DisplayAdvertising @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_GasStationTV @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_HispStreamingAudio @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_Homeowners @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_Newspaper @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_Outdoor @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_PlaceBased @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_SocialMedia @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_StreamingAudio @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_Telemundo @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_Univision @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_OnlineVideoAds @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
	insert into @TotalStaging
	exec usp_Pacing_HispIba @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;



insert into PacingTotal
select *, null, null, null from @TotalStaging

update PacingTotal
set CreatedBy = 'MediaManagerETL', CreatedOn = Getdate()
where CreatedBy is null and CreatedOn is null