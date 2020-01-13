USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'AccountType')
BEGIN

	CREATE TABLE
		dim.AccountType
	(
		AccountTypeKey					INT IDENTITY(1, 1),
		AccountType						VARCHAR(5) NOT NULL,
		ProductNumber					SMALLINT NOT NULL,
		ProductName						VARCHAR(40) NOT NULL,
		ProductNumberAndName			VARCHAR(50) NOT NULL,
		ProductSortOrder				VARCHAR(10) NOT NULL,
		ProductCategory1				VARCHAR(5) NOT NULL,
		ProductCategory2				VARCHAR(50) NOT NULL,
		ProductCategory3				VARCHAR(50) NOT NULL,
		ProductCategory4				VARCHAR(50) NOT NULL,
		ProductCategory5				VARCHAR(50) NOT NULL,
		ParticipationPortionFlag		VARCHAR(3) NOT NULL,
		ParticipationPortionSortOrder	SMALLINT NOT NULL,
		AccountTypeSourceSystem			VARCHAR(25) NOT NULL,
		AccountTypeSourceID				VARCHAR(20) NOT NULL,
		AccountTypeHash					VARBINARY(64) NOT NULL,
		AccountTypeStartEffectiveDate	DATE NOT NULL,
		AccountTypeEndEffectiveDate		DATE NOT NULL,
		AccountTypeActiveRecordFlag		CHAR(1) NOT NULL
	);

	ALTER TABLE dim.AccountType ADD CONSTRAINT PK_AccountType
	PRIMARY KEY CLUSTERED (AccountTypeKey);



	SET IDENTITY_INSERT dim.AccountType ON;

	INSERT INTO
		dim.AccountType
	(
		AccountTypeKey,
		AccountType,
		ProductNumber,
		ProductName,
		ProductNumberAndName,
		ProductSortOrder,
		ProductCategory1,
		ProductCategory2,
		ProductCategory3,
		ProductCategory4,
		ProductCategory5,
		ParticipationPortionFlag,
		AccountTypeSourceSystem,
		AccountTypeSourceID,
		AccountTypeHash,
		AccountTypeStartEffectiveDate,
		AccountTypeEndEffectiveDate,
		AccountTypeActiveRecordFlag
	)
	VALUES
	(
		-2,																--	AccountTypeKey
		'Share',														--	AccountType
		-2,																--	ProductNumber
		'<Product Missing>',											--	ProductName
		'<Product Missing>',											--	ProductNumberAndName
		'X0000',														--	ProductSortOrder
		'Share',														--	ProductCategory1
		'<N/A>',														--	ProductCategory2
		'<N/A>',														--	ProductCategory3
		'<N/A>',														--	ProductCategory4
		'<N/A>',														--	ProductCategory5
		'N/A',															--	ParticipationPortionFlag
		'Sentinel',														--	AccountTypeSourceSystem
		'Share|-2|NA',													--	AccountTypeSourceID
		HASHBYTES('SHA2_512', 'Share' + '-2' + '<Product Missing>'
				+ 'X0000' + 'Share' + '<N/A>' + '<N/A>' + '<N/A>'
				+ '<N/A>' + 'N/A'),										--	AccountTypeHash
		'2017-01-01',													--	AccountTypeStartEffectiveDate
		'2099-12-31',													--	AccountTypeEndEffectiveDate
		'Y'																--	AccountTypeActiveRecordFlag
	);


	INSERT INTO
		dim.AccountType
	(
		AccountTypeKey,
		AccountType,
		ProductNumber,
		ProductName,
		ProductNumberAndName,
		ProductSortOrder,
		ProductCategory1,
		ProductCategory2,
		ProductCategory3,
		ProductCategory4,
		ProductCategory5,
		ParticipationPortionFlag,
		AccountTypeSourceSystem,
		AccountTypeSourceID,
		AccountTypeHash,
		AccountTypeStartEffectiveDate,
		AccountTypeEndEffectiveDate,
		AccountTypeActiveRecordFlag
	)
	VALUES
	(
		-1,																--	AccountTypeKey
		'Loan',															--	AccountType
		-1,																--	ProductNumber
		'<Product Missing>',											--	ProductName
		'<Product Missing>',											--	ProductNumberAndName
		'X0000',														--	ProductSortOrder
		'Loan',															--	ProductCategory1
		'<N/A>',														--	ProductCategory2
		'<N/A>',														--	ProductCategory3
		'<N/A>',														--	ProductCategory4
		'<N/A>',														--	ProductCategory5
		'N/A',															--	ParticipationPortionFlag
		'Sentinel',														--	AccountTypeSourceSystem
		'Loan|-1|NA'				,									--	AccountTypeSourceID
		HASHBYTES('SHA2_512', 'Loan' + '-1' + '<Product Missing>'
				+ 'X0000' + 'Loan' + '<N/A>' + '<N/A>' + '<N/A>'
				+ '<N/A>' + 'N/A'),										--	AccountTypeHash
		'2017-01-01',													--	AccountTypeStartEffectiveDate
		'2099-12-31',													--	AccountTypeEndEffectiveDate
		'Y'																--	AccountTypeActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.AccountType OFF;


	INSERT INTO
		dim.AccountType
	(
		AccountType,
		ProductNumber,
		ProductName,
		ProductNumberAndName,
		ProductSortOrder,
		ProductCategory1,
		ProductCategory2,
		ProductCategory3,
		ProductCategory4,
		ProductCategory5,
		ParticipationPortionFlag,
		ParticipationPortionFlagSortOrder,
		AccountTypeSourceSystem,
		AccountTypeSourceID,
		AccountTypeHash,
		AccountTypeStartEffectiveDate,
		AccountTypeEndEffectiveDate,
		AccountTypeActiveRecordFlag
	)
	VALUES
	(
		'Loan',															--	AccountType
		9001,															--	ProductNumber
		'VISA CREDIT CARDS - PLATINUM',									--	ProductName
		'9001 - VISA CREDIT CARDS - PLATINUM',							--	ProductNumberAndName
		'L9001',														--	ProductSortOrder
		'Loan',															--	ProductCategory1
		'<N/A>',														--	ProductCategory2
		'<N/A>',														--	ProductCategory3
		'<N/A>',														--	ProductCategory4
		'<N/A>',														--	ProductCategory5
		'N/A',															--	ParticipationPortionFlag
		1,																--	ParticipationPortionFlagSortOrder
		'Vantiv',														--	AccountTypeSourceSystem
		'Loan|9001|NA',													--	AccountTypeSourceID
		HASHBYTES('SHA2_512', 'Loan' + '||' + '9001' + '||'
				+ 'VISA CREDIT CARDS - PLATINUM' + '||' + 'L9001'
				+ '||' + 'Loan' + '||'+ '<N/A>' + '||' + '<N/A>'
				+ '||' + '<N/A>' + '||' + '<N/A>' + '||'+ 'N/A'),		--	AccountTypeHash
		'2017-01-01',													--	AccountTypeStartEffectiveDate
		'2099-12-31',													--	AccountTypeEndEffectiveDate
		'Y'																--	AccountTypeActiveRecordFlag
	);


	INSERT INTO
		dim.AccountType
	(
		AccountType,
		ProductNumber,
		ProductName,
		ProductNumberAndName,
		ProductSortOrder,
		ProductCategory1,
		ProductCategory2,
		ProductCategory3,
		ProductCategory4,
		ProductCategory5,
		ParticipationPortionFlag,
		ParticipationPortionFlagSortOrder,
		AccountTypeSourceSystem,
		AccountTypeSourceID,
		AccountTypeHash,
		AccountTypeStartEffectiveDate,
		AccountTypeEndEffectiveDate,
		AccountTypeActiveRecordFlag
	)
	VALUES
	(
		'Loan',															--	AccountType
		9002,															--	ProductNumber
		'VISA CREDIT CARDS - CREDIT BUILDER',							--	ProductName
		'9002 - VISA CREDIT CARDS - CREDIT BUILDER',					--	ProductNumberAndName
		'L9002',														--	ProductSortOrder
		'Loan',															--	ProductCategory1
		'<N/A>',														--	ProductCategory2
		'<N/A>',														--	ProductCategory3
		'<N/A>',														--	ProductCategory4
		'<N/A>',														--	ProductCategory5
		'N/A',															--	ParticipationPortionFlag
		1,																--	ParticipationPortionFlagSortOrder
		'Vantiv',														--	AccountTypeSourceSystem
		'Loan|9002|NA',													--	AccountTypeSourceID
		HASHBYTES('SHA2_512', 'Loan' + '||' + '9002' + '||'
				+ 'VISA CREDIT CARDS - CREDIT BUILDER' + '||'
				+ 'L9002' + '||' + 'Loan' + '||' + '<N/A>' + '||'
				+ '<N/A>' + '||' + '<N/A>' + '||' + '<N/A>' + '||'
				+ 'N/A'),												--	AccountTypeHash
		'2017-01-01',													--	AccountTypeStartEffectiveDate
		'2099-12-31',													--	AccountTypeEndEffectiveDate
		'Y'																--	AccountTypeActiveRecordFlag
	);


	INSERT INTO
		dim.AccountType
	(
		AccountType,
		ProductNumber,
		ProductName,
		ProductNumberAndName,
		ProductSortOrder,
		ProductCategory1,
		ProductCategory2,
		ProductCategory3,
		ProductCategory4,
		ProductCategory5,
		ParticipationPortionFlag,
		ParticipationPortionFlagSortOrder,
		AccountTypeSourceSystem,
		AccountTypeSourceID,
		AccountTypeHash,
		AccountTypeStartEffectiveDate,
		AccountTypeEndEffectiveDate,
		AccountTypeActiveRecordFlag
	)
	VALUES
	(
		'Loan',															--	AccountType
		9003,															--	ProductNumber
		'VISA CREDIT CARDS - BUSINESS',									--	ProductName
		'9003 - VISA CREDIT CARDS - BUSINESS',							--	ProductNumberAndName
		'L9003',														--	ProductSortOrder
		'Loan',															--	ProductCategory1
		'<N/A>',														--	ProductCategory2
		'<N/A>',														--	ProductCategory3
		'<N/A>',														--	ProductCategory4
		'<N/A>',														--	ProductCategory5
		'N/A',															--	ParticipationPortionFlag
		1,																--	ParticipationPortionFlagSortOrder
		'Vantiv',														--	AccountTypeSourceSystem
		'Loan|9003|NA',													--	AccountTypeSourceID
		HASHBYTES('SHA2_512', 'Loan' + '||' + '9003' + '||'
				+ 'VISA CREDIT CARDS - BUSINESS' + '||'+ 'L9003'
				+ '||' + 'Loan' + '||' + '<N/A>' + '||' + '<N/A>'
				+ '||' + '<N/A>' + '||' + '<N/A>' + '||' + 'N/A'),		--	AccountTypeHash
		'2017-01-01',													--	AccountTypeStartEffectiveDate
		'2099-12-31',													--	AccountTypeEndEffectiveDate
		'Y'																--	AccountTypeActiveRecordFlag
	);

END;
