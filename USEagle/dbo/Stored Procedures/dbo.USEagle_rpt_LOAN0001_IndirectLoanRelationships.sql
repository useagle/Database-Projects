USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_LOAN0001_IndirectLoanRelationships')
	DROP PROCEDURE dbo.USEagle_rpt_LOAN0001_IndirectLoanRelationships;
GO


CREATE PROCEDURE dbo.USEagle_rpt_LOAN0001_IndirectLoanRelationships

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <04/04/2018>    
-- Modify Date: 
-- Description:	<File maintenance for loans that were manually modified.> 
-- =============================================

AS
BEGIN

	IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%MonthEndDates%')
		DROP TABLE #MonthEndDates;


	CREATE TABLE
		#MonthEndDates
	(
		ProcessDateInt		INT,

		CONSTRAINT PK_MonthEndDates PRIMARY KEY (ProcessDateInt)
	);


	INSERT INTO
		#MonthEndDates
	(
		ProcessDateInt
	)
	SELECT
		ProcessDateInt = Cal.CalendarKey
	FROM
		USEagleDW.dim.Calendar Cal
	WHERE
		Cal.MonthEndFlag = 'Y'
		AND
		DATEDIFF(m, Cal.CalendarDate, SYSDATETIME()) BETWEEN 1 AND 13;




	IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%ActiveShares%')
		DROP TABLE #ActiveShares;


	CREATE TABLE
		#ActiveShares
	(
		SSN						CHAR(9) NOT NULL,
		ProcessDateInt			INT NOT NULL,
		NumberOfActiveShares	SMALLINT NOT NULL,

		CONSTRAINT PK_ActiveShares PRIMARY KEY (SSN, ProcessDateInt)
	);


	INSERT INTO
		#ActiveShares
	SELECT
		Mem.SSN,
		ProcessDateInt = Mem.ProcessDate,
		NumberOfActiveShares = COUNT(Share.PARENTACCOUNT)
	FROM
		ARCUSYM000.dbo.NAME Mem
			INNER JOIN
		ARCUSYM000.dbo.SAVINGS Share
			ON Mem.PARENTACCOUNT = Share.PARENTACCOUNT AND Mem.ProcessDate = Share.ProcessDate
			INNER JOIN
		#MonthEndDates Dt
			ON Mem.ProcessDate = Dt.ProcessDateInt
	WHERE
		Mem.TYPE IN (0, 1)
		AND
		Mem.ExpirationDate IS NULL
		AND
		Mem.SSN IS NOT NULL
		AND
		Share.SHARECODE = 1
		AND
		Share.CLOSEDATE IS NULL
		AND
		DATEDIFF(dd, Share.ACTIVITYDATE, CONVERT(DATE, CAST(Share.ProcessDate AS VARCHAR), 112)) <= 30
	GROUP BY
		Mem.SSN,
		Mem.ProcessDate;




	IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%IndirectLoans%')
		DROP TABLE #IndirectLoans;


	CREATE TABLE
		#IndirectLoans
	(
		AccountNumber		VARCHAR(10),
		LoanID				CHAR(20) NOT NULL,
		ProcessDateInt		INT NOT NULL,
		LoanBalance			DECIMAL(16, 2) NOT NULL,
		SSN					CHAR(9) NULL
	);

	INSERT INTO
		#IndirectLoans
	(
		AccountNumber,
		LoanID,
		ProcessDateInt,
		LoanBalance,
		SSN
	)
	SELECT
		AccountNumber = Ln.PARENTACCOUNT,
		LoanID = Ln.ID,
		ProcessDateInt = Ln.ProcessDate,
		LoanBalance= Ln.BALANCE,
		SSN = Mem.SSN
	FROM
		ARCUSYM000.dbo.LOAN Ln
			INNER JOIN
		#MonthEndDates Dt
			ON Ln.ProcessDate = Dt.ProcessDateInt
			LEFT JOIN
		ARCUSYM000.dbo.NAME Mem
			ON Ln.PARENTACCOUNT = Mem.PARENTACCOUNT AND Ln.ProcessDate = Mem.ProcessDate
				AND Mem.TYPE IN (0, 1) AND Mem.ExpirationDate IS NULL AND Mem.SSN IS NOT NULL
	WHERE
		Ln.TYPE IN (9, 23)
		AND
		Ln.CLOSEDATE IS NULL
		AND
		Ln.CHARGEOFFDATE IS NULL;


	WITH Loans AS
	(
		SELECT
			Ln.ProcessDateInt,
			Ln.AccountNumber,
			Ln.LoanID,
			LoanBalance = MAX(Ln.LoanBalance),
			NumberOfActiveShares = ISNULL(SUM(Share.NumberOfActiveShares), 0)
		FROM
			#IndirectLoans Ln
				LEFT JOIN
			#ActiveShares Share
				ON Ln.ProcessDateInt = Share.ProcessDateInt AND Ln.SSN = Share.SSN
		GROUP BY
			Ln.ProcessDateInt,
			Ln.AccountNumber,
			Ln.LoanID
	)
	SELECT
		MonthEndDate = CONVERT(DATE, CAST(Ln.ProcessDateInt AS VARCHAR), 112),
		NumberOfIndirectLoans = COUNT(Ln.LoanID),
		TotalIndirectLoanBalance = SUM(Ln.LoanBalance),
		NumberOfIndirectLoansWithActiveShares = SUM(CASE
														WHEN Ln.NumberOfActiveShares = 0 THEN 0
														ELSE 1
													END),
		BalanceOfIndirectLoansWithActiveShares = SUM(	CASE
															WHEN Ln.NumberOfActiveShares = 0 THEN 0
															ELSE Ln.LoanBalance
														END),
		NumberOfIndirectLoansWithNoActiveShares = SUM(	CASE
															WHEN Ln.NumberOfActiveShares > 0 THEN 0
															ELSE 1
														END),
		BalanceOfIndirectLoansWithNoActiveShares = SUM(	CASE
															WHEN Ln.NumberOfActiveShares > 0 THEN 0
															ELSE Ln.LoanBalance
														END)
	FROM
		Loans Ln
	GROUP BY
		Ln.ProcessDateInt
	ORDER BY
		MonthEndDate DESC;

END;
GO


