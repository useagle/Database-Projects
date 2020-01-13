USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'BalanceSheet')
BEGIN

	CREATE TABLE
		fact.BalanceSheet
	(
		BalanceSheetKey				INT IDENTITY(1, 1),
		GLAccountBranchKey			INT NOT NULL,
		GLAccountKey				INT NOT NULL,
		MonthEndDateKey				INT NOT NULL,
		AccountBalance				DECIMAL(16, 2) NOT NULL,
		BalanceSheetSourceSystem	VARCHAR(25) NOT NULL,
		BalanceSheetSourceID		CHAR(25) NOT NULL
	);

	ALTER TABLE fact.BalanceSheet ADD CONSTRAINT PK_BalanceSheet
	PRIMARY KEY CLUSTERED (BalanceSheetKey);

	ALTER TABLE fact.BalanceSheet ADD CONSTRAINT FK_BalanceSheet_GLAccount
	FOREIGN KEY (GLAccountKey) REFERENCES dim.GLAccount (GLAccountKey);

	ALTER TABLE fact.BalanceSheet ADD CONSTRAINT FK_BalanceSheet_GLAccountBranch
	FOREIGN KEY (GLAccountBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.BalanceSheet ADD CONSTRAINT FK_BalanceSheet_MonthEndDate
	FOREIGN KEY (MonthEnddateKey) REFERENCES dim.Calendar (CalendarKey);

END;
