USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_TransactionType_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_TransactionType_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_TransactionType_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		TransactionAccountType			VARCHAR(10),
		TransactionActionCode			VARCHAR(3),
		TransactionActionName			VARCHAR(15),
		TransactionSourceCode			VARCHAR(3),
		TransactionSourceName			VARCHAR(30),
		TransactionTypeSourceSystem		VARCHAR(25),
		TransactionTypeSourceID			VARCHAR(15),
		TransactionTypeHash				VARBINARY(64),
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspTransactionType_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		TransactionTypeEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		TransactionTypeActiveRecordFlag = 'N'
	FROM
		dim.TransactionType tar
			LEFT JOIN
		#Source src
			ON tar.TransactionTypeSourceSystem = src.TransactionTypeSourceSystem AND tar.TransactionTypeSourceID = src.TransactionTypeSourceID
	WHERE
		tar.TransactionTypeSourceSystem <> 'Sentinel'
		AND
		tar.TransactionTypeActiveRecordFlag = 'Y'
		AND
		(src.TransactionAccountType IS NULL
			OR
			tar.TransactionTypeHash <> src.TransactionTypeHash);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.TransactionType
	(
		TransactionAccountType,
		TransactionActionCode,
		TransactionActionName,
		TransactionSourceCode,
		TransactionSourceName,
		TransactionTypeSourceSystem,
		TransactionTypeSourceID,
		TransactionTypeHash,
		TransactionTypeStartEffectiveDate,
		TransactionTypeEndEffectiveDate,
		TransactionTypeActiveRecordFlag
	)
	SELECT
		src.TransactionAccountType,
		src.TransactionActionCode,
		src.TransactionActionName,
		src.TransactionSourceCode,
		src.TransactionSourceName,
		src.TransactionTypeSourceSystem,
		src.TransactionTypeSourceID,
		src.TransactionTypeHash,
		TransactionTypeStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		TransactionTypeEndEffectiveDate = '2099-12-31',
		TransactionTypeActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.TransactionType tar
			ON src.TransactionTypeSourceSystem = tar.TransactionTypeSourceSystem AND src.TransactionTypeSourceID = tar.TransactionTypeSourceID AND tar.TransactionTypeActiveRecordFlag = 'Y'
	WHERE
		tar.TransactionTypeKey IS NULL
	ORDER BY
		TransactionTypeSourceID;



	DROP TABLE #Source;

END;
