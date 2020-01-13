USE USEagle;
GO


CREATE PROCEDURE dbo.USEagle_rpt_PARAM0001_PrivilegeGroupList
AS

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <09/11/2017>    
-- Modify Date: 
-- Description:	<Lists privilege groups for report parameters> 
-- =============================================

BEGIN

	SELECT
		PrivilegeGroupID = tl.SequenceNumber,
		PrivilegeGroupName = 'Privilege Group ' + CAST(tl.SequenceNumber AS VARCHAR)
	FROM
		Admin.dbo.Tally tl
	WHERE
		tl.SequenceNumber BETWEEN 1 AND 50
	ORDER BY
		tl.SequenceNumber;

END;
GO
