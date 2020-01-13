USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'Transaction')
BEGIN

	CREATE TABLE
		fact.[Transaction]
	(
		TransactionKey				INT IDENTITY(1, 1),
		AccountDescriptorKey		INT NOT NULL,
		TransactionBranchKey		INT NOT NULL,
		TransactionDateKey			INT NOT NULL,
		TransactionDescriptorKey	INT NOT NULL,
		TransactionTimeKey			INT NOT NULL,
		TransactionTypeKey			INT NOT NULL,
		UserKey						INT NOT NULL,
		TransactionAmount			DECIMAL(16, 2) NOT NULL,
		TransactionCount			INT NOT NULL,
		TransactionSourceSystem		VARCHAR(25) NOT NULL,
		TransactionSourceID			VARCHAR(50) NOT NULL
	);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT PK_Transaction
	PRIMARY KEY CLUSTERED (TransactionKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_AccountDescriptor
	FOREIGN KEY (AccountDescriptorKey) REFERENCES dim.AccountDescriptor (AccountDescriptorKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionBranch
	FOREIGN KEY (TransactionBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionDate
	FOREIGN KEY (TransactionDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionDescriptor
	FOREIGN KEY (TransactionDescriptorKey) REFERENCES dim.TransactionDescriptor (TransactionDescriptorKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionTime
	FOREIGN KEY (TransactionTimeKey) REFERENCES dim.Time (TimeKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionType
	FOREIGN KEY (TransactionTypeKey) REFERENCES dim.TransactionType (TransactionTypeKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_User
	FOREIGN KEY (UserKey) REFERENCES dim.[User] (UserKey);

END;
