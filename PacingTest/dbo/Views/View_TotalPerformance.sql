create view [dbo].[View_TotalPerformance]

AS

SELECT 
  mNum  = Month(createdOn)
  ,plannedImps = sum(totalPlannedImpressions)
  ,impsToDate = sum(impressionstodate)
  FROM [dbo].[PacingTotal]
  group by Month(createdOn)