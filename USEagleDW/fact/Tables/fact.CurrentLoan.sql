USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'CurrentLoan')
BEGIN

	CREATE TABLE
		fact.CurrentLoan
	(
		LoanKey						INT IDENTITY(1, 1),
		LoanBranchKey				INT NOT NULL,
		LoanChargeOffDateKey		INT NOT NULL,
		LoanCloseDateKey			INT NOT NULL,
		LoanCreditScoreKey			INT NOT NULL,
		LoanDescriptorKey			INT NOT NULL,
		LoanLastPaymentDateKey		INT NOT NULL,
		LoanNextPaymentDateKey		INT NOT NULL,
		LoanOpenDateKey				INT NOT NULL,
		LoanOriginationBranchKey	INT NOT NULL,
		LoanScheduledCloseDateKey	INT NOT NULL,
		LoanStatusKey				INT NOT NULL,
		LoanTypeKey					INT NOT NULL,
		MemberBranchKey				INT NOT NULL,
		ChargedOffLoanCount			INT NOT NULL,
		ClosedLoanCount				INT NOT NULL,
		LoanChargeOffAmount			DECIMAL(16, 2) NOT NULL,
		LoanCreditScore				SMALLINT NOT NULL,
		LoanCurrentBalance			DECIMAL(16, 2) NOT NULL,
		LoanCurrentRate				DECIMAL(8, 6) NOT NULL,
		LoanOriginalBalance			DECIMAL(16, 2) NOT NULL,
		LoanOriginalRate			DECIMAL(8, 6) NOT NULL,
		OpenLoanCount				INT NOT NULL,
		TotalLoanCount				INT NOT NULL,
		LoanSourceSystem			VARCHAR(25) NOT NULL,
		LoanSourceID				SMALLINT NOT NULL
	);

	ALTER TABLE dim.CurrentLoan ADD CONSTRAINT PK_CurrentLoan
	PRIMARY KEY CLUSTERED (LoanKey);

END;
