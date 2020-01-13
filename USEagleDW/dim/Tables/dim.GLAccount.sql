USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND name = 'GLAccount')
BEGIN

	CREATE TABLE
		dim.GLAccount
	(
		GLAccountKey					INT IDENTITY(1, 1),
		GLAccountFullNumber				CHAR(14),
		GLAccountNumber					CHAR(11),
		GLAccountDescription			VARCHAR(50),
		GLAccountCategory1				VARCHAR(50),
		GLAccountCategory2				VARCHAR(50),
		GLAccountCategory3				VARCHAR(50),
		GLAccountCategory4				VARCHAR(50),
		GLAccountCategory5				VARCHAR(50),
		GLAccountCategory6				VARCHAR(50),
		GLAccountCategory7				VARCHAR(50),
		GLAccountCategorySortOrder		VARCHAR(50),
		GLAccountBranchNumber			SMALLINT,
		GLAccountBranchName				VARCHAR(40),
		GLAccountBranchNumberAndName	VARCHAR(50),
		GLAccountBranchCategory			VARCHAR(20),
		GLAccountBranchCategoryOrder	TINYINT,
		GLAccountName					VARCHAR(40),
		GLAccountFlashReportCategory1	VARCHAR(20),
		GLAccountFlashReportCategory2	VARCHAR(30),
		GLAccountFlashReportCategory3	VARCHAR(30),
		GLAccountFlashReportSortOrder	INT,
		GLAccountSourceSystem			VARCHAR(25),
		GLAccountSourceID				CHAR(14),
		GLAccountCheckSum				INT,
		GLAccountStartEffectiveDate		DATE,
		GLAccountEndEffectiveDate		DATE,
		GLAccountActiveRecordFlag		CHAR(1)
	);

	ALTER TABLE dim.GLAccount ADD CONSTRAINT PK_GLAccount
	PRIMARY KEY CLUSTERED (GLAccountKey);



	SET IDENTITY_INSERT dim.GLAccount ON;

	INSERT INTO
		dim.GLAccount
	(
		GLAccountKey,
		GLAccountFullNumber,
		GLAccountNumber,
		GLAccountDescription,
		GLAccountCategory1,
		GLAccountCategory2,
		GLAccountCategory3,
		GLAccountCategory4,
		GLAccountCategory5,
		GLAccountCategory6,
		GLAccountCategory7,
		GLAccountCategorySortOrder,
		GLAccountBranchNumber,
		GLAccountBranchName,
		GLAccountBranchNumberAndName,
		GLAccountBranchCategory,
		GLAccountBranchCategoryOrder,
		GLAccountName,
		GLAccountFlashReportCategory1,
		GLAccountFlashReportCategory2,
		GLAccountFlashReportCategory3,
		GLAccountFlashReportSortOrder,
		GLAccountSourceSystem,
		GLAccountSourceID,
		GLAccountCheckSum,
		GLAccountStartEffectiveDate,
		GLAccountEndEffectiveDate,
		GLAccountActiveRecordFlag
	)
	VALUES
	(
		-1,																			--	GLAccountKey
		'N/A',																		--	GLAccountFullNumber
		'N/A',																		--	GLAccountNumber
		'<GL Account Missing>',														--	GLAccountDescription
		'<GL Account Missing>',														--	GLAccountCategory1
		'<GL Account Missing>',														--	GLAccountCategory2
		'<GL Account Missing>',														--	GLAccountCategory3
		'<GL Account Missing>',														--	GLAccountCategory4
		'<GL Account Missing>',														--	GLAccountCategory5
		'<GL Account Missing>',														--	GLAccountCategory6
		'<GL Account Missing>',														--	GLAccountCategory7
		'<GL Account Missing>',														--	GLAccountCategorySortOrder
		-1,																			--	GLAccountBranchNumber
		'<GL Account Missing>',														--	GLAccountBranchName
		'<GL Account Missing>',														--	GLAccountBranchNumberAndName
		'GL ACCOUNT MISSING',														--	GLAccountBranchCategory
		99,																			--	GLAccountBranchCategoryOrder
		'<GL Account Missing>',														--	GLAccountName
		'N/A',																		--	GLAccountFlashReportCategory1,
		'N/A',																		--	GLAccountFlashReportCategory2,
		'N/A',																		--	GLAccountFlashReportCategory3,
		9999,																		--	GLAccountFlashReportSortOrder,
		'Sentinel',																	--	GLAccountSourceSystem
		'N/A',																		--	GLAccountSourceID
		CHECKSUM('N/A', '<GL Account Missing>', '<GL Account Missing>',
			'<GL Account Missing>', '<GL Account Missing>', '<GL Account Missing>',
			'<GL Account Missing>', '<GL Account Missing>', '<GL Account Missing>',
			'<GL Account Missing>', '<GL Account Missing>', 'GL ACCOUNT MISSING',
			99, '<GL Account Missing>', 'N/A', 'N/A', 'N/A', 9999),					--	GLAccountCheckSum
		'2017-01-01',																--	GLAccountStartEffectiveDate
		'2099-12-31',																--	GLAccountEndEffectiveDate
		'Y'																			--	GLAccountActiveRecordFlag
	);

	SET IDENTITY_INSERT dim.GLAccount OFF;

END;
