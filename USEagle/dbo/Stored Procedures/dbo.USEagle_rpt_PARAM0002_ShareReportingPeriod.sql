USE USEagle;
GO


CREATE PROCEDURE dbo.USEagle_rpt_PARAM0002_ShareReportingPeriod
AS

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <09/20/2017>    
-- Modify Date: 
-- Description:	<Lists privilege groups for report parameters> 
-- =============================================

BEGIN

	SELECT
		ReportPeriod = RIGHT(('0' + CAST(Dt.MonthNum AS VARCHAR)), 2) + '/' + CAST(Dt.YearNum AS VARCHAR),
		Dt.YearNum,
		MonthNumOfYear = Dt.MonthNum,
		No = ROW_NUMBER() OVER (ORDER BY Dt.CalendarDate DESC)
	FROM
		USEagleDW.dim.Calendar Dt
	WHERE
		Dt.MonthEndFlag = 'Y'
		AND
		Dt.CalendarDate < CAST(SYSDATETIME() AS DATE)
		AND
		Dt.CalendarDate >= (SELECT MIN(POSTDATE) FROM ARCUSYM000.dbo.SAVINGSTRANSACTION)
	ORDER BY
		CalendarDate DESC;

END;
GO
