CREATE PROCEDURE [dbo].[usp_Pacing_GasStationTV]
	
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
	FROM [MedManGasStationTV] tactic
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
        --mb.Closed,
        mb.[TargetDemo],
        [ProcessSource] = 'GasStationTV' 
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
                MedManGasStationTV as tactic
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
           -- mb.Closed,
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
        [GasStationTV].[BudgetLookup],
        [GasStationTV].[AssociateID],
        [GasStationTV].Year,
        [GasStationTV].MonthNum,
        [GasStationTV].[DataType],
        Count([GasStationTV].[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManGasStationTV] [GasStationTV] 
    GROUP BY
        [GasStationTV].[BudgetLookup],
        [GasStationTV].[AssociateID],
        [GasStationTV].Year,
        [GasStationTV].MonthNum,
        [GasStationTV].[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    [GasStationTV].Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    [GasStationTV].MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    [GasStationTV].[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    [GasStationTV].Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    [GasStationTV].MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    [GasStationTV].[DataType]
                )='Planned'
            )
        );

		SELECT [QRY - GasStationTV - Months Complete 1].[BudgetLookup], Sum([QRY - GasStationTV - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - GasStationTV - Months Complete 1]
		GROUP BY [QRY - GasStationTV - Months Complete 1].[BudgetLookup];


		SELECT
        [GasStationTV].[ReportingTactic],
		'Media Math' as [Vendor],
        '' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        [GasStationTV].[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum([GasStationTV].[PlannedImpressions]) AS [Total Planned Impressions],
        Count([GasStationTV].[PlannedImpressions]) AS [Planned Months],
        Avg([GasStationTV].[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum([GasStationTV].DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum([GasStationTV].Clicks) AS [Clicks to Date],
        Sum([GasStationTV].Spend) AS [Spend to Date],
        [QRY - GasStationTV - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].PaymentDeactivationDate,
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
        'MediaManagerETL' AS CreatedBy,
        'GasStationTV' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                [dbo].[MedManGasStationTV] [GasStationTV] 
            INNER JOIN
                #MonthComplete2 [QRY - GasStationTV - Months Complete 2] 
                    ON [GasStationTV].[BudgetLookup] = [QRY - GasStationTV - Months Complete 2].[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = [GasStationTV].[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = [GasStationTV].[BudgetLookup] 
            GROUP BY
                [GasStationTV].[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].STCode,
                [QRY - Master Agent Profile].Type2019,
                [GasStationTV].[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - GasStationTV - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];
    

	END
END