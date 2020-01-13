USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_Sageworks_Deposits')
	DROP PROCEDURE dbo.USEagle_extract_Sageworks_Deposits;
GO


CREATE PROCEDURE dbo.USEagle_extract_Sageworks_Deposits

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <08/10/2018>    
-- Modify Date: <10/22/2018>	CJH
-- Description:	<extract of Business Shares>
-- ======================================================================

AS
BEGIN

	DECLARE @ProcessDateInt		INT;

	SELECT
		@ProcessDateInt = ProcessDate
	FROM
		ARCUSYM000.dbo.ufnARCUGetLatestProcessDate();


	SELECT 
		UniqueID = CONCAT(RIGHT(Acct.AccountNumber, 7), Nm.NameOrdinal),
		ShareID = CONCAT(RTRIM(Acct.AccountNumber), RTRIM(Sh.ShareID)),
		ShareTypeDesc = sh.ShareTypeDescription,
		Balance = sh.ShareBalance,
		DivRate = sh.ShareDivRate
	FROM
		ARCUSYM000.arcu.vwARCUAccount Acct
			INNER JOIN
		ARCUSYM000.arcu.vwARCUName Nm 
			ON Nm.ProcessDate = @ProcessDateInt AND Nm.NameType = 0 AND Acct.AccountNumber = Nm.AccountNumber 
			INNER JOIN
		ARCUSYM000.arcu.vwARCUShare Sh
			ON Sh.ProcessDate = @ProcessDateInt AND Acct.AccountNumber = Sh.AccountNumber
	WHERE
		Acct.ProcessDate = @ProcessDateInt
		AND
		Acct.AccountType = 9 
		AND
		Acct.AccountCloseDate IS NULL
		AND
		Sh.ShareCloseDate IS NULL
	ORDER BY
		ShareID;

END;
GO


