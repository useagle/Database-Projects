USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_Branch_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_Branch_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_Branch_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		BranchNumber			SMALLINT,
		BranchName				VARCHAR(40),
		BranchNumberAndName		VARCHAR(50),
		BranchCategory			VARCHAR(20),
		BranchCategoryOrder		TINYINT,
		BranchHiddenFlag		CHAR(1),
		BranchSourceSystem		VARCHAR(25),
		BranchSourceID			SMALLINT,
		BranchHash				VARBINARY(64)
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspBranch_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		BranchEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		BranchActiveRecordFlag = 'N'
	FROM
		dim.Branch tar
			LEFT JOIN
		#Source src
			ON tar.BranchSourceSystem = src.BranchSourceSystem AND tar.BranchSourceID = src.BranchSourceID
	WHERE
		tar.BranchSourceSystem <> 'Sentinel'
		AND
		tar.BranchActiveRecordFlag = 'Y'
		AND
		(src.BranchNumber IS NULL
			OR
			tar.BranchHash <> src.BranchHash);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.Branch
	(
		BranchNumber,
		BranchName,
		BranchNumberAndName,
		BranchCategory,
		BranchCategoryOrder,
		BranchHiddenFlag,
		BranchSourceSystem,
		BranchSourceID,
		BranchHash,
		BranchStartEffectiveDate,
		BranchEndEffectiveDate,
		BranchActiveRecordFlag
	)
	SELECT
		src.BranchNumber,
		src.BranchName,
		src.BranchNumberAndName,
		src.BranchCategory,
		src.BranchCategoryOrder,
		src.BranchHiddenFlag,
		src.BranchSourceSystem,
		src.BranchSourceID,
		src.BranchHash,
		BranchStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		BranchEndEffectiveDate = '2099-12-31',
		BranchActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.Branch tar
			ON src.BranchSourceSystem = tar.BranchSourceSystem AND src.BranchSourceID = tar.BranchSourceID AND tar.BranchActiveRecordFlag = 'Y'
	WHERE
		tar.BranchKey IS NULL
	ORDER BY
		BranchCategoryOrder,
		BranchNumber;



	DROP TABLE #Source;

END;
