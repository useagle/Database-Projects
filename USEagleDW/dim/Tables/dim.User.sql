USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'User')
BEGIN

	CREATE TABLE
		dim.[User]
	(
		UserKey					INT IDENTITY(1, 1),
		UserNumber				SMALLINT,
		UserName				VARCHAR(20),
		UserNumberAndName		VARCHAR(30),
		UserSourceSystem		VARCHAR(25),
		UserSourceID			SMALLINT,
		UserCheckSum			INT,
		UserStartEffectiveDate	DATE,
		UserEndEffectiveDate	DATE,
		UserActiveRecordFlag	CHAR(1)
	);

	ALTER TABLE dim.[User] ADD CONSTRAINT PK_User
	PRIMARY KEY CLUSTERED (UserKey);



	SET IDENTITY_INSERT dim.[User] ON;

	INSERT INTO
		dim.[User]
	(
		UserKey,
		UserNumber,
		UserName,
		UserNumberAndName,
		UserSourceSystem,
		UserSourceID,
		UserCheckSum,
		UserStartEffectiveDate,
		UserEndEffectiveDate,
		UserActiveRecordFlag
	)
	VALUES
	(
		-1,								--	UserKey
		-1,								--	UserNumber
		'<User Missing>',				--	UserName
		'<User Missing>',				--	UserNumberAndName
		'Sentinel',						--	UserSourceSystem
		-1,								--	UserSourceID
		CHECKSUM('<User Missing>'),		--	UserCheckSum
		'2017-01-01',					--	UserStartEffectiveDate
		'2099-12-31',					--	UserEndEffectiveDate
		'Y'								--	UserActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.[User] OFF;

END;
