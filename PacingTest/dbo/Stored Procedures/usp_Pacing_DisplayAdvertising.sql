CREATE PROCEDURE [dbo].[usp_Pacing_DisplayAdvertising]
	
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
	FROM [MedManDisplayAdvertising] tactic
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
       -- mb.Closed,
        mb.[TargetDemo],
        [ProcessSource] = 'DisplayAdvertising' 
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
                MedManDisplayAdvertising as tactic
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
        [DisplayAdvertising].[BudgetLookup],
        [DisplayAdvertising].[AssociateID],
        [DisplayAdvertising].Year,
        [DisplayAdvertising].MonthNum,
        [DisplayAdvertising].[DataType],
        Count([DisplayAdvertising].[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManDisplayAdvertising] [DisplayAdvertising] 
    GROUP BY
        [DisplayAdvertising].[BudgetLookup],
        [DisplayAdvertising].[AssociateID],
        [DisplayAdvertising].Year,
        [DisplayAdvertising].MonthNum,
        [DisplayAdvertising].[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    [DisplayAdvertising].Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    [DisplayAdvertising].MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    [DisplayAdvertising].[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    [DisplayAdvertising].Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    [DisplayAdvertising].MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    [DisplayAdvertising].[DataType]
                )='Planned'
            )
        );

		SELECT [QRY - DisplayAdvertising - Months Complete 1].[BudgetLookup], Sum([QRY - DisplayAdvertising - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - DisplayAdvertising - Months Complete 1]
		GROUP BY [QRY - DisplayAdvertising - Months Complete 1].[BudgetLookup];


		SELECT
        [DisplayAdvertising].[ReportingTactic],
		'Media Math' as [Vendor],
        '' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        [DisplayAdvertising].[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum([DisplayAdvertising].[PlannedImpressions]) AS [Total Planned Impressions],
        Count([DisplayAdvertising].[PlannedImpressions]) AS [Planned Months],
        Avg([DisplayAdvertising].[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum([DisplayAdvertising].DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum([DisplayAdvertising].Clicks) AS [Clicks to Date],
        Sum([DisplayAdvertising].Spend) AS [Spend to Date],
        [QRY - DisplayAdvertising - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].PaymentDeactivationDate,
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
        'MediaManagerETL' AS CreatedBy,
        'DisplayAdvertising' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                [dbo].[MedManDisplayAdvertising] [DisplayAdvertising] 
            INNER JOIN
                #MonthComplete2 [QRY - DisplayAdvertising - Months Complete 2] 
                    ON [DisplayAdvertising].[BudgetLookup] = [QRY - DisplayAdvertising - Months Complete 2].[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = [DisplayAdvertising].[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = [DisplayAdvertising].[BudgetLookup] 
            GROUP BY
                [DisplayAdvertising].[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].STCode,
                [QRY - Master Agent Profile].Type2019,
                [DisplayAdvertising].[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - DisplayAdvertising - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];
    

	END
END