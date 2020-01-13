USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'TransactionCode')
BEGIN

	CREATE TABLE
		dim.TransactionCode
	(
		TransactionCodeKey					INT IDENTITY(1, 1),
		TransactionAccountType				VARCHAR(6),
		TransactionTypeCode					VARCHAR(3),
		TransactionTypeName					VARCHAR(15),
		TransactionSourceCode				VARCHAR(3),
		TransactionSourceName				VARCHAR(30),
		TransactionCodeSourceSystem			VARCHAR(25),
		TransactionCodeSourceID				SMALLINT,
		TransactionCodeHash					INT,
		TransactionCodeStartEffectiveDate	DATE,
		TransactionCodeEndEffectiveDate		DATE,
		TransactionCodeActiveRecordFlag		CHAR(1)
	);

	ALTER TABLE dim.TransactionCode ADD CONSTRAINT PK_TransactionCode
	PRIMARY KEY CLUSTERED (TransactionCodeKey);



	SET IDENTITY_INSERT dim.TransactionCode ON;

	INSERT INTO
		dim.TransactionCode
	(
		TransactionCodeKey,
		TransactionAccountType,
		TransactionTypeCode,
		TransactionTypeName,
		TransactionSourceCode,
		TransactionSourceName,
		TransactionCodeSourceSystem,
		TransactionCodeSourceID,
		TransactionCodeHash,
		TransactionCodeStartEffectiveDate,
		TransactionCodeEndEffectiveDate,
		TransactionCodeActiveRecordFlag
	)
	VALUES
	(
		-1,											--	TransactionCodeKey
		'N/A',										--	TransactionAccountType
		'N/A',										--	TransactionTypeCode
		'N/A',										--	TransactionTypeName
		'N/A',										--	TransactionSourceCode
		'N/A',										--	TransactionSourceCode
		'Sentinel',									--	TransactionCodeSourceSystem
		-1,											--	TransactionCodeSourceID
		HASHBYTES('SHA2_512', 'N/A' + 'N/A' + 'N/A'
					+ 'N/A'+ 'N/A'),				--	TransactionCodeCheckSum
		'2017-01-01',								--	TransactionCodeStartEffectiveDate
		'2099-12-31',								--	TransactionCodeEndEffectiveDate
		'Y'											--	TransactionCodeActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.TransactionCode OFF;

END;
