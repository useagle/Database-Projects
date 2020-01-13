USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'LoanStatus')
BEGIN

	CREATE TABLE
		dim.LoanStatus
	(
		LoanStatusKey					INT IDENTITY(1, 1),
		LoanStatusNumber				SMALLINT,
		LoanStatusName					VARCHAR(25),
		LoanStatusNumberAndName			VARCHAR(35),
		LoanStatusSourceSystem			VARCHAR(25),
		LoanStatusSourceID				SMALLINT,
		LoanStatusCheckSum				INT,
		LoanStatusStartEffectiveDate	DATE,
		LoanStatusEndEffectiveDate		DATE,
		LoanStatusActiveRecordFlag		CHAR(1)
	);

	ALTER TABLE dim.LoanStatus ADD CONSTRAINT PK_LoanStatus
	PRIMARY KEY CLUSTERED (LoanStatusKey);



	SET IDENTITY_INSERT dim.LoanStatus ON;

	INSERT INTO
		dim.LoanStatus
	(
		LoanStatusKey,
		LoanStatusNumber,
		LoanStatusName,
		LoanStatusNumberAndName,
		LoanStatusSourceSystem,
		LoanStatusSourceID,
		LoanStatusCheckSum,
		LoanStatusStartEffectiveDate,
		LoanStatusEndEffectiveDate,
		LoanStatusActiveRecordFlag
	)
	VALUES
	(
		-2,								--	LoanStatusKey
		-2,								--	LoanStatusNumber
		'<Not Applicable>',				--	LoanStatusName
		'<Not Applicable>',				--	LoanStatusNumberAndName
		'Sentinel',						--	LoanStatusSourceSystem
		-2,								--	LoanStatusSourceID
		CHECKSUM('<Not Applicable>'),	--	LoanStatusCheckSum
		'2017-01-01',					--	LoanStatusStartEffectiveDate
		'2099-12-31',					--	LoanStatusEndEffectiveDate
		'Y'								--	LoanStatusActiveRecordFlag
	);


	INSERT INTO
		dim.LoanStatus
	(
		LoanStatusKey,
		LoanStatusNumber,
		LoanStatusName,
		LoanStatusNumberAndName,
		LoanStatusSourceSystem,
		LoanStatusSourceID,
		LoanStatusCheckSum,
		LoanStatusStartEffectiveDate,
		LoanStatusEndEffectiveDate,
		LoanStatusActiveRecordFlag
	)
	VALUES
	(
		-1,									--	LoanStatusKey
		-1,									--	LoanStatusNumber
		'<Loan Status Missing>',			--	LoanStatusName
		'<Loan Status Missing>',			--	LoanStatusNumberAndName
		'Sentinel',							--	LoanStatusSourceSystem
		-1,									--	LoanStatusSourceID
		CHECKSUM('<Loan Status Missing>'),	--	LoanStatusCheckSum
		'2017-01-01',						--	LoanStatusStartEffectiveDate
		'2099-12-31',						--	LoanStatusEndEffectiveDate
		'Y'									--	LoanStatusActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.LoanStatus OFF;

END;
