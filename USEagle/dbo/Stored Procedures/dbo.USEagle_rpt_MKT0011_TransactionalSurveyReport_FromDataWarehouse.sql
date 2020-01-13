USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_MKT0011_TransactionalSurveyReport')
	DROP PROCEDURE dbo.USEagle_rpt_MKT0011_TransactionalSurveyReport;
GO


CREATE PROCEDURE dbo.USEagle_rpt_MKT0011_TransactionalSurveyReport
(
	@ReportDate			DATE
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
		@CurrentProcessDate		INT,
		@ReportProcessDate		INT;

	SELECT
		@CurrentProcessDate = CAST(CONVERT(VARCHAR(8), MAX(ShareTransPostDate), 112) AS INT)
	FROM
		ARCUSYM000.arcu.vwARCUShareTransaction;

	SET @ReportProcessDate = CAST(CONVERT(VARCHAR(8), @ReportDate, 112) AS INT);



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
			ARCUSYM000.dbo.USERS Usr
		WHERE
			ProcessDate = @ReportProcessDate
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
			AccountNumber = Share.PARENTACCOUNT,
			ActionType = 'New Account',
			UserNumber = Share.CREATEDBYUSER,
			BranchNumber = Share.BRANCH
		FROM
			ARCUSYM000.dbo.SAVINGS Share
				INNER JOIN
			#UserList Usr
				ON Share.CREATEDBYUSER = Usr.UserNumber
		WHERE
			Share.ProcessDate = @CurrentProcessDate
			AND
			Share.OPENDATE = @ReportDate

		UNION ALL

		--	Share Transactions
		SELECT DISTINCT
			TransactionPriority = 3,
			AccountNumber = Txn.PARENTACCOUNT,
			ActionType = 'Transaction',
			UserNumber = Txn.USERNUMBER,
			BranchNumber = Txn.BRANCH
		FROM
			ARCUSYM000.dbo.SAVINGSTRANSACTION Txn
				INNER JOIN
			#UserList Usr
				ON Txn.USERNUMBER = Usr.UserNumber
		WHERE
			Txn.POSTDATE = @ReportDate
			AND
			(Txn.ACTIONCODE = 'W'
				OR
				(Txn.ACTIONCODE = 'D'
				AND
				Txn.TRANSFERCODE = 0))	--	Deposits and Withdrawals (Includes Transfers)

		UNION ALL

		--	New Loan Accounts
		SELECT DISTINCT
			TransactionPriority = 2,
			AccountNumber = Ln.PARENTACCOUNT,
			ActionType = 'New Loan',
			UserNumber = Ln.CREATEDBYUSER,
			BranchNumber = Ln.BRANCH
		FROM
			ARCUSYM000.dbo.LOAN Ln
				INNER JOIN
			#UserList Usr
				ON Ln.CREATEDBYUSER = Usr.UserNumber
		WHERE
			Ln.ProcessDate = @CurrentProcessDate
			AND
			Ln.OPENDATE = @ReportDate
			AND
			(Ln.CLOSEDATE IS NULL
				OR
				Ln.CLOSEDATE <> @ReportDate)

		UNION ALL

		--	Loan Payments
		SELECT DISTINCT
			TransactionPriority = 4,
			Txn.AccountNumber,
			ActionType = 'Loan Payment',
			UserNumber = Txn.LoanTransUserNumber,
			BranchNumber = Txn.LoanTransBranch
		FROM
			ARCUSYM000.arcu.vwARCULoanTransaction Txn
				INNER JOIN
			#UserList Usr
				ON Txn.LoanTransUserNumber = Usr.UserNumber
		WHERE
			Txn.LoanTransPostDate = @ReportDate
			AND
			Txn.LoanTransActionCode = 'P'
	),
	Transactions AS
	(
		SELECT
			TransactionPriorityOrder = ROW_NUMBER() OVER (PARTITION BY AccountNumber ORDER BY TransactionPriority),
			AccountNumber,
			ActionType,
			UserNumber,
			BranchNumber,
			RandomPercentage = ABS(CHECKSUM(NEWID())) % 100
		FROM
			AllTransactions
	),
	PrimaryMember AS
	(
		SELECT
			AccountNumber = Acct.ACCOUNTNUMBER,
			MemberFirstName = Mem.FIRST,
			MemberLastName = Mem.LAST,
			MemberStreetAddress = Mem.STREET,
			MemberCity = Mem.CITY,
			MemberState = Mem.STATE,
			MemberZip = MEM.ZIPCODE,
			MemberSSN = 'x' + RIGHT(RTRIM(Mem.SSN), 4),
			MemberEmail = Mem.EMAIL,
			MemberBirthDate = Mem.BIRTHDATE,
			MemberJoinDate = Acct.OPENDATE
		FROM
			ARCUSYM000.dbo.ACCOUNT Acct
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Acct.ACCOUNTNUMBER = Mem.PARENTACCOUNT AND Mem.ProcessDate = @CurrentProcessDate
		WHERE
			Acct.ProcessDate = @CurrentProcessDate
			AND
			Acct.TYPE NOT IN (2, 4, 5, 6, 8)
			AND
			Mem.TYPE = 0		--	Primary member only
			AND
			Mem.EMAIL IS NOT NULL
			AND
			Mem.EMAIL <> 'na@na.com'
	)
	SELECT
		Txn.AccountNumber,
		Txn.ActionType,
		ActionDate = @ReportDate,
		Mem.MemberFirstName,
		Mem.MemberLastName,
		Mem.MemberStreetAddress,
		Mem.MemberCity,
		Mem.MemberState,
		Mem.MemberZip,
		Mem.MemberSSN,
		Mem.MemberEmail,
		Mem.MemberBirthDate,
		Mem.MemberJoinDate,
		UserNumberAndName = CAST(Usr.NUMBER AS VARCHAR) + ' - ' + Usr.NAME,
		BranchNumber = Txn.BranchNumber
	FROM
		Transactions Txn
			INNER JOIN
		PrimaryMember Mem
			ON Txn.AccountNumber = Mem.AccountNumber
			LEFT JOIN
		ARCUSYM000.dbo.USERS Usr
			ON Txn.UserNumber = Usr.NUMBER AND Usr.ProcessDate = @CurrentProcessDate
	WHERE
		Txn.TransactionPriorityOrder = 1
		AND
		Txn.RandomPercentage < 10
	ORDER BY
		AccountNumber,
		ActionType;


	DROP TABLE #UserList;
	DROP TABLE #PrivilegeGroup;

END;
GO
