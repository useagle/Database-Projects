USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'CurrentAccount')
BEGIN

	CREATE TABLE
		fact.CurrentAccount
	(
		CurrentAccountKey				INT IDENTITY(1, 1),
		AccountBranchKey				INT NOT NULL,
		AccountCloseDateKey				INT NOT NULL,
		AccountDescriptorKey			INT NOT NULL,
		AccountOpenDateKey				INT NOT NULL,
		AllAccountsCount				INT NOT NULL,
		ClosedAccountsCount				INT NOT NULL,
		OpenAccountsCount				INT NOT NULL,
		OpenLoansCount					INT NOT NULL,
		OpenSharesCount					INT NOT NULL,
		TotalLoanBalance				DECIMAL(16, 2) NOT NULL,
		TotalShareBalance				DECIMAL(16, 2) NOT NULL,
		CurrentAccountSourceSystem		VARCHAR(25) NOT NULL,
		CurrentAccountSourceID			VARCHAR(10) NOT NULL
	);

	ALTER TABLE fact.CurrentAccount ADD CONSTRAINT PK_CurrentAccount
	PRIMARY KEY CLUSTERED (CurrentAccountKey);

	ALTER TABLE fact.CurrentAccount ADD CONSTRAINT FK_CurrentAccount_AccountBranch
	FOREIGN KEY (AccountBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.CurrentAccount ADD CONSTRAINT FK_CurrentAccount_AccountCloseDate
	FOREIGN KEY (AccountCloseDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.CurrentAccount ADD CONSTRAINT FK_CurrentAccount_AccountDescriptor
	FOREIGN KEY (AccountDescriptorKey) REFERENCES dim.AccountDescriptor (AccountDescriptorKey);

	ALTER TABLE fact.CurrentAccount ADD CONSTRAINT FK_CurrentAccount_AccountOpenDate
	FOREIGN KEY (AccountOpenDateKey) REFERENCES dim.Calendar (CalendarKey);

END;
