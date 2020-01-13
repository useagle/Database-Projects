USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_PARAM0010_ShowExcluded')
	DROP PROCEDURE dbo.USEagle_rpt_PARAM0010_ShowExcluded;
GO


CREATE PROCEDURE dbo.USEagle_rpt_PARAM0010_ShowExcluded
AS

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <10/26/2018>    
-- Modify Date: 
-- Description:	<Lists privilege groups for report parameters> 
-- =============================================

BEGIN

	SELECT
		ShowExcluded = 'X',
		ShowExcludedDesc = '<ALL>'

	UNION

	SELECT
		ShowExcluded = 'N',
		ShowExcludedDesc = 'No'

	UNION

	SELECT
		ShowExcludedUp = 'Y',
		ShowExcludedDesc = 'Yes'

	ORDER BY
		ShowExcludedDesc;

END;
GO
