USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDim_Member_InsertUpdateDelete')
	DROP PROCEDURE etl.uspDim_Member_InsertUpdateDelete;
GO


CREATE PROCEDURE etl.uspDim_Member_InsertUpdateDelete
AS
BEGIN

	CREATE TABLE
		#Source
	(
		MemberBankruptcyFlag		CHAR(1) NOT NULL,
		MemberBirthDate				DATE NULL,
		MemberCity					VARCHAR(40) NOT NULL,
		MemberCloseReason			VARCHAR(40) NOT NULL,
		MemberCloseReasonRaw		VARCHAR(40) NOT NULL,
		MemberCloseReasonText		VARCHAR(40) NOT NULL,
		MemberDelinquencyFlag		CHAR(1) NOT NULL,
		MemberEmail					VARCHAR(40) NOT NULL,
		MemberJoinDate				DATE NULL,
		MemberMarketingOptOutFlag	CHAR(1) NOT NULL,
		MemberNoMailFlag			CHAR(1) NOT NULL,
		MemberNumber				VARCHAR(10) NOT NULL,
		MemberSSN					CHAR(5) NULL,
		MemberState					VARCHAR(10) NOT NULL,
		MemberStatus				VARCHAR(6) NOT NULL,
		MemberStreetAddress			VARCHAR(40) NOT NULL,
		MemberTypeNumber			SMALLINT NOT NULL,
		MemberTypeName				VARCHAR(50) NOT NULL,
		MemberTypeNumberAndName		VARCHAR(55) NOT NULL,
		MemberTypeCategory1			VARCHAR(25) NOT NULL,
		MemberTypeCategory2			VARCHAR(25) NOT NULL,
		MemberTypeCategory3			VARCHAR(25) NOT NULL,
		MemberZipCode				VARCHAR(10) NOT NULL,
		PrimaryMemberFirstName		VARCHAR(20) NOT NULL,
		PrimaryMemberLastName		VARCHAR(40) NOT NULL,
		PrimaryMemberFullName		VARCHAR(75) NOT NULL,
		MemberSourceSystem			VARCHAR(25) NOT NULL,
		MemberSourceID				VARCHAR(10) NOT NULL,
		MemberHash					VARBINARY(64) NOT NULL
	);

	INSERT INTO	#Source
	EXEC Staging.etl.uspMember_GetData;



	--	End date all records that are no longer in the source system or that have changed
	UPDATE
		tar
	SET
		MemberEndEffectiveDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)),
		MemberActiveRecordFlag = 'N'
	FROM
		dim.Member tar
			LEFT JOIN
		#Source src
			ON tar.MemberSourceSystem = src.MemberSourceSystem AND tar.MemberSourceID = src.MemberSourceID
	WHERE
		tar.MemberSourceSystem <> 'Sentinel'
		AND
		tar.MemberActiveRecordFlag = 'Y'
		AND
		(src.MemberNumber IS NULL
			OR
			tar.MemberHash <> src.MemberHash);



	--	Insert records for new or updated records in the source system
	INSERT INTO
		dim.Member
	(
		MemberBankruptcyFlag,
		MemberBirthDate,
		MemberCity,
		MemberCloseReason,
		MemberCloseReasonRaw,
		MemberCloseReasonText,
		MemberDelinquencyFlag,
		MemberEmail,
		MemberJoinDate,
		MemberMarketingOptOutFlag,
		MemberNoMailFlag,
		MemberNumber,
		MemberSSN,
		MemberState,
		MemberStatus,
		MemberStreetAddress,
		MemberTypeNumber,
		MemberTypeName,
		MemberTypeNumberAndName,
		MemberTypeCategory1,
		MemberTypeCategory2,
		MemberTypeCategory3,
		MemberZipCode,
		PrimaryMemberFirstName,
		PrimaryMemberLastName,
		PrimaryMemberFullName,
		MemberSourceSystem,
		MemberSourceID,
		MemberHash,
		MemberStartEffectiveDate,
		MemberEndEffectiveDate,
		MemberActiveRecordFlag
	)
	SELECT
		src.MemberBankruptcyFlag,
		src.MemberBirthDate,
		src.MemberCity,
		src.MemberCloseReason,
		src.MemberCloseReasonRaw,
		src.MemberCloseReasonText,
		src.MemberDelinquencyFlag,
		src.MemberEmail,
		src.MemberJoinDate,
		src.MemberMarketingOptOutFlag,
		src.MemberNoMailFlag,
		src.MemberNumber,
		src.MemberSSN,
		src.MemberState,
		src.MemberStatus,
		src.MemberStreetAddress,
		src.MemberTypeNumber,
		src.MemberTypeName,
		src.MemberTypeNumberAndName,
		src.MemberTypeCategory1,
		src.MemberTypeCategory2,
		src.MemberTypeCategory3,
		src.MemberZipCode,
		src.PrimaryMemberFirstName,
		src.PrimaryMemberLastName,
		src.PrimaryMemberFullName,
		src.MemberSourceSystem,
		src.MemberSourceID,
		src.MemberHash,
		MemberStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		MemberEndEffectiveDate = '2099-12-31',
		MemberActiveRecordFlag = 'Y'
	FROM
		#Source src
			LEFT JOIN
		dim.Member tar
			ON src.MemberSourceSystem = tar.MemberSourceSystem AND src.MemberSourceID = tar.MemberSourceID AND tar.MemberActiveRecordFlag = 'Y'
	WHERE
		tar.MemberKey IS NULL
	ORDER BY
		MemberNumber;


	DROP TABLE #Source;

END;
