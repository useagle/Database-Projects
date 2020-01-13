USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_User_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_User_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_User_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		UserNumber			SMALLINT,
		UserName			VARCHAR(20),
		UserNumberAndName	VARCHAR(30),
		UserSourceSystem	VARCHAR(25),
		UserSourceID		SMALLINT,
		UserCheckSum		INT,
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspUser_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		UserEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		UserActiveRecordFlag = 'N'
	FROM
		dim.[User] tar
			LEFT JOIN
		#Source src
			ON tar.UserSourceSystem = src.UserSourceSystem AND tar.UserSourceID = src.UserSourceID
	WHERE
		tar.UserSourceSystem <> 'Sentinel'
		AND
		tar.UserActiveRecordFlag = 'Y'
		AND
		(src.UserNumber IS NULL
			OR
			tar.UserCheckSum <> src.UserCheckSum);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.[User]
	(
		UserNumber,
		UserName,
		UserNumberAndName,
		UserSourceSystem,
		UserSourceID,
		UserCheckSum,
		UserStartEffectiveDate,
		UserEndEffectiveDate,
		UserActiveRecordFlag
	)
	SELECT
		src.UserNumber,
		src.UserName,
		src.UserNumberAndName,
		src.UserSourceSystem,
		src.UserSourceID,
		src.UserCheckSum,
		UserStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		UserEndEffectiveDate = '2099-12-31',
		UserActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.[User] tar
			ON src.UserSourceSystem = tar.UserSourceSystem AND src.UserSourceID = tar.UserSourceID AND tar.UserActiveRecordFlag = 'Y'
	WHERE
		tar.UserKey IS NULL
	ORDER BY
		UserNumber;



	DROP TABLE #Source;

END;
