USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_StrategyCorps_Transactions')
	DROP PROCEDURE dbo.USEagle_extract_StrategyCorps_Transactions;
GO


CREATE PROCEDURE dbo.USEagle_extract_StrategyCorps_Transactions

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <11/30/2018>    
-- Modify Date: 
-- Description:	<extract of shares>
-- ======================================================================

AS
BEGIN

	DECLARE
		@StartTransactionDate	DATE,
		@EndTransactionDate		DATE;


	SELECT
		@StartTransactionDate = DATEADD(mm, -3, DATEADD(dd, 1, MAX(Dt.CalendarDate))),
		@EndTransactionDate = DATEADD(dd, -1, DATEADD(dd, 1, MAX(Dt.CalendarDate)))
	FROM
		USEagleDW.dim.Calendar Dt
	WHERE
		Dt.MonthEndFlag = 'Y'
		AND
--		Dt.CalendarDate < CAST(SYSDATETIME() AS DATE);
		Dt.CalendarDate < '2018-11-30';



	SELECT
		AccountNumber = Txn.PARENTACCOUNT + '-' + RTRIM(Txn.PARENTID),
		TransactionCode = ISNULL(Txn.ACTIONCODE, ''),
		SupplementalCode = ISNULL(Txn.SOURCECODE, ''),
		TransactionAmount = ISNULL(Txn.BALANCECHANGE, 0.00),
		PostedDate = CAST(Txn.POSTDATE AS DATE),
		Description = ''
	FROM
		ARCUSYM000.dbo.SAVINGSTRANSACTION Txn
	WHERE
		Txn.POSTDATE BETWEEN @StartTransactionDate AND @EndTransactionDate
		AND
		Txn.VOIDCODE = 0
		AND
		(Txn.ACTIONCODE = 'D'
			OR
			Txn.ACTIONCODE = 'W')
		AND
		Txn.SOURCECODE IS NOT NULL
		AND
		Txn.SOURCECODE <> ''
		AND
		Txn.SOURCECODE <> 'V'
		AND
		Txn.SOURCECODE <> 'F'

	ORDER BY
		AccountNumber,
		PostedDate;

END;
GO


