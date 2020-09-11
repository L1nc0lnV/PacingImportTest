CREATE PROCEDURE [dbo].[usp_Pacing_SocialMedia]
	
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
  as (SELECT SocialMedia.[BudgetLookup], Count(SocialMedia.[PlannedImpressions]) AS [Total Planned Months]
		FROM [dbo].[MedManSocialMedia] SocialMedia
		GROUP BY SocialMedia.[BudgetLookup])


	  SELECT
        SocialMedia.[ReportingTactic],
        ''  as [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        SocialMedia.[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        SocialMedia.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        SocialMedia.Year,
        SocialMedia.MonthNum,
        Sum(SocialMedia.PlannedImpressions) AS [Current Month Planned Impressions],
		Sum(SocialMedia.DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum(SocialMedia.PlannedClicks) AS [Current Month Planned Clicks],
		Sum(SocialMedia.Clicks) AS [Current Month Clicks],
		Sum(SocialMedia.Spend) AS [Current Month Spend],
        [Agent Budgets].[SBMSBudget],
        [Qry - SocialMedia - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        MonthAssign.FirstYear_MonthNumber,
        [Agent Budgets].PaymentDeactivationDate,
      --  [Agent Budgets].Closed,
        [Agent Budgets].[TargetDemo],
        [ProcessSource] = 'SocialMedia' 
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
    INNER JOIN
        (
            [dbo].[MasterBudgetSource] [Agent Budgets] 
        INNER JOIN
            (
                tpm [Qry - SocialMedia - Total Planned Months] 
            INNER JOIN
                [dbo].[MedManSocialMedia] SocialMedia
                    ON [Qry - SocialMedia - Total Planned Months].[BudgetLookup] = SocialMedia.[BudgetLookup]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = SocialMedia.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = SocialMedia.[AssociateID] 
            GROUP BY
                SocialMedia.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].[MediaState],
                SocialMedia.[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                SocialMedia.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                SocialMedia.Year,
                SocialMedia.MonthNum,
                [Agent Budgets].[SBMSBudget],
                [Qry - SocialMedia - Total Planned Months].[Total Planned Months],
                MonthAssign.FirstYear_MonthNumber,
                [Agent Budgets].PaymentDeactivationDate,
             --   [Agent Budgets].Closed,
                [Agent Budgets].[TargetDemo],
                MonthAssign.FirstYear_YearNumber 
            HAVING
                (
                    (
                        (
                            SocialMedia.Year
                        )=[FirstYear_YearNumber]
                    ) 
                    AND (
                        (
                            SocialMedia.MonthNum
                        )=[FirstYear_MonthNumber]
                    )
                );
	
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
		
    SELECT
        SocialMedia.[BudgetLookup],
        SocialMedia.[AssociateID],
        SocialMedia.Year,
        SocialMedia.MonthNum,
        SocialMedia.[DataType],
        Count(SocialMedia.[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManSocialMedia] SocialMedia 
    GROUP BY
        SocialMedia.[BudgetLookup],
        SocialMedia.[AssociateID],
        SocialMedia.Year,
        SocialMedia.MonthNum,
        SocialMedia.[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    SocialMedia.Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    SocialMedia.MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    SocialMedia.[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    SocialMedia.Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    SocialMedia.MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    SocialMedia.[DataType]
                )='Planned'
            )
        );
    
		SELECT [QRY - SocialMedia - Months Complete 1].[BudgetLookup], Sum([QRY - SocialMedia - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - SocialMedia - Months Complete 1]
		GROUP BY [QRY - SocialMedia - Months Complete 1].[BudgetLookup];

		SELECT
        SocialMedia.[ReportingTactic],
        'Media Math' AS [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        SocialMedia.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum(SocialMedia.[PlannedImpressions]) AS [Total Planned Impressions],
        Count(SocialMedia.[PlannedImpressions]) AS [Planned Months],
        Avg(SocialMedia.[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum(SocialMedia.DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum(SocialMedia.Clicks) AS [Clicks to Date],
        Sum(SocialMedia.Spend) AS [Spend to Date],
        [QRY - SocialMedia - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].[PaymentDeactivationDate],
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
            'MediaManagerETL' AS CreatedBy,
        'SocialMedia' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                #MonthComplete2 [QRY - SocialMedia - Months Complete 2] 
            INNER JOIN
                [dbo].[MedManSocialMedia] SocialMedia 
                    ON [QRY - SocialMedia - Months Complete 2].[BudgetLookup] = SocialMedia.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = SocialMedia.[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = SocialMedia.[BudgetLookup] 
            GROUP BY
                SocialMedia.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                SocialMedia.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - SocialMedia - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];  

		drop table #MonthComplete1
		drop table #MonthComplete2

	END
END