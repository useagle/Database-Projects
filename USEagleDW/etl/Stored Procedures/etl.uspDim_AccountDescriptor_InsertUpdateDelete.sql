USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_AccountDescriptor_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_AccountDescriptor_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_AccountDescriptor_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		AccountCloseReason				VARCHAR(40) NOT NULL,
		AccountCloseReasonRaw			VARCHAR(40) NOT NULL,
		AccountCloseReasonText			VARCHAR(40) NOT NULL,
		AccountNumber					VARCHAR(10) NOT NULL,
		AccountPrimaryName				VARCHAR(75) NOT NULL,
		AccountStatus					VARCHAR(6) NOT NULL,
		AccountTypeNumber				SMALLINT NOT NULL,
		AccountTypeName					VARCHAR(50) NOT NULL,
		AccountTypeNumberAndName		VARCHAR(55) NOT NULL,
		AccountTypeCategory1			VARCHAR(25) NOT NULL,
		AccountTypeCategory2			VARCHAR(25) NOT NULL,
		AccountTypeCategory3			VARCHAR(25) NOT NULL,
		AccountDescriptorSourceSystem	VARCHAR(25) NOT NULL,
		AccountDescriptorSourceID		VARCHAR(10) NOT NULL,
		AccountDescriptorHash			VARBINARY(64) NOT NULL
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspAccountDescriptor_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		AccountDescriptorEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		AccountDescriptorActiveRecordFlag = 'N'
	FROM
		dim.AccountDescriptor tar
			LEFT JOIN
		#Source src
			ON tar.AccountDescriptorSourceSystem = src.AccountDescriptorSourceSystem AND tar.AccountDescriptorSourceID = src.AccountDescriptorSourceID
	WHERE
		tar.AccountDescriptorSourceSystem <> 'Sentinel'
		AND
		tar.AccountDescriptorActiveRecordFlag = 'Y'
		AND
		(src.AccountNumber IS NULL
			OR
			tar.AccountDescriptorHash <> src.AccountDescriptorHash);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.AccountDescriptor
	(
		AccountCloseReason,
		AccountCloseReasonRaw,
		AccountCloseReasonText,
		AccountNumber,
		AccountPrimaryName,
		AccountStatus,
		AccountTypeNumber,
		AccountTypeName,
		AccountTypeNumberAndName,
		AccountTypeCategory1,
		AccountTypeCategory2,
		AccountTypeCategory3,
		AccountDescriptorSourceSystem,
		AccountDescriptorSourceID,
		AccountDescriptorHash,
		AccountDescriptorStartEffectiveDate,
		AccountDescriptorEndEffectiveDate,
		AccountDescriptorActiveRecordFlag
	)
	SELECT
		src.AccountCloseReason,
		src.AccountCloseReasonRaw,
		src.AccountCloseReasonText,
		src.AccountNumber,
		src.AccountPrimaryName,
		src.AccountStatus,
		src.AccountTypeNumber,
		src.AccountTypeName,
		src.AccountTypeNumberAndName,
		src.AccountTypeCategory1,
		src.AccountTypeCategory2,
		src.AccountTypeCategory3,
		src.AccountDescriptorSourceSystem,
		src.AccountDescriptorSourceID,
		src.AccountDescriptorHash,
		AccountDescriptorStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		AccountDescriptorEndEffectiveDate = '2099-12-31',
		AccountDescriptorActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.AccountDescriptor tar
			ON src.AccountDescriptorSourceSystem = tar.AccountDescriptorSourceSystem AND src.AccountDescriptorSourceID = tar.AccountDescriptorSourceID AND tar.AccountDescriptorActiveRecordFlag = 'Y'
	WHERE
		tar.AccountDescriptorKey IS NULL
	ORDER BY
		AccountNumber;


	DROP TABLE #Source;

END;
