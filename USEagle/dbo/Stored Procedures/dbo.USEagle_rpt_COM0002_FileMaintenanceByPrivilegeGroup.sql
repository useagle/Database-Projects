USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_COM0002_FileMaintenanceByPrivilegeGroup')
	DROP PROCEDURE dbo.USEagle_rpt_COM0002_FileMaintenanceByPrivilegeGroup;
GO


CREATE PROCEDURE dbo.USEagle_rpt_COM0002_FileMaintenanceByPrivilegeGroup
(
	@StartDate			DATE,
	@EndDate			DATE,
	@PrivilegeGroup		SMALLINT
)

-- =============================================
-- Author:		<Nilam Keval>
-- Create date: <09/01/2016>    
-- Modify Date: 12/16/2016 nkeval - exclude account #390711
--				02/27/2016 nkeval - re-wrote query to make more dynamic	
-- Description:	<File maintenance for loans that were manually modified.> 
-- =============================================

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
		FileType = 'Account',
		AccountNumber = Account.AccountFMAccountNumber,
		CardLoanShareID = Account.AccountFMID,
		PostDate = Account.AccountFMPostDate,
		UserNumberAndName = CAST(Account.AccountFMUserNumber AS VARCHAR) + ' - ' + Cat.UserName,
		FieldName = FM.[Field Name],
		BeforeValue =	CASE
							WHEN Account.AccountFMNewCharacter IS NOT NULL OR  Account.AccountFMOldCharacter IS NOT NULL THEN Account.AccountFMOldCharacter
							WHEN CONVERT(VARCHAR(20), Account.AccountFMNewDate, 101) IS NOT NULL OR CONVERT(VARCHAR(20), Account.AccountFMOldDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), Account.AccountFMOldDate, 101)
							WHEN CAST	(CASE
											WHEN Account.AccountFMDataType = 2 THEN Account.AccountFMNewNumber / 10
											ELSE Account.AccountFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN Account.AccountFMDataType = 2 THEN Account.AccountFMOldNumber / 10
																					ELSE Account.AccountFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN Account.AccountFMDataType = 2 THEN Account.AccountFMOldNumber / 10
																															ELSE Account.AccountFMOldNumber
																														END AS VARCHAR(20))
						END,
		AfterValue =	CASE
							WHEN Account.AccountFMNewCharacter IS NOT NULL THEN Account.AccountFMNewCharacter
							WHEN CONVERT(VARCHAR(20), Account.AccountFMNewDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), Account.AccountFMNewDate, 101)
							WHEN CAST(	CASE
											WHEN Account.AccountFMDataType = 2 THEN Account.AccountFMNewNumber / 10
											ELSE Account.AccountFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN Account.AccountFMDataType = 2 THEN Account.AccountFMOldNumber  /10
																					ELSE Account.AccountFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN Account.AccountFMDataType = 2 THEN Account.AccountFMNewNumber/10
																															ELSE Account.AccountFMNewNumber
																														END AS VARCHAR(20))
						END
	FROM
		ARCUSYM000.arcu.vwARCUAccountFMHistory Account
			INNER JOIN
		#UserList Usr
			ON Account.AccountFMUserNumber = Usr.UserNumber
			LEFT JOIN
		ExternalMisc.dbo.FMFieldNumberNameLookup FM
			ON Account.AccountFMRecordType = FM.FMHistoryRecordType AND Account.AccountFMFieldNumber = FM.FMHistoryFieldNumber
					AND Account.AccountFMSubFieldNumber=FM.FMHistorySubFieldNumber
			LEFT JOIN
		ARCUSYM000.arcu.vwARCUUserCategory Cat
			ON Account.AccountFMUserNumber = Cat.UserNumber
	WHERE
		Account.AccountFMUserNumber NOT BETWEEN 800 AND 999
		AND
		Account.AccountFMUserNumber NOT BETWEEN 9500 AND 9999
		AND
		CAST(Account.AccountFMPostDate AS DATE) BETWEEN @StartDate AND @EndDate

	UNION ALL

	SELECT
		FileType = 'Card',
		AccountNumber = Card.CardFMAccountNumber,
		CardLoanShareID =	CASE
								WHEN Card.CardFMID IS NULL THEN NULL
								ELSE 'x' + RIGHT(('xxxx' + Card.CardFMID), 4)
							END,
		PostDate = Card.CardFMPostDate,
		UserNumberAndName = CAST(Card.CardFMUserNumber AS VARCHAR) + ' - ' + Cat.UserName,
		FieldName = FM.[Field Name],
		BeforeValue =	CASE
							WHEN Card.CardFMNewCharacter IS NOT NULL OR  Card.CardFMOldCharacter IS NOT NULL THEN Card.CardFMOldCharacter
							WHEN CONVERT(VARCHAR(20), Card.CardFMNewDate, 101) IS NOT NULL OR CONVERT(VARCHAR(20), Card.CardFMOldDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), Card.CardFMOldDate, 101)
							WHEN CAST	(CASE
											WHEN Card.CardFMDataType = 2 THEN Card.CardFMNewNumber / 10
											ELSE Card.CardFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN Card.CardFMDataType = 2 THEN Card.CardFMOldNumber / 10
																					ELSE Card.CardFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN Card.CardFMDataType = 2 THEN Card.CardFMOldNumber / 10
																															ELSE Card.CardFMOldNumber
																														END AS VARCHAR(20))
						END,
		AfterValue =	CASE
							WHEN Card.CardFMNewCharacter IS NOT NULL THEN Card.CardFMNewCharacter
							WHEN CONVERT(VARCHAR(20), Card.CardFMNewDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), Card.CardFMNewDate, 101)
							WHEN CAST(	CASE
											WHEN Card.CardFMDataType = 2 THEN Card.CardFMNewNumber / 10
											ELSE Card.CardFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN Card.CardFMDataType = 2 THEN Card.CardFMOldNumber  /10
																					ELSE Card.CardFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN Card.CardFMDataType = 2 THEN Card.CardFMNewNumber/10
																															ELSE Card.CardFMNewNumber
																														END AS VARCHAR(20))
						END
	FROM
		ARCUSYM000.arcu.vwARCUCardFMHistory Card
			INNER JOIN
		#UserList Usr
			ON Card.CardFMUserNumber = Usr.UserNumber
			LEFT JOIN
		ExternalMisc.dbo.FMFieldNumberNameLookup FM
			ON Card.CardFMRecordType = FM.FMHistoryRecordType AND Card.CardFMFieldNumber = FM.FMHistoryFieldNumber
					AND Card.CardFMSubFieldNumber=FM.FMHistorySubFieldNumber
			LEFT JOIN
		ARCUSYM000.arcu.vwARCUUserCategory Cat
			ON Card.CardFMUserNumber = Cat.UserNumber
	WHERE
		Card.CardFMUserNumber NOT BETWEEN 800 AND 999
		AND
		Card.CardFMUserNumber NOT BETWEEN 9500 AND 9999
		AND
		CAST(Card.CardFMPostDate AS DATE) BETWEEN @StartDate AND @EndDate

	UNION ALL

	SELECT
		FileType = 'Loan',
		AccountNumber = Loan.LoanFMAccountNumber,
		CardLoanShareID = Loan.LoanFMID,
		PostDate = Loan.LoanFMPostDate,
		UserNumberAndName = CAST(Loan.LoanFMUserNumber AS VARCHAR) + ' - ' + Cat.UserName,
		FieldName = FM.[Field Name],
		BeforeValue =	CASE
							WHEN Loan.LoanFMNewCharacter IS NOT NULL OR  Loan.LoanFMOldCharacter IS NOT NULL THEN Loan.LoanFMOldCharacter
							WHEN CONVERT(VARCHAR(20), Loan.LoanFMNewDate, 101) IS NOT NULL OR CONVERT(VARCHAR(20), Loan.LoanFMOldDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), Loan.LoanFMOldDate, 101)
							WHEN CAST	(CASE
											WHEN Loan.LoanFMDataType = 2 THEN Loan.LoanFMNewNumber / 10
											ELSE Loan.LoanFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN Loan.LoanFMDataType = 2 THEN Loan.LoanFMOldNumber / 10
																					ELSE Loan.LoanFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN Loan.LoanFMDataType = 2 THEN Loan.LoanFMOldNumber / 10
																															ELSE Loan.LoanFMOldNumber
																														END AS VARCHAR(20))
						END,
		AfterValue =	CASE
							WHEN Loan.LoanFMNewCharacter IS NOT NULL THEN Loan.LoanFMNewCharacter
							WHEN CONVERT(VARCHAR(20), Loan.LoanFMNewDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), Loan.LoanFMNewDate, 101)
							WHEN CAST(	CASE
											WHEN Loan.LoanFMDataType = 2 THEN Loan.LoanFMNewNumber / 10
											ELSE Loan.LoanFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN Loan.LoanFMDataType = 2 THEN Loan.LoanFMOldNumber  /10
																					ELSE Loan.LoanFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN Loan.LoanFMDataType = 2 THEN Loan.LoanFMNewNumber/10
																															ELSE Loan.LoanFMNewNumber
																														END AS VARCHAR(20))
						END
	FROM
		ARCUSYM000.arcu.vwARCULoanFMHistory Loan
			INNER JOIN
		#UserList Usr
			ON Loan.LoanFMUserNumber = Usr.UserNumber
			LEFT JOIN
		ExternalMisc.dbo.FMFieldNumberNameLookup FM
			ON Loan.LoanFMRecordType = FM.FMHistoryRecordType AND Loan.LoanFMFieldNumber = FM.FMHistoryFieldNumber
					AND Loan.LoanFMSubFieldNumber=FM.FMHistorySubFieldNumber
			LEFT JOIN
		ARCUSYM000.arcu.vwARCUUserCategory Cat
			ON Loan.LoanFMUserNumber = Cat.UserNumber
	WHERE
		Loan.LoanFMUserNumber NOT BETWEEN 800 AND 999
		AND
		Loan.LoanFMUserNumber NOT BETWEEN 9500 AND 9999
		AND
		CAST(Loan.LoanFMPostDate AS DATE) BETWEEN @StartDate AND @EndDate

	UNION ALL

	SELECT
		FileType = 'Share',
		AccountNumber = Share.ShareFMAccountNumber,
		CardLoanShareID = Share.ShareFMID,
		PostDate = Share.ShareFMPostDate,
		UserNumberAndName = CAST(Share.ShareFMUserNumber AS VARCHAR) + ' - ' + Cat.UserName,
		FieldName = FM.[Field Name],
		BeforeValue =	CASE
							WHEN Share.ShareFMNewCharacter IS NOT NULL OR  Share.ShareFMOldCharacter IS NOT NULL THEN Share.ShareFMOldCharacter
							WHEN CONVERT(VARCHAR(20), Share.ShareFMNewDate, 101) IS NOT NULL OR CONVERT(VARCHAR(20), Share.ShareFMOldDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), Share.ShareFMOldDate, 101)
							WHEN CAST	(CASE
											WHEN Share.ShareFMDataType = 2 THEN Share.ShareFMNewNumber / 10
											ELSE Share.ShareFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN Share.ShareFMDataType = 2 THEN Share.ShareFMOldNumber / 10
																					ELSE Share.ShareFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN Share.ShareFMDataType = 2 THEN Share.ShareFMOldNumber / 10
																															ELSE Share.ShareFMOldNumber
																														END AS VARCHAR(20))
						END,
		AfterValue =	CASE
							WHEN Share.ShareFMNewCharacter IS NOT NULL THEN Share.ShareFMNewCharacter
							WHEN CONVERT(VARCHAR(20), Share.ShareFMNewDate, 101) IS NOT NULL THEN CONVERT(VARCHAR(20), Share.ShareFMNewDate, 101)
							WHEN CAST(	CASE
											WHEN Share.ShareFMDataType = 2 THEN Share.ShareFMNewNumber / 10
											ELSE Share.ShareFMNewNumber
										END AS VARCHAR(20)) <> '0.00' OR CAST(	CASE
																					WHEN Share.ShareFMDataType = 2 THEN Share.ShareFMOldNumber  /10
																					ELSE Share.ShareFMOldNumber
																				END AS VARCHAR(20)) <> '0.00' THEN CAST(CASE
																															WHEN Share.ShareFMDataType = 2 THEN Share.ShareFMNewNumber/10
																															ELSE Share.ShareFMNewNumber
																														END AS VARCHAR(20))
						END
	FROM
		ARCUSYM000.arcu.vwARCUShareFMHistory Share
			INNER JOIN
		#UserList Usr
			ON Share.ShareFMUserNumber = Usr.UserNumber
			LEFT JOIN
		ExternalMisc.dbo.FMFieldNumberNameLookup FM
			ON Share.ShareFMRecordType = FM.FMHistoryRecordType AND Share.ShareFMFieldNumber = FM.FMHistoryFieldNumber
					AND Share.ShareFMSubFieldNumber=FM.FMHistorySubFieldNumber
			LEFT JOIN
		ARCUSYM000.arcu.vwARCUUserCategory Cat
			ON Share.ShareFMUserNumber = Cat.UserNumber
	WHERE
		Share.ShareFMUserNumber NOT BETWEEN 800 AND 999
		AND
		Share.ShareFMUserNumber NOT BETWEEN 9500 AND 9999
		AND
		CAST(Share.ShareFMPostDate AS DATE) BETWEEN @StartDate AND @EndDate

	ORDER BY
		FileType,
		AccountNumber,
		CardLoanShareID;


	DROP TABLE #UserList;

END;
GO


