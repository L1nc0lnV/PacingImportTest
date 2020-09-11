CREATE PROCEDURE [dbo].[usp_Pacing_Cinema]
	
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
  as (SELECT Cinema.[BudgetLookup], Count(Cinema.[PlannedImpressions]) AS [Total Planned Months]
		FROM [dbo].[MedManCinema] Cinema
		GROUP BY Cinema.[BudgetLookup])


	  SELECT
        Cinema.[ReportingTactic],
        ''  as [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        Cinema.[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        Cinema.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Cinema.Year,
        Cinema.MonthNum,
        Sum(Cinema.PlannedImpressions) AS [Current Month Planned Impressions],
		Sum(Cinema.DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum(Cinema.PlannedClicks) AS [Current Month Planned Clicks],
		Sum(Cinema.Clicks) AS [Current Month Clicks],
		Sum(Cinema.Spend) AS [Current Month Spend],
        [Agent Budgets].[SBMSBudget],
        [Qry - Cinema - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        MonthAssign.FirstYear_MonthNumber,
        [Agent Budgets].PaymentDeactivationDate,
       -- [Agent Budgets].Closed,
        [Agent Budgets].[TargetDemo],
        [ProcessSource] = 'Cinema' 
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
    INNER JOIN
        (
            [dbo].[MasterBudgetSource] [Agent Budgets] 
        INNER JOIN
            (
                tpm [Qry - Cinema - Total Planned Months] 
            INNER JOIN
                [dbo].[MedManCinema] Cinema
                    ON [Qry - Cinema - Total Planned Months].[BudgetLookup] = Cinema.[BudgetLookup]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = Cinema.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = Cinema.[AssociateID] 
            GROUP BY
                Cinema.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].[MediaState],
                Cinema.[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                Cinema.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                Cinema.Year,
                Cinema.MonthNum,
                [Agent Budgets].[SBMSBudget],
                [Qry - Cinema - Total Planned Months].[Total Planned Months],
                MonthAssign.FirstYear_MonthNumber,
                [Agent Budgets].PaymentDeactivationDate,
              --  [Agent Budgets].Closed,
                [Agent Budgets].[TargetDemo],
                MonthAssign.FirstYear_YearNumber 
            HAVING
                (
                    (
                        (
                            Cinema.Year
                        )=[FirstYear_YearNumber]
                    ) 
                    AND (
                        (
                            Cinema.MonthNum
                        )=[FirstYear_MonthNumber]
                    )
                );
	
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
		
    SELECT
        Cinema.[BudgetLookup],
        Cinema.[AssociateID],
        Cinema.Year,
        Cinema.MonthNum,
        Cinema.[DataType],
        Count(Cinema.[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManCinema] Cinema 
    GROUP BY
        Cinema.[BudgetLookup],
        Cinema.[AssociateID],
        Cinema.Year,
        Cinema.MonthNum,
        Cinema.[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    Cinema.Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    Cinema.MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    Cinema.[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    Cinema.Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    Cinema.MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    Cinema.[DataType]
                )='Planned'
            )
        );
    
		SELECT [QRY - Cinema - Months Complete 1].[BudgetLookup], Sum([QRY - Cinema - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - Cinema - Months Complete 1]
		GROUP BY [QRY - Cinema - Months Complete 1].[BudgetLookup];

		SELECT
        Cinema.[ReportingTactic],
        'Media Math' AS [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        Cinema.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum(Cinema.[PlannedImpressions]) AS [Total Planned Impressions],
        Count(Cinema.[PlannedImpressions]) AS [Planned Months],
        Avg(Cinema.[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum(Cinema.DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum(Cinema.Clicks) AS [Clicks to Date],
        Sum(Cinema.Spend) AS [Spend to Date],
        [QRY - Cinema - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].[PaymentDeactivationDate],
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
            'MediaManagerETL' AS CreatedBy,
        'Cinema' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                #MonthComplete2 [QRY - Cinema - Months Complete 2] 
            INNER JOIN
                [dbo].[MedManCinema] Cinema 
                    ON [QRY - Cinema - Months Complete 2].[BudgetLookup] = Cinema.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = Cinema.[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = Cinema.[BudgetLookup] 
            GROUP BY
                Cinema.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                Cinema.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - Cinema - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];  

		drop table #MonthComplete1
		drop table #MonthComplete2

	END
END