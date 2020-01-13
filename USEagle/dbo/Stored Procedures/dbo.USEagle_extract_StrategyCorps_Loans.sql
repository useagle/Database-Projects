USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_StrategyCorps_Loans')
	DROP PROCEDURE dbo.USEagle_extract_StrategyCorps_Loans;
GO


CREATE PROCEDURE dbo.USEagle_extract_StrategyCorps_Loans

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <11/27/2018>    
-- Modify Date: 
-- Description:	<extract of loans>
-- ======================================================================

AS
BEGIN

	DECLARE @ProcessDateInt		INT;

	SELECT
		@ProcessDateInt = MAX(Dt.CalendarKey)
	FROM
		USEagleDW.dim.Calendar Dt
	WHERE
		Dt.MonthEndFlag = 'Y'
		AND
--		Dt.CalendarDate < CAST(SYSDATETIME() AS DATE);
		Dt.CalendarDate < '2018-11-30';


	WITH Secondaries AS
	(
		SELECT
			Sec.PARENTACCOUNT,
			SecondaryName = ISNULL(RTRIM(Sec.FIRST) + ' ', '') + RTRIM(Sec.LAST),
			SecondaryTaxID = RTRIM(Sec.SSN),
			SecondaryOrder = ROW_NUMBER() OVER (PARTITION BY Sec.PARENTACCOUNT ORDER BY Sec.ORDINAL)
		FROM
			ARCUSYM000.dbo.NAME Sec
		WHERE
			Sec.ProcessDate = @ProcessDateInt
			AND
			Sec.TYPE = 1
			AND
			Sec.EXPIRATIONDATE IS NULL AND Sec.ProcessDate = @ProcessDateInt
	)
	SELECT 
		AccountNumber = Ln.PARENTACCOUNT + '-' + RTRIM(Ln.ID),
		AccountStatus =	CASE
							WHEN Ln.CHARGEOFFDATE IS NOT NULL THEN 'CHARGED-OFF'
							WHEN Ln.CLOSEDATE IS NOT NULL THEN 'CLOSED'
							ELSE 'OPEN'
						END,
		ProductOrTypeCode = Ln.TYPE,
		DateAccountOpened = CAST(Ln.OPENDATE AS DATE),
		HouseholdOrPortfolioKey = '',
		Name = ISNULL(RTRIM(Prim.FIRST) + ' ', '') + RTRIM(Prim.LAST),
		Name2 = ISNULL(Sec.SecondaryName, ''),
		Name3 = ISNULL(Tert.SecondaryName, ''),
		TaxID = RTRIM(Prim.SSN),
		TaxID2 = ISNULL(Sec.SecondaryTaxID, ''),
		TaxID3 = ISNULL(Tert.SecondaryTaxID, ''),
		StreetAddress = ISNULL(RTRIM(Prim.STREET), ''),
		City = ISNULL(RTRIM(Prim.CITY), ''),
		State = ISNULL(RTRIM(Prim.STATE), ''),
		Zip = ISNULL(RTRIM(Prim.ZIPCODE), ''),
		CurrentOutstandingLoanBalance = Ln.BALANCE,
		PYTDorYTDInterestPaid = Ln.INTERESTYTD,
		CurrentInterestRate = Ln.INTERESTRATE / 1000.0
	FROM
		ARCUSYM000.dbo.LOAN Ln
			INNER JOIN
		ARCUSYM000.dbo.ACCOUNT Acct
			ON Ln.PARENTACCOUNT = Acct.ACCOUNTNUMBER AND Acct.ProcessDate = @ProcessDateInt
			INNER JOIN
		ARCUSYM000.dbo.NAME Prim
			ON Ln.PARENTACCOUNT = Prim.PARENTACCOUNT AND Prim.TYPE = 0 AND Prim.EXPIRATIONDATE IS NULL AND Prim.ProcessDate = @ProcessDateInt
			LEFT JOIN
		Secondaries Sec
			ON Ln.PARENTACCOUNT = Sec.PARENTACCOUNT AND Sec.SecondaryOrder = 1
			LEFT JOIN
		Secondaries Tert
			ON Ln.PARENTACCOUNT = Tert.PARENTACCOUNT AND Tert.SecondaryOrder = 2
	WHERE
		Ln.ProcessDate = @ProcessDateInt
		AND
		Acct.TYPE NOT IN (9, 10)
	ORDER BY
		Ln.PARENTACCOUNT,
		Ln.ID;

END;
GO


