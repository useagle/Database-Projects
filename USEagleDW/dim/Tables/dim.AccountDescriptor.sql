USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'AccountDescriptor')
BEGIN

	CREATE TABLE
		dim.AccountDescriptor
	(
		AccountDescriptorKey					INT IDENTITY(1, 1),
		AccountCloseReason						VARCHAR(40) NOT NULL,
		AccountCloseReasonRaw					VARCHAR(40) NOT NULL,
		AccountCloseReasonText					VARCHAR(40) NOT NULL,
		AccountNumber							VARCHAR(10) NOT NULL,
		AccountPrimaryName						VARCHAR(75) NOT NULL,
		AccountStatus							VARCHAR(6) NOT NULL,
		AccountTypeNumber						SMALLINT NOT NULL,
		AccountTypeName							VARCHAR(50) NOT NULL,
		AccountTypeNumberAndName				VARCHAR(55) NOT NULL,
		AccountTypeCategory1					VARCHAR(25) NOT NULL,
		AccountTypeCategory2					VARCHAR(25) NOT NULL,
		AccountTypeCategory3					VARCHAR(25) NOT NULL,
		AccountDescriptorSourceSystem			VARCHAR(25) NOT NULL,
		AccountDescriptorSourceID				VARCHAR(10) NOT NULL,
		AccountDescriptorHash					VARBINARY(64) NOT NULL,
		AccountDescriptorStartEffectiveDate		DATE NOT NULL,
		AccountDescriptorEndEffectiveDate		DATE NOT NULL,
		AccountDescriptorActiveRecordFlag		CHAR(1) NOT NULL
	);

	ALTER TABLE dim.AccountDescriptor ADD CONSTRAINT PK_AccountDescriptor
	PRIMARY KEY CLUSTERED (AccountDescriptorKey);



	SET IDENTITY_INSERT dim.AccountDescriptor ON;

	INSERT INTO
		dim.AccountDescriptor
	(
		AccountDescriptorKey,
		AccountCloseReason,
		AccountCloseReasonRaw,
		AccountCloseReasonText,
		AccountNumber,
		AccountPrimaryName,
		AccountStatus,
		AccountTypeNumber,
		AccountTypeName,
		AccountTypeNumberAndName,
		AccountTypeCategory1,
		AccountTypeCategory2,
		AccountTypeCategory3,
		AccountDescriptorSourceSystem,
		AccountDescriptorSourceID,
		AccountDescriptorHash,
		AccountDescriptorStartEffectiveDate,
		AccountDescriptorEndEffectiveDate,
		AccountDescriptorActiveRecordFlag
	)
	VALUES
	(
		-1,																		--	AccountDescriptorKey
		'N/A',																	--	AccountCloseReason
		'N/A',																	--	AccountCloseReasonRaw
		'N/A',																	--	AccountCloseReasonText
		-1,																		--	AccountNumber
		'<Account Descriptor Missing>',											--	AccountPrimaryName
		'N/A',																	--	AccountStatus
		-1,																		--	AccountTypeNumber
		'N/A',																	--	AccountTypeName
		'N/A',																	--	AccountTypeNameAndNumber
		'N/A',																	--	AccountTypeCategory1
		'N/A',																	--	AccountTypeCategory2
		'N/A',																	--	AccountTypeCategory3
		'Sentinel',																--	AccountDescriptorSourceSystem
		-1,																		--	AccountDescriptorSourceID
		HASHBYTES('SHA2_512', 'N/A' + 'N/A' + 'N/A' + '<Account Descriptor Missing>'
			+ 'N/A' + '-1' + 'N/A' + 'N/A' + 'N/A' + 'N/A>'),					--	AccountDescriptorHash
		'2017-01-01',															--	AccountDescriptorStartEffectiveDate
		'2099-12-31',															--	AccountDescriptorEndEffectiveDate
		'Y'																		--	AccountDescriptorActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.AccountDescriptor OFF;

END;
