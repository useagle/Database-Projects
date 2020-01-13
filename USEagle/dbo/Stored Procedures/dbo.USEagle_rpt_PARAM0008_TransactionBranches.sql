USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_PARAM0008_TransactionBranches')
	DROP PROCEDURE dbo.USEagle_rpt_PARAM0008_TransactionBranches;
GO


CREATE PROCEDURE dbo.USEagle_rpt_PARAM0008_TransactionBranches
AS

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <10/26/2018>    
-- Modify Date: 
-- Description:	<Lists privilege groups for report parameters> 
-- =============================================

BEGIN

	WITH Branches AS
	(
		SELECT DISTINCT
			Txn.TransactionBranchKey
		FROM
			USEagleDW.fact.[Transaction] Txn
		WHERE
			Txn.TransactionDateKey >= 20181022
	)
	SELECT
		BranchNumber = -1,
		BranchDesc = '<ALL>'

	UNION

	SELECT
		BranchNumber = Brn.BranchNumber,
		BranchDesc = Brn.BranchNumberAndName
	FROM
		USEagleDW.dim.Branch Brn
			INNER JOIN
		Branches
			ON Brn.BranchKey = Branches.TransactionBranchKey

	ORDER BY
		BranchNumber;

END;
GO
