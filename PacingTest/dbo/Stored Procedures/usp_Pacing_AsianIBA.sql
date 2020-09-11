CREATE PROCEDURE [dbo].[usp_Pacing_AsianIBA]

	@QueryType varchar(20),
	@FY_YN int,
	@SY_YN int,
	@FY_MN int,
	@SY_MN int
AS
	
  DECLARE @MonthAssign TABLE (FirstYear_YearNumber int, SecondYear_YearNumber int, FirstYear_MonthNumber int, SecondYear_MonthNumber int)

  insert into @MonthAssign Values (@FY_YN, @SY_YN, @FY_MN, @SY_MN);

  BEGIN
  IF @QueryType = 'currmonth'
  BEGIN
  -- Return monthly data

  With tpm (BudgetLookup, [Total Planned Months])
	AS(
  	SELECT [Asian IBA].[BudgetLookup], Count([Asian IBA].[PlannedImpressions]) AS [Total Planned Months]
	FROM [dbo].[MedManAsianIba] [Asian IBA]
	GROUP BY [Asian IBA].[BudgetLookup])

  SELECT
        [Asian IBA].[ReportingTactic],
		'' as Vendor,
        [Asian IBA].[AsianSegment] as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        [Asian IBA].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        [Asian IBA].[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        [Asian IBA].Year,
        [Asian IBA].MonthNum,
        Sum([Asian IBA].[PlannedImpressions]) AS [Current Month Planned Impressions],
        Sum([Asian IBA].DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum([Asian IBA].PlannedClicks) AS [Current Month Planned Clicks],
        Sum([Asian IBA].Clicks) AS [Current Month Clicks],
        Sum([Asian IBA].Spend) AS [Current Month Spend],
        [Agent Budgets].[SBMSBudget],
        [Qry - Asian IBA - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        MonthAssign.FirstYear_MonthNumber,
        [Agent Budgets].PaymentDeactivationDate,
        --[Agent Budgets].Closed,
		[Agent Budgets].[TargetDemo],
        [ProcessSource] = 'AsianIBA' 

		--  MonthAssign.FirstYear_YearNumber,
    FROM
        @MonthAssign MonthAssign,
        (([dbo].[MedManAsianIba] [Asian IBA] 
    INNER JOIN
        [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
            ON [Asian IBA].[AssociateID] = [QRY - Master Agent Profile].[AssociateID]
        ) 
	INNER JOIN
		[dbo].[MasterBudgetSource] [Agent Budgets] 
			ON [Asian IBA].[BudgetLookup] = [Agent Budgets].AssociateIDTactic
		) 
	INNER JOIN
	tpm [Qry - Asian IBA - Total Planned Months] 
		ON [Asian IBA].[BudgetLookup] = [Qry - Asian IBA - Total Planned Months].[BudgetLookup] 
	GROUP BY
	[Asian IBA].[ReportingTactic],
	[Asian IBA].[AsianSegment],
	[QRY - Master Agent Profile].[MarketArea],
	[QRY - Master Agent Profile].[MediaState],
	[Asian IBA].[AssociateID],
	[QRY - Master Agent Profile].[STCode],
	[QRY - Master Agent Profile].Type2019,
	[Asian IBA].[AGENTNAME],
	[QRY - Master Agent Profile].[TerminationDate],
	[Agent Budgets].Radius,
	[QRY - Master Agent Profile].NumberOfTargetedZips,
	[Asian IBA].Year,
	[Asian IBA].MonthNum,
	[Agent Budgets].[SBMSBudget],
	[Qry - Asian IBA - Total Planned Months].[Total Planned Months],
	MonthAssign.FirstYear_MonthNumber,
	[Agent Budgets].PaymentDeactivationDate,
    --[Agent Budgets].Closed,
	[Agent Budgets].[TargetDemo],
	MonthAssign.FirstYear_YearNumber 
	HAVING
	(
		(
			(
				[Asian IBA].Year
			)=[FirstYear_YearNumber]
		) 
		AND (
			(
				[Asian IBA].MonthNum
			)=[FirstYear_MonthNumber]
		)
	);
	END

-- Return complete data
IF @QueryType = 'total'
	BEGIN

	SELECT
        MedManAsianIBA.[BudgetLookup],
        MedManAsianIBA.[AssociateID],
        MedManAsianIBA.Year,
        MedManAsianIBA.monthnum,
        MedManAsianIBA.[DataType],
        Count(MedManAsianIBA.[AssociateID]) AS [CountOfAssociate ID],
        ma.FirstYear_MonthNumber,
        ma.SecondYear_MonthNumber,
        ma.FirstYear_YearNumber,
        ma.SecondYear_YearNumber 
	into #MonthComplete1
    FROM
        MedManAsianIBA,
        @MonthAssign ma
    GROUP BY
        MedManAsianIBA.[BudgetLookup],
        MedManAsianIBA.[AssociateID],
        MedManAsianIBA.Year,
        MedManAsianIBA.MonthNum,
        MedManAsianIBA.[DataType],
        ma.FirstYear_MonthNumber,
        ma.SecondYear_MonthNumber,
        ma.FirstYear_YearNumber,
        ma.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    MedManAsianIBA.Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    MedManAsianIBA.MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    MedManAsianIBA.[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    MedManAsianIBA.Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    MedManAsianIBA.MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    MedManAsianIBA.[DataType]
                )='Planned'
            )
        );

		SELECT
			#MonthComplete1.[BudgetLookup],
			Sum(#MonthComplete1.[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1
		GROUP BY
			#MonthComplete1.[BudgetLookup];


		SELECT
        MedManAsianIBA.[ReportingTactic],
		'' as [Vendor],
        MedManAsianIBA.[AsianSegment] as [Segment],
        MasterAgentSource.[MarketArea],
        MasterAgentSource.MediaState,
        MasterAgentSource.[AssociateID],
        MasterAgentSource.[STCode],
        MasterAgentSource.[Type2019],
        MedManAsianIBA.[AGENTNAME],
        MasterAgentSource.[TerminationDate],
        MasterBudgetSource.Radius,
        MasterAgentSource.NumberOfTargetedZips,
        Sum(MedManAsianIBA.PlannedImpressions) AS [Total Planned Impressions],
        Count(MedManAsianIBA.PlannedImpressions) AS [Planned Months],
        Avg(MedManAsianIBA.PlannedImpressions) AS [Impressions Per Month],
        MasterBudgetSource.SBMSBudget,
        Sum(MedManAsianIBA.DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum(MedManAsianIBA.Clicks) AS [Clicks to Date],
        Sum(MedManAsianIBA.Spend) AS [Spend to Date],
        #MonthComplete2.[SumOfCountOfAssociate ID] AS [Completed Months],
        MasterBudgetSource.[PaymentDeactivationDate],
        MasterBudgetSource.[TargetDemo],
        Getdate() AS CreatedOn,
        'MediaManagerETL' AS CreatedBy,
        'AsianIBA' AS ProcessSource

   --     Sum([Facebook News Feed].PlannedClicks) AS [Total Planned Clicks],
			--Count([Facebook News Feed].[PlannedClicks]) AS [Planned Months],
			--Avg([Facebook News Feed].[PlannedClicks]) AS [Clicks Per Month]
    FROM
        #MonthComplete2
    INNER JOIN
        (
            (
                [MedManAsianIba] 
            INNER JOIN
                MasterBudgetSource
                    ON MedManAsianIBA.[BudgetLookup] = MasterBudgetSource.AssociateIDTactic
                ) 
        INNER JOIN
            MasterAgentSource 
                ON MedManAsianIBA.[AssociateID] = MasterAgentSource.[AssociateID]
            ) 
                ON #MonthComplete2.[BudgetLookup] = MedManAsianIBA.[BudgetLookup] 
        GROUP BY
            MedManAsianIBA.[ReportingTactic],
            MedManAsianIBA.[AsianSegment],
            MasterAgentSource.[MarketArea],
            MasterAgentSource.MediaState,
            MasterAgentSource.[AssociateID],
            MasterAgentSource.[STCode],
            MasterAgentSource.[Type2019],
            MedManAsianIBA.[AGENTNAME],
            MasterAgentSource.[TerminationDate],
            MasterBudgetSource.Radius,
            MasterAgentSource.NumberOfTargetedZips,
            MasterBudgetSource.[SBMSBudget],
            #MonthComplete2.[SumOfCountOfAssociate ID],
            MasterBudgetSource.[PaymentDeactivationDate],
            MasterBudgetSource.[TargetDemo];


			drop table #MonthComplete1, #MonthComplete2

	END
END