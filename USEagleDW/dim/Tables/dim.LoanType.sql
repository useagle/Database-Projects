USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'LoanType')
BEGIN

	CREATE TABLE
		dim.LoanType
	(
		LoanTypeKey						INT IDENTITY(1, 1),
		LoanTypeNumber					SMALLINT,
		LoanTypeName					VARCHAR(40),
		LoanTypeNumberAndName			VARCHAR(50),
		LoanTypeSourceSystem			VARCHAR(25),
		LoanTypeSourceID				SMALLINT,
		LoanTypeCheckSum				INT,
		LoanTypeStartEffectiveDate		DATE,
		LoanTypeEndEffectiveDate		DATE,
		LoanTypeActiveRecordFlag		CHAR(1)
	);

	ALTER TABLE dim.LoanType ADD CONSTRAINT PK_LoanType
	PRIMARY KEY CLUSTERED (LoanTypeKey);



	SET IDENTITY_INSERT dim.LoanType ON;

	INSERT INTO
		dim.LoanType
	(
		LoanTypeKey,
		LoanTypeNumber,
		LoanTypeName,
		LoanTypeNumberAndName,
		LoanTypeSourceSystem,
		LoanTypeSourceID,
		LoanTypeCheckSum,
		LoanTypeStartEffectiveDate,
		LoanTypeEndEffectiveDate,
		LoanTypeActiveRecordFlag
	)
	VALUES
	(
		-2,								--	LoanTypeKey
		-2,								--	LoanTypeNumber
		'<Not Applicable>',				--	LoanTypeName
		'<Not Applicable>',				--	LoanTypeNumberAndName
		'Sentinel',						--	LoanTypeSourceSystem
		-2,								--	LoanTypeSourceID
		CHECKSUM('<Not Applicable>'),	--	LoanTypeCheckSum
		'2017-01-01',					--	LoanTypeStartEffectiveDate
		'2099-12-31',					--	LoanTypeEndEffectiveDate
		'Y'								--	LoanTypeActiveRecordFlag
	);


	INSERT INTO
		dim.LoanType
	(
		LoanTypeKey,
		LoanTypeNumber,
		LoanTypeName,
		LoanTypeNumberAndName,
		LoanTypeSourceSystem,
		LoanTypeSourceID,
		LoanTypeCheckSum,
		LoanTypeStartEffectiveDate,
		LoanTypeEndEffectiveDate,
		LoanTypeActiveRecordFlag
	)
	VALUES
	(
		-1,									--	LoanTypeKey
		-1,									--	LoanTypeNumber
		'<Loan Type Missing>',				--	LoanTypeName
		'<Loan Type Missing>',				--	LoanTypeNumberAndName
		'Sentinel',							--	LoanTypeSourceSystem
		-1,									--	LoanTypeSourceID
		CHECKSUM('<Loan Type Missing>'),	--	LoanTypeCheckSum
		'2017-01-01',						--	LoanTypeStartEffectiveDate
		'2099-12-31',						--	LoanTypeEndEffectiveDate
		'Y'									--	LoanTypeActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.LoanType OFF;


	INSERT INTO
		dim.LoanType
	(
		LoanTypeNumber,
		LoanTypeName,
		LoanTypeNumberAndName,
		LoanTypeSourceSystem,
		LoanTypeSourceID,
		LoanTypeCheckSum,
		LoanTypeStartEffectiveDate,
		LoanTypeEndEffectiveDate,
		LoanTypeActiveRecordFlag
	)
	VALUES
	(
		9001,							--	LoanTypeNumber
		'VISA CREDIT CARDS',			--	LoanTypeName
		'9001 - VISA CREDIT CARDS',		--	LoanTypeNumberAndName
		'Vantiv',						--	LoanTypeSourceSystem
		9001,							--	LoanTypeSourceID
		CHECKSUM('VISA CREDIT CARDS'),	--	LoanTypeCheckSum
		'2017-01-01',					--	LoanTypeStartEffectiveDate
		'2099-12-31',					--	LoanTypeEndEffectiveDate
		'Y'								--	LoanTypeActiveRecordFlag
	);

END;
