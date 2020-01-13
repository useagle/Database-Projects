USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_AccountType_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_AccountType_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_AccountType_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		AccountType								VARCHAR(5),
		ProductNumber							SMALLINT,
		ProductName								VARCHAR(40),
		ProductNumberAndName					VARCHAR(50),
		ProductSortOrder						VARCHAR(10),
		ProductCategory1						VARCHAR(5),
		ProductCategory2						VARCHAR(50),
		ProductCategory3						VARCHAR(50),
		ProductCategory4						VARCHAR(50),
		ProductCategory5						VARCHAR(50),
		MarketingProductCategoryName			VARCHAR(50),
		MarketingProductCategoryAbbreviation	VARCHAR(50),
		ParticipationPortionFlag				VARCHAR(3),
		ParticipationPortionFlagSortOrder		SMALLINT,
		AccountTypeSourceSystem					VARCHAR(25),
		AccountTypeSourceID						VARCHAR(20),
		AccountTypeHash							VARBINARY(64)
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspAccountType_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		AccountTypeEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		AccountTypeActiveRecordFlag = 'N'
	FROM
		dim.AccountType tar
			LEFT JOIN
		#Source src
			ON tar.AccountTypeSourceSystem = src.AccountTypeSourceSystem AND tar.AccountTypeSourceID = src.AccountTypeSourceID
	WHERE
		tar.AccountTypeSourceSystem NOT IN ('Sentinel', 'Vantiv')
		AND
		tar.AccountTypeActiveRecordFlag = 'Y'
		AND
		(src.ProductNumber IS NULL
			OR
			tar.AccountTypeHash <> src.AccountTypeHash);



	--	Insert records for new or updated records in the source system
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
	SELECT
		src.AccountType,
		src.ProductNumber,
		src.ProductName,
		src.ProductNumberAndName,
		src.ProductSortOrder,
		src.ProductCategory1,
		src.ProductCategory2,
		src.ProductCategory3,
		src.ProductCategory4,
		src.ProductCategory5,
		src.ParticipationPortionFlag,
		src.ParticipationPortionFlagSortOrder,
		src.AccountTypeSourceSystem,
		src.AccountTypeSourceID,
		src.AccountTypeHash,
		AccountTypeStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		AccountTypeEndEffectiveDate = '2099-12-31',
		AccountTypeActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.AccountType tar
			ON src.AccountTypeSourceSystem = tar.AccountTypeSourceSystem AND src.AccountTypeSourceID = tar.AccountTypeSourceID AND tar.AccountTypeActiveRecordFlag = 'Y'
	WHERE
		tar.AccountTypeKey IS NULL
	ORDER BY
		AccountType,
		ProductNumber;


	DROP TABLE #Source;

END;
