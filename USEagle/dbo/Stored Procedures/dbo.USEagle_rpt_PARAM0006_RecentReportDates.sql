USE USEagle;
GO


CREATE PROCEDURE dbo.USEagle_rpt_PARAM0006_RecentReportDates
AS

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <09/26/2017>    
-- Modify Date: 
-- Description:	<Lists privilege groups for report parameters> 
-- =============================================

BEGIN

	SELECT
		ReportDate = Dt.CalendarDate,
		ReportDateString = CONVERT(VARCHAR(10), Dt.CalendarDate, 120)
	FROM
		USEagleDW.dim.Calendar Dt
	WHERE
		Dt.CalendarDate < CAST(SYSDATETIME() AS DATE)
		AND
		Dt.CalendarDate >= DATEADD(dd, -31, CAST(SYSDATETIME() AS DATE))
	ORDER BY
		CalendarDate DESC;

END;
GO
