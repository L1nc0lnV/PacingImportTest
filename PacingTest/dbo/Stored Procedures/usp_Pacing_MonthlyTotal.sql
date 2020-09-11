CREATE PROCEDURE [dbo].[usp_Pacing_MonthlyTotal]
	
	-- Params passed into stored procedures to generate data by criteria. Defaults to current month, override will run historical
	@FY_YN int,
	@SY_YN int,
	@FY_MN int,
	@SY_MN int,
	@clientID int = 1000 -- For now, just State Farm. Need to link this to the BT_Client_ID
AS
 
 DECLARE @QueryType varchar(20) = 'currmonth';
 DECLARE @runCounter int = (select isnull(max(DataRunCount),0)+1 from PacingMonthly)


  -- Format input dates for join criteria (Cody)
  DECLARE @MonthAssign TABLE (FirstYear_YearNumber int, SecondYear_YearNumber int, FirstYear_MonthNumber int, SecondYear_MonthNumber int)

  insert into @MonthAssign Values (@FY_YN, @SY_YN, @FY_MN, @SY_MN);

declare @CurrentMonthCalcs TABLE (
	[Reporting Tactic] [varchar](255),
	[Vendor] [varchar](255),
	[Segment] [varchar](255),
	[MarketArea] [varchar](255),
	[MediaState] [varchar](255),
	[AssociateID] [varchar](255),
	[STCode] [varchar](255),
	[Type2019] [varchar](255),
	[AGENTNAME] [varchar](255),
	[TerminationDate] varchar(200),
	[Radius] [int],
	[NumberOfTargetedZips] [varchar](255),
	[Year] [varchar](255),
	[MonthNum] [nvarchar](255),
	[Current Month Planned Impressions] decimal(18,2),
	[Current Month Impressions Delivery] decimal(18,2),
	[Current Month Planned Clicks] [decimal](18, 2),
	[Current Month Clicks] decimal(18,2),
	[Current Month Spend] [decimal](18, 4),
	[SBMSBudget] [decimal](18, 2),
	[Total Planned Months] [int],
	[FirstYear_MonthNumber] [int],
	[PaymentDeactivationDate] varchar(200),
	--[ClosedDate] varchar(200), -- Closed column from budget import
	[TargetDemo] [varchar](255),
	[ProcessSource] [varchar](255))


insert into @CurrentMonthCalcs
exec usp_Pacing_AsianIBA @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_AutoTargeting @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_Broadcast @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_Cinema @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_DisplayAdvertising @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_GasStationTV @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_HispStreamingAudio @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_Homeowners @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_Newspaper @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_Outdoor @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_PlaceBased @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_SocialMedia @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_StreamingAudio @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_Telemundo @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_Univision @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_OnlineVideoAds @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;
insert into @CurrentMonthCalcs
exec usp_Pacing_HispIba @QueryType, @FY_YN, @SY_YN, @FY_MN, @SY_MN;






WITH CTE ([Month],[Year],[ProcessSource],[AssociateID],[AgentName],[ReportingTactic],Segment,[MarketArea],[MediaState],[STCode],[Type2019],[Radius],[NumberOfTargetedZips],
		   SBMSBudget,[TotalPlannedMonths],[PeriodSpend],[ImpressionsDelivered],[ImpressionsPlanned],
		   [ImpressionsPercentDelivered], [ZeroDollarImpressionsFlag],[Clicks],[ClicksPlanned],[ClicksPercent],[OutOfScheduleFlag],
		   [PercentOfBudget],[TerminationDate],[Vendor],[PaymentDeactivationDate],[TargetDemo])
AS(
select
	 cm.MonthNum
	,cm.Year
	,cm.ProcessSource
	,cm.[AssociateID]
	,[Agent Name] = ma.AgentLastName + ', ' + ma.AgentFirstName
	,[Reporting Tactic]
	,Segment
	,cm.MarketArea
	,cm.MediaState
	,cm.STCode
	,cm.Type2019
	,cm.Radius
	,cm.NumberOfTargetedZips
	,SBMSBudget
	,[Total Planned Months]
	,[Current Month Spend]
	,[Current Month Impressions Delivery]
	,[Current Month Planned Impressions]
	,CASE
		When ([Current Month Planned Impressions] is not null AND [Current Month Planned Impressions] <> 0)
			 AND ([Current Month Impressions Delivery] is not null AND [Current Month Impressions Delivery] <> 0)
			THEN convert(varchar(25),convert(decimal(18,2),([Current Month Impressions Delivery] / [Current Month Planned Impressions]) * 100))
		when ([Current Month Planned Clicks] = 0 OR [Current Month Planned Clicks] is null) AND ([current month spend] > 0 AND [Current Month Impressions Delivery] = 0)
			then 'Delivered Not Scheduled - Money Spent'
		when [Current Month Planned Clicks] = 0 OR [Current Month Planned Clicks] is null
			then 'Delivered Not Scheduled - Added Value'
	END AS [MonthlyImpressionsPercentDelivered]
	,case
	when ([current month spend] = 0 AND [Current Month Impressions Delivery] > 0)
		then '$0 Added Value'
	else ''
	END as [Zero Dollar Impressions Flag]
	,[Current Month Clicks]
	,[Current Month Planned Clicks]
	,CASE
		WHEN [Reporting Tactic] like 'Social Media' AND ([Current Month Planned Clicks] is not null AND [Current Month Planned Clicks] <> 0)
			AND ([Current Month Clicks] is not null AND [Current Month Clicks] <> 0)
		THEN convert(varchar(15),convert(decimal(18,2),([Current Month Clicks] / [Current Month Planned Clicks]) * 100))
		ELSE 'N/A'
	END AS [Click Percentage]
	,case
		when [Reporting Tactic] not like 'Social Media' AND ([Current Month Planned Impressions] = 0 OR [Current Month Planned Impressions] is null)
			then 'OOS1000'
		when [Reporting Tactic] not like 'Social Media' AND ([Current Month Impressions Delivery] = 0 OR ([Current Month Impressions Delivery] / [Current Month Planned Impressions] <= .1))
			then 'OOS1001'
		when [Reporting Tactic] like 'Social Media' AND ([Current Month Planned Clicks] = 0 OR [Current Month Planned Clicks] is null)
			then 'OOS1000'
		when [Reporting Tactic] like 'Social Media' AND ([Current Month Clicks] = 0 OR ([Current Month Clicks] / [Current Month Planned Clicks] <= .1))
			then 'OOS1001'
		else 'OOS1002'
	END as [OutofScheduleFlagID]
	,CASE
		WHEN [Current Month Spend] <> 0 AND SBMSBudget <> 0
			THEN convert(decimal(18,2),([Current Month Spend] / SBMSBudget)*100)
		WHEN [Current Month Spend] = 0
			THEN 0
	END AS [Percent of Budget]
	,cm.TerminationDate
	,cm.Vendor
	,cm.PaymentDeactivationDate
	,cm.TargetDemo
from @CurrentMonthCalcs cm
join MasterAgentSource ma
	on ma.AssociateID = cm.AssociateID )

select
	 @clientID as [ClientID]
	,Getdate() as ProcessPeriod
	,*
	,CASE
		WHEN ISNUMERIC([ImpressionsPercentDelivered]) = 0  THEN 'N/A'
		WHEN convert(decimal(18,2),[ImpressionsPercentDelivered]) >= 100  THEN 'IMP1000'
		WHEN convert(decimal(18,2),[ImpressionsPercentDelivered]) >= 75 THEN 'IMP1001'
		WHEN convert(decimal(18,2),[ImpressionsPercentDelivered]) >= 50 THEN  'IMP1002'
		WHEN convert(decimal(18,2),[ImpressionsPercentDelivered]) >= 25 THEN 'IMP1003'
		WHEN convert(decimal(18,2),[ImpressionsPercentDelivered]) >= 10 THEN 'IMP1004'
		ELSE 'IMP1005'
	END AS [ImpressionsPacingRangeID]
	,CASE
		WHEN ISNUMERIC([ClicksPercent]) = 0  THEN 'N/A'
		WHEN convert(decimal(18,2),[ClicksPercent]) >= 100  THEN 'IMP1006'
		WHEN convert(decimal(18,2),[ClicksPercent]) >= 75 THEN 'IMP1007'
		WHEN convert(decimal(18,2),[ClicksPercent]) >= 50 THEN  'IMP1008'
		WHEN convert(decimal(18,2),[ClicksPercent]) >= 25 THEN 'IMP1009'
		WHEN convert(decimal(18,2),[ClicksPercent]) >= 10 THEN 'IMP1010'
		ELSE 'IMP1011'
	END AS [ClickPacingRangeID]
	,CASE
		WHEN [ImpressionsDelivered] = 0 THEN 0
		ELSE convert(decimal(18,3),(([Clicks] / [ImpressionsDelivered])*100))
	END AS CTR
		,CASE
		WHEN (ISNUMERIC([PeriodSpend]) = 1 AND ISNUMERIC([ImpressionsDelivered]) = 1 AND
						[PeriodSpend] <> 0 AND [ImpressionsDelivered] <> 0)
			THEN convert(decimal(18,2),[PeriodSpend]/([ImpressionsDelivered]/1000))
		ELSE 0
	END AS CPM
	,CASE
		WHEN [PercentOfBudget] <= .15 then 'FLAG1003'                                                                   -- Under Spent
		WHEN [ImpressionsDelivered] = 0 or [ImpressionsDelivered]  is null then 'FLAG1000'                              -- Reflight
		WHEN ([ImpressionsPlanned] = 0 or [ImpressionsPlanned] is null) AND [ImpressionsDelivered] > 0 then 'FLAG1001'  -- DNS
		--WHEN CTE.ClosedDate is not null then 'FLAG1007'                                                                 -- Closed
		WHEN CTE.PaymentDeactivationDate is not null then 'FLAG1006'                                                    -- Deactivated
		WHEN CTE.[TerminationDate] is not null then 'FLAG1005' + CTE.[OutOfScheduleFlag]                                -- Terminated - (date)
		WHEN convert(decimal(18,3),(([Clicks] / [ImpressionsDelivered])*100)) < .1 AND [Clicks] <= 5 THEN 'FLAG1002'	-- Click/CTR
		ELSE 'FLAG1004'																									-- None
	END AS Flag,
	NotesID = null,
	Getdate() AS CreatedOn
	,'MediaManagerETL' as CreatedBy
	,null as UpdatedOn
	,null as UpdatedBy
	,'' as [Severity]
	into #PacingMonthlyFinal
	from CTE

	insert into dbo.PacingMonthly
	Select
		[ProcessSource],
		[ClientID],
		[EnrollmentPeriod] = 1,
		[DataPeriod] = cast(getdate() as date),
		[DataRunCount] = @runCounter, -- Incremental counter, if this gets re-run multiple times
		[Month], -- month on record
		[Year], -- year on record
		[ReportingTactic], 
		[Vendor],
		[AssociateID], 
		[AgentName],
		[TerminationDate], 
		[Segment], 
		[MarketArea],
		[MediaState],
		[STCode],
		[Type2019],
		[Radius],
		[NumberOfTargetedZips],
		[ImpressionsPlanned], 
		[ImpressionsDelivered],
		[ImpressionsPacingRange] = impgrade.value,
		[ImpressionsPercentDelivered],
		[ZeroDollarImpressionsFlag],
		[Clicks], 
		[ClicksPlanned], 
		[ClicksPercent],
		[ClicksPacingRange] = clickgrade.value,
		[SBMSBudget],
		[PeriodSpend],
		[PercentOfBudget],
		[TotalPlannedMonths],
		[OutOfScheduleFlag] = oosflag.value,
		[PaymentDeactivationDate],
		[TargetDemo],
		[CTR],
		[CPM],
		[Flag] = flag.value,
		null,
		null,
		final.[CreatedOn], 
		final.[CreatedBy], 
		final.[UpdatedOn], 
		final.[UpdatedBy],
		[Severity]
	
	FROM #PacingMonthlyFinal final
	left JOIN PacingPerformanceAttributes flag
		on final.flag = flag.attributeid
	LEFT JOIN PacingPerformanceAttributes oosflag
		on final.OutOfScheduleFlag = oosflag.attributeID
	LEFT JOIN PacingPerformanceAttributes impgrade
		on final.[ImpressionsPacingRangeID] = impgrade.attributeID
	LEFT JOIN PacingPerformanceAttributes clickgrade
		on final.ClickPacingRangeID = clickgrade.attributeID


	drop table #PacingMonthlyFinal