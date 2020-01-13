USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'Member')
BEGIN

	CREATE TABLE
		dim.Member
	(
		MemberKey					INT IDENTITY(1, 1),
		MemberCloseReason			VARCHAR(40) NOT NULL,
		MemberCloseReasonRaw		VARCHAR(40) NOT NULL,
		MemberCloseReasonText		VARCHAR(40) NOT NULL,
		MemberNumber				VARCHAR(10) NOT NULL,
		MemberPrimaryName			VARCHAR(75) NOT NULL,
		MemberStatus				VARCHAR(6) NOT NULL,
		MemberTypeNumber			SMALLINT NOT NULL,
		MemberTypeName				VARCHAR(50) NOT NULL,
		MemberTypeNumberAndName		VARCHAR(55) NOT NULL,
		MemberTypeCategory1			VARCHAR(25) NOT NULL,
		MemberTypeCategory2			VARCHAR(25) NOT NULL,
		MemberTypeCategory3			VARCHAR(25) NOT NULL,
		MemberSourceSystem			VARCHAR(25) NOT NULL,
		MemberSourceID				VARCHAR(10) NOT NULL,
		MemberHash					VARBINARY(64) NOT NULL,
		MemberStartEffectiveDate	DATE NOT NULL,
		MemberEndEffectiveDate		DATE NOT NULL,
		MemberActiveRecordFlag		CHAR(1) NOT NULL
	);

	ALTER TABLE dim.Member ADD CONSTRAINT PK_Member
	PRIMARY KEY CLUSTERED (MemberKey);



	SET IDENTITY_INSERT dim.Member ON;

	INSERT INTO
		dim.Member
	(
		MemberKey,
		MemberCloseReason,
		MemberCloseReasonRaw,
		MemberCloseReasonText,
		MemberNumber,
		MemberPrimaryName,
		MemberStatus,
		MemberTypeNumber,
		MemberTypeName,
		MemberTypeNumberAndName,
		MemberTypeCategory1,
		MemberTypeCategory2,
		MemberTypeCategory3,
		MemberSourceSystem,
		MemberSourceID,
		MemberHash,
		MemberStartEffectiveDate,
		MemberEndEffectiveDate,
		MemberActiveRecordFlag
	)
	VALUES
	(
		-1,																		--	MemberKey
		'N/A',																	--	MemberCloseReason
		'N/A',																	--	MemberCloseReasonRaw
		'N/A',																	--	MemberCloseReasonText
		-1,																		--	MemberNumber
		'<Member Descriptor Missing>',											--	MemberPrimaryName
		'N/A',																	--	MemberStatus
		-1,																		--	MemberTypeNumber
		'N/A',																	--	MemberTypeName
		'N/A',																	--	MemberTypeNameAndNumber
		'N/A',																	--	MemberTypeCategory1
		'N/A',																	--	MemberTypeCategory2
		'N/A',																	--	MemberTypeCategory3
		'Sentinel',																--	MemberSourceSystem
		-1,																		--	MemberSourceID
		HASHBYTES('SHA2_512', 'N/A' + 'N/A' + 'N/A' + '<Member Descriptor Missing>'
			+ 'N/A' + '-1' + 'N/A' + 'N/A' + 'N/A' + 'N/A>'),					--	MemberHash
		'2017-01-01',															--	MemberStartEffectiveDate
		'2099-12-31',															--	MemberEndEffectiveDate
		'Y'																		--	MemberActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.Member OFF;

END;
