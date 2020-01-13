USE USEagle;
GO


CREATE PROCEDURE dbo.USEagle_rpt_PARAM0005_OptInCategory
AS

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <09/26/2017>    
-- Modify Date: 
-- Description:	<Lists privilege groups for report parameters> 
-- =============================================

BEGIN

	SELECT
		OptInCategory = '0',
		OptInCategoryName = 'Opt In Matches Share FM'

	UNION ALL

	SELECT
		OptInCategory = '1',
		OptInCategoryName = 'Opt In Without Matching Share FM'

	UNION ALL

	SELECT
		OptInCategory = '2',
		OptInCategoryName = 'Share FM Without Matching Opt In'

	ORDER BY
		OptInCategory;

END;
GO
