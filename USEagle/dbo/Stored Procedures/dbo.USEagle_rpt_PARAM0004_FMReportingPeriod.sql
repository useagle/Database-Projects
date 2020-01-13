USE USEagle;
GO


CREATE PROCEDURE dbo.USEagle_rpt_PARAM0004_FMReportingPeriod
AS

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <09/26/2017>    
-- Modify Date: 
-- Description:	<Lists privilege groups for report parameters> 
-- =============================================

BEGIN

	SELECT
		ReportPeriodMonthEndDate = Dt.CalendarDate,
		ReportPeriod = RIGHT(('0' + CAST(Dt.MonthNum AS VARCHAR)), 2) + '/' + CAST(Dt.YearNum AS VARCHAR)
	FROM
		USEagleDW.dim.Calendar Dt
	WHERE
		Dt.MonthEndFlag = 'Y'
		AND
		Dt.CalendarDate < CAST(SYSDATETIME() AS DATE)
		AND
		Dt.CalendarDate >= (SELECT MIN(ShareFMPostDate) FROM ARCUSYM000.arcu.vwARCUShareFMHistory)
	ORDER BY
		CalendarDate DESC;

END;
GO
