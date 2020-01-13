USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'CurrentShare')
BEGIN

	CREATE TABLE
		fact.CurrentShare
	(
		ShareKey						INT IDENTITY(1, 1),
		AccountTypeKey					INT NOT NULL,
		ShareBranchKey					INT NOT NULL,
		ShareChargeOffDateKey			INT NOT NULL,
		ShareCloseDateKey				INT NOT NULL,
		ShareDescriptorKey				INT NOT NULL,
		ShareOpenDateKey				INT NOT NULL,
		ShareOriginationBranchKey		INT NOT NULL,
		ShareStatusKey					INT NOT NULL,
		MemberKey						INT NOT NULL,
		MemberBranchKey					INT NOT NULL,
		ChargedOffShareCount			INT NOT NULL,
		ClosedShareCount				INT NOT NULL,
		ShareChargeOffAmount			DECIMAL(16, 2) NOT NULL,
		ShareCurrentBalance				DECIMAL(16, 2) NOT NULL,
		ShareDividendRate				DECIMAL(8, 6) NOT NULL,
		ShareOriginalBalance			DECIMAL(16, 2) NOT NULL,
		ShareTerm						DECIMAL(8, 6) NOT NULL,
		OpenShareCount					INT NOT NULL,
		TotalShareCount					INT NOT NULL,
		ShareSourceSystem				VARCHAR(25) NOT NULL,
		ShareSourceID					SMALLINT NOT NULL
	);

	ALTER TABLE fact.CurrentShare ADD CONSTRAINT PK_CurrentShare
	PRIMARY KEY CLUSTERED (ShareKey);

END;
