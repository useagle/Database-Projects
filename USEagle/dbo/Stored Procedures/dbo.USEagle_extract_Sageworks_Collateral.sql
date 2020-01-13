USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_Sageworks_Collateral')
	DROP PROCEDURE dbo.USEagle_extract_Sageworks_Collateral;
GO


CREATE PROCEDURE dbo.USEagle_extract_Sageworks_Collateral

-- ======================================================================
-- Author:		<Nilam Keval>
-- Create date: <08/10/2018>    
-- Modify Date: <10/22/2018>	CJH
-- Description:	<extract of Business Loans>
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
		LoanID = CONCAT(RTRIM(Acct.AccountNumber), RTRIM(Ln.LoanID)),
		TrackingType = Trk.LoanTrackingType,
		TrackingTypeDesc = Trk.LoanTrackingDescription,
		CollateralAmt = Trk.LoanTrackingUserAmount1,
		CollateralInfoType =	CASE
									WHEN Trk.LoanTrackingType = 30 THEN LoanTrackingDefUserChar3
									WHEN Trk.LoanTrackingType = 35 THEN LoanTrackingDefUserChar5
									ELSE NULL
								END,
		CollateralInfo =	CASE
								WHEN Trk.LoanTrackingType = 30 THEN LoanTrackingUserChar3
								WHEN Trk.LoanTrackingType = 35 THEN LoanTrackingUserChar5
								ELSE NULL
							END
	FROM
		ARCUSYM000.arcu.vwARCUAccount Acct
			INNER JOIN
		ARCUSYM000.arcu.vwARCUName Nm 
			ON Nm.ProcessDate = @ProcessDateInt AND Nm.NameType = 0 AND Acct.AccountNumber = Nm.AccountNumber 
			INNER JOIN
		ARCUSYM000.arcu.vwARCULoan Ln
			ON Ln.ProcessDate = @ProcessDateInt AND Acct.AccountNumber = Ln.AccountNumber
			INNER JOIN
		ARCUSYM000.arcu.vwARCULoanTracking Trk
			ON Trk.ProcessDate = @ProcessDateInt AND Acct.AccountNumber = Trk.AccountNumber AND Ln.LoanID = Trk.LoanID
	WHERE
		Acct.ProcessDate = @ProcessDateInt
		AND
		Acct.AccountType = 9 
		AND
		Acct.AccountCloseDate IS NULL
		AND
		Ln.LoanCloseDate IS NULL
		AND
		Ln.LoanChargeoffDate IS NULL
		AND
		Trk.LoanTrackingType IN (30, 35)
	ORDER BY
		LoanID;

END;
GO


