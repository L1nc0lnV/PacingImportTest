CREATE PROCEDURE [dbo].[usp_Pacing_FacebookNF]
	
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

	  SELECT
		[Facebook News Feed].[BudgetLookup],
		Count([Facebook News Feed].[PlannedClicks]) 
		AS [Total Planned Months]
	into #fb_nf_planned_months
	FROM MedManFacebookNewsFeed as [Facebook News Feed]
	GROUP BY [Facebook News Feed].[BudgetLookup]
	HAVING (((Count([Facebook News Feed].[PlannedClicks]))<>0));

	SELECT
        'Facebook News Feed' AS [Reporting Tactic],
        [Facebook News Feed].Vendor,
		'' as [Segment],
        [QRY - Master Agent Profile].[MarketArea],
        [QRY - Master Agent Profile].[MediaState],
        [Facebook News Feed].[AssociateID],
        [QRY - Master Agent Profile].[STCode],
        [QRY - Master Agent Profile].Type2019,
        [Facebook News Feed].[AGENTNAME],
        [QRY - Master Agent Profile].[TerminationDate],
        [FB NF Budgets].Radius,
        [QRY - Master Agent Profile].NumberOfTargetedZips,
        [Facebook News Feed].Year,
        [Facebook News Feed].MonthNum,
        Sum([Facebook News Feed].PlannedImpressions) AS [Current Month Planned Impressions],
        Sum([Facebook News Feed].DeliveredImpressionsToDate) AS [Current Month Impressions Delivery],
		Sum([Facebook News Feed].PlannedClicks) AS [Current Month Planned Clicks],
        Sum([Facebook News Feed].Clicks) AS [Current Month Clicks],
        Sum([Facebook News Feed].Spend) AS [Current Month Spend],
        [FB NF Budgets].SumOfSbms AS [SBMSBudget],
        [Qry - Facebook - Total Planned Months].[Total Planned Months] AS [Total Planned Months],
        ma.FirstYear_MonthNumber,
        [FB NF Budgets].PaymentDeactivationDate,
		'' as TargetDemo,
        [ProcessSource] = 'FBNF' 
    FROM
        @MonthAssign ma,
        [dbo].[MasterBudgetSourcePivotFBNF] [FB NF Budgets]
    INNER JOIN
        (
            (
                MedManFacebookNewsFeed as [Facebook News Feed] 
            INNER JOIN
                MasterAgentSource as [QRY - Master Agent Profile] 
                    ON [Facebook News Feed].[AssociateID] = [QRY - Master Agent Profile].[AssociateID]
                ) 
        INNER JOIN
            #fb_nf_planned_months as [Qry - Facebook - Total Planned Months] 
                ON [Facebook News Feed].[BudgetLookup] = [Qry - Facebook - Total Planned Months].[BudgetLookup]
            ) 
                ON [FB NF Budgets].AssociateIDTactic = [Facebook News Feed].[BudgetLookup] 
        GROUP BY
            [Facebook News Feed].Vendor,
            [QRY - Master Agent Profile].[MarketArea],
            [QRY - Master Agent Profile].[MediaState],
            [Facebook News Feed].[AssociateID],
            [QRY - Master Agent Profile].[STCode],
            [QRY - Master Agent Profile].Type2019,
            [Facebook News Feed].[AGENTNAME],
            [QRY - Master Agent Profile].[TerminationDate],
            [FB NF Budgets].Radius,
            [QRY - Master Agent Profile].NumberOfTargetedZips,
            [Facebook News Feed].Year,
            [Facebook News Feed].MonthNum,
            [FB NF Budgets].SumOfSbms,
            [Qry - Facebook - Total Planned Months].[Total Planned Months],
            ma.FirstYear_MonthNumber,
            [FB NF Budgets].PaymentDeactivationDate,
            ma.FirstYear_YearNumber 
        HAVING
            (
                (
                    (
                        [Facebook News Feed].Year
                    )=[FirstYear_YearNumber]
                ) 
                AND (
                    (
                        [Facebook News Feed].MonthNum
                    )=[FirstYear_MonthNumber]
                )
            );

			drop table #fb_nf_planned_months

	END
-- Return complete data
IF @QueryType = 'total'
	BEGIN

-- Facebook NF Total

  -- Generate Month Complete 1
  	SELECT
        [Facebook News Feed].[BudgetLookup],
        [Facebook News Feed].[AssociateID],
        [Facebook News Feed].Year,
        [Facebook News Feed].MonthNum,
        [Facebook News Feed].[DataType],
        Count([Facebook News Feed].[AssociateID]) AS [CountOfAssociate ID],
        ma.FirstYear_MonthNumber,
        ma.SecondYear_MonthNumber,
        ma.FirstYear_YearNumber,
        ma.SecondYear_YearNumber
	into #MonthComplete1
    FROM
        @MonthAssign as ma,
        MedManFacebookNewsFeed as [Facebook News Feed] 
    GROUP BY
        [Facebook News Feed].[BudgetLookup],
        [Facebook News Feed].[AssociateID],
        [Facebook News Feed].Year,
        [Facebook News Feed].MonthNum,
        [Facebook News Feed].[DataType],
        ma.FirstYear_MonthNumber,
        ma.SecondYear_MonthNumber,
        ma.FirstYear_YearNumber,
        ma.SecondYear_YearNumber 
    HAVING
        (
            (
                (
                    [Facebook News Feed].Year
                )=ma.[FirstYear_YearNumber]
            ) 
            AND (
                (
                    [Facebook News Feed].MonthNum
                )<=ma.[FirstYear_MonthNumber]
            ) 
            AND (
                (
                    [Facebook News Feed].[DataType]
                )='Planned'
            )
        ) 
        OR (
            (
                (
                    [Facebook News Feed].Year
                )=ma.[SecondYear_YearNumber]
            ) 
            AND (
                (
                    [Facebook News Feed].MonthNum
                )<=ma.[SecondYear_MonthNumber]
            ) 
            AND (
                (
                    [Facebook News Feed].[DataType]
                )='Planned'
            )
        );



		--Generate Month Complete 2

		    SELECT
        [QRY - Facebook - Months Complete 1].BudgetLookup,
        Sum([QRY - Facebook - Months Complete 1].[CountOfAssociate ID]) AS [SumOfCountOfAssociate ID]
		into #MonthComplete2
		FROM
        #MonthComplete1 [QRY - Facebook - Months Complete 1] 
		GROUP BY
        [QRY - Facebook - Months Complete 1].BudgetLookup;


		  SELECT
		    'Facebook News Feed' AS [Reporting Tactic],
            '' AS Vendor, -- add
            '' AS Segment,
			[QRY - Master Agent Profile].MarketArea,
            [QRY - Master Agent Profile].MediaState, -- add
			[QRY - Master Agent Profile].AssociateID,
			[QRY - Master Agent Profile].STCode,
			[QRY - Master Agent Profile].Type2019,
			[Facebook News Feed].[AGENTNAME],
			[QRY - Master Agent Profile].[TerminationDate],
			[FB NF Budgets].Radius,
			[QRY - Master Agent Profile].NumberOfTargetedZips,
            Sum([Facebook News Feed].PlannedImpressions) AS [Total Planned Impressions], -- add
            Count([Facebook News Feed].[PlannedClicks]) AS [Planned Months], -- reorder
            Avg([Facebook News Feed].PlannedImpressions) AS [Impressions Per Month],
            --Avg([FB NF Budgets].SumOfSbms) AS [AvgOfSum of SBMS Budget], why Cody, why?
            [FB NF Budgets].SumOfSbms AS [SBMSBudget], -- Changed from Average, why Cody...
            Sum([Facebook News Feed].DeliveredImpressionsToDate) AS [Impressions to Date], -- reordered
            Sum([Facebook News Feed].Clicks) AS [Clicks to Date], -- reordered
			Sum([Facebook News Feed].Spend) AS [Spend to Date], -- reordered
			[QRY - Facebook - Months Complete 2].[SumOfCountOfAssociate ID] AS [Completed Months], -- reordered
			[FB NF Budgets].PaymentDeactivationDate, -- reordered
			'Not Available' AS [Target Demo],
             Getdate() AS CreatedOn,
            'MediaManagerETL' AS CreatedBy,
            'FBNF' AS ProcessSource -- reordered

			--Sum([Facebook News Feed].PlannedClicks) AS [Total Planned Clicks],
			--Count([Facebook News Feed].[PlannedClicks]) AS [Planned Months],
			--Avg([Facebook News Feed].[PlannedClicks]) AS [Clicks Per Month]


			--Avg([FB NF Budgets].SumOfSbms) AS [AvgOfSum of SBMS Budget], --why was this in there Cody

		 FROM
			[dbo].[MasterBudgetSourcePivotFBNF] [FB NF Budgets] 
		INNER JOIN
		    (
		        (
		            [dbo].[MedManFacebookNewsFeed] [Facebook News Feed] 
		        INNER JOIN
		            [dbo].[MasterAgentSource] [QRY - Master Agent Profile] 
		                ON [Facebook News Feed].[AssociateID] = [QRY - Master Agent Profile].[AssociateID]
		            ) 
		    INNER JOIN
		        #MonthComplete2 [QRY - Facebook - Months Complete 2] 
		            ON [Facebook News Feed].[BudgetLookup] = [QRY - Facebook - Months Complete 2].[BudgetLookup]
		        ) 
		            ON [FB NF Budgets].AssociateIDTactic = [Facebook News Feed].[BudgetLookup] 
		    GROUP BY
                [Facebook News Feed].Vendor,
			    [QRY - Master Agent Profile].[MarketArea],
                [QRY - Master Agent Profile].MediaState,
				[QRY - Master Agent Profile].[AssociateID],
				[QRY - Master Agent Profile].[STCode],
				 [QRY - Master Agent Profile].Type2019,
				[Facebook News Feed].[AGENTNAME],
				 [QRY - Master Agent Profile].[TerminationDate],
					[FB NF Budgets].Radius,
				[QRY - Master Agent Profile].NumberOfTargetedZips,
                [FB NF Budgets].SumOfSbms,
				[QRY - Facebook - Months Complete 2].[SumOfCountOfAssociate ID],
			 [FB NF Budgets].PaymentDeactivationDate


		drop table #MonthComplete1
		drop table #MonthComplete2


	END
END