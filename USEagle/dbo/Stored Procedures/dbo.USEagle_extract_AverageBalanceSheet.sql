USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_AverageBalanceSheet')
	DROP PROCEDURE dbo.USEagle_extract_AverageBalanceSheet;
GO


CREATE PROCEDURE dbo.USEagle_extract_AverageBalanceSheet

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <12/11/2017>    
-- Modify Date: 
-- Description:	<File maintenance for users based on funds availability category.> 
-- ======================================================================

AS
BEGIN

	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;


	DECLARE
		@LastCompletedMonthEndDate			DATE,
		@LastCompletedMonthEndDateInt		INT,
		@NumberOfRollups					TINYINT,
		@PreviousCompletedMonthEndDate		DATE,
		@PreviousCompletedMonthEndDateInt	INT,
		@RollupLevel						TINYINT = 0;


	SET @LastCompletedMonthEndDate = DATEADD(dd, -1 * DAY(SYSDATETIME()), CAST(SYSDATETIME() AS DATE));
	SET @LastCompletedMonthEndDateInt = CAST(CONVERT(VARCHAR(8), @LastCompletedMonthEndDate, 112) AS INT);

	SET @PreviousCompletedMonthEndDate = DATEADD(dd, -1, DATEADD(mm, -1, DATEADD(dd, 1 - DAY(SYSDATETIME()), CAST(SYSDATETIME() AS DATE))));
	SET @PreviousCompletedMonthEndDateInt = CAST(CONVERT(VARCHAR(8), @PreviousCompletedMonthEndDate, 112) AS INT);


	/*
	SELECT
		@LastCompletedMonthEndDate,
		@LastCompletedMonthEndDateInt,
		@PreviousCompletedMonthEndDate,
		@PreviousCompletedMonthEndDateInt;
	*/


	IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%BalanceSheet%')
		DROP TABLE #BalanceSheet;


	CREATE TABLE
		#BalanceSheet
	(
		GLAccountNumber				VARCHAR(11),
		GLAccountDescription		VARCHAR(50),
		AverageEndOfMonthBalance	DECIMAL(12, 2)
	);


	WITH LastCompletedMonthEndOfMonthBalance AS
	(
		SELECT
			GLAcct.GLACCOUNTNUMBER,
			GLAcct.BALANCE
		FROM
			ARCUSYM000.dbo.GLACCOUNT GLAcct
		WHERE
			GLAcct.ProcessDate = @LastCompletedMonthEndDateInt
	),
	LastCompletedMonthBackDatedTransactions AS
	(
		SELECT
			GLTxn.PARENTGLACCOUNT,
			BalanceUpdate = SUM(GLTxn.AMOUNT)
		FROM
			ARCUSYM000.dbo.GLHISTORY GLTxn
		WHERE
			YEAR(GLTxn.EFFECTIVEDATE) = YEAR(@LastCompletedMonthEndDate)
			AND
			MONTH(GLTxn.EFFECTIVEDATE) = MONTH(@LastCompletedMonthEndDate)
			AND
			GLTxn.POSTDATE > @LastCompletedMonthEndDate
		GROUP BY
			GLTxn.PARENTGLACCOUNT
	),
	LastCompletedMonthBalance AS
	(
		SELECT
			Bal.GLACCOUNTNUMBER,
			Balance =	CASE
							WHEN GLACCOUNTNUMBER = '94000000000000' THEN Bal.BALANCE
							ELSE Bal.BALANCE + ISNULL(Txn.BalanceUpdate, 0)
						END
		FROM
			LastCompletedMonthEndOfMonthBalance Bal
				LEFT JOIN
			LastCompletedMonthBackDatedTransactions Txn
				ON Bal.GLACCOUNTNUMBER = Txn.PARENTGLACCOUNT
	),
	PreviousCompletedMonthEndOfMonthBalance AS
	(
		SELECT
			GLAcct.GLACCOUNTNUMBER,
			GLAcct.BALANCE
		FROM
			ARCUSYM000.dbo.GLACCOUNT GLAcct
		WHERE
			GLAcct.ProcessDate = @PreviousCompletedMonthEndDateInt
	),
	PreviousCompletedMonthBackDatedTransactions AS
	(
		SELECT
			GLTxn.PARENTGLACCOUNT,
			BalanceUpdate = SUM(GLTxn.AMOUNT)
		FROM
			ARCUSYM000.dbo.GLHISTORY GLTxn
		WHERE
			YEAR(GLTxn.EFFECTIVEDATE) = YEAR(@PreviousCompletedMonthEndDate)
			AND
			MONTH(GLTxn.EFFECTIVEDATE) = MONTH(@PreviousCompletedMonthEndDate)
			AND
			GLTxn.POSTDATE > @PreviousCompletedMonthEndDate
		GROUP BY
			GLTxn.PARENTGLACCOUNT
	),
	PreviousCompletedMonthBalance AS
	(
		SELECT
			Bal.GLACCOUNTNUMBER,
			Balance =	CASE
							WHEN GLACCOUNTNUMBER = '94000000000000' THEN Bal.BALANCE
							ELSE Bal.BALANCE + ISNULL(Txn.BalanceUpdate, 0)
						END
		FROM
			PreviousCompletedMonthEndOfMonthBalance Bal
				LEFT JOIN
			PreviousCompletedMonthBackDatedTransactions Txn
				ON Bal.GLACCOUNTNUMBER = Txn.PARENTGLACCOUNT
	),
	AverageBalance AS
	(
		SELECT
			LastBal.GLACCOUNTNUMBER,
			AverageBalance = 0.5 * (LastBal.Balance + PrevBal.Balance)
		FROM
			LastCompletedMonthBalance LastBal
				INNER JOIN
			PreviousCompletedMonthBalance PrevBal
				ON LastBal.GLACCOUNTNUMBER = PrevBal.GLACCOUNTNUMBER
	)
	INSERT INTO
		#BalanceSheet
	(
		GLAccountNumber,
		GLAccountDescription,
		AverageEndOfMonthBalance
	)
	SELECT
		Cfg.GLAccountNumber,
		Cfg.GLAccountDescription,
		AverageEndOfMonthBalance =	CASE
										WHEN Cfg.GLAccountNumber >= '800000' THEN -1 * SUM(Bal.AverageBalance)
										ELSE SUM(Bal.AverageBalance)
									END
	FROM
		Staging.business.FinancialExtractsConfiguration Cfg
			LEFT JOIN
		AverageBalance Bal
			ON Cfg.GLAccountNumber =	CASE
											WHEN LEN(Cfg.GLAccountNumber) = 6 THEN LEFT(Bal.GLACCOUNTNUMBER, 6)
											WHEN LEN(Cfg.GLAccountNumber) = 11 THEN LEFT(Bal.GLACCOUNTNUMBER, 6) + '-' + SUBSTRING(Bal.GLACCOUNTNUMBER, 7, 4)
											ELSE '-1'
										END
	WHERE
		Cfg.ExcludeFromReportFlag = 'N'
	GROUP BY
		Cfg.GLAccountNumber,
		Cfg.GLAccountDescription
	ORDER BY
		Cfg.GLAccountNumber;


	SELECT
		@NumberOfRollups = MAX(RollupLevel)
	FROM
		Staging.business.FinancialExtractsConfiguration;


	WHILE @RollupLevel < @NumberOfRollups
	BEGIN

		SET @RollupLevel = @RollupLevel + 1;

		WITH AccountRollup AS
		(
			SELECT
				Cfg.RollupAccount,
				Subtotal = SUM(Bal.AverageEndOfMonthBalance)
			FROM
				Staging.business.FinancialExtractsConfiguration Cfg
					INNER JOIN
				#BalanceSheet Bal
					ON Cfg.GLAccountNumber = Bal.GLAccountNumber
			WHERE
				Cfg.RollupLevel = @RollupLevel
			GROUP BY
				Cfg.RollupAccount
		)
		UPDATE
			Bal
		SET
			AverageEndOfMonthBalance = Sub.Subtotal
		FROM
			#BalanceSheet Bal
				INNER JOIN
			AccountRollup Sub
				ON Bal.GLAccountNumber = Sub.RollupAccount;


	/*
		PRINT 'Rollup #' + CAST(@RollupLevel AS VARCHAR);
		PRINT '---------'


		SELECT
			Bal.*,
			Cfg.*
		FROM
			#BalanceSheet Bal
				INNER JOIN
			Staging.business.FinancialExtractsConfiguration Cfg
				ON Bal.GLAccountNumber = Cfg.GLAccountNumber
		WHERE
			Cfg.HideFromReportFlag = 'N'
		ORDER BY
			Bal.GLAccountNumber;
	*/

	END;


	WITH TotalAssets AS
	(
		SELECT
			AverageEndOfMonthBalance
		FROM
			#BalanceSheet
		WHERE
			GLAccountNumber = '799999'
	),
	TotalLiabilitiesAndMembersEquity AS
	(
		SELECT
			AverageEndOfMonthBalance
		FROM
			#BalanceSheet
		WHERE
			GLAccountNumber = '999996'
	)
	UPDATE
		Bal
	SET
		AverageEndOfMonthBalance = Liab.AverageEndOfMonthBalance - Assets.AverageEndOfMonthBalance
	FROM
		#BalanceSheet Bal
			CROSS JOIN
		TotalAssets Assets
			CROSS JOIN
		TotalLiabilitiesAndMembersEquity Liab
	WHERE
		GLAccountNumber = '999997'


	SELECT
		[GL Account  Name] =
			CASE
				WHEN Cfg.FormattingCode = 'Blank' THEN SPACE(86)
				WHEN Cfg.FormattingCode = 'Sub' THEN SPACE(70) + '--------------- '
				ELSE CAST(Bal.GLAccountNumber AS CHAR(12))
						+ CAST(Bal.GLAccountDescription AS CHAR(58))
						+	CASE
								WHEN Bal.AverageEndOfMonthBalance < 0 THEN RIGHT('            <' + FORMAT(ABS(Bal.AverageEndOfMonthBalance), 'N2') + '>', 16)
								ELSE RIGHT('            ' + FORMAT(Bal.AverageEndOfMonthBalance, 'N2'), 15)
							END
			END
			+ SPACE(46)
	FROM
		Staging.business.FinancialExtractsConfiguration Cfg
			INNER JOIN
		#BalanceSheet Bal
			ON Cfg.GLAccountNumber = Bal.GLAccountNumber
	WHERE
		Cfg.HideFromReportFlag = 'N'
	ORDER BY
		Bal.GLAccountNumber;


	DROP TABLE #BalanceSheet;

END;
GO

