CREATE PROCEDURE [dbo].[usp_Pacing_StreamingAudio]
	
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
  as (SELECT StreamingAudio.[BudgetLookup], Count(StreamingAudio.[PlannedImpressions]) AS [Total Planned Months]
		FROM [dbo].[MedManStreamingAudio] StreamingAudio
		GROUP BY StreamingAudio.[BudgetLookup])


	  SELECT
        StreamingAudio.[ReportingTactic],
        ''  as [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        StreamingAudio.[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        StreamingAudio.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        StreamingAudio.Year,
        StreamingAudio.MonthNum,
        Sum(StreamingAudio.PlannedImpressions) AS [Current Month Planned Impressions],
		Sum(StreamingAudio.DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum(StreamingAudio.PlannedClicks) AS [Current Month Planned Clicks],
		Sum(StreamingAudio.Clicks) AS [Current Month Clicks],
		Sum(StreamingAudio.Spend) AS [Current Month Spend],
        [Agent Budgets].[SBMSBudget],
        [Qry - StreamingAudio - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        MonthAssign.FirstYear_MonthNumber,
        [Agent Budgets].PaymentDeactivationDate,
      --  [Agent Budgets].Closed,
        [Agent Budgets].[TargetDemo],
        [ProcessSource] = 'StreamingAudio' 
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
    INNER JOIN
        (
            [dbo].[MasterBudgetSource] [Agent Budgets] 
        INNER JOIN
            (
                tpm [Qry - StreamingAudio - Total Planned Months] 
            INNER JOIN
                [dbo].[MedManStreamingAudio] StreamingAudio
                    ON [Qry - StreamingAudio - Total Planned Months].[BudgetLookup] = StreamingAudio.[BudgetLookup]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = StreamingAudio.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = StreamingAudio.[AssociateID] 
            GROUP BY
                StreamingAudio.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].[MediaState],
                StreamingAudio.[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                StreamingAudio.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                StreamingAudio.Year,
                StreamingAudio.MonthNum,
                [Agent Budgets].[SBMSBudget],
                [Qry - StreamingAudio - Total Planned Months].[Total Planned Months],
                MonthAssign.FirstYear_MonthNumber,
                [Agent Budgets].PaymentDeactivationDate,
          --      [Agent Budgets].Closed,
                [Agent Budgets].[TargetDemo],
                MonthAssign.FirstYear_YearNumber 
            HAVING
                (
                    (
                        (
                            StreamingAudio.Year
                        )=[FirstYear_YearNumber]
                    ) 
                    AND (
                        (
                            StreamingAudio.MonthNum
                        )=[FirstYear_MonthNumber]
                    )
                );
	
	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN
		
    SELECT
        StreamingAudio.[BudgetLookup],
        StreamingAudio.[AssociateID],
        StreamingAudio.Year,
        StreamingAudio.MonthNum,
        StreamingAudio.[DataType],
        Count(StreamingAudio.[AssociateID]) AS [CountOfAssociate ID],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber
	into #MonthComplete1
    FROM
        @MonthAssign MonthAssign,
        [dbo].[MedManStreamingAudio] StreamingAudio 
    GROUP BY
        StreamingAudio.[BudgetLookup],
        StreamingAudio.[AssociateID],
        StreamingAudio.Year,
        StreamingAudio.MonthNum,
        StreamingAudio.[DataType],
        MonthAssign.FirstYear_MonthNumber,
        MonthAssign.SecondYear_MonthNumber,
        MonthAssign.FirstYear_YearNumber,
        MonthAssign.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    StreamingAudio.Year
                )=[FirstYear_YearNumber]
            ) 
            AND (
                (
                    StreamingAudio.MonthNum
                )<=[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    StreamingAudio.[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    StreamingAudio.Year
                )=[SecondYear_YearNumber]
            ) 
            AND (
                (
                    StreamingAudio.MonthNum
                )<=[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    StreamingAudio.[DataType]
                )='Planned'
            )
        );
    
		SELECT [QRY - StreamingAudio - Months Complete 1].[BudgetLookup], Sum([QRY - StreamingAudio - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM #MonthComplete1 [QRY - StreamingAudio - Months Complete 1]
		GROUP BY [QRY - StreamingAudio - Months Complete 1].[BudgetLookup];

		SELECT
        StreamingAudio.[ReportingTactic],
        'Media Math' AS [Vendor],
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].MediaState,
        [QRY - Master Agent Profile].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        StreamingAudio.[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [Agent Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        Sum(StreamingAudio.[PlannedImpressions]) AS [Total Planned Impressions],
        Count(StreamingAudio.[PlannedImpressions]) AS [Planned Months],
        Avg(StreamingAudio.[PlannedImpressions]) AS [Impressions Per Month],
        [Agent Budgets].[SBMSBudget],
        Sum(StreamingAudio.DeliveredImpressionsToDate) AS [Impressions to Date],
        Sum(StreamingAudio.Clicks) AS [Clicks to Date],
        Sum(StreamingAudio.Spend) AS [Spend to Date],
        [QRY - StreamingAudio - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months],
        [Agent Budgets].[PaymentDeactivationDate],
        [Agent Budgets].[TargetDemo],
        Getdate() AS CreatedOn,
            'MediaManagerETL' AS CreatedBy,
        'StreamingAudio' AS ProcessSource
    FROM
        [dbo].[MasterBudgetSource] [Agent Budgets] 
    INNER JOIN
        (
            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
        INNER JOIN
            (
                #MonthComplete2 [QRY - StreamingAudio - Months Complete 2] 
            INNER JOIN
                [dbo].[MedManStreamingAudio] StreamingAudio 
                    ON [QRY - StreamingAudio - Months Complete 2].[BudgetLookup] = StreamingAudio.[BudgetLookup]
                ) 
                    ON [QRY - Master Agent Profile].[AssociateID] = StreamingAudio.[AssociateID]
                ) 
                    ON [Agent Budgets].AssociateIDTactic = StreamingAudio.[BudgetLookup] 
            GROUP BY
                StreamingAudio.[ReportingTactic],
                [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
                [QRY - Master Agent Profile].[AssociateID],
                [QRY - Master Agent Profile].[STCode],
                [QRY - Master Agent Profile].Type2019,
                StreamingAudio.[AGENTNAME],
                [QRY - Master Agent Profile].[TerminationDate],
                [Agent Budgets].Radius,
                [QRY - Master Agent Profile].NumberOfTargetedZips,
                [Agent Budgets].[SBMSBudget],
                [QRY - StreamingAudio - Months Complete 2].[SumOfCountOfAssociate ID],
                [Agent Budgets].PaymentDeactivationDate,
                [Agent Budgets].[TargetDemo];  

		drop table #MonthComplete1
		drop table #MonthComplete2

	END
END