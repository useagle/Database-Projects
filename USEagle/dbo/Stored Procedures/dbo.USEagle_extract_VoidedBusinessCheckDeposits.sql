USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_VoidedBusinessCheckDeposits')
	DROP PROCEDURE dbo.USEagle_extract_VoidedBusinessCheckDeposits;
GO


CREATE PROCEDURE dbo.USEagle_extract_VoidedBusinessCheckDeposits

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <12/11/2017>    
-- Modify Date: 
-- Description:	<File maintenance for users based on funds availability category.> 
-- ======================================================================

AS
BEGIN

	DECLARE
		@ProcessDateInt		INT,
		@TransactionDate	DATE;


	SELECT
		@ProcessDateInt = MAX(ProcessDate)
	FROM
		ARCUSYM000.dbo.ACCOUNT;


	SET @TransactionDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE));


	SELECT DISTINCT
		MemberNumber = Txn.PARENTACCOUNT,
		AccountID = Txn.PARENTID,
		TransactionPostDateTime = DATEADD(hh, FLOOR(Txn.POSTTIME / 100), DATEADD(mi, Txn.POSTTIME % 100, Txn.POSTDATE)),
		DepositCount = SUM(	CASE
								WHEN Txn.ACTIONCODE = 'D' AND (Txn.SOURCECODE = 'C' OR Txn.SOURCECODE = 'K' ) THEN 1
								ELSE 0
							END) OVER (PARTITION BY Txn.PARENTACCOUNT, Txn.PARENTID, Txn.POSTDATE, Txn.POSTTIME),
		DraftCount = SUM(	CASE
								WHEN Txn.SOURCECODE = 'D' AND Txn.ACTIONCODE = 'W' THEN 1
								ELSE 0
							END) OVER (PARTITION BY Txn.PARENTACCOUNT, Txn.PARENTID, Txn.POSTDATE, Txn.POSTTIME),
		TotalBalanceChange = SUM(	CASE
										WHEN Txn.ACTIONCODE = 'D' AND Txn.SOURCECODE IS NOT NULL THEN Txn.BALANCECHANGE
										WHEN Txn.ACTIONCODE = 'W' AND Txn.SOURCECODE = 'C' THEN Txn.BALANCECHANGE
										ELSE 0
									END) OVER (PARTITION BY Txn.PARENTACCOUNT, Txn.PARENTID, Txn.POSTDATE, Txn.POSTTIME),
		TotalDepositAmount = SUM(ISNULL(TRY_CAST(REPLACE(REPLACE(Txn.COMMENT, 'Check Received ', ''), ',', '') AS DECIMAL(12, 2)), 0)) OVER (PARTITION BY Txn.PARENTACCOUNT, Txn.PARENTID, Txn.POSTDATE, Txn.POSTTIME),
		DepositDifference = SUM(	CASE
										WHEN Txn.ACTIONCODE = 'D' AND Txn.SOURCECODE IS NOT NULL THEN Txn.BALANCECHANGE
										WHEN Txn.ACTIONCODE = 'W' AND Txn.SOURCECODE = 'C' THEN Txn.BALANCECHANGE
										ELSE 0
									END) OVER (PARTITION BY Txn.PARENTACCOUNT, Txn.PARENTID, Txn.POSTDATE, Txn.POSTTIME)
							- SUM(ISNULL(TRY_CAST(REPLACE(REPLACE(Txn.COMMENT, 'Check Received ', ''), ',', '') AS DECIMAL(12, 2)), 0)) OVER (PARTITION BY Txn.PARENTACCOUNT, Txn.PARENTID, Txn.POSTDATE, Txn.POSTTIME)
	FROM
		ARCUSYM000.dbo.SAVINGSTRANSACTION Txn
			INNER JOIN
		ARCUSYM000.dbo.SAVINGS Share
			ON Txn.PARENTACCOUNT = Share.PARENTACCOUNT AND Txn.PARENTID = Share.ID AND Share.ProcessDate = @ProcessDateInt
			INNER JOIN
		ARCUSYM000.dbo.ACCOUNT Mem
			ON Txn.PARENTACCOUNT = Mem.ACCOUNTNUMBER AND Mem.ProcessDate = @ProcessDateInt
	WHERE
		CAST(Txn.EFFECTIVEDATE AS DATE) = @TransactionDate
		AND
		Txn.VOIDCODE = 1
		AND
		Share.TYPE <> 1
		AND
		Mem.CLOSEDATE IS NULL
		AND
		Mem.TYPE IN (9, 10, 19, 20, 21, 22)			--	Business-related account types
	ORDER BY
		MemberNumber,
		AccountID,
		TransactionPostDateTime;

END;
GO


