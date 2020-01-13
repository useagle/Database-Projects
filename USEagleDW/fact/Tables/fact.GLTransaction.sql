USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'GLTransaction')
BEGIN

	CREATE TABLE
		fact.GLTransaction
	(
		GLTransactionKey				INT IDENTITY(1, 1),
		GLAccountBranchKey				INT NOT NULL,
		GLAccountKey					INT NOT NULL,
		GLTransactionDetailKey			INT NOT NULL,
		GLTransactionEffectiveDateKey	INT NOT NULL,
		UserKey							INT NOT NULL,
		CreditAmount					DECIMAL(16, 2) NOT NULL,
		DebitAmount						DECIMAL(16, 2) NOT NULL,
		TransactionAmount				DECIMAL(16, 2) NOT NULL,
		GLTransactionSourceSystem		VARCHAR(25) NOT NULL,
		GLTransactionSourceID			CHAR(25) NOT NULL
	);

	ALTER TABLE fact.GLTransaction ADD CONSTRAINT PK_GLTransaction
	PRIMARY KEY CLUSTERED (GLTransactionKey);

	ALTER TABLE fact.GLTransaction ADD CONSTRAINT FK_GLTransaction_GLTransactionEffectiveDate
	FOREIGN KEY (GLTransactionEffectiveDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.GLTransaction ADD CONSTRAINT FK_GLTransaction_GLAccount
	FOREIGN KEY (GLAccountKey) REFERENCES dim.GLAccount (GLAccountKey);

	ALTER TABLE fact.GLTransaction ADD CONSTRAINT FK_GLTransaction_GLAccountBranch
	FOREIGN KEY (GLAccountBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.GLTransaction ADD CONSTRAINT FK_GLTransaction_User
	FOREIGN KEY (UserKey) REFERENCES dim.[User] (UserKey);

END;
