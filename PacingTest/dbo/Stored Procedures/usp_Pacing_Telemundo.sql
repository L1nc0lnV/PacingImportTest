CREATE PROCEDURE [dbo].[usp_Pacing_Telemundo]
	
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

	  with tpm (BudgetLookup, [Total Planned Months])
  as (SELECT Telemundo.[BudgetLookup], Count(Telemundo.[PlannedImpressions]) AS [Total Planned Months]
		FROM [dbo].[MedManTelemundo] Telemundo
		GROUP BY Telemundo.[BudgetLookup])


	  SELECT
        Telemundo.[ReportingTactic],
        'Media Math'  as [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        Telemundo.[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        Telemundo.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Telemundo.Year,
        Telemundo.MonthNum,
        Sum(Telemundo.PlannedImpressions) AS [Current Month Planned Impressions],
		Sum(Telemundo.DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum(Telemundo.PlannedClicks) AS [Current Month Planned Clicks],
		Sum(Telemundo.Clicks) AS [Current Month Clicks],
		Sum(Telemundo.Spend) AS [Current Month Spend],
        [Agent Budgets].[SBMSBudget],
        [Qry - Telemundo - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        MonthAssign.FirstYear_MonthNumber,
        [Agent Budgets].PaymentDeactivationDate,
        [Agent Budgets].[TargetDemo],
       -- [Agent Budgets].Closed,
        [ProcessSource] = 'Telemundo' 
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
    INNER JOIN
        (
            [dbo].[MasterBudgetSource] [Agent Budgets] 
        INNER JOIN
            (
                tpm [Qry - Telemundo - Total Planned Months] 
            INNER JOIN
                [dbo].[MedManTelemundo] Telemundo 
                    ON [Qry - Telemundo - Total Planned Months].[BudgetLookup] = Telemundo.[BudgetLookup]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = Telemundo.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = Telemundo.[AssociateID] 
            GROUP BY
                Telemundo.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].[MediaState],
                Telemundo.[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                Telemundo.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                Telemundo.Year,
                Telemundo.MonthNum,
                [Agent Budgets].[SBMSBudget],
                [Qry - Telemundo - Total Planned Months].[Total Planned Months],
                MonthAssign.FirstYear_MonthNumber,
                [Agent Budgets].PaymentDeactivationDate,
             --   [Agent Budgets].Closed,
                [Agent Budgets].[TargetDemo],
                MonthAssign.FirstYear_YearNumber 
            HAVING
                (
                    (
                        (
                            Telemundo.Year
                        )=[FirstYear_YearNumber]
                    ) 
                    AND (
                        (
                            Telemundo.MonthNum
                        )=[FirstYear_MonthNumber]
                    )
                );
	
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
		
    SELECT
        Telemundo.[BudgetLookup],
        Telemundo.[AssociateID],
        Telemundo.Year,
        Telemundo.MonthNum,
        Telemundo.[DataType],
        Count(Telemundo.[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManTelemundo] Telemundo 
    GROUP BY
        Telemundo.[BudgetLookup],
        Telemundo.[AssociateID],
        Telemundo.Year,
        Telemundo.MonthNum,
        Telemundo.[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    Telemundo.Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    Telemundo.MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    Telemundo.[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    Telemundo.Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    Telemundo.MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    Telemundo.[DataType]
                )='Planned'
            )
        );
    
		SELECT [QRY - Telemundo - Months Complete 1].[BudgetLookup], Sum([QRY - Telemundo - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - Telemundo - Months Complete 1]
		GROUP BY [QRY - Telemundo - Months Complete 1].[BudgetLookup];

		SELECT
        Telemundo.[ReportingTactic],
        'Media Math' AS [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        Telemundo.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum(Telemundo.[PlannedImpressions]) AS [Total Planned Impressions],
        Count(Telemundo.[PlannedImpressions]) AS [Planned Months],
        Avg(Telemundo.[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum(Telemundo.DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum(Telemundo.Clicks) AS [Clicks to Date],
        Sum(Telemundo.Spend) AS [Spend to Date],
        [QRY - Telemundo - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].[PaymentDeactivationDate],
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
            'MediaManagerETL' AS CreatedBy,
        'Telemundo' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                #MonthComplete2 [QRY - Telemundo - Months Complete 2] 
            INNER JOIN
                [dbo].[MedManTelemundo] Telemundo 
                    ON [QRY - Telemundo - Months Complete 2].[BudgetLookup] = Telemundo.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = Telemundo.[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = Telemundo.[BudgetLookup] 
            GROUP BY
                Telemundo.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                Telemundo.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - Telemundo - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];  

		drop table #MonthComplete1
		drop table #MonthComplete2

	END
END