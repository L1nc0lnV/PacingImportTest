CREATE PROCEDURE [dbo].[usp_Pacing_Outdoor]
	
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
	SELECT tactic.[BudgetLookup], Count(tactic.[PlannedImpressions]) AS [Total Planned Months]
	into #tactic_planned_months
	FROM [MedManOutdoor] tactic
	GROUP BY tactic.[BudgetLookup];

	
	SELECT
        tactic.[ReportingTactic],
        [Vendor] = '',
		'' as [Segment],
        ma.[MarketArea],
        ma.[MediaState],
        tactic.[AssociateID],
        ma.[STCode],
        ma.Type2019,
        tactic.[AGENTNAME],
        ma.[TerminationDate],
        mb.Radius,
        ma.NumberOfTargetedZips,
        tactic.Year,
        tactic.[MonthNum],
        Sum(tactic.[PlannedImpressions]) AS [Current Month Planned Impressions],
        Sum(tactic.[DeliveredImpressionstodate]) AS [Current Month Impressions Delivery],
		Sum([tactic].PlannedClicks) AS [Current Month Planned Clicks],
        Sum(tactic.Clicks) AS [Current Month Clicks],
        Sum(tactic.Spend) AS [Current Month Spend],
        mb.[SBMSBudget],
        tacticp.[Total Planned Months] AS [Total Planned Months],
		FirstYear_MonthNumber,
        mb.[PaymentDeactivationDate],
     --   mb.Closed,
        mb.[TargetDemo],
        [ProcessSource] = 'Outdoor' 
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
                MedManOutdoor as tactic
                    ON mb.AssociateIDTactic = tactic.[BudgetLookup]
                ) 
        INNER JOIN
            #tactic_planned_months tacticp
                ON tactic.[BudgetLookup] = tacticp.[BudgetLookup]
            ) 
                ON ma.[AssociateID] = tactic.[AssociateID] 
        GROUP BY
            tactic.[ReportingTactic],
            ma.[MarketArea],
            ma.[MediaState],
            tactic.[AssociateID],
            ma.[STCode],
            ma.Type2019,
            tactic.[AGENTNAME],
            ma.[TerminationDate],
            mb.radius,
            ma.NumberOfTargetedZips,
            tactic.Year,
            tactic.MonthNum,
            mb.[SBMSBudget],
            tacticp.[Total Planned Months],
            mb.[PaymentDeactivationDate],
         --   mb.Closed,
            mb.[TargetDemo],
            FirstYear_MonthNumber,
            SecondYear_MonthNumber,
            FirstYear_YearNumber,
            SecondYear_YearNumber,
            FirstYear_MonthNumber 
        HAVING
            (
               tactic.Year =[FirstYear_YearNumber]
			   AND
			   tactic.MonthNum=[FirstYear_MonthNumber]
                )


				drop table #tactic_planned_months
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
	
	SELECT
        [Outdoor].[BudgetLookup],
        [Outdoor].[AssociateID],
        [Outdoor].Year,
        [Outdoor].MonthNum,
        [Outdoor].[DataType],
        Count([Outdoor].[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManOutdoor] [Outdoor] 
    GROUP BY
        [Outdoor].[BudgetLookup],
        [Outdoor].[AssociateID],
        [Outdoor].Year,
        [Outdoor].MonthNum,
        [Outdoor].[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    [Outdoor].Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    [Outdoor].MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    [Outdoor].[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    [Outdoor].Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    [Outdoor].MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    [Outdoor].[DataType]
                )='Planned'
            )
        );

		SELECT [QRY - Outdoor - Months Complete 1].[BudgetLookup], Sum([QRY - Outdoor - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - Outdoor - Months Complete 1]
		GROUP BY [QRY - Outdoor - Months Complete 1].[BudgetLookup];


		SELECT
        [Outdoor].[ReportingTactic],
		'Media Math' as [Vendor],
        '' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        [Outdoor].[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum([Outdoor].[PlannedImpressions]) AS [Total Planned Impressions],
        Count([Outdoor].[PlannedImpressions]) AS [Planned Months],
        Avg([Outdoor].[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum([Outdoor].DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum([Outdoor].Clicks) AS [Clicks to Date],
        Sum([Outdoor].Spend) AS [Spend to Date],
        [QRY - Outdoor - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].PaymentDeactivationDate,
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
        'MediaManagerETL' AS CreatedBy,
        'Outdoor' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                [dbo].[MedManOutdoor] [Outdoor] 
            INNER JOIN
                #MonthComplete2 [QRY - Outdoor - Months Complete 2] 
                    ON [Outdoor].[BudgetLookup] = [QRY - Outdoor - Months Complete 2].[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = [Outdoor].[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = [Outdoor].[BudgetLookup] 
            GROUP BY
                [Outdoor].[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].STCode,
                [QRY - Master Agent Profile].Type2019,
                [Outdoor].[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - Outdoor - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];
    

	END
END