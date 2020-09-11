CREATE PROCEDURE [dbo].[usp_Pacing_Broadcast]
	
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
  as (SELECT Broadcast.[BudgetLookup], Count(Broadcast.[PlannedImpressions]) AS [Total Planned Months]
		FROM [dbo].[MedManBroadcast] Broadcast
		GROUP BY Broadcast.[BudgetLookup])


	  SELECT
        Broadcast.[ReportingTactic],
        ''  as [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        Broadcast.[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        Broadcast.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Broadcast.Year,
        Broadcast.MonthNum,
        Sum(Broadcast.PlannedImpressions) AS [Current Month Planned Impressions],
		Sum(Broadcast.DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum(Broadcast.PlannedClicks) AS [Current Month Planned Clicks],
		Sum(Broadcast.Clicks) AS [Current Month Clicks],
		Sum(Broadcast.Spend) AS [Current Month Spend],
        [Agent Budgets].[SBMSBudget],
        [Qry - Broadcast - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        MonthAssign.FirstYear_MonthNumber,
        [Agent Budgets].PaymentDeactivationDate,
        --[Agent Budgets].Closed,
        [Agent Budgets].[TargetDemo],
        [ProcessSource] = 'Broadcast' 
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
    INNER JOIN
        (
            [dbo].[MasterBudgetSource] [Agent Budgets] 
        INNER JOIN
            (
                tpm [Qry - Broadcast - Total Planned Months] 
            INNER JOIN
                [dbo].[MedManBroadcast] Broadcast
                    ON [Qry - Broadcast - Total Planned Months].[BudgetLookup] = Broadcast.[BudgetLookup]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = Broadcast.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = Broadcast.[AssociateID] 
            GROUP BY
                Broadcast.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].[MediaState],
                Broadcast.[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                Broadcast.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                Broadcast.Year,
                Broadcast.MonthNum,
                [Agent Budgets].[SBMSBudget],
                [Qry - Broadcast - Total Planned Months].[Total Planned Months],
                MonthAssign.FirstYear_MonthNumber,
                [Agent Budgets].PaymentDeactivationDate,
               -- [Agent Budgets].Closed,
                [Agent Budgets].[TargetDemo],
                MonthAssign.FirstYear_YearNumber 
            HAVING
                (
                    (
                        (
                            Broadcast.Year
                        )=[FirstYear_YearNumber]
                    ) 
                    AND (
                        (
                            Broadcast.MonthNum
                        )=[FirstYear_MonthNumber]
                    )
                );
	
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
		
    SELECT
        Broadcast.[BudgetLookup],
        Broadcast.[AssociateID],
        Broadcast.Year,
        Broadcast.MonthNum,
        Broadcast.[DataType],
        Count(Broadcast.[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManBroadcast] Broadcast 
    GROUP BY
        Broadcast.[BudgetLookup],
        Broadcast.[AssociateID],
        Broadcast.Year,
        Broadcast.MonthNum,
        Broadcast.[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    Broadcast.Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    Broadcast.MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    Broadcast.[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    Broadcast.Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    Broadcast.MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    Broadcast.[DataType]
                )='Planned'
            )
        );
    
		SELECT [QRY - Broadcast - Months Complete 1].[BudgetLookup], Sum([QRY - Broadcast - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - Broadcast - Months Complete 1]
		GROUP BY [QRY - Broadcast - Months Complete 1].[BudgetLookup];

		SELECT
        Broadcast.[ReportingTactic],
        'Media Math' AS [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        Broadcast.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum(Broadcast.[PlannedImpressions]) AS [Total Planned Impressions],
        Count(Broadcast.[PlannedImpressions]) AS [Planned Months],
        Avg(Broadcast.[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum(Broadcast.DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum(Broadcast.Clicks) AS [Clicks to Date],
        Sum(Broadcast.Spend) AS [Spend to Date],
        [QRY - Broadcast - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].[PaymentDeactivationDate],
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
            'MediaManagerETL' AS CreatedBy,
        'Broadcast' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                #MonthComplete2 [QRY - Broadcast - Months Complete 2] 
            INNER JOIN
                [dbo].[MedManBroadcast] Broadcast 
                    ON [QRY - Broadcast - Months Complete 2].[BudgetLookup] = Broadcast.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = Broadcast.[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = Broadcast.[BudgetLookup] 
            GROUP BY
                Broadcast.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                Broadcast.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - Broadcast - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];  

		drop table #MonthComplete1
		drop table #MonthComplete2

	END
END