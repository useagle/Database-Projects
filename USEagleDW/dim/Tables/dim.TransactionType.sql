USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'TransactionType')
BEGIN

	CREATE TABLE
		dim.TransactionType
	(
		TransactionTypeKey					INT IDENTITY(1, 1),
		TransactionAccountType				VARCHAR(6),
		TransactionActionCode				VARCHAR(3),
		TransactionActionName				VARCHAR(15),
		TransactionSourceCode				VARCHAR(3),
		TransactionSourceName				VARCHAR(30),
		TransactionTypeSourceSystem			VARCHAR(25),
		TransactionTypeSourceID				VARCHAR(15),
		TransactionTypeHash					INT,
		TransactionTypeStartEffectiveDate	DATE,
		TransactionTypeEndEffectiveDate		DATE,
		TransactionTypeActiveRecordFlag		CHAR(1)
	);

	ALTER TABLE dim.TransactionType ADD CONSTRAINT PK_TransactionType
	PRIMARY KEY CLUSTERED (TransactionTypeKey);



	SET IDENTITY_INSERT dim.TransactionType ON;

	INSERT INTO
		dim.TransactionType
	(
		TransactionTypeKey,
		TransactionAccountType,
		TransactionActionCode,
		TransactionActionName,
		TransactionSourceCode,
		TransactionSourceName,
		TransactionTypeSourceSystem,
		TransactionTypeSourceID,
		TransactionTypeHash,
		TransactionTypeStartEffectiveDate,
		TransactionTypeEndEffectiveDate,
		TransactionTypeActiveRecordFlag
	)
	VALUES
	(
		-1,											--	TransactionTypeKey
		'N/A',										--	TransactionAccountType
		'N/A',										--	TransactionActionCode
		'N/A',										--	TransactionActionName
		'N/A',										--	TransactionSourceCode
		'N/A',										--	TransactionSourceCode
		'Sentinel',									--	TransactionTypeSourceSystem
		-1,											--	TransactionTypeSourceID
		HASHBYTES('SHA2_512', 'N/A' + 'N/A' + 'N/A'
					+ 'N/A'+ 'N/A'),				--	TransactionTypeCheckSum
		'2017-01-01',								--	TransactionTypeStartEffectiveDate
		'2099-12-31',								--	TransactionTypeEndEffectiveDate
		'Y'											--	TransactionTypeActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.TransactionType OFF;

END;
