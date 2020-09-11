CREATE PROCEDURE [dbo].[usp_Pacing_OnlineVideoAds]
	
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
  as (SELECT OnlineVideoAds.[BudgetLookup], Count(OnlineVideoAds.[PlannedImpressions]) AS [Total Planned Months]
		FROM [dbo].[MedManOnlineVideoAds] OnlineVideoAds
		GROUP BY OnlineVideoAds.[BudgetLookup])


	  SELECT
        OnlineVideoAds.[ReportingTactic],
        ''  as [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        OnlineVideoAds.[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        OnlineVideoAds.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        OnlineVideoAds.Year,
        OnlineVideoAds.MonthNum,
        Sum(OnlineVideoAds.PlannedImpressions) AS [Current Month Planned Impressions],
		Sum(OnlineVideoAds.DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum(OnlineVideoAds.PlannedClicks) AS [Current Month Planned Clicks],
		Sum(OnlineVideoAds.Clicks) AS [Current Month Clicks],
		Sum(OnlineVideoAds.Spend) AS [Current Month Spend],
        [Agent Budgets].[SBMSBudget],
        [Qry - OnlineVideoAds - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        MonthAssign.FirstYear_MonthNumber,
        [Agent Budgets].PaymentDeactivationDate,
       -- [Agent Budgets].Closed,
        [Agent Budgets].[TargetDemo],
        [ProcessSource] = 'OnlineVideoAds' 
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
    INNER JOIN
        (
            [dbo].[MasterBudgetSource] [Agent Budgets] 
        INNER JOIN
            (
                tpm [Qry - OnlineVideoAds - Total Planned Months] 
            INNER JOIN
                [dbo].[MedManOnlineVideoAds] OnlineVideoAds
                    ON [Qry - OnlineVideoAds - Total Planned Months].[BudgetLookup] = OnlineVideoAds.[BudgetLookup]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = OnlineVideoAds.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = OnlineVideoAds.[AssociateID] 
            GROUP BY
                OnlineVideoAds.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].[MediaState],
                OnlineVideoAds.[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                OnlineVideoAds.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                OnlineVideoAds.Year,
                OnlineVideoAds.MonthNum,
                [Agent Budgets].[SBMSBudget],
                [Qry - OnlineVideoAds - Total Planned Months].[Total Planned Months],
                MonthAssign.FirstYear_MonthNumber,
                [Agent Budgets].PaymentDeactivationDate,
          --      [Agent Budgets].Closed,
                [Agent Budgets].[TargetDemo],
                MonthAssign.FirstYear_YearNumber 
            HAVING
                (
                    (
                        (
                            OnlineVideoAds.Year
                        )=[FirstYear_YearNumber]
                    ) 
                    AND (
                        (
                            OnlineVideoAds.MonthNum
                        )=[FirstYear_MonthNumber]
                    )
                );
	
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
		
    SELECT
        OnlineVideoAds.[BudgetLookup],
        OnlineVideoAds.[AssociateID],
        OnlineVideoAds.Year,
        OnlineVideoAds.MonthNum,
        OnlineVideoAds.[DataType],
        Count(OnlineVideoAds.[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManOnlineVideoAds] OnlineVideoAds 
    GROUP BY
        OnlineVideoAds.[BudgetLookup],
        OnlineVideoAds.[AssociateID],
        OnlineVideoAds.Year,
        OnlineVideoAds.MonthNum,
        OnlineVideoAds.[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    OnlineVideoAds.Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    OnlineVideoAds.MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    OnlineVideoAds.[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    OnlineVideoAds.Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    OnlineVideoAds.MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    OnlineVideoAds.[DataType]
                )='Planned'
            )
        );
    
		SELECT [QRY - OnlineVideoAds - Months Complete 1].[BudgetLookup], Sum([QRY - OnlineVideoAds - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - OnlineVideoAds - Months Complete 1]
		GROUP BY [QRY - OnlineVideoAds - Months Complete 1].[BudgetLookup];

		SELECT
        OnlineVideoAds.[ReportingTactic],
        'Media Math' AS [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        OnlineVideoAds.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum(OnlineVideoAds.[PlannedImpressions]) AS [Total Planned Impressions],
        Count(OnlineVideoAds.[PlannedImpressions]) AS [Planned Months],
        Avg(OnlineVideoAds.[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum(OnlineVideoAds.DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum(OnlineVideoAds.Clicks) AS [Clicks to Date],
        Sum(OnlineVideoAds.Spend) AS [Spend to Date],
        [QRY - OnlineVideoAds - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].[PaymentDeactivationDate],
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
            'MediaManagerETL' AS CreatedBy,
        'OnlineVideoAds' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                #MonthComplete2 [QRY - OnlineVideoAds - Months Complete 2] 
            INNER JOIN
                [dbo].[MedManOnlineVideoAds] OnlineVideoAds 
                    ON [QRY - OnlineVideoAds - Months Complete 2].[BudgetLookup] = OnlineVideoAds.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = OnlineVideoAds.[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = OnlineVideoAds.[BudgetLookup] 
            GROUP BY
                OnlineVideoAds.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                OnlineVideoAds.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - OnlineVideoAds - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];  

		drop table #MonthComplete1
		drop table #MonthComplete2

	END
END