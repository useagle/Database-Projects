USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_MarquisMCIF_Officers')
	DROP PROCEDURE dbo.USEagle_extract_MarquisMCIF_Officers;
GO


CREATE PROCEDURE dbo.USEagle_extract_MarquisMCIF_Officers

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <04/10/2019>    
-- Modify Date: 
-- Description:	<extract of loan officer lookup data for Marquis MCIF>
-- ======================================================================

AS
BEGIN

	SELECT DISTINCT
		Val = RIGHT('000' + CAST(Usr.UserNumber AS VARCHAR), 4)			--	Officer Code (4, 1-4)
			+ LEFT(RTRIM(Usr.UserName) + SPACE(20), 20)					--	Officer Description (20, 5-24)
			+ SPACE(4)													--	Officer Branch (4, 25-28)
	FROM
		USEagleDW.fact.CurrentLoan Ln
			INNER JOIN
		USEagleDW.dim.[User] Usr
			ON Ln.OriginatedByUserKey = Usr.UserKey
	WHERE
		Usr.UserNumber > 0

	UNION

	SELECT DISTINCT
		Val = RIGHT('000' + CAST(Usr.UserNumber AS VARCHAR), 4)			--	Officer Code (4, 1-4)
			+ LEFT(RTRIM(Usr.UserName) + SPACE(20), 20)					--	Officer Description (20, 5-24)
			+ SPACE(4)													--	Officer Branch (4, 25-28)
	FROM
		USEagleDW.fact.CurrentShare Sh
			INNER JOIN
		USEagleDW.dim.[User] Usr
			ON Sh.OriginatedByUserKey = Usr.UserKey
	WHERE
		Usr.UserNumber > 0
	ORDER BY
		Val;

END;
GO


