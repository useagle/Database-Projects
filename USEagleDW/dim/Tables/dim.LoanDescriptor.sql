USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'LoanDescriptor')
BEGIN

	CREATE TABLE
		dim.LoanDescriptor
	(
		LoanDescriptorKey					INT IDENTITY(1, 1),
		LoanAccountNumber					VARCHAR(25) NOT NULL,
		LoanID								VARCHAR(10) NOT NULL,
		LoanIsIndirectFlag					CHAR(1) NOT NULL,
		LoanTerm							SMALLINT NOT NULL,
		LoanDescriptorSourceSystem			VARCHAR(25) NOT NULL,
		LoanDescriptorSourceID				CHAR(15) NOT NULL,
		LoanDescriptorHash					VARBINARY(64),
		LoanDescriptorStartEffectiveDate	DATE,
		LoanDescriptorEndEffectiveDate		DATE,
		LoanDescriptorActiveRecordFlag		CHAR(1)
	);

	ALTER TABLE dim.LoanDescriptor ADD CONSTRAINT PK_LoanDescriptor
	PRIMARY KEY CLUSTERED (LoanDescriptorKey);



	SET IDENTITY_INSERT dim.LoanDescriptor ON;

	INSERT INTO
		dim.LoanDescriptor
	(
		LoanDescriptorKey,
		LoanAccountNumber,
		LoanID,
		LoanIsIndirectFlag,
		LoanTerm,
		LoanDescriptorSourceSystem,
		LoanDescriptorSourceID,
		LoanDescriptorHash,	
		LoanDescriptorStartEffectiveDate,
		LoanDescriptorEndEffectiveDate,
		LoanDescriptorActiveRecordFlag
	)
	VALUES
	(
		-2,														--	LoanDescriptorKey
		'<Not Applicable>',										--	LoanAccountNumber
		'N/A',													--	LoanID
		'X',													--	LoanIsIndirectFlag
		0,														--	LoanTerm,
		'Sentinel',												--	LoanDescriptorSourceSystem
		-2,														--	LoanDescriptorSourceID
		HASHBYTES('SHA2_512', '<Not Applicable>' + '||X||0'),	--	LoanDescriptorHash
		'2017-01-01',											--	LoanDescriptorStartEffectiveDate
		'2099-12-31',											--	LoanDescriptorEndEffectiveDate
		'Y'														--	LoanDescriptorActiveRecordFlag
	);


	INSERT INTO
		dim.LoanDescriptor
	(
		LoanDescriptorKey,
		LoanAccountNumber,
		LoanID,
		LoanIsIndirectFlag,
		LoanTerm,
		LoanDescriptorSourceSystem,
		LoanDescriptorSourceID,
		LoanDescriptorHash,	
		LoanDescriptorStartEffectiveDate,
		LoanDescriptorEndEffectiveDate,
		LoanDescriptorActiveRecordFlag
	)
	VALUES
	(
		-1,																	--	LoanDescriptorKey
		'<Loan Descriptor Missing>',										--	LoanAccountNumber
		'N/A',																--	LoanID
		'X',																--	LoanIsIndirectFlag
		0,																	--	LoanTerm
		'Sentinel',															--	LoanDescriptorSourceSystem
		-1,																	--	LoanDescriptorSourceID
		HASHBYTES('SHA2_512', '<Loan Descriptor Missing>' + '||X||0'),		--	LoanDescriptorHash
		'2017-01-01',														--	LoanDescriptorStartEffectiveDate
		'2099-12-31',														--	LoanDescriptorEndEffectiveDate
		'Y'																	--	LoanDescriptorActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.LoanDescriptor OFF;

END;
