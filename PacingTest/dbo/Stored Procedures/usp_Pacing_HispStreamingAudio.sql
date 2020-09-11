CREATE PROCEDURE [dbo].[usp_Pacing_HispStreamingAudio]
	
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
  as (SELECT HispStreamingAudio.[BudgetLookup], Count(HispStreamingAudio.[PlannedImpressions]) AS [Total Planned Months]
		FROM [dbo].[MedManHispStreamingAudio] HispStreamingAudio
		GROUP BY HispStreamingAudio.[BudgetLookup])


	  SELECT
        HispStreamingAudio.[ReportingTactic],
        ''  as [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        HispStreamingAudio.[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        HispStreamingAudio.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        HispStreamingAudio.Year,
        HispStreamingAudio.MonthNum,
        Sum(HispStreamingAudio.PlannedImpressions) AS [Current Month Planned Impressions],
		Sum(HispStreamingAudio.DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum(HispStreamingAudio.PlannedClicks) AS [Current Month Planned Clicks],
		Sum(HispStreamingAudio.Clicks) AS [Current Month Clicks],
		Sum(HispStreamingAudio.Spend) AS [Current Month Spend],
        [Agent Budgets].[SBMSBudget],
        [Qry - HispStreamingAudio - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        MonthAssign.FirstYear_MonthNumber,
        [Agent Budgets].PaymentDeactivationDate,
      --  [Agent Budgets].Closed,
        [Agent Budgets].[TargetDemo],
        [ProcessSource] = 'HispStreamingAudio' 
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
    INNER JOIN
        (
            [dbo].[MasterBudgetSource] [Agent Budgets] 
        INNER JOIN
            (
                tpm [Qry - HispStreamingAudio - Total Planned Months] 
            INNER JOIN
                [dbo].[MedManHispStreamingAudio] HispStreamingAudio
                    ON [Qry - HispStreamingAudio - Total Planned Months].[BudgetLookup] = HispStreamingAudio.[BudgetLookup]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = HispStreamingAudio.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = HispStreamingAudio.[AssociateID] 
            GROUP BY
                HispStreamingAudio.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].[MediaState],
                HispStreamingAudio.[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                HispStreamingAudio.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                HispStreamingAudio.Year,
                HispStreamingAudio.MonthNum,
                [Agent Budgets].[SBMSBudget],
                [Qry - HispStreamingAudio - Total Planned Months].[Total Planned Months],
                MonthAssign.FirstYear_MonthNumber,
                [Agent Budgets].PaymentDeactivationDate,
            --    [Agent Budgets].Closed,
                [Agent Budgets].[TargetDemo],
                MonthAssign.FirstYear_YearNumber 
            HAVING
                (
                    (
                        (
                            HispStreamingAudio.Year
                        )=[FirstYear_YearNumber]
                    ) 
                    AND (
                        (
                            HispStreamingAudio.MonthNum
                        )=[FirstYear_MonthNumber]
                    )
                );
	
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
		
    SELECT
        HispStreamingAudio.[BudgetLookup],
        HispStreamingAudio.[AssociateID],
        HispStreamingAudio.Year,
        HispStreamingAudio.MonthNum,
        HispStreamingAudio.[DataType],
        Count(HispStreamingAudio.[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManHispStreamingAudio] HispStreamingAudio 
    GROUP BY
        HispStreamingAudio.[BudgetLookup],
        HispStreamingAudio.[AssociateID],
        HispStreamingAudio.Year,
        HispStreamingAudio.MonthNum,
        HispStreamingAudio.[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    HispStreamingAudio.Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    HispStreamingAudio.MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    HispStreamingAudio.[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    HispStreamingAudio.Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    HispStreamingAudio.MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    HispStreamingAudio.[DataType]
                )='Planned'
            )
        );
    
		SELECT [QRY - HispStreamingAudio - Months Complete 1].[BudgetLookup], Sum([QRY - HispStreamingAudio - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - HispStreamingAudio - Months Complete 1]
		GROUP BY [QRY - HispStreamingAudio - Months Complete 1].[BudgetLookup];

		SELECT
        HispStreamingAudio.[ReportingTactic],
        'Media Math' AS [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        HispStreamingAudio.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum(HispStreamingAudio.[PlannedImpressions]) AS [Total Planned Impressions],
        Count(HispStreamingAudio.[PlannedImpressions]) AS [Planned Months],
        Avg(HispStreamingAudio.[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum(HispStreamingAudio.DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum(HispStreamingAudio.Clicks) AS [Clicks to Date],
        Sum(HispStreamingAudio.Spend) AS [Spend to Date],
        [QRY - HispStreamingAudio - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].[PaymentDeactivationDate],
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
            'MediaManagerETL' AS CreatedBy,
        'HispStreamingAudio' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                #MonthComplete2 [QRY - HispStreamingAudio - Months Complete 2] 
            INNER JOIN
                [dbo].[MedManHispStreamingAudio] HispStreamingAudio 
                    ON [QRY - HispStreamingAudio - Months Complete 2].[BudgetLookup] = HispStreamingAudio.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = HispStreamingAudio.[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = HispStreamingAudio.[BudgetLookup] 
            GROUP BY
                HispStreamingAudio.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                HispStreamingAudio.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - HispStreamingAudio - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];  

		drop table #MonthComplete1
		drop table #MonthComplete2

	END
END