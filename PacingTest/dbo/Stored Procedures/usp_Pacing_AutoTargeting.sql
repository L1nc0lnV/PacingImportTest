CREATE PROCEDURE [dbo].[usp_Pacing_AutoTargeting]
	
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
	SELECT atr.[BudgetLookup], Count(atr.[PlannedImpressions]) AS [Total Planned Months]
	into #atr_planned_months
	FROM [MedManAutoTargeting] atr
	GROUP BY atr.[BudgetLookup];

	
	SELECT
        atr.[ReportingTactic],
        [Vendor] = '',
		'' as [Segment],
        ma.[MarketArea],
        ma.[MediaState],
        atr.[AssociateID],
        ma.[STCode],
        ma.Type2019,
        atr.[AGENTNAME],
        ma.[TerminationDate],
        mb.Radius,
        ma.NumberOfTargetedZips,
        atr.Year,
        atr.[MonthNum],
        Sum(atr.[PlannedImpressions]) AS [Current Month Planned Impressions],
        Sum(atr.[DeliveredImpressionstodate]) AS [Current Month Impressions Delivery],
		Sum([atr].PlannedClicks) AS [Current Month Planned Clicks],
        Sum(atr.Clicks) AS [Current Month Clicks],
        Sum(atr.Spend) AS [Current Month Spend],
        mb.[SBMSBudget],
        atrp.[Total Planned Months] AS [Total Planned Months],
		FirstYear_MonthNumber,
        mb.[PaymentDeactivationDate],
        --mb.Closed,
        mb.[TargetDemo],
        [ProcessSource] = 'AutoTargeting' 
        --SecondYear_MonthNumber,
        --FirstYear_YearNumber,
        --SecondYear_YearNumber 
    FROM
        @MonthAssign MonthAssign,
        [MasterAgentSource] as ma
    INNER JOIN
        (
            (
                MasterBudgetSource as mb
            INNER JOIN
                MedManAutoTargeting as atr
                    ON mb.AssociateIDTactic = atr.[BudgetLookup]
                ) 
        INNER JOIN
            #atr_planned_months atrp
                ON atr.[BudgetLookup] = atrp.[BudgetLookup]
            ) 
                ON ma.[AssociateID] = atr.[AssociateID] 
        GROUP BY
            atr.[ReportingTactic],
            ma.[MarketArea],
            ma.[MediaState],
            atr.[AssociateID],
            ma.[STCode],
            ma.Type2019,
            atr.[AGENTNAME],
            ma.[TerminationDate],
            mb.radius,
            ma.NumberOfTargetedZips,
            atr.Year,
            atr.MonthNum,
            mb.[SBMSBudget],
            atrp.[Total Planned Months],
            mb.[PaymentDeactivationDate],
            --mb.Closed,
            mb.[TargetDemo],
            FirstYear_MonthNumber,
            SecondYear_MonthNumber,
            FirstYear_YearNumber,
            SecondYear_YearNumber,
            FirstYear_MonthNumber 
        HAVING
            (
               atr.Year =[FirstYear_YearNumber]
			   AND
			   atr.MonthNum=[FirstYear_MonthNumber]
                )


				drop table #atr_planned_months
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
	
	SELECT
        [Auto Trader].[BudgetLookup],
        [Auto Trader].[AssociateID],
        [Auto Trader].Year,
        [Auto Trader].MonthNum,
        [Auto Trader].[DataType],
        Count([Auto Trader].[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManAutoTargeting] [Auto Trader] 
    GROUP BY
        [Auto Trader].[BudgetLookup],
        [Auto Trader].[AssociateID],
        [Auto Trader].Year,
        [Auto Trader].MonthNum,
        [Auto Trader].[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    [Auto Trader].Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    [Auto Trader].MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    [Auto Trader].[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    [Auto Trader].Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    [Auto Trader].MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    [Auto Trader].[DataType]
                )='Planned'
            )
        );

		SELECT [QRY - AutoTargeting - Months Complete 1].[BudgetLookup], Sum([QRY - AutoTargeting - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - AutoTargeting - Months Complete 1]
		GROUP BY [QRY - AutoTargeting - Months Complete 1].[BudgetLookup];


		SELECT
        [Auto Trader].[ReportingTactic],
		'Media Math' as [Vendor],
        '' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        [Auto Trader].[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum([Auto Trader].[PlannedImpressions]) AS [Total Planned Impressions],
        Count([Auto Trader].[PlannedImpressions]) AS [Planned Months],
        Avg([Auto Trader].[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum([Auto Trader].DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum([Auto Trader].Clicks) AS [Clicks to Date],
        Sum([Auto Trader].Spend) AS [Spend to Date],
        [QRY - AutoTargeting - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].PaymentDeactivationDate,
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
        'MediaManagerETL' AS CreatedBy,
        'AutoTargeting' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                [dbo].[MedManAutoTargeting] [Auto Trader] 
            INNER JOIN
                #MonthComplete2 [QRY - AutoTargeting - Months Complete 2] 
                    ON [Auto Trader].[BudgetLookup] = [QRY - AutoTargeting - Months Complete 2].[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = [Auto Trader].[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = [Auto Trader].[BudgetLookup] 
            GROUP BY
                [Auto Trader].[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].STCode,
                [QRY - Master Agent Profile].Type2019,
                [Auto Trader].[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - AutoTargeting - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];
    

	END
END