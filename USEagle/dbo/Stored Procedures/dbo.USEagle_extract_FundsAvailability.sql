USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_FundsAvailability')
	DROP PROCEDURE dbo.USEagle_extract_FundsAvailability;
GO


CREATE PROCEDURE dbo.USEagle_extract_FundsAvailability

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <08/10/2018>    
-- Modify Date: <10/22/2018>	CJH
-- Description:	<extract of Business Loans>
-- ======================================================================

AS
BEGIN

	DECLARE
		@ProcessDate		DATE,
		@ProcessDateInt		INT,
		@30DaysAgoDate		DATE,
		@62DaysAgoDate		DATE,
		@90DaysAgoDate		DATE,
		@6MonthsAgoDate		DATE;


	SELECT
		@ProcessDate = MAX(POSTDATE)
		
	FROM
		ARCUSYM000.dbo.SAVINGSTRANSACTION;

	SET @ProcessDateInt = CAST(CONVERT(VARCHAR(8), @ProcessDate, 112) AS INT);


	SET @30DaysAgoDate = DATEADD(dd, -30, @ProcessDate);
	SET @62DaysAgoDate = DATEADD(dd, -60, @ProcessDate);
	SET @90DaysAgoDate = DATEADD(dd, -90, @ProcessDate);
	SET @6MonthsAgoDate = DATEADD(mm, -6, @ProcessDate);


	WITH PrimaryAccounts AS
	(
		SELECT
			AccountNumber = Acct.ACCOUNTNUMBER,
			Mem.SSN
		FROM
			ARCUSYM000.dbo.ACCOUNT Acct
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Acct.ACCOUNTNUMBER = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt AND Mem.TYPE = 0
		WHERE
			Acct.ProcessDate = @ProcessDateInt
			AND
			Acct.CLOSEDATE IS NULL
			AND
			Acct.TYPE NOT IN (8, 17, 99)
	),
	ACHCredits AS
	(
		SELECT
			Mem.SSN,
			ACHCount = COUNT(Mem.SSN)
		FROM
			ARCUSYM000.dbo.SAVINGSTRANSACTION Txn
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Txn.PARENTACCOUNT = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt
		WHERE
			Txn.POSTDATE >= @62DaysAgoDate
			AND
			Txn.ACTIONCODE = 'D'
			AND
			Txn.SOURCECODE = 'E'
			AND
			Txn.BALANCECHANGE >= 500
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	),
	BankruptcyOrDerogatoryWarning AS
	(
		SELECT DISTINCT
			Mem.SSN
		FROM
			USEagle.dbo.USEagle_ufn_ActiveAccountWarnings(@ProcessDateInt) Warn
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Warn.AccountNumber = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt
		WHERE
			Warn.AccountCloseDate IS NULL
			AND
			(Warn.WarningCode1 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode2 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode3 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode4 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode5 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode6 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode7 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode8 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode9 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode10 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode11 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode12 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode13 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode14 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode15 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode16 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode17 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode18 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode19 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900)
				OR
				Warn.WarningCode20 IN (1, 9, 12, 14, 16, 19, 22, 30, 31, 32, 33, 36, 37, 40, 44, 49, 54, 56, 90, 900))
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	),
	LatestShareActivity AS
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
	LoanPastDueWarning AS
	(
		SELECT DISTINCT
			Mem.SSN
		FROM
			USEagle.dbo.USEagle_ufn_ActiveAccountWarnings(@ProcessDateInt) Warn
				INNER JOIN
			ARCUSYM000.dbo.NAME Mem
				ON Warn.AccountNumber = Mem.PARENTACCOUNT AND Mem.ProcessDate = @ProcessDateInt
		WHERE
			Warn.AccountCloseDate IS NULL
			AND
			(Warn.WarningCode1 = 2
				OR
				Warn.WarningCode2 = 2
				OR
				Warn.WarningCode3 = 2
				OR
				Warn.WarningCode4 = 2
				OR
				Warn.WarningCode5 = 2
				OR
				Warn.WarningCode6 = 2
				OR
				Warn.WarningCode7 = 2
				OR
				Warn.WarningCode8 = 2
				OR
				Warn.WarningCode9 = 2
				OR
				Warn.WarningCode10 = 2
				OR
				Warn.WarningCode11 = 2
				OR
				Warn.WarningCode12 = 2
				OR
				Warn.WarningCode13 = 2
				OR
				Warn.WarningCode14 = 2
				OR
				Warn.WarningCode15 = 2
				OR
				Warn.WarningCode16 = 2
				OR
				Warn.WarningCode17 = 2
				OR
				Warn.WarningCode18 = 2
				OR
				Warn.WarningCode19 = 2
				OR
				Warn.WarningCode20 = 2)
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
			Acct.TYPE NOT IN (8, 17, 99)
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	),
	OpportunityChecking AS
	(
		SELECT
			Mem.SSN,
			OpportunityCheckingOpenDate = MIN(Share.OPENDATE)
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
			Share.TYPE = 8		--	Opportunity Checking
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	),
	ShareBalance AS
	(
		SELECT
			Mem.SSN,
			ShareBalance = CAST(SUM(Share.BALANCE) AS DECIMAL(18, 2))
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
			Share.IRSCODE = 0	--	Right of offset account
			AND
			Mem.TYPE IN (0, 1)
			AND
			Mem.EXPIRATIONDATE IS NULL
		GROUP BY
			Mem.SSN
	)
	SELECT
		Acct.AccountNumber,
		MemberMoreThan90Days =	CASE
									WHEN MemDt.MembershipDate <= @90DaysAgoDate THEN 1
									ELSE 0
								END,
		Member30To90Days =	CASE
								WHEN MemDt.MembershipDate <= @30DaysAgoDate AND MemDt.MembershipDate > @90DaysAgoDate THEN 1
								ELSE 0
							END,
		NewMember =	CASE
						WHEN MemDt.MembershipDate > @30DaysAgoDate THEN 1
						ELSE 0
					END,
		BankruptcyOrDerogatoryWarning =	CASE
											WHEN Warn.SSN IS NOT NULL THEN 1
											ELSE 0
										END,
		PastDueLoanWarning =	CASE
									WHEN PastDue.SSN IS NOT NULL THEN 1
									ELSE 0
								END,
		RecentShareActivity =	CASE
									WHEN Actv.ActivityDate >= @30DaysAgoDate THEN 1
									ELSE 0
								END,
		OpportunityChecking =	CASE
									WHEN Opp.SSN IS NOT NULL THEN 1
									ELSE 0
								END,
		TwoACHCredits =	CASE
							WHEN ACH.ACHCount >= 2 THEN 1
							ELSE 0
						END,
		TotalOffsetBalance = ISNULL(Bal.ShareBalance, 0),
		FundsAvailabilityScore =	CASE
										WHEN Acct.SSN = '000000000'
											THEN 3
										WHEN MemDt.MembershipDate <= @90DaysAgoDate
											AND Warn.SSN IS NULL
											AND PastDue.SSN IS NULL
											AND Actv.ActivityDate >= @30DaysAgoDate
											AND Opp.SSN IS NULL
											AND ACH.ACHCount >= 2
											THEN 1
										WHEN MemDt.MembershipDate <= @30DaysAgoDate
											AND Warn.SSN IS NULL
											AND PastDue.SSN IS NULL
											AND Actv.ActivityDate >= @30DaysAgoDate
											AND (Opp.SSN IS NULL OR Opp.OpportunityCheckingOpenDate < @6MonthsAgoDate)
											THEN 2
										ELSE 3
									END
	FROM
		PrimaryAccounts Acct
			LEFT JOIN
		ACHCredits ACH
			ON Acct.SSN = ACH.SSN
			LEFT JOIN
		BankruptcyOrDerogatoryWarning Warn
			ON Acct.SSN = Warn.SSN
			LEFT JOIN
		LatestShareActivity Actv
			ON Acct.SSN = Actv.SSN
			LEFT JOIN
		LoanPastDueWarning PastDue
			ON Acct.SSN = PastDue.SSN
			LEFT JOIN
		MembershipDate MemDt
			ON Acct.SSN = MemDt.SSN
			LEFT JOIN
		OpportunityChecking Opp
			ON Acct.SSN = Opp.SSN
			LEFT JOIN
		ShareBalance Bal
			ON Acct.SSN = Bal.SSN
	ORDER BY
		AccountNumber;

END;
GO


