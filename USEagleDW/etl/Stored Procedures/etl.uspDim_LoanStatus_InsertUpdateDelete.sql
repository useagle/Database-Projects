USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_LoanStatus_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_LoanStatus_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_LoanStatus_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		LoanStatusNumber			SMALLINT,
		LoanStatusName				VARCHAR(40),
		LoanStatusNumberAndName		VARCHAR(50),
		LoanStatusSourceSystem		VARCHAR(25),
		LoanStatusSourceID			SMALLINT,
		LoanStatusCheckSum			INT,
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspLoanStatus_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		LoanStatusEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		LoanStatusActiveRecordFlag = 'N'
	FROM
		dim.LoanStatus tar
			LEFT JOIN
		#Source src
			ON tar.LoanStatusSourceSystem = src.LoanStatusSourceSystem AND tar.LoanStatusSourceID = src.LoanStatusSourceID
	WHERE
		tar.LoanStatusSourceSystem <> 'Sentinel'
		AND
		tar.LoanStatusActiveRecordFlag = 'Y'
		AND
		(src.LoanStatusNumber IS NULL
			OR
			tar.LoanStatusCheckSum <> src.LoanStatusCheckSum);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.LoanStatus
	(
		LoanStatusNumber,
		LoanStatusName,
		LoanStatusNumberAndName,
		LoanStatusSourceSystem,
		LoanStatusSourceID,
		LoanStatusCheckSum,
		LoanStatusStartEffectiveDate,
		LoanStatusEndEffectiveDate,
		LoanStatusActiveRecordFlag
	)
	SELECT
		src.LoanStatusNumber,
		src.LoanStatusName,
		src.LoanStatusNumberAndName,
		src.LoanStatusSourceSystem,
		src.LoanStatusSourceID,
		src.LoanStatusCheckSum,
		LoanStatusStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		LoanStatusEndEffectiveDate = '2099-12-31',
		LoanStatusActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.LoanStatus tar
			ON src.LoanStatusSourceSystem = tar.LoanStatusSourceSystem AND src.LoanStatusSourceID = tar.LoanStatusSourceID AND tar.LoanStatusActiveRecordFlag = 'Y'
	WHERE
		tar.LoanStatusKey IS NULL
	ORDER BY
		LoanStatusNumber;



	DROP TABLE #Source;

END;
