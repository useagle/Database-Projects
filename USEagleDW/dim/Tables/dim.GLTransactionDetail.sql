USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'GLTransactionDetail')
BEGIN

	CREATE TABLE
		dim.GLTransactionDetail
	(
		GLTransactionDetailKey					INT IDENTITY(1, 1),
		Comment									VARCHAR(40) NOT NULL,
		GLTransactionPostDate					DATE NOT NULL,
		Reference								CHAR(10) NOT NULL,
		SequenceNumber							INT NOT NULL,
		GLTransactionDetailSourceSystem			VARCHAR(25) NOT NULL,
		GLTransactionDetailSourceID				VARCHAR(40) NOT NULL,
		GLTransactionDetailCheckSum				INT NOT NULL,
		GLTransactionDetailStartEffectiveDate	DATE NOT NULL,
		GLTransactionDetailEndEffectiveDate		DATE NOT NULL,
		GLTransactionDetailActiveRecordFlag		CHAR(1) NOT NULL
	);

	ALTER TABLE dim.GLTransactionDetail ADD CONSTRAINT PK_GLTransactionDetail
	PRIMARY KEY CLUSTERED (GLTransactionDetailKey);



	SET IDENTITY_INSERT dim.GLTransactionDetail ON;

	INSERT INTO
		dim.GLTransactionDetail
	(
		GLTransactionDetailKey,
		Comment,
		GLTransactionPostDate,
		Reference,
		SequenceNumber	,
		GLTransactionDetailSourceSystem,
		GLTransactionDetailSourceID,
		GLTransactionDetailCheckSum,
		GLTransactionDetailStartEffectiveDate,
		GLTransactionDetailEndEffectiveDate,
		GLTransactionDetailActiveRecordFlag
	)
	VALUES
	(
		-1,																--	GLTransactionDetailKey
		'<Detail Missing>',												--	Comment
		'1900-01-01',													--	GLTransactionPostDate
		'<Missing>',													--	Reference
		-1,																--	SequenceNumber
		'Sentinel',														--	GLTransactionDetailSourceSystem
		-1,																--	GLTransactionDetailSourceID
		CHECKSUM('<Detail Missing>', '1900-01-01', '<Missing>', -1),	--	GLTransactionDetailCheckSum
		'2017-01-01',													--	GLTransactionDetailStartEffectiveDate
		'2099-12-31',													--	GLTransactionDetailEndEffectiveDate
		'Y'																--	GLTransactionDetailActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.GLTransactionDetail OFF;

END;
