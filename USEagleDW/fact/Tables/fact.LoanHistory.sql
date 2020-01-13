USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'LoanHistory')
BEGIN

	CREATE TABLE
		fact.LoanHistory
	(
		LoanHistoryKey				INT IDENTITY(1, 1),
		AccountBranchKey			INT NOT NULL,
		LoanBranchKey				INT NOT NULL,
		LoanChargeOffDateKey		INT NOT NULL,
		LoanCloseDateKey			INT NOT NULL,
		LoanCreditScoreKey			INT NOT NULL,
		LoanDescriptorKey			INT NOT NULL,
		LoanLastPaymentDateKey		INT NOT NULL,
		LoanNextPaymentDateKey		INT NOT NULL,
		LoanOpenDateKey				INT NOT NULL,
		LoanScheduledCloseDateKey	INT NOT NULL,
		LoanStatusKey				INT NOT NULL,
		LoanTypeKey					INT NOT NULL,
		LoanChargeOffAmount			DECIMAL(16, 2) NOT NULL,
		LoanCurrentBalance			DECIMAL(16, 2) NOT NULL,
		LoanCurrentRate				DECIMAL(8, 6) NOT NULL,
		LoanOriginalBalance			DECIMAL(16, 2) NOT NULL,
		LoanOriginalRate			DECIMAL(8, 6) NOT NULL,
		TotalLoanCount				INT NOT NULL,
		LoanHistorySourceSystem		VARCHAR(25) NOT NULL,
		LoanHistorySourceID			SMALLINT NOT NULL
	);

	ALTER TABLE dim.LoanHistory ADD CONSTRAINT PK_LoanHistory
	PRIMARY KEY CLUSTERED (LoanHistoryKey);

END;
