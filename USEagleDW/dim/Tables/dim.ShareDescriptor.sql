USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'ShareDescriptor')
BEGIN

	CREATE TABLE
		dim.ShareDescriptor
	(
		ShareDescriptorKey					INT IDENTITY(1, 1),
		ShareAccountNumber					VARCHAR(30) NOT NULL,
		ShareNumber							VARCHAR(10) NOT NULL,
		ShareDescriptorSourceSystem			VARCHAR(25) NOT NULL,
		ShareDescriptorSourceID				SMALLINT NOT NULL,
		ShareDescriptorHash					VARBINARY(64) NOT NULL,
		ShareDescriptorStartEffectiveDate	DATE NOT NULL,
		ShareDescriptorEndEffectiveDate		DATE NOT NULL,
		ShareDescriptorActiveRecordFlag		CHAR(1) NOT NULL
	);

	ALTER TABLE dim.ShareDescriptor ADD CONSTRAINT PK_ShareDescriptor
	PRIMARY KEY CLUSTERED (ShareDescriptorKey);



	SET IDENTITY_INSERT dim.ShareDescriptor ON;

	INSERT INTO
		dim.ShareDescriptor
	(
		ShareDescriptorKey,
		ShareAccountNumber,
		ShareNumber,
		ShareDescriptorSourceSystem,
		ShareDescriptorSourceID,
		ShareDescriptorHash,
		ShareDescriptorStartEffectiveDate,
		ShareDescriptorEndEffectiveDate,
		ShareDescriptorActiveRecordFlag
	)
	VALUES
	(
		-2,											--	ShareDescriptorKey
		'<Not Applicable>',							--	ShareAccountNumber
		-2,											--	ShareNumber,
		'Sentinel',									--	ShareDescriptorSourceSystem
		-2,											--	ShareDescriptorSourceID
		HASHBYTES('SHA2_512', '<Not Applicable>'),	--	ShareDescriptorHash
		'2017-01-01',								--	ShareDescriptorStartEffectiveDate
		'2099-12-31',								--	ShareDescriptorEndEffectiveDate
		'Y'											--	ShareDescriptorActiveRecordFlag
	);


	INSERT INTO
		dim.ShareDescriptor
	(
		ShareDescriptorKey,
		ShareAccountNumber,
		ShareNumber,
		ShareDescriptorSourceSystem,
		ShareDescriptorSourceID,
		ShareDescriptorHash,
		ShareDescriptorStartEffectiveDate,
		ShareDescriptorEndEffectiveDate,
		ShareDescriptorActiveRecordFlag
	)
	VALUES
	(
		-1,														--	ShareDescriptorKey
		'<Share Descriptor Missing>',							--	ShareAccountNumber
		-1,														--	ShareNumber
		'Sentinel',												--	ShareDescriptorSourceSystem
		-1,														--	ShareDescriptorSourceID
		HASHBYTES('SHA2_512', '<Share Descriptor Missing>'),	--	ShareDescriptorHash
		'2017-01-01',											--	ShareDescriptorStartEffectiveDate
		'2099-12-31',											--	ShareDescriptorEndEffectiveDate
		'Y'														--	ShareDescriptorActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.ShareDescriptor OFF;

END;
