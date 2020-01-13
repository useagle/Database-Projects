USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'Budget')
BEGIN

	CREATE TABLE
		fact.Budget
	(
		BudgetKey				INT IDENTITY(1, 1),
		BudgetDateKey			INT NOT NULL,
		GLAccountKey			INT NOT NULL,
		GLAccountBranchKey		INT NOT NULL,
		BudgetAmount			DECIMAL(16, 2) NOT NULL,
		BudgetSourceSystem		VARCHAR(25) NOT NULL,
		BudgetSourceID			CHAR(25) NOT NULL
	);

	ALTER TABLE fact.Budget ADD CONSTRAINT PK_Budget
	PRIMARY KEY CLUSTERED (BudgetKey);

	ALTER TABLE fact.Budget ADD CONSTRAINT FK_Budget_BudgetDate
	FOREIGN KEY (BudgetDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.Budget ADD CONSTRAINT FK_Budget_GLAccount
	FOREIGN KEY (GLAccountKey) REFERENCES dim.GLAccount (GLAccountKey);

	ALTER TABLE fact.Budget ADD CONSTRAINT FK_Budget_GLAccountBranch
	FOREIGN KEY (GLAccountBranchKey) REFERENCES dim.Branch (BranchKey);

END;
