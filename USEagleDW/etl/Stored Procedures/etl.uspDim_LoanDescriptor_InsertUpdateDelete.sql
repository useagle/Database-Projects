USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_LoanDescriptor_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_LoanDescriptor_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_LoanDescriptor_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		LoanAccountNumber				VARCHAR(25),
		LoanDescription					VARCHAR(30),
		LoanID							VARCHAR(10),
		LoanIsIndirectFlag				CHAR(1),
		LoanTerm						SMALLINT,
		LoanDescriptorSourceSystem		VARCHAR(25),
		LoanDescriptorSourceID			CHAR(15),
		LoanDescriptorHash				VARBINARY(64),
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspLoanDescriptor_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		LoanDescriptorEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		LoanDescriptorActiveRecordFlag = 'N'
	FROM
		dim.LoanDescriptor tar
			LEFT JOIN
		#Source src
			ON tar.LoanDescriptorSourceSystem = src.LoanDescriptorSourceSystem AND tar.LoanDescriptorSourceID = src.LoanDescriptorSourceID
	WHERE
		tar.LoanDescriptorSourceSystem <> 'Sentinel'
		AND
		tar.LoanDescriptorActiveRecordFlag = 'Y'
		AND
		(src.LoanAccountNumber IS NULL
			OR
			tar.LoanDescriptorHash <> src.LoanDescriptorHash);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.LoanDescriptor
	(
		LoanAccountNumber,
		LoanDescription,
		LoanID,
		LoanIsIndirectFlag,
		LoanTerm,
		LoanDescriptorSourceSystem,
		LoanDescriptorSourceID,
		LoanDescriptorHash,
		LoanDescriptorStartEffectiveDate,
		LoanDescriptorEndEffectiveDate,
		LoanDescriptorActiveRecordFlag
	)
	SELECT
		src.LoanAccountNumber,
		src.LoanDescription,
		src.LoanID,
		src.LoanIsIndirectFlag,
		src.LoanTerm,
		src.LoanDescriptorSourceSystem,
		src.LoanDescriptorSourceID,
		src.LoanDescriptorHash,
		LoanDescriptorStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		LoanDescriptorEndEffectiveDate = '2099-12-31',
		LoanDescriptorActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.LoanDescriptor tar
			ON src.LoanDescriptorSourceSystem = tar.LoanDescriptorSourceSystem AND src.LoanDescriptorSourceID = tar.LoanDescriptorSourceID AND tar.LoanDescriptorActiveRecordFlag = 'Y'
	WHERE
		tar.LoanDescriptorKey IS NULL
	ORDER BY
		LoanAccountNumber;



	DROP TABLE #Source;

END;
