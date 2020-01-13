USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'Branch')
BEGIN

	CREATE TABLE
		dim.Branch
	(
		BranchKey					INT IDENTITY(1, 1),
		BranchNumber				SMALLINT,
		BranchName					VARCHAR(40),
		BranchNumberAndName			VARCHAR(50),
		BranchCategory				VARCHAR(20),
		BranchCategoryOrder			TINYINT,
		BranchHiddenFlag			CHAR(1),
		BranchSourceSystem			VARCHAR(25),
		BranchSourceID				SMALLINT,
		BranchCheckSum				INT,
		BranchStartEffectiveDate	DATE,
		BranchEndEffectiveDate		DATE,
		BranchActiveRecordFlag		CHAR(1)
	);

	ALTER TABLE dim.Branch ADD CONSTRAINT PK_Branch
	PRIMARY KEY CLUSTERED (BranchKey);



	SET IDENTITY_INSERT dim.Branch ON;

	INSERT INTO
		dim.Branch
	(
		BranchKey,
		BranchNumber,
		BranchName,
		BranchNumberAndName,
		BranchCategory,
		BranchCategoryOrder,
		BranchHiddenFlag,
		BranchSourceSystem,
		BranchSourceID,
		BranchCheckSum,
		BranchStartEffectiveDate,
		BranchEndEffectiveDate,
		BranchActiveRecordFlag
	)
	VALUES
	(
		-1,													--	BranchKey
		-1,													--	BranchNumber
		'<Branch Missing>',									--	BranchName
		'<Branch Missing>',									--	BranchNumberAndName
		'BRANCH MISSING',									--	BranchCategory
		99,													--	BranchCategoryOrder
		'N',												--	BranchHiddenFlag
		'Sentinel',											--	BranchSourceSystem
		-1,													--	BranchSourceID
		CHECKSUM('<Branch Missing>', 'BRANCH MISSING'),		--	BranchCheckSum
		'2017-01-01',										--	BranchStartEffectiveDate
		'2099-12-31',										--	BranchEndEffectiveDate
		'Y'													--	BranchActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.Branch OFF;

END;
