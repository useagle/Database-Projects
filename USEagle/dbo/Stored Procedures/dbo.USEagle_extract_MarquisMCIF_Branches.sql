USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_MarquisMCIF_Branches')
	DROP PROCEDURE dbo.USEagle_extract_MarquisMCIF_Branches;
GO


CREATE PROCEDURE dbo.USEagle_extract_MarquisMCIF_Branches

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <04/10/2019>    
-- Modify Date: 
-- Description:	<extract of branch lookup data for Marquis MCIF>
-- ======================================================================

AS
BEGIN

	SELECT DISTINCT
		Val = RIGHT('000' + CAST(Brn.BranchNumber AS VARCHAR), 4)			--	Branch Number (4, 1-4)
			+ LEFT(RTRIM(Brn.BranchName) + SPACE(40), 40)					--	Branch Description (40, 5-44)
			+ SPACE(4)														--	Branch Region (4, 45-48)
	FROM
		USEagleDW.fact.CurrentLoan Ln
			INNER JOIN
		USEagleDW.dim.Branch Brn
			ON Ln.LoanBranchKey = Brn.BranchKey
	WHERE
		Brn.BranchKey > 0

	UNION

	SELECT DISTINCT
		Val = RIGHT('000' + CAST(Brn.BranchNumber AS VARCHAR), 4)			--	Branch Number (4)
			+ LEFT(RTRIM(Brn.BranchName) + SPACE(40), 40)					--	Branch Description (40)
			+ SPACE(4)														--	Branch Region (4)
	FROM
		USEagleDW.fact.CurrentShare Sh
			INNER JOIN
		USEagleDW.dim.Branch Brn
			ON Sh.ShareOriginationBranchKey = Brn.BranchKey
	WHERE
		Brn.BranchKey > 0

	ORDER BY
		Val;

END;
GO


