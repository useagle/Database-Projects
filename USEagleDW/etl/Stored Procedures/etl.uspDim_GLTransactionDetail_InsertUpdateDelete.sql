USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_GLTransactionDetail_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_GLTransactionDetail_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_GLTransactionDetail_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		Comment								VARCHAR(40) NOT NULL,
		GLTransactionPostDate				DATE NOT NULL,
		Reference							CHAR(10) NOT NULL,
		SequenceNumber						INT NOT NULL,
		GLTransactionDetailSourceSystem		VARCHAR(25),
		GLTransactionDetailSourceID			VARCHAR(40),
		GLTransactionDetailHash				VARBINARY(64)
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspGLTransactionDetail_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		GLTransactionDetailEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		GLTransactionDetailActiveRecordFlag = 'N'
	FROM
		dim.GLTransactionDetail tar
			LEFT JOIN
		#Source src
			ON tar.GLTransactionDetailSourceSystem = src.GLTransactionDetailSourceSystem AND tar.GLTransactionDetailSourceID = src.GLTransactionDetailSourceID
	WHERE
		tar.GLTransactionDetailSourceSystem <> 'Sentinel'
		AND
		tar.GLTransactionDetailActiveRecordFlag = 'Y'
		AND
		(src.GLTransactionDetailSourceID IS NULL
			OR
			tar.GLTransactionDetailHash <> src.GLTransactionDetailHash);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.GLTransactionDetail
	(
		Comment,
		GLTransactionPostDate,
		Reference,
		SequenceNumber,
		GLTransactionDetailSourceSystem,
		GLTransactionDetailSourceID,
		GLTransactionDetailHash,
		GLTransactionDetailStartEffectiveDate,
		GLTransactionDetailEndEffectiveDate,
		GLTransactionDetailActiveRecordFlag
	)
	SELECT
		src.Comment,
		src.GLTransactionPostDate,
		src.Reference,
		src.SequenceNumber,
		src.GLTransactionDetailSourceSystem,
		src.GLTransactionDetailSourceID,
		src.GLTransactionDetailHash,
		GLTransactionDetailStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		GLTransactionDetailEndEffectiveDate = '2099-12-31',
		GLTransactionDetailActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.GLTransactionDetail tar
			ON src.GLTransactionDetailSourceSystem = tar.GLTransactionDetailSourceSystem AND src.GLTransactionDetailSourceID = tar.GLTransactionDetailSourceID AND tar.GLTransactionDetailActiveRecordFlag = 'Y'
	WHERE
		tar.GLTransactionDetailKey IS NULL
	ORDER BY
		src.GLTransactionDetailSourceID;



	DROP TABLE #Source;

END;
