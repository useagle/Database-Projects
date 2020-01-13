USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_TransactionDescriptor_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_TransactionDescriptor_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_TransactionDescriptor_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		TransactionConsoleNumber			SMALLINT NOT NULL,
		TransactionParentID					CHAR(4) NOT NULL,
		TransactionSequenceNumber			INT NOT NULL,
		TransactionDescriptorSourceSystem	VARCHAR(25) NOT NULL,
		TransactionDescriptorSourceID		VARCHAR(40) NOT NULL,
		TransactionDescriptorHash			VARBINARY(64) NOT NULL
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspTransactionDescriptor_GetData;


/*
	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		TransactionDescriptorEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		TransactionDescriptorActiveRecordFlag = 'N'
	FROM
		dim.TransactionDescriptor tar
			LEFT JOIN
		#Source src
			ON tar.TransactionDescriptorSourceSystem = src.TransactionDescriptorSourceSystem AND tar.TransactionDescriptorSourceID = src.TransactionDescriptorSourceID
	WHERE
		tar.TransactionDescriptorSourceSystem <> 'Sentinel'
		AND
		tar.TransactionDescriptorActiveRecordFlag = 'Y'
		AND
		(src.TransactionDescriptorSourceID IS NULL
			OR
			tar.TransactionDescriptorHash <> src.TransactionDescriptorHash);
*/


	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.TransactionDescriptor
	(
		TransactionConsoleNumber,
		TransactionParentID,
		TransactionSequenceNumber,
		TransactionDescriptorSourceSystem,
		TransactionDescriptorSourceID,
		TransactionDescriptorHash,
		TransactionDescriptorStartEffectiveDate,
		TransactionDescriptorEndEffectiveDate,
		TransactionDescriptorActiveRecordFlag
	)
	SELECT
		src.TransactionConsoleNumber,
		src.TransactionParentID,
		src.TransactionSequenceNumber,
		src.TransactionDescriptorSourceSystem,
		src.TransactionDescriptorSourceID,
		src.TransactionDescriptorHash,
		TransactionDescriptorStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		TransactionDescriptorEndEffectiveDate = '2099-12-31',
		TransactionDescriptorActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.TransactionDescriptor tar
			ON src.TransactionDescriptorSourceSystem = tar.TransactionDescriptorSourceSystem AND src.TransactionDescriptorSourceID = tar.TransactionDescriptorSourceID AND tar.TransactionDescriptorActiveRecordFlag = 'Y'
	WHERE
		tar.TransactionDescriptorKey IS NULL
	ORDER BY
		TransactionDescriptorSourceID;


	DROP TABLE #Source;

END;
