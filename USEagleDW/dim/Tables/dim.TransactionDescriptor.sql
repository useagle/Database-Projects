USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'TransactionDescriptor')
BEGIN

	CREATE TABLE
		dim.TransactionDescriptor
	(
		TransactionDescriptorKey					INT IDENTITY(1, 1),
		TransactionConsoleNumber					SMALLINT NOT NULL,
		TransactionParentID							CHAR(4) NOT NULL,
		TransactionSequenceNumber					INT NOT NULL,
		TransactionDescriptorSourceSystem			VARCHAR(25) NOT NULL,
		TransactionDescriptorSourceID				VARCHAR(40) NOT NULL,
		TransactionDescriptorHash					VARBINARY(64) NOT NULL,
		TransactionDescriptorStartEffectiveDate		DATE NOT NULL,
		TransactionDescriptorEndEffectiveDate		DATE NOT NULL,
		TransactionDescriptorActiveRecordFlag		CHAR(1) NOT NULL
	);

	ALTER TABLE dim.TransactionDescriptor ADD CONSTRAINT PK_TransactionDescriptor
	PRIMARY KEY CLUSTERED (TransactionDescriptorKey);


	SET IDENTITY_INSERT dim.TransactionDescriptor ON;

	INSERT INTO
		dim.TransactionDescriptor
	(
		TransactionDescriptorKey,
		TransactionConsoleNumber,
		TransactionParentID,
		TransactionSequenceNumber,
		TransactionDescriptorSourceSystem,
		TransactionDescriptorSourceID,
		TransactionDescriptorHash,
		TransactionDescriptorStartEffectiveDate,
		TransactionDescriptorEndEffectiveDate,
		TransactionDescriptorActiveRecordFlag
	)
	VALUES
	(
		-1,												--	TransactionDescriptorKey
		-1,												--	TransactionConsoleNumber
		'N/A',											--	TransactionParentID
		-1,												--	TransactionSequenceNumber
		'Sentinel',										--	TransactionDescriptorSourceSystem
		-1,												--	TransactionDescriptorSourceID
		HASHBYTES('SHA2_512', '-1' + 'N/A' + '-1'),		--	TransactionDescriptorHash
		'2017-01-01',									--	TransactionDescriptorStartEffectiveDate
		'2099-12-31',									--	TransactionDescriptorEndEffectiveDate
		'Y'												--	TransactionDescriptorActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.TransactionDescriptor OFF;

END;
