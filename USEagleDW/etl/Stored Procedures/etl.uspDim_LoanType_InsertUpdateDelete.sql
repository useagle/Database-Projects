USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_LoanType_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_LoanType_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_LoanType_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		LoanTypeNumber				SMALLINT,
		LoanTypeName				VARCHAR(40),
		LoanTypeNumberAndName		VARCHAR(50),
		LoanTypeSourceSystem		VARCHAR(25),
		LoanTypeSourceID			SMALLINT,
		LoanTypeCheckSum			INT,
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspLoanType_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		LoanTypeEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		LoanTypeActiveRecordFlag = 'N'
	FROM
		dim.LoanType tar
			LEFT JOIN
		#Source src
			ON tar.LoanTypeSourceSystem = src.LoanTypeSourceSystem AND tar.LoanTypeSourceID = src.LoanTypeSourceID
	WHERE
		tar.LoanTypeSourceSystem NOT IN ('Sentinel', 'Vantiv')
		AND
		tar.LoanTypeActiveRecordFlag = 'Y'
		AND
		(src.LoanTypeNumber IS NULL
			OR
			tar.LoanTypeCheckSum <> src.LoanTypeCheckSum);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.LoanType
	(
		LoanTypeNumber,
		LoanTypeName,
		LoanTypeNumberAndName,
		LoanTypeSourceSystem,
		LoanTypeSourceID,
		LoanTypeCheckSum,
		LoanTypeStartEffectiveDate,
		LoanTypeEndEffectiveDate,
		LoanTypeActiveRecordFlag
	)
	SELECT
		src.LoanTypeNumber,
		src.LoanTypeName,
		src.LoanTypeNumberAndName,
		src.LoanTypeSourceSystem,
		src.LoanTypeSourceID,
		src.LoanTypeCheckSum,
		LoanTypeStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		LoanTypeEndEffectiveDate = '2099-12-31',
		LoanTypeActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.LoanType tar
			ON src.LoanTypeSourceSystem = tar.LoanTypeSourceSystem AND src.LoanTypeSourceID = tar.LoanTypeSourceID AND tar.LoanTypeActiveRecordFlag = 'Y'
	WHERE
		tar.LoanTypeKey IS NULL
	ORDER BY
		LoanTypeNumber;



	DROP TABLE #Source;

END;
