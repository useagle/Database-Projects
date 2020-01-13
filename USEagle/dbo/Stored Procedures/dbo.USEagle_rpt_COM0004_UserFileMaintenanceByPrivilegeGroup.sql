USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_COM0004_UserFileMaintenanceByPrivilegeGroup')
	DROP PROCEDURE dbo.USEagle_rpt_COM0004_UserFileMaintenanceByPrivilegeGroup;
GO


CREATE PROCEDURE dbo.USEagle_rpt_COM0004_UserFileMaintenanceByPrivilegeGroup
(
	@StartDate			DATE,
	@EndDate			DATE,
	@PrivilegeGroup		SMALLINT
)

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <09/9/2017>    
-- Modify Date: 
-- Description:	<File maintenance for users that were manually modified.> 
-- ======================================================================

AS
BEGIN

	DECLARE
		@PrivilegeGroupName		VARCHAR(20),
		@ProcessDate			INT;


	SET @PrivilegeGroupName = 'PRIVILEGEGROUP' + CAST(@PrivilegeGroup AS VARCHAR);


	SELECT
		@ProcessDate = MAX(ProcessDate)
	FROM
		Staging.arcusym000.dbo_LOAN;


	IF EXISTS (SELECT 1 FROM tempdb.sys.objects WHERE name LIKE '%UserList%')
		DROP TABLE #UserList;


	CREATE TABLE
		#UserList
	(
		UserNumber	INT
	);


	WITH RawData AS
	(
		SELECT
			Usr.NUMBER,
			Usr.PRIVILEGEGROUP1,
			Usr.PRIVILEGEGROUP2,
			Usr.PRIVILEGEGROUP3,
			Usr.PRIVILEGEGROUP4,
			Usr.PRIVILEGEGROUP5,
			Usr.PRIVILEGEGROUP6,
			Usr.PRIVILEGEGROUP7,
			Usr.PRIVILEGEGROUP8,
			Usr.PRIVILEGEGROUP9,
			Usr.PRIVILEGEGROUP10,
			Usr.PRIVILEGEGROUP11,
			Usr.PRIVILEGEGROUP12,
			Usr.PRIVILEGEGROUP13,
			Usr.PRIVILEGEGROUP14,
			Usr.PRIVILEGEGROUP15,
			Usr.PRIVILEGEGROUP16,
			Usr.PRIVILEGEGROUP17,
			Usr.PRIVILEGEGROUP18,
			Usr.PRIVILEGEGROUP19,
			Usr.PRIVILEGEGROUP20,
			Usr.PRIVILEGEGROUP21,
			Usr.PRIVILEGEGROUP22,
			Usr.PRIVILEGEGROUP23,
			Usr.PRIVILEGEGROUP24,
			Usr.PRIVILEGEGROUP25,
			Usr.PRIVILEGEGROUP26,
			Usr.PRIVILEGEGROUP27,
			Usr.PRIVILEGEGROUP28,
			Usr.PRIVILEGEGROUP29,
			Usr.PRIVILEGEGROUP30,
			Usr.PRIVILEGEGROUP31,
			Usr.PRIVILEGEGROUP32,
			Usr.PRIVILEGEGROUP33,
			Usr.PRIVILEGEGROUP34,
			Usr.PRIVILEGEGROUP35,
			Usr.PRIVILEGEGROUP36,
			Usr.PRIVILEGEGROUP37,
			Usr.PRIVILEGEGROUP38,
			Usr.PRIVILEGEGROUP39,
			Usr.PRIVILEGEGROUP40,
			Usr.PRIVILEGEGROUP41,
			Usr.PRIVILEGEGROUP42,
			Usr.PRIVILEGEGROUP43,
			Usr.PRIVILEGEGROUP44,
			Usr.PRIVILEGEGROUP45,
			Usr.PRIVILEGEGROUP46,
			Usr.PRIVILEGEGROUP47,
			Usr.PRIVILEGEGROUP48,
			Usr.PRIVILEGEGROUP49,
			Usr.PRIVILEGEGROUP50
		FROM
			ARCUSYM000.dbo.USERS Usr
		WHERE
			ProcessDate = @ProcessDate
	),
	UnpivotedData AS
	(
		SELECT
			NUMBER,
			PrivilegeGroup,
			Flag
		FROM
			RawData
				UNPIVOT
			(Flag FOR PrivilegeGroup IN
				(PRIVILEGEGROUP1,
				PRIVILEGEGROUP2,
				PRIVILEGEGROUP3,
				PRIVILEGEGROUP4,
				PRIVILEGEGROUP5,
				PRIVILEGEGROUP6,
				PRIVILEGEGROUP7,
				PRIVILEGEGROUP8,
				PRIVILEGEGROUP9,
				PRIVILEGEGROUP10,
				PRIVILEGEGROUP11,
				PRIVILEGEGROUP12,
				PRIVILEGEGROUP13,
				PRIVILEGEGROUP14,
				PRIVILEGEGROUP15,
				PRIVILEGEGROUP16,
				PRIVILEGEGROUP17,
				PRIVILEGEGROUP18,
				PRIVILEGEGROUP19,
				PRIVILEGEGROUP20,
				PRIVILEGEGROUP21,
				PRIVILEGEGROUP22,
				PRIVILEGEGROUP23,
				PRIVILEGEGROUP24,
				PRIVILEGEGROUP25,
				PRIVILEGEGROUP26,
				PRIVILEGEGROUP27,
				PRIVILEGEGROUP28,
				PRIVILEGEGROUP29,
				PRIVILEGEGROUP30,
				PRIVILEGEGROUP31,
				PRIVILEGEGROUP32,
				PRIVILEGEGROUP33,
				PRIVILEGEGROUP34,
				PRIVILEGEGROUP35,
				PRIVILEGEGROUP36,
				PRIVILEGEGROUP37,
				PRIVILEGEGROUP38,
				PRIVILEGEGROUP39,
				PRIVILEGEGROUP40,
				PRIVILEGEGROUP41,
				PRIVILEGEGROUP42,
				PRIVILEGEGROUP43,
				PRIVILEGEGROUP44,
				PRIVILEGEGROUP45,
				PRIVILEGEGROUP46,
				PRIVILEGEGROUP47,
				PRIVILEGEGROUP48,
				PRIVILEGEGROUP49,
				PRIVILEGEGROUP50)) as unpvt
	)
	INSERT INTO
		#UserList
	(
		UserNumber
	)
	SELECT DISTINCT
		NUMBER
	FROM
		UnpivotedData
	WHERE
		PrivilegeGroup = @PrivilegeGroupName
		AND
		Flag = 1
	ORDER BY
		NUMBER;


	SELECT
		FileType = 'User',
		UserNumber = UserFM.UserFMUserNumber,
		CardLoanShareID = UserFM.UserFMID,
		PostDate = UserFM.UserFMPostDate,
		UserNumberAndName = CAST(UserFM.UserFMUserNumber AS VARCHAR) + ' - ' + Cat.UserName,
		FieldName = FM.[Field Name],
		BeforeValue =	CASE
							WHEN UserFM.UserFMNewCharacter IS NOT NULL OR  UserFM.UserFMOldCharacter IS NOT NULL THEN UserFM.UserFMOldCharacter
							WHEN CONVERT(VARCHAR(20), UserFM.UserFMNewDate, 101) IS NOT NULL OR CONVERT(VARCHAR(20), UserFM.UserFMOldDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), UserFM.UserFMOldDate, 101)
							WHEN CAST	(CASE
											WHEN UserFM.UserFMDataType = 2 THEN UserFM.UserFMNewNumber / 10
											ELSE UserFM.UserFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN UserFM.UserFMDataType = 2 THEN UserFM.UserFMOldNumber / 10
																					ELSE UserFM.UserFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN UserFM.UserFMDataType = 2 THEN UserFM.UserFMOldNumber / 10
																															ELSE UserFM.UserFMOldNumber
																														END AS VARCHAR(20))
						END,
		AfterValue =	CASE
							WHEN UserFM.UserFMNewCharacter IS NOT NULL THEN UserFM.UserFMNewCharacter
							WHEN CONVERT(VARCHAR(20), UserFM.UserFMNewDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), UserFM.UserFMNewDate, 101)
							WHEN CAST(	CASE
											WHEN UserFM.UserFMDataType = 2 THEN UserFM.UserFMNewNumber / 10
											ELSE UserFM.UserFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN UserFM.UserFMDataType = 2 THEN UserFM.UserFMOldNumber  /10
																					ELSE UserFM.UserFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN UserFM.UserFMDataType = 2 THEN UserFM.UserFMNewNumber/10
																															ELSE UserFM.UserFMNewNumber
																														END AS VARCHAR(20))
						END
	FROM
		ARCUSYM000.arcu.vwARCUUserFMHistory UserFM
			INNER JOIN
		#UserList Usr
			ON UserFM.UserFMUserNumber = Usr.UserNumber
			LEFT JOIN
		ExternalMisc.dbo.FMFieldNumberNameLookup FM
			ON UserFM.UserFMRecordType = FM.FMHistoryRecordType AND UserFM.UserFMFieldNumber = FM.FMHistoryFieldNumber
					AND UserFM.UserFMSubFieldNumber=FM.FMHistorySubFieldNumber
			LEFT JOIN
		ARCUSYM000.arcu.vwARCUUserCategory Cat
			ON UserFM.UserFMUserNumber = Cat.UserNumber
	WHERE
		UserFM.UserFMUserNumber NOT BETWEEN 800 AND 999
		AND
		UserFM.UserFMUserNumber NOT BETWEEN 9500 AND 9999
		AND
		CAST(UserFM.UserFMPostDate AS DATE) BETWEEN @StartDate AND @EndDate
	ORDER BY
		FileType,
		UserNumber,
		CardLoanShareID;


	DROP TABLE #UserList;

END;
GO


