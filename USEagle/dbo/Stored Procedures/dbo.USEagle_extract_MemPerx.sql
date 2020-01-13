USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_MemPerx')
	DROP PROCEDURE dbo.USEagle_extract_MemPerx;
GO


CREATE PROCEDURE dbo.USEagle_extract_MemPerx

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <10/11/2017>    
-- Modify Date: 
-- Description:	<File maintenance for users that were manually modified.> 
-- ======================================================================

AS
BEGIN

	DECLARE
		@ProcessDate		DATE,
		@ProcessDateInt		INT,
		@ActivityDate		DATE,
		@MembershipDate		DATE;


	SELECT
		@ProcessDate = MAX(POSTDATE)
	FROM
		ARCUSYM000.dbo.SAVINGSTRANSACTION;

	SET @ProcessDateInt = CAST(CONVERT(VARCHAR(8), @ProcessDate, 112) AS INT);

	SET @ActivityDate = DATEADD(dd, -30, @ProcessDate);

	SET @MembershipDate = DATEADD(yy, -3, @ProcessDate);



	WITH PrimaryAccounts AS
	(
		SELECT
			AccountNumber = Acct.ACCOUNTNUMBER,
			Mem.SSN
		FROM
			ARCUSYM000.dbo.ACCOUNT Acct
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Acct.ACCOUNTNUMBER = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt
		WHERE
			Acct.ProcessDate = @ProcessDateInt
			AND
			Acct.CLOSEDATE IS NULL
			AND
			Acct.TYPE NOT IN (8, 9, 10, 11, 12, 17, 99)
			AND
			Mem.TYPE = 0
	),
	HasMortgage AS
	(
		SELECT
			Mem.SSN
		FROM
			ARCUSYM000.dbo.TRACKING Track
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Track.PARENTACCOUNT = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt
		WHERE
			Track.ProcessDate = @ProcessDateInt
			AND
			Track.TYPE = 31
			AND
			Track.EXPIREDATE IS NULL
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	),
	LoanBalances AS
	(
		SELECT
			Mem.SSN,
			LoanBalance = SUM(Ln.BALANCE)
		FROM
			ARCUSYM000.dbo.LOAN Ln
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Ln.PARENTACCOUNT = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt
		WHERE
			Ln.ProcessDate = @ProcessDateInt
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	),
	LatestCheckingAccountActivity AS
	(
		SELECT
			Mem.SSN,
			ActivityDate = MAX(Share.ACTIVITYDATE)
		FROM
			ARCUSYM000.dbo.SAVINGS Share
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Share.PARENTACCOUNT = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt
		WHERE
			Share.ProcessDate = @ProcessDateInt
			AND
			Share.CLOSEDATE IS NULL
			AND
			Share.SHARECODE = 1
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	),
	MembershipDate AS
	(
		SELECT
			Mem.SSN,
			MembershipDate = MIN(Acct.OPENDATE)
		FROM
			ARCUSYM000.dbo.ACCOUNT Acct
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Acct.ACCOUNTNUMBER = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt
		WHERE
			Acct.ProcessDate = @ProcessDateInt
			AND
			Acct.CLOSEDATE IS NULL
			AND
			Acct.TYPE NOT IN (8, 9, 10, 11, 12, 17, 99)
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	),
	ShareBalances AS
	(
		SELECT
			Mem.SSN,
			ShareBalance = SUM(Share.BALANCE)
		FROM
			ARCUSYM000.dbo.SAVINGS Share
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Share.PARENTACCOUNT = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt
		WHERE
			Share.ProcessDate = @ProcessDateInt
			AND
			Share.CLOSEDATE IS NULL
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	)
	SELECT
		Acct.AccountNumber,
		LargeBalance =	CASE
							WHEN ISNULL(ShareBal.ShareBalance, 0) + ISNULL(LnBal.LoanBalance, 0) > 100000 THEN 1
							WHEN Mort.SSN IS NOT NULL THEN 1
							ELSE 0
						END,
		RecentCheckingActivity =	CASE
										WHEN Actv.ActivityDate >= @ActivityDate THEN 1
										ELSE 0
									END,
		LongtimeMember =	CASE
								WHEN MemDt.MembershipDate <= @MembershipDate THEN 1
								ELSE 0
							END,
		MemPerxScore = 	CASE
							WHEN ISNULL(ShareBal.ShareBalance, 0) + ISNULL(LnBal.LoanBalance, 0) > 100000 THEN 1
							WHEN Mort.SSN IS NOT NULL THEN 1
							ELSE 0
						END +
						CASE
							WHEN Actv.ActivityDate >= @ActivityDate THEN 1
							ELSE 0
						END +
						CASE
							WHEN MemDt.MembershipDate <= @MembershipDate THEN 1
							ELSE 0
						END
	FROM
		PrimaryAccounts Acct
			LEFT JOIN
		HasMortgage Mort
			ON Acct.SSN = Mort.SSN
			LEFT JOIN
		LoanBalances LnBal
			ON Acct.SSN = LnBal.SSN
			LEFT JOIN
		LatestCheckingAccountActivity Actv
			ON Acct.SSN = Actv.SSN
			LEFT JOIN
		MembershipDate MemDt
			ON Acct.SSN = MemDt.SSN
			LEFT JOIN
		ShareBalances ShareBal
			ON Acct.SSN = ShareBal.SSN
	ORDER BY
		AccountNumber;

END;
GO


