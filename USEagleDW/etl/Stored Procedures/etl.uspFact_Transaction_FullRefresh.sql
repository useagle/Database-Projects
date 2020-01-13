USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspFact_GLTransaction_FullRefresh')
	DROP PROCEDURE etl.uspFact_GLTransaction_FullRefresh;
GO


CREATE PROCEDURE etl.uspFact_GLTransaction_FullRefresh
AS
BEGIN


	ALTER TABLE fact.GLTransaction DROP CONSTRAINT FK_GLTransaction_GLAccount;
	ALTER TABLE fact.GLTransaction DROP CONSTRAINT FK_GLTransaction_GLAccountBranch;
	ALTER TABLE fact.GLTransaction DROP CONSTRAINT FK_GLTransaction_GLTransactionDetail;
	ALTER TABLE fact.GLTransaction DROP CONSTRAINT FK_GLTransaction_GLTransactionEffectiveDate;
	ALTER TABLE fact.GLTransaction DROP CONSTRAINT FK_GLTransaction_User;


	TRUNCATE TABLE fact.GLTransaction;


	IF EXISTS(SELECT * FROM tempdb.sys.objects WHERE name LIKE '%GLTransaction%')
		DROP TABLE #GLTransaction;


	CREATE TABLE
		#GLTransaction
	(
		GLAccountNumber				CHAR(14),
		TransactionSequenceNumber	INT,
		GLAccountBranchNumber		SMALLINT,
		GLTransactionEffectiveDate	DATE,
		UserNumber					SMALLINT,
		CreditAmount				DECIMAL(16, 2),
		DebitAmount					DECIMAL(16, 2),
		TransactionAmount			DECIMAL(16, 2),
		GLTransactionSourceSystem	VARCHAR(25),
		GLTransactionSourceID		VARCHAR(40)
	);


	INSERT INTO
		#GLTransaction
	(
		GLAccountNumber,
		TransactionSequenceNumber,
		GLAccountBranchNumber,
		GLTransactionEffectiveDate,
		UserNumber,
		CreditAmount,
		DebitAmount,
		TransactionAmount,
		GLTransactionSourceSystem,
		GLTransactionSourceID
	)
	SELECT
		GLAccountNumber = GLTrans.PARENTGLACCOUNT,
		TransactionSequenceNumber = GLTrans.SEQUENCENUMBER,
		GLAccountBranchNumber = CAST(RIGHT(GLTrans.PARENTGLACCOUNT, 4) AS SMALLINT),
		GLTransactionEffectiveDate = GLTrans.EFFECTIVEDATE,
		UserNumber = GLTrans.USERNUMBER,
		CreditAmount =	CASE
							WHEN GLTrans.DEBITCREDITCODE = 1 THEN GLTrans.AMOUNT
							ELSE 0
						END,
		DebitAmount =	CASE
							WHEN GLTrans.DEBITCREDITCODE = 0 THEN GLTrans.AMOUNT
							ELSE 0
						END,
		TransactionAmount = GLTrans.AMOUNT,
		GLTransactionSourceSystem = 'ARCU',
		GLTransactionSourceID = GLTrans.PARENTGLACCOUNT + '|' + CAST(GLTrans.SEQUENCENUMBER AS VARCHAR)+ '|'
								+ CONVERT(VARCHAR(8), GLTrans.POSTDATE, 112) + '|' + CAST(GLTrans.ORDINAL AS VARCHAR)
	FROM
		Staging.arcusym000.dbo_GLHISTORY GLTrans
	WHERE
		GLTrans.EFFECTIVEDATE >= '2017-01-01'
		AND
		GLTrans.DEBITCREDITCODE IN (0, 1);


	INSERT INTO
		fact.GLTransaction
	(
		GLAccountKey,
		GLAccountBranchKey,
		GLTransactionDetailKey,
		GLTransactionEffectiveDateKey,
		UserKey,
		CreditAmount,
		DebitAmount,
		TransactionAmount,
		GLTransactionSourceSystem,
		GLTransactionSourceID
	)
	SELECT
		GLAccountKey = ISNULL(GLAcct.GLAccountKey, -1),
		GLAccountBranchKey = ISNULL(Brn.BranchKey, -1),
		GLTransactionDetailKey= ISNULL(Dtl.GLTransactionDetailKey, -1),
		GLTransactionEffectiveDateKey = ISNULL(Dt.CalendarKey, -1),
		UserKey = ISNULL(Usr.UserKey, -1),
		CreditAmount = Trans.CreditAmount,
		DebitAmount = Trans.DebitAmount,
		TransactionAmount =	-1 * Trans.TransactionAmount,
		Trans.GLTransactionSourceSystem,
		Trans.GLTransactionSourceID
	FROM
		#GLTransaction Trans
			LEFT JOIN
		dim.Branch Brn
			ON Brn.BranchSourceSystem = 'ARCU' AND Trans.GLAccountBranchNumber = Brn.BranchSourceID AND Brn.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.Calendar Dt
			ON Trans.GLTransactionEffectiveDate = Dt.CalendarDate
			LEFT JOIN
		dim.GLAccount GLAcct
			ON GLAcct.GLAccountSourceSystem = 'ARCU' AND Trans.GLAccountNumber = GLAcct.GLAccountSourceID AND GLAcct.GLAccountActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.GLTransactionDetail Dtl
			ON Dtl.GLTransactionDetailSourceSystem = 'ARCU' AND Trans.GLTransactionSourceID = Dtl.GLTransactionDetailSourceID AND Dtl.GLTransactionDetailActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.[User] Usr
			ON Usr.UserSourceSystem = 'ARCU' AND Trans.UserNumber = Usr.UserSourceID AND Usr.UserActiveRecordFlag = 'Y'
	WHERE
		(GLAcct.GLAccountCategory1 = 'INCOME STATEMENT'
		OR
		GLAcct.GLAccountCategory1 IS NULL)
	ORDER BY
		Trans.GLTransactionEffectiveDate,
		Trans.GLAccountNumber;


	WITH DistinctGLTransactions AS
	(
		SELECT
			Trans.GLAccountKey,
			Trans.GLAccountBranchKey,
			MonthStartDate = 10000 * YEAR(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
							+ 100 * MONTH(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
							+ DAY(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))

		FROM
			fact.GLTransaction Trans
				INNER JOIN
			dim.Calendar EffDate
				ON Trans.GLTransactionEffectiveDateKey = EffDate.CalendarKey
		GROUP BY
			Trans.GLAccountKey,
			Trans.GLAccountBranchKey,
			10000 * YEAR(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
				+ 100 * MONTH(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
				+ DAY(DATEADD(dd, 1, EOMONTH(EffDate.CalendarDate, -1)))
	)
	INSERT INTO
		fact.GLTransaction
	(
		GLAccountBranchKey,
		GLAccountKey,
		GLTransactionDetailKey,
		GLTransactionEffectiveDateKey,
		UserKey,
		CreditAmount,
		DebitAmount,
		TransactionAmount,
		GLTransactionSourceSystem,
		GLTransactionSourceID
	)
	SELECT
		Budg.GLAccountBranchKey,
		Budg.GLAccountKey,
		GLTransactionDetailKey = -1,
		GLTransactionEffectiveDateKey = Budg.BudgetDateKey,
		UserKey = -1,
		CreditAmount = 0,
		DebitAmount = 0,
		TransactionAmount = 0,
		GLTransactionSourceSystem = 'Budget',
		GLTransactionSourceID = 'N/A'
	FROM
		fact.Budget Budg
			LEFT JOIN
		DistinctGLTransactions Trans
			ON Budg.GLAccountKey = Trans.GLAccountKey AND Budg.GLAccountBranchKey = Trans.GLAccountBranchKey AND Budg.BudgetDateKey = Trans.MonthStartDate
	WHERE
		Trans.GLAccountKey IS NULL
	ORDER BY
		Budg.BudgetDateKey,
		Budg.GLAccountKey;


	DROP TABLE #GLTransaction;


	ALTER TABLE fact.GLTransaction ADD CONSTRAINT FK_GLTransaction_GLAccount
	FOREIGN KEY (GLAccountKey) REFERENCES dim.GLAccount (GLAccountKey);

	ALTER TABLE fact.GLTransaction ADD CONSTRAINT FK_GLTransaction_GLAccountBranch
	FOREIGN KEY (GLAccountBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.GLTransaction ADD CONSTRAINT FK_GLTransaction_GLTransactionDetail
	FOREIGN KEY (GLTransactionDetailKey) REFERENCES dim.GLTransactionDetail (GLTransactionDetailKey);

	ALTER TABLE fact.GLTransaction ADD CONSTRAINT FK_GLTransaction_GLTransactionEffectiveDate
	FOREIGN KEY (GLTransactionEffectiveDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.GLTransaction ADD CONSTRAINT FK_GLTransaction_User
	FOREIGN KEY (UserKey) REFERENCES dim.[User] (UserKey);

END;
