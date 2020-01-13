USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspFact_Budget_FullRefresh')
	DROP PROCEDURE etl.uspFact_Budget_FullRefresh;
GO


CREATE PROCEDURE etl.uspFact_Budget_FullRefresh
AS
BEGIN

	ALTER TABLE fact.Budget DROP CONSTRAINT FK_BudgetDate;
	ALTER TABLE fact.Budget DROP CONSTRAINT FK_GLAccount;
	ALTER TABLE fact.Budget DROP CONSTRAINT FK_GLAccountBranch;


	TRUNCATE TABLE fact.Budget;


	IF EXISTS(SELECT * FROM tempdb.sys.objects WHERE name LIKE '%Budget%')
		DROP TABLE #Budget;


	CREATE TABLE
		#Budget
	(
		GLAccountNumber		CHAR(14),
		BranchNumber		SMALLINT,
		BudgetDate			DATE,
		BudgetAmount		DECIMAL(16, 2)
	);


	INSERT INTO	#Budget
	EXEC Staging.etl.uspBudget_GetData;


	INSERT INTO
		fact.Budget
	(
		BudgetDateKey,
		GLAccountKey,
		GLAccountBranchKey,
		BudgetAmount,
		BudgetSourceSystem,
		BudgetSourceID
	)
	SELECT
		BudgetDateKey = ISNULL(Dt.CalendarKey, -1),
		GLAccountKey = ISNULL(GLAcct.GLAccountKey, -1),
		GLAccountBranchKey = ISNULL(Brn.BranchKey, -1),
		BudgetAmount =	CASE
							WHEN GLAcct.GLAccountCategory3 = 'TOTAL EXPENSE' THEN -1 * Budg.BudgetAmount
							ELSE Budg.BudgetAmount
						END,
		BudgetSourceSystem = 'Budget',
		BudgetSourceID = Budg.GLAccountNumber + '|' + CONVERT(VARCHAR(10), Budg.BudgetDate, 120)
	FROM
		#Budget Budg
			LEFT JOIN
		dim.Branch Brn
			ON Brn.BranchSourceSystem = 'ARCU' AND Budg.BranchNumber = Brn.BranchSourceID AND Brn.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.Calendar Dt
			ON Budg.BudgetDate = Dt.CalendarDate
			LEFT JOIN
		dim.GLAccount GLAcct
			ON GLAcct.GLAccountSourceSystem = 'ARCU' AND Budg.GLAccountNumber = GLAcct.GLAccountSourceID AND GLAcct.GLAccountActiveRecordFlag = 'Y'
	WHERE
		(GLAcct.GLAccountCategory1 = 'INCOME STATEMENT'
		OR
		GLAcct.GLAccountCategory1 IS NULL)
	ORDER BY
		Budg.BudgetDate,
		Budg.GLAccountNumber;


	ALTER TABLE fact.Budget ADD CONSTRAINT FK_BudgetDate
	FOREIGN KEY (BudgetDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.Budget ADD CONSTRAINT FK_GLAccount
	FOREIGN KEY (GLAccountKey) REFERENCES dim.GLAccount (GLAccountKey);

	ALTER TABLE fact.Budget ADD CONSTRAINT FK_GLAccountBranch
	FOREIGN KEY (GLAccountBranchKey) REFERENCES dim.Branch (BranchKey);

END;
