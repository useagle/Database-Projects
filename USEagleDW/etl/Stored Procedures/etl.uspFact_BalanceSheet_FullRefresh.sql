USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspFact_BalanceSheet_FullRefresh')
	DROP PROCEDURE etl.uspFact_BalanceSheet_FullRefresh;
GO


CREATE PROCEDURE etl.uspFact_BalanceSheet_FullRefresh
AS
BEGIN

	ALTER TABLE fact.BalanceSheet DROP CONSTRAINT FK_BalanceSheet_GLAccount;
	ALTER TABLE fact.BalanceSheet DROP CONSTRAINT FK_BalanceSheet_GLAccountBranch;
	ALTER TABLE fact.BalanceSheet DROP CONSTRAINT FK_BalanceSheet_Period;


	TRUNCATE TABLE fact.BalanceSheet;


	IF EXISTS(SELECT * FROM tempdb.sys.objects WHERE name LIKE '%BalanceSheet%')
		DROP TABLE #BalanceSheet;


	CREATE TABLE
		#BalanceSheet
	(
		GLAccountNumber					CHAR(14),
		GLAccountBranchNumber			SMALLINT,
		PeriodDate						DATE,
		AccountBalance					DECIMAL(16, 2),
		EndOfDaySnapshotBalance			DECIMAL(16, 2),
		BackDatedTransactionAmount		DECIMAL(16, 2),
		BalanceSheetSourceSystem		VARCHAR(25),
		BalanceSheetSourceID			VARCHAR(40)
	);


	INSERT INTO
		#BalanceSheet
	(
		GLAccountNumber,
		GLAccountBranchNumber,
		PeriodDate,
		AccountBalance,
		EndOfDaySnapshotBalance,
		BackDatedTransactionAmount,
		BalanceSheetSourceSystem,
		BalanceSheetSourceID
	)
	EXEC Staging.etl.uspBalanceSheet_GetData;


	INSERT INTO
		fact.BalanceSheet
	(
		GLAccountKey,
		GLAccountBranchKey,
		PeriodKey,
		AccountBalance,
		BalanceSheetSourceSystem,
		BalanceSheetSourceID
	)
	SELECT
		GLAccountKey = ISNULL(GLAcct.GLAccountKey, -1),
		GLAccountBranchKey = ISNULL(Brn.BranchKey, -1),
		PeriodKey = CAST(CONVERT(VARCHAR(8), Trans.PeriodDate, 112) AS INT),
		AccountBalance = Trans.AccountBalance,
		Trans.BalanceSheetSourceSystem,
		Trans.BalanceSheetSourceID
	FROM
		#BalanceSheet Trans
			LEFT JOIN
		dim.Branch Brn
			ON Brn.BranchSourceSystem = 'ARCU' AND Trans.GLAccountBranchNumber = Brn.BranchSourceID AND Brn.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.GLAccount GLAcct
			ON GLAcct.GLAccountSourceSystem = 'ARCU' AND Trans.GLAccountNumber = GLAcct.GLAccountSourceID AND GLAcct.GLAccountActiveRecordFlag = 'Y'
	WHERE
		(GLAcct.GLAccountCategory1 = 'BALANCE SHEET'
		OR
		GLAcct.GLAccountCategory1 IS NULL)
	ORDER BY
		Trans.PeriodDate,
		Trans.GLAccountNumber;


/*
	WITH DistinctBalanceSheets AS
	(
		SELECT
			Bal.GLAccountKey,
			Bal.GLAccountBranchKey,
			MonthStartDate = 10000 * YEAR(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
							+ 100 * MONTH(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
							+ DAY(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))

		FROM
			fact.BalanceSheet Bal
				INNER JOIN
			dim.Calendar Dt
				ON Bal.MonthEndDateKey = Dt.CalendarKey
		GROUP BY
			Bal.GLAccountKey,
			Bal.GLAccountBranchKey,
			10000 * YEAR(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
				+ 100 * MONTH(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
				+ DAY(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
	)
	INSERT INTO
		fact.BalanceSheet
	(
		GLAccountBranchKey,
		GLAccountKey,
		AccountBalance,
		BalanceSheetSourceSystem,
		BalanceSheetSourceID
	)
	SELECT
		Budg.GLAccountBranchKey,
		Budg.GLAccountKey,
		BalanceSheetDetailKey = -1,
		BalanceSheetEffectiveDateKey = Budg.BudgetDateKey,
		UserKey = -1,
		CreditAmount = 0,
		DebitAmount = 0,
		TransactionAmount = 0,
		BalanceSheetSourceSystem = 'Budget',
		BalanceSheetSourceID = 'N/A'
	FROM
		fact.Budget Budg
			LEFT JOIN
		DistinctBalanceSheets Trans
			ON Budg.GLAccountKey = Trans.GLAccountKey AND Budg.GLAccountBranchKey = Trans.GLAccountBranchKey AND Budg.BudgetDateKey = Trans.MonthStartDate
	WHERE
		Trans.GLAccountKey IS NULL
	ORDER BY
		Budg.BudgetDateKey,
		Budg.GLAccountKey;
*/


	DROP TABLE #BalanceSheet;


	ALTER TABLE fact.BalanceSheet ADD CONSTRAINT FK_BalanceSheet_GLAccount
	FOREIGN KEY (GLAccountKey) REFERENCES dim.GLAccount (GLAccountKey);

	ALTER TABLE fact.BalanceSheet ADD CONSTRAINT FK_BalanceSheet_GLAccountBranch
	FOREIGN KEY (GLAccountBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.BalanceSheet ADD CONSTRAINT FK_BalanceSheet_Period
	FOREIGN KEY (PeriodKey) REFERENCES dim.Calendar (CalendarKey);

END;
