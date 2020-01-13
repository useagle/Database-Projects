USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_TransactionSurvey')
	DROP PROCEDURE dbo.USEagle_extract_TransactionSurvey;
GO


CREATE PROCEDURE dbo.USEagle_extract_TransactionSurvey
(
	@ReportDate			DATE = NULL
)

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <10/10/2017>    
-- Modify Date: 
-- Description:	<File maintenance for users that were manually modified.> 
-- ======================================================================

AS
BEGIN

	DECLARE
		@CutoffBirthDate	DATE,
		@ProcessDate		DATE,
		@ProcessDateInt		INT;


	IF @ReportDate IS NULL
		SET @ReportDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE));

	SET @ProcessDate = @ReportDate;
	SET @ProcessDateInt = CAST(CONVERT(VARCHAR(8), @ProcessDate, 112) AS INT);
	SET @CutoffBirthDate = DATEADD(yy, -18, @ProcessDate);



	IF EXISTS (SELECT 1 FROM tempdb.sys.objects WHERE name LIKE '%PrivilegeGroup%')
		DROP TABLE #PrivilegeGroup;


	CREATE TABLE
		#PrivilegeGroup
	(
		PrivilegeGroupName	VARCHAR(20)
	);


	INSERT INTO #PrivilegeGroup (PrivilegeGroupName) VALUES ('PRIVILEGEGROUP1');
	INSERT INTO #PrivilegeGroup (PrivilegeGroupName) VALUES ('PRIVILEGEGROUP2');
	INSERT INTO #PrivilegeGroup (PrivilegeGroupName) VALUES ('PRIVILEGEGROUP3');
	INSERT INTO #PrivilegeGroup (PrivilegeGroupName) VALUES ('PRIVILEGEGROUP4');
	INSERT INTO #PrivilegeGroup (PrivilegeGroupName) VALUES ('PRIVILEGEGROUP7');
	INSERT INTO #PrivilegeGroup (PrivilegeGroupName) VALUES ('PRIVILEGEGROUP27');
	INSERT INTO #PrivilegeGroup (PrivilegeGroupName) VALUES ('PRIVILEGEGROUP39');
	INSERT INTO #PrivilegeGroup (PrivilegeGroupName) VALUES ('PRIVILEGEGROUP40');



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
			Staging.arcusym000.dbo_USERS Usr
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
		Dt.UserNumber
	)
	SELECT DISTINCT
		NUMBER
	FROM
		UnpivotedData Dt
			INNER JOIN
		#PrivilegeGroup Grp
			ON Dt.PrivilegeGroup = Grp.PrivilegeGroupName
	WHERE
		Dt.NUMBER > 1000
		AND
		Dt.Flag = 1
	ORDER BY
		Dt.NUMBER;


	WITH AllTransactions AS
	(
		--	New Share Accounts
		SELECT DISTINCT
			TransactionPriority = 1,
			TransactionID = 'S' + CAST(Share.ShareSourceID AS VARCHAR),
			MemberKey = Share.MemberKey,
			TransactionType = 'New Account',
			UserNumber = Usr.UserNumber
		FROM
			USEagleDW.fact.CurrentShare Share
				INNER JOIN
			USEagleDW.dim.[User] Usr
				ON Share.OriginatedByUserKey = Usr.UserKey
				INNER JOIN
			#UserList List
				ON Usr.UserSourceID = List.UserNumber
		WHERE
			Share.ShareOpenDateKey = @ProcessDateInt

		UNION ALL

		--	Share Transactions
		SELECT DISTINCT
			TransactionPriority = 3,
			TransactionID = 'T' + CAST(Txn.TransactionKey AS VARCHAR),
			MemberKey = Txn.MemberKey,
			TransactionType = 'Transaction',
			UserNumber = Usr.UserNumber
		FROM
			USEAgleDW.fact.[Transaction] Txn
				INNER JOIN
			USEagleDW.dim.TransactionType Typ
				ON Txn.TransactionTypeKey = Typ.TransactionTypeKey
				INNER JOIN
			USEagleDW.dim.[User] Usr
				ON Txn.UserKey = Usr.UserKey
				INNER JOIN
			#UserList List
				ON Usr.UserSourceID = List.UserNumber
		WHERE
			Txn.TransactionDateKey = @ProcessDateInt
			AND
			(Typ.TransactionActionCode = 'W'
				OR
				(Typ.TransactionActionCode = 'D'))
				--AND
				--Txn.TRANSFERCODE = 0))	--	Deposits and Withdrawals (Includes Transfers)

		UNION ALL

		--	New Loan Accounts
		SELECT DISTINCT
			TransactionPriority = 2,
			TransactionID = CAST(Ln.LoanSourceID AS VARCHAR),		--	Already includes 'L'
			MemberKey = Ln.MemberKey,
			TransactionType = 'New Loan',
			UserNumber = Usr.UserNumber
		FROM
			USEagleDW.fact.CurrentLoan Ln
				INNER JOIN
			USEagleDW.dim.[User] Usr
				ON Ln.OriginatedByUserKey = Usr.UserKey
				INNER JOIN
			#UserList List
				ON Usr.UserSourceID = List.UserNumber
		WHERE
			Ln.LoanOpenDateKey = @ProcessDateInt
			AND
			Ln.LoanCloseDateKey = -2

		UNION ALL

		--	Loan Payments
		SELECT DISTINCT
			TransactionPriority = 4,
			TransactionID = 'T' + CAST(Txn.TransactionKey AS VARCHAR),
			MemberKey = Txn.MemberKey,
			TransactionType = 'Transaction',
			UserNumber = Usr.UserNumber
		FROM
			USEAgleDW.fact.[Transaction] Txn
				INNER JOIN
			USEagleDW.dim.TransactionType Typ
				ON Txn.TransactionTypeKey = Typ.TransactionTypeKey
				INNER JOIN
			USEagleDW.dim.[User] Usr
				ON Txn.UserKey = Usr.UserKey
				INNER JOIN
			#UserList List
				ON Usr.UserSourceID = List.UserNumber
		WHERE
			Txn.TransactionDateKey = @ProcessDateInt
			AND
			Typ.TransactionActionCode = 'P'
	),
	Transactions AS
	(
		SELECT
			TransactionPriorityOrder = ROW_NUMBER() OVER (PARTITION BY MemberKey ORDER BY TransactionPriority),
			TransactionID,
			MemberKey,
			TransactionType,
			UserNumber,
			RandomPercentage = ABS(CHECKSUM(NEWID())) % 100
		FROM
			AllTransactions
	)
	INSERT INTO
		USEagleDW.extract.TransactionSurvey
	(
		TransactionID,
		TransactionType,
		PrimaryMemberFirstName,
		ExtractDate,
		TransactionDate,
		Mem.MemberEmail
	)
	SELECT
		Txn.TransactionID,
		Txn.TransactionType,
		Mem.PrimaryMemberFirstName,
		ExtractDate = CAST(SYSDATETIME() AS DATE),
		TransactionDate = @ProcessDate,
		Mem.MemberEmail
	FROM
		Transactions Txn
			INNER JOIN
		USEagleDW.dim.Member Mem
			ON Txn.MemberKey = Mem.MemberKey
	WHERE
		Mem.MemberTypeNumber NOT IN (2, 4, 5, 6, 8)
		AND
		Mem.MemberEmail <> ''
		AND
		Mem.MemberEmail <> 'na@na.com'
		AND
		Mem.MemberBirthDate <= @CutoffBirthDate
		AND
		Txn.TransactionPriorityOrder = 1
		AND
		Txn.RandomPercentage < 30		--	FSR, Call-Centers, eAgents to be 100%
	ORDER BY
		Mem.PrimaryMemberLastName,
		Txn.TransactionID;


	DROP TABLE #UserList;
	DROP TABLE #PrivilegeGroup;

END;
GO
