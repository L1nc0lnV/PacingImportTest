CREATE PROCEDURE [dbo].[usp_Pacing_HispIba]
	
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
  as (SELECT HispIba.[BudgetLookup], Count(HispIba.[PlannedImpressions]) AS [Total Planned Months]
		FROM [dbo].[MedManHispIba] HispIba
		GROUP BY HispIba.[BudgetLookup])


	  SELECT
        HispIba.[ReportingTactic],
        ''  as [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        HispIba.[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        HispIba.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        HispIba.Year,
        HispIba.MonthNum,
        Sum(HispIba.PlannedImpressions) AS [Current Month Planned Impressions],
		Sum(HispIba.DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum(HispIba.PlannedClicks) AS [Current Month Planned Clicks],
		Sum(HispIba.Clicks) AS [Current Month Clicks],
		Sum(HispIba.Spend) AS [Current Month Spend],
        [Agent Budgets].[SBMSBudget],
        [Qry - HispIba - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        MonthAssign.FirstYear_MonthNumber,
        [Agent Budgets].PaymentDeactivationDate,
        --[Agent Budgets].Closed,
        [Agent Budgets].[TargetDemo],
        [ProcessSource] = 'HispIba' 
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
    INNER JOIN
        (
            [dbo].[MasterBudgetSource] [Agent Budgets] 
        INNER JOIN
            (
                tpm [Qry - HispIba - Total Planned Months] 
            INNER JOIN
                [dbo].[MedManHispIba] HispIba
                    ON [Qry - HispIba - Total Planned Months].[BudgetLookup] = HispIba.[BudgetLookup]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = HispIba.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = HispIba.[AssociateID] 
            GROUP BY
                HispIba.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].[MediaState],
                HispIba.[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                HispIba.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                HispIba.Year,
                HispIba.MonthNum,
                [Agent Budgets].[SBMSBudget],
                [Qry - HispIba - Total Planned Months].[Total Planned Months],
                MonthAssign.FirstYear_MonthNumber,
                [Agent Budgets].PaymentDeactivationDate,
              --  [Agent Budgets].Closed,
                [Agent Budgets].[TargetDemo],
                MonthAssign.FirstYear_YearNumber 
            HAVING
                (
                    (
                        (
                            HispIba.Year
                        )=[FirstYear_YearNumber]
                    ) 
                    AND (
                        (
                            HispIba.MonthNum
                        )=[FirstYear_MonthNumber]
                    )
                );
	
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
		
    SELECT
        HispIba.[BudgetLookup],
        HispIba.[AssociateID],
        HispIba.Year,
        HispIba.MonthNum,
        HispIba.[DataType],
        Count(HispIba.[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManHispIba] HispIba 
    GROUP BY
        HispIba.[BudgetLookup],
        HispIba.[AssociateID],
        HispIba.Year,
        HispIba.MonthNum,
        HispIba.[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    HispIba.Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    HispIba.MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    HispIba.[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    HispIba.Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    HispIba.MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    HispIba.[DataType]
                )='Planned'
            )
        );
    
		SELECT [QRY - HispIba - Months Complete 1].[BudgetLookup], Sum([QRY - HispIba - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - HispIba - Months Complete 1]
		GROUP BY [QRY - HispIba - Months Complete 1].[BudgetLookup];

		SELECT
        HispIba.[ReportingTactic],
        'Media Math' AS [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        HispIba.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum(HispIba.[PlannedImpressions]) AS [Total Planned Impressions],
        Count(HispIba.[PlannedImpressions]) AS [Planned Months],
        Avg(HispIba.[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum(HispIba.DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum(HispIba.Clicks) AS [Clicks to Date],
        Sum(HispIba.Spend) AS [Spend to Date],
        [QRY - HispIba - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].[PaymentDeactivationDate],
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
            'MediaManagerETL' AS CreatedBy,
        'HispIba' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                #MonthComplete2 [QRY - HispIba - Months Complete 2] 
            INNER JOIN
                [dbo].[MedManHispIba] HispIba 
                    ON [QRY - HispIba - Months Complete 2].[BudgetLookup] = HispIba.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = HispIba.[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = HispIba.[BudgetLookup] 
            GROUP BY
                HispIba.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                HispIba.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - HispIba - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];  

		drop table #MonthComplete1
		drop table #MonthComplete2

	END
END