-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_dev_cleanup]

AS
BEGIN
	truncate table [dbo].[MedManAsianIba]
	truncate table [dbo].[MedManAutoTargeting]
    truncate table [dbo].[MedManBroadcast]
	truncate table [dbo].[MedManCinema]
	truncate table [dbo].[MedManDisplayAdvertising]
	truncate table [dbo].[MedManGasStationTV]
	truncate table [dbo].[MedManHispStreamingAudio]
	truncate table [dbo].[MedManHomeowners]
	truncate table [dbo].[MedManNewspaper]
	truncate table [dbo].[MedManOnlineVideoAds]
	truncate table [dbo].[MedManOutdoor]
	truncate table [dbo].[MedManPlaceBased]
	truncate table [dbo].[MedManSocialMedia]
	truncate table [dbo].[MedManStreamingAudio]
	truncate table [dbo].[MedManTelemundo]
	truncate table [dbo].[MedManUnivision]
	truncate table [dbo].[PacingMonthly]
	truncate table [dbo].[PacingTotal]
	truncate table [dbo].[MedManHispIba]

	truncate table [dbo].[MasterAgentSource]
	truncate table [dbo].[MasterBudgetSource]
END
