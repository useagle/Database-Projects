USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_COM0005_EmployeeNegativeAccountActivity')
	DROP PROCEDURE dbo.USEagle_rpt_COM0005_EmployeeNegativeAccountActivity;
GO


CREATE PROCEDURE dbo.USEagle_rpt_COM0005_EmployeeNegativeAccountActivity
(
	@ProcessDate		DATE
)
-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <10/12/2017>    
-- Modify Date: 
-- Description:	<File maintenance for users that were manually modified.> 
-- ======================================================================

AS
BEGIN

	DECLARE @ProcessDateInt	INT;

	SET @ProcessDateInt = CAST(CONVERT(VARCHAR(8), @ProcessDate, 112) AS INT);



	WITH MemberAccounts AS
	(
		SELECT
			*
		FROM
			ARCUSYM000.dbo.ACCOUNT Acct
		WHERE
			Acct.ProcessDate = @ProcessDateInt
			AND
			Acct.TYPE = 4
			AND
			Acct.CLOSEDATE IS NULL
	)
	SELECT
		IssueType = 'Past Due Loan',
		AccountNumber = Ln.PARENTACCOUNT,
		ShareID = NULL,
		ActivityPostDate = NULL,
		NewBalance = NULL,
		LoanID = Ln.ID,
		NumberOfDaysDelinquent = DATEDIFF(dd, Ln.DUEDATE, @ProcessDate)
	FROM
		ARCUSYM000.dbo.LOAN Ln
			INNER JOIN
		MemberAccounts Acct
			ON Ln.PARENTACCOUNT = Acct.ACCOUNTNUMBER
	WHERE
		Ln.ProcessDate = @ProcessDateInt
		AND
		DATEDIFF(dd, Ln.DUEDATE, @ProcessDate) > 30
		AND
		Ln.CLOSEDATE IS NULL
		AND
		Ln.CHARGEOFFDATE IS NULL
		AND
		Ln.BALANCE > 0

	UNION ALL

	SELECT
		IssueType = 'Courtesy Fee',
		AccountNumber = Txn.PARENTACCOUNT,
		ShareID = Txn.PARENTID,
		ActivityPostDate = Txn.POSTDATE,
		NewBalance = Txn.NEWBALANCE,
		LoanID = NULL,
		NumberOfDaysDelinquent = NULL
	FROM
		ARCUSYM000.dbo.SAVINGSTRANSACTION Txn
			INNER JOIN
		MemberAccounts Acct
			ON Txn.PARENTACCOUNT = Acct.ACCOUNTNUMBER
	WHERE
		Txn.POSTDATE = @ProcessDate
		AND
		Txn.SOURCECODE = 'F'
		AND
		Txn.DESCRIPTION = 'Courtesy Pay Fee'

	UNION ALL

	SELECT
		IssueType = 'NSF Fee',
		AccountNumber = Txn.PARENTACCOUNT,
		ShareID = Txn.PARENTID,
		ActivityPostDate = CAST(Txn.POSTDATE AS DATE),
		NewBalance = Txn.NEWBALANCE,
		LoanID = NULL,
		NumberOfDaysDelinquent = NULL
	FROM
		ARCUSYM000.dbo.SAVINGSTRANSACTION Txn
			INNER JOIN
		MemberAccounts Acct
			ON Txn.PARENTACCOUNT = Acct.ACCOUNTNUMBER
	WHERE
		Txn.POSTDATE = @ProcessDate
		AND
		Txn.SOURCECODE = 'F'
		AND
		Txn.DESCRIPTION LIKE '%NSF Fee%'

	ORDER BY
		AccountNumber,
		ActivityPostDate;

END;
GO


