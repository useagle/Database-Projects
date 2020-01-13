USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_GLAccount_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_GLAccount_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_GLAccount_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		GLAccountFullNumber				CHAR(14),
		GLAccountNumber					CHAR(11),
		GLAccountDescription			VARCHAR(50),
		GLAccountCategory1				VARCHAR(50),
		GLAccountCategory2				VARCHAR(50),
		GLAccountCategory3				VARCHAR(50),
		GLAccountCategory3Order			TINYINT,
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
		GLAccountHash					VARBINARY(64)
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspGLAccount_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		GLAccountEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		GLAccountActiveRecordFlag = 'N'
	FROM
		dim.GLAccount tar
			LEFT JOIN
		#Source src
			ON tar.GLAccountSourceSystem = src.GLAccountSourceSystem AND tar.GLAccountSourceID = src.GLAccountSourceID
	WHERE
		tar.GLAccountSourceSystem <> 'Sentinel'
		AND
		tar.GLAccountActiveRecordFlag = 'Y'
		AND
		(src.GLAccountNumber IS NULL
			OR
			tar.GLAccountHash <> src.GLAccountHash);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.GLAccount
	(
		GLAccountFullNumber,
		GLAccountNumber,
		GLAccountDescription,
		GLAccountCategory1,
		GLAccountCategory2,
		GLAccountCategory3,
		GLAccountCategory3Order,
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
		GLAccountHash,
		GLAccountStartEffectiveDate,
		GLAccountEndEffectiveDate,
		GLAccountActiveRecordFlag
	)
	SELECT
		src.GLAccountFullNumber,
		src.GLAccountNumber,
		src.GLAccountDescription,
		src.GLAccountCategory1,
		src.GLAccountCategory2,
		src.GLAccountCategory3,
		src.GLAccountCategory3Order,
		src.GLAccountCategory4,
		src.GLAccountCategory5,
		src.GLAccountCategory6,
		src.GLAccountCategory7,
		src.GLAccountCategorySortOrder,
		src.GLAccountBranchNumber,
		src.GLAccountBranchName,
		src.GLAccountBranchNumberAndName,
		src.GLAccountBranchCategory,
		src.GLAccountBranchCategoryOrder,
		src.GLAccountName,
		src.GLAccountFlashReportCategory1,
		src.GLAccountFlashReportCategory2,
		src.GLAccountFlashReportCategory3,
		src.GLAccountFlashReportSortOrder,
		src.GLAccountSourceSystem,
		src.GLAccountSourceID,
		src.GLAccountHash,
		GLAccountStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		GLAccountEndEffectiveDate = '2099-12-31',
		GLAccountActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.GLAccount tar
			ON src.GLAccountSourceSystem = tar.GLAccountSourceSystem AND src.GLAccountSourceID = tar.GLAccountSourceID AND tar.GLAccountActiveRecordFlag = 'Y'
	WHERE
		tar.GLAccountKey IS NULL
	ORDER BY
		src.GLAccountNumber;



	DROP TABLE #Source;

END;
