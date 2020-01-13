USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspFact_CurrentLoan_FullRefresh')
	DROP PROCEDURE etl.uspFact_CurrentLoan_FullRefresh;
GO


CREATE PROCEDURE etl.uspFact_CurrentLoan_FullRefresh
AS
BEGIN

	DECLARE
		@ProcessDateInt							INT,
		@CreditCardBusinessAccountTypeKey		INT,
		@CreditCardCreditBuilderAccountTypeKey	INT,
		@CreditCardPlatinumAccountTypeKey		INT,
		@CreditCardBranchKey					INT;


	SELECT
		@ProcessDateInt = MAX(ProcessDate)
	FROM
		Staging.arcusym000.dbo_LOAN


	SELECT
		@CreditCardBusinessAccountTypeKey = AcctTyp.AccountTypeKey
	FROM
		dim.AccountType AcctTyp
	WHERE
		AcctTyp.ProductName = 'VISA CREDIT CARDS - BUSINESS'
		AND
		AcctTyp.AccountTypeActiveRecordFlag = 'Y';


	SELECT
		@CreditCardCreditBuilderAccountTypeKey = AcctTyp.AccountTypeKey
	FROM
		dim.AccountType AcctTyp
	WHERE
		AcctTyp.ProductName = 'VISA CREDIT CARDS - CREDIT BUILDER'
		AND
		AcctTyp.AccountTypeActiveRecordFlag = 'Y';


	SELECT
		@CreditCardPlatinumAccountTypeKey = AcctTyp.AccountTypeKey
	FROM
		dim.AccountType AcctTyp
	WHERE
		AcctTyp.ProductName = 'VISA CREDIT CARDS - PLATINUM'
		AND
		AcctTyp.AccountTypeActiveRecordFlag = 'Y';


	SELECT
		@CreditCardBranchKey = Brn.BranchKey
	FROM
		dim.Branch Brn
	WHERE
		Brn.BranchName = 'MAIN BRANCH'
		AND
		Brn.BranchActiveRecordFlag = 'Y';


/*
	DELETE
	FROM
		dim.LoanDescriptor
	WHERE
		LoanDescriptorKey >= 0;


	DBCC CHECKIDENT('dim.LoanDescriptor', RESEED, 0);


	WITH Loans AS
	(
		SELECT
			LoanAccountNumber = Ln.PARENTACCOUNT + '-' + CAST(Ln.ID AS VARCHAR),
			LoanID = RTRIM(Ln.ID),
			LoanIsIndirectFlag =	CASE
										WHEN Ln.TYPE IN (9, 23) THEN 'Y'
										ELSE 'N'
									END,
			LoanDescriptorSourceSystem = 'ARCU',
			LoanDescriptorSourceID = Ln.etlSurrogateKey
		FROM
			Staging.arcusym000.dbo_LOAN Ln
		WHERE
			Ln.ProcessDate = @ProcessDate
			AND
			Ln.OPENDATE <> ISNULL(Ln.CLOSEDATE, '2077-12-31')
	)
	INSERT INTO
		dim.LoanDescriptor
	(
		LoanAccountNumber,
		LoanID,
		LoanIsIndirectFlag,
		LoanDescriptorSourceSystem,
		LoanDescriptorSourceID,
		LoanDescriptorHash,
		LoanDescriptorStartEffectiveDate,
		LoanDescriptorEndEffectiveDate,
		LoanDescriptorActiveRecordFlag
	)
	SELECT
		LoanAccountNumber,
		LoanID,
		LoanIsIndirectFlag,
		LoanDescriptorSourceSystem,
		LoanDescriptorSourceID,
		LoanDescriptorHash = HASHBYTES('SHA2_512', LoanAccountNumber + LoanIsIndirectFlag),
		LoanDescriptorStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		LoanDescriptorEndEffectiveDate = '2099-12-31',
		LoanDescriptorActiveRecordFlag = 'Y'
	FROM
		Loans
	ORDER BY
		LoanDescriptorSourceID;
*/

--	EXEC etl.uspDim_LoanDescriptor_InsertUpdateDelete;

	TRUNCATE TABLE fact.CurrentLoan;


	INSERT INTO
		fact.CurrentLoan
	(
		AccountTypeKey,
		ApprovedByUserKey,
		LoanBranchKey,
		LoanChargeOffDateKey,
		LoanCloseDateKey,
		LoanCreditScoreKey,
		LoanDescriptorKey,
		LoanLastPaymentDateKey,
		LoanNextPaymentDateKey,
		LoanOpenDateKey,
		LoanOriginationBranchKey,
		LoanScheduledCloseDateKey,
		LoanStatusKey,
		MemberKey,
		MemberBranchKey,
		OriginatedByUserKey,
		ChargedOffLoanCount,
		ClosedLoanCount,
		DelinquentLoanCount,
		LoanChargeOffAmount,
		LoanCreditScore,
		LoanCurrentBalance,
		LoanCurrentRate,
		LoanDelinquentAmount,
		LoanOriginalBalance,
		LoanOriginalRate,
		LoanUndisbursedAmount,
		OpenLoanCount,
		TotalLoanCount,
		LoanSourceSystem,
		LoanSourceID
	)
	SELECT
		AccountTypeKey = ISNULL(AcctTyp.AccountTypeKey, -1),
		ApprovedByUserKey =	CASE
								WHEN Ln.OPENDATE < '2012-04-15' THEN -2		--	Pre-Conversion
								ELSE ISNULL(AppUsr.UserKey, -1)
							END,
		LoanBranchKey = ISNULL(LnBr.BranchKey, -1),
		LoanChargeOffDateKey =	CASE
									WHEN Ln.CHARGEOFFDATE IS NULL AND Ln.CHARGEOFFAMOUNT = 0 THEN -2
									WHEN Ln.CHARGEOFFDATE IS NULL AND Ln.CHARGEOFFAMOUNT > 0 THEN -1
									ELSE 10000 * YEAR(Ln.CHARGEOFFDATE) + 100 * MONTH(Ln.CHARGEOFFDATE) + DAY(Ln.CHARGEOFFDATE)
								END,
		LoanCloseDateKey =	CASE
								WHEN Ln.CLOSEDATE IS NULL THEN -2
								ELSE 10000 * YEAR(Ln.CLOSEDATE) + 100 * MONTH(Ln.CLOSEDATE) + DAY(Ln.CLOSEDATE)
							END,
		LoanCreditScoreKey = ISNULL(Ln.CREDITSCORE, -1),
		LoanDescriptorKey = ISNULL(Descr.LoanDescriptorKey, -1),
		LoanLastPaymentDateKey =	CASE
										WHEN Ln.LASTPAYMENTDATE IS NULL THEN -1
										ELSE 10000 * YEAR(Ln.LASTPAYMENTDATE) + 100 * MONTH(Ln.LASTPAYMENTDATE) + DAY(Ln.LASTPAYMENTDATE)
									END,
		LoanNextPaymentDateKey =	CASE
										WHEN Ln.BALANCE = 0 THEN -2
										WHEN Ln.DUEDATE IS NULL THEN -1
										ELSE 10000 * YEAR(Ln.DUEDATE) + 100 * MONTH(Ln.DUEDATE) + DAY(Ln.DUEDATE)
									END,
		LoanOpenDateKey =	CASE
								WHEN Ln.OPENDATE IS NULL THEN -1
								ELSE 10000 * YEAR(Ln.OPENDATE) + 100 * MONTH(Ln.OPENDATE) + DAY(Ln.OPENDATE)
							END,
		LoanOriginationBranchKey = ISNULL(OrigBr.BranchKey, -1),
		LoanScheduledCloseDateKey = -1,
		LoanStatusKey =	CASE
							WHEN Ln.CHARGEOFFDATE IS NOT NULL THEN 3
							WHEN Ln.CLOSEDATE IS NOT NULL THEN 2
							WHEN Ln.OPENDATE IS NOT NULL THEN 1
							ELSE -1
						END,
		MemberKey = ISNULL(Mem.MemberKey, -1),
		MemberBranchKey = ISNULL(MemBr.BranchKey, -1),
		OriginatedByUserKey =	CASE
									WHEN Ln.OPENDATE < '2012-04-15' THEN -2		--	Pre-Conversion
									ELSE ISNULL(OrigUsr.UserKey, -1)
								END,
		ChargedOffLoanCount =	CASE
									WHEN Ln.CHARGEOFFDATE IS NULL THEN 0
									ELSE 1
								END,
		ClosedLoanCount =	CASE
								WHEN Ln.CLOSEDATE IS NULL THEN 0
								ELSE 1
							END,
		DelinquentLoanCount =	CASE
									WHEN Ln.CLOSEDATE IS NULL AND Ln.CHARGEOFFDATE IS NULL AND Ln.DUEDATE < DATEADD(dd, -10, CAST(SYSDATETIME() AS DATE)) THEN 1
									ELSE 0
								END,
		LoanChargeOffAmount = Ln.CHARGEOFFAMOUNT,
		LoanCreditScore = ISNULL(Ln.CREDITSCORE, 0),
		LoanCurrentBalance = Ln.BALANCE,
		LoanCurrentRate = Ln.INTERESTRATE / 100000.0,
		LoanDelinquentAmount =	CASE
									WHEN Ln.CLOSEDATE IS NULL AND Ln.CHARGEOFFDATE IS NULL AND Ln.DUEDATE < DATEADD(dd, -10, CAST(SYSDATETIME() AS DATE)) THEN CAST(Ln.BALANCE / 10.00 AS DECIMAL(16, 2))
									ELSE 0
								END,
		LoanOriginalBalance = Ln.ORIGINALBALANCE,
		LoanOriginalRate = Ln.OriginalRate / 100000.0,
		LoanUndisbursedAmount = ISNULL(Ln.CREDITLIMIT, 0) - Ln.BALANCE,
		OpenLoanCount =	CASE
							WHEN Ln.CLOSEDATE IS NULL AND Ln.CHARGEOFFDATE IS NULL THEN 1
							ELSE 0
						END,
		TotalLoanCount = 1,
		LoanSourceSystem = 'ARCU',
		LoanSourceID = 'L' + RTRIM(Ln.PARENTACCOUNT) + RTRIM(Ln.ID)
	FROM
		Staging.arcusym000.dbo_LOAN Ln
			INNER JOIN
		Staging.arcusym000.arcu_vwARCUMemberAccounts MemAcct
			ON Ln.PARENTACCOUNT = MemAcct.AccountNumber AND MemAcct.ProcessDate = @ProcessDateInt
			LEFT JOIN
		USEagleDW.dim.AccountType AcctTyp
			ON AcctTyp.AccountTypeSourceSystem = 'ARCU' AND 'Loan|' + CAST(Ln.TYPE AS VARCHAR) + '|NA' = AcctTyp.AccountTypeSourceID AND AcctTyp.AccountTypeActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch LnBr
			ON LnBr.BranchSourceSystem = 'ARCU' AND Ln.BRANCH = LnBr.BranchSourceID AND LnBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch MemBr
			ON MemBr.BranchSourceSystem = 'ARCU' AND MemAcct.AccountBranch = MemBr.BranchSourceID AND MemBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch OrigBr
			ON OrigBr.BranchSourceSystem = 'ARCU' AND Ln.CREATEDATBRANCH = OrigBr.BranchSourceID AND OrigBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.LoanDescriptor Descr
			ON Descr.LoanDescriptorSourceSystem = 'ARCU' AND 'L' + RTRIM(Ln.PARENTACCOUNT) + RTRIM(Ln.ID) = Descr.LoanDescriptorSourceID AND Descr.LoanDescriptorActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Member Mem
			ON Mem.MemberSourceSystem = 'ARCU' AND Ln.PARENTACCOUNT = Mem.MemberSourceID AND Mem.MemberActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.[User] AppUsr
			ON AppUsr.UserSourceSystem = 'ARCU' AND Ln.APPROVALCODE = AppUsr.UserSourceID AND AppUsr.UserActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.[User] OrigUsr
			ON OrigUsr.UserSourceSystem = 'ARCU' AND Ln.CREATEDBYUSER = OrigUsr.UserSourceID AND OrigUsr.UserActiveRecordFlag = 'Y'
	WHERE
		Ln.ProcessDate = @ProcessDateInt
		AND
		Ln.OPENDATE <> ISNULL(Ln.CLOSEDATE, '2077-12-31')
		AND
		(Ln.PARTICIPATIONNUMBER IS NULL
			OR
			Ln.PARTICIPATIONNUMBER <> 3
			OR
			Ln.TYPE NOT IN (9, 23))
	ORDER BY
		Ln.etlSurrogateKey;


	INSERT INTO
		fact.CurrentLoan
	(
		AccountTypeKey,
		ApprovedByUserKey,
		LoanBranchKey,
		LoanChargeOffDateKey,
		LoanCloseDateKey,
		LoanCreditScoreKey,
		LoanDescriptorKey,
		LoanLastPaymentDateKey,
		LoanNextPaymentDateKey,
		LoanOpenDateKey,
		LoanOriginationBranchKey,
		LoanScheduledCloseDateKey,
		LoanStatusKey,
		MemberKey,
		MemberBranchKey,
		OriginatedByUserKey,
		ChargedOffLoanCount,
		ClosedLoanCount,
		DelinquentLoanCount,
		LoanChargeOffAmount,
		LoanCreditScore,
		LoanCurrentBalance,
		LoanCurrentRate,
		LoanDelinquentAmount,
		LoanOriginalBalance,
		LoanOriginalRate,
		LoanUndisbursedAmount,
		OpenLoanCount,
		TotalLoanCount,
		LoanSourceSystem,
		LoanSourceID
	)
	SELECT
		AccountTypeKey = ISNULL(AcctTyp.AccountTypeKey, -1),
		ApprovedByUserKey =	CASE
								WHEN Ln.OPENDATE < '2012-04-15' THEN -2		--	Pre-Conversion
								ELSE ISNULL(AppUsr.UserKey, -1)
							END,
		LoanBranchKey = ISNULL(LnBr.BranchKey, -1),
		LoanChargeOffDateKey =	CASE
									WHEN Ln.CHARGEOFFDATE IS NULL AND Ln.CHARGEOFFAMOUNT = 0 THEN -2
									WHEN Ln.CHARGEOFFDATE IS NULL AND Ln.CHARGEOFFAMOUNT > 0 THEN -1
									ELSE 10000 * YEAR(Ln.CHARGEOFFDATE) + 100 * MONTH(Ln.CHARGEOFFDATE) + DAY(Ln.CHARGEOFFDATE)
								END,
		LoanCloseDateKey =	CASE
								WHEN Ln.CLOSEDATE IS NULL THEN -2
								ELSE 10000 * YEAR(Ln.CLOSEDATE) + 100 * MONTH(Ln.CLOSEDATE) + DAY(Ln.CLOSEDATE)
							END,
		LoanCreditScoreKey = ISNULL(Ln.CREDITSCORE, -1),
		LoanDescriptorKey = ISNULL(Descr.LoanDescriptorKey, -1),
		LoanLastPaymentDateKey =	CASE
										WHEN Ln.LASTPAYMENTDATE IS NULL THEN -1
										ELSE 10000 * YEAR(Ln.LASTPAYMENTDATE) + 100 * MONTH(Ln.LASTPAYMENTDATE) + DAY(Ln.LASTPAYMENTDATE)
									END,
		LoanNextPaymentDateKey =	CASE
										WHEN Ln.BALANCE = 0 THEN -2
										WHEN Ln.DUEDATE IS NULL THEN -1
										ELSE 10000 * YEAR(Ln.DUEDATE) + 100 * MONTH(Ln.DUEDATE) + DAY(Ln.DUEDATE)
									END,
		LoanOpenDateKey =	CASE
								WHEN Ln.OPENDATE IS NULL THEN -1
								ELSE 10000 * YEAR(Ln.OPENDATE) + 100 * MONTH(Ln.OPENDATE) + DAY(Ln.OPENDATE)
							END,
		LoanOriginationBranchKey = ISNULL(OrigBr.BranchKey, -1),
		LoanScheduledCloseDateKey = -1,
		LoanStatusKey =	CASE
							WHEN Ln.CHARGEOFFDATE IS NOT NULL THEN 3
							WHEN Ln.CLOSEDATE IS NOT NULL THEN 2
							WHEN Ln.OPENDATE IS NOT NULL THEN 1
							ELSE -1
						END,
		MemberKey = ISNULL(Mem.MemberKey, -1),
		MemberBranchKey = ISNULL(MemBr.BranchKey, -1),
		OriginatedByUserKey =	CASE
									WHEN Ln.OPENDATE < '2012-04-15' THEN -2		--	Pre-Conversion
									ELSE ISNULL(OrigUsr.UserKey, -1)
								END,
		ChargedOffLoanCount =	CASE
									WHEN Ln.CHARGEOFFDATE IS NULL THEN 0
									ELSE 1
								END,
		ClosedLoanCount =	CASE
								WHEN Ln.CLOSEDATE IS NULL THEN 0
								ELSE 1
							END,
		DelinquentLoanCount =	CASE
									WHEN Ln.CLOSEDATE IS NULL AND Ln.CHARGEOFFDATE IS NULL AND Ln.DUEDATE < DATEADD(dd, -10, CAST(SYSDATETIME() AS DATE)) THEN 1
									ELSE 0
								END,
		LoanChargeOffAmount = CAST(Ln.CHARGEOFFAMOUNT / 10.00 AS DECIMAL(16, 2)),
		LoanCreditScore = ISNULL(Ln.CREDITSCORE, 0),
		LoanCurrentBalance = CAST(Ln.BALANCE / 10.00 AS DECIMAL(16, 2)),
		LoanCurrentRate = Ln.INTERESTRATE / 100000.0,
		LoanDelinquentAmount =	CASE
									WHEN Ln.CLOSEDATE IS NULL AND Ln.CHARGEOFFDATE IS NULL AND Ln.DUEDATE < DATEADD(dd, -10, CAST(SYSDATETIME() AS DATE)) THEN CAST(Ln.BALANCE / 10.00 AS DECIMAL(16, 2))
									ELSE 0
								END,
		LoanOriginalBalance = CAST(Ln.ORIGINALBALANCE / 10.00 AS DECIMAL(16, 2)),
		LoanOriginalRate = Ln.OriginalRate / 100000.0,
		LoanUndisbursedAmount = 0,
		OpenLoanCount =	CASE
							WHEN Ln.CLOSEDATE IS NULL AND Ln.CHARGEOFFDATE IS NULL THEN 1
							ELSE 0
						END,
		TotalLoanCount = 1,
		LoanSourceSystem = 'ARCU',
		LoanSourceID = 'L' + RTRIM(Ln.PARENTACCOUNT) + RTRIM(Ln.ID)
	FROM
		Staging.arcusym000.dbo_LOAN Ln
			INNER JOIN
		Staging.arcusym000.arcu_vwARCUMemberAccounts MemAcct
			ON Ln.PARENTACCOUNT = MemAcct.AccountNumber AND MemAcct.ProcessDate = @ProcessDateInt
			LEFT JOIN
		USEagleDW.dim.AccountType AcctTyp
			ON AcctTyp.AccountTypeSourceSystem = 'ARCU' AND 'Loan|' + CAST(Ln.TYPE AS VARCHAR) + '|N' = AcctTyp.AccountTypeSourceID AND AcctTyp.AccountTypeActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch LnBr
			ON LnBr.BranchSourceSystem = 'ARCU' AND Ln.BRANCH = LnBr.BranchSourceID AND LnBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch MemBr
			ON MemBr.BranchSourceSystem = 'ARCU' AND MemAcct.AccountBranch = MemBr.BranchSourceID AND MemBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch OrigBr
			ON OrigBr.BranchSourceSystem = 'ARCU' AND Ln.CREATEDATBRANCH = OrigBr.BranchSourceID AND OrigBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.LoanDescriptor Descr
			ON Descr.LoanDescriptorSourceSystem = 'ARCU' AND 'L' + RTRIM(Ln.PARENTACCOUNT) + RTRIM(Ln.ID) = Descr.LoanDescriptorSourceID AND Descr.LoanDescriptorActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Member Mem
			ON Mem.MemberSourceSystem = 'ARCU' AND Ln.PARENTACCOUNT = Mem.MemberSourceID AND Mem.MemberActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.[User] AppUsr
			ON AppUsr.UserSourceSystem = 'ARCU' AND Ln.APPROVALCODE = AppUsr.UserSourceID AND AppUsr.UserActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.[User] OrigUsr
			ON OrigUsr.UserSourceSystem = 'ARCU' AND Ln.CREATEDBYUSER = OrigUsr.UserSourceID AND OrigUsr.UserActiveRecordFlag = 'Y'
	WHERE
		Ln.ProcessDate = @ProcessDateInt
		AND
		Ln.OPENDATE <> ISNULL(Ln.CLOSEDATE, '2077-12-31')
		AND
		Ln.PARTICIPATIONNUMBER = 3
		AND
		Ln.TYPE IN (9, 23)
	ORDER BY
		Ln.etlSurrogateKey;


	INSERT INTO
		fact.CurrentLoan
	(
		AccountTypeKey,
		ApprovedByUserKey,
		LoanBranchKey,
		LoanChargeOffDateKey,
		LoanCloseDateKey,
		LoanCreditScoreKey,
		LoanDescriptorKey,
		LoanLastPaymentDateKey,
		LoanNextPaymentDateKey,
		LoanOpenDateKey,
		LoanOriginationBranchKey,
		LoanScheduledCloseDateKey,
		LoanStatusKey,
		MemberKey,
		MemberBranchKey,
		OriginatedByUserKey,
		ChargedOffLoanCount,
		ClosedLoanCount,
		DelinquentLoanCount,
		LoanChargeOffAmount,
		LoanCreditScore,
		LoanCurrentBalance,
		LoanCurrentRate,
		LoanDelinquentAmount,
		LoanOriginalBalance,
		LoanOriginalRate,
		LoanUndisbursedAmount,
		OpenLoanCount,
		TotalLoanCount,
		LoanSourceSystem,
		LoanSourceID
	)
	SELECT
		AccountTypeKey = ISNULL(AcctTyp.AccountTypeKey, -1),
		ApprovedByUserKey =	CASE
								WHEN Ln.OPENDATE < '2012-04-15' THEN -2		--	Pre-Conversion
								ELSE ISNULL(AppUsr.UserKey, -1)
							END,
		LoanBranchKey = ISNULL(LnBr.BranchKey, -1),
		LoanChargeOffDateKey =	CASE
									WHEN Ln.CHARGEOFFDATE IS NULL AND Ln.CHARGEOFFAMOUNT = 0 THEN -2
									WHEN Ln.CHARGEOFFDATE IS NULL AND Ln.CHARGEOFFAMOUNT > 0 THEN -1
									ELSE 10000 * YEAR(Ln.CHARGEOFFDATE) + 100 * MONTH(Ln.CHARGEOFFDATE) + DAY(Ln.CHARGEOFFDATE)
								END,
		LoanCloseDateKey =	CASE
								WHEN Ln.CLOSEDATE IS NULL THEN -2
								ELSE 10000 * YEAR(Ln.CLOSEDATE) + 100 * MONTH(Ln.CLOSEDATE) + DAY(Ln.CLOSEDATE)
							END,
		LoanCreditScoreKey = ISNULL(Ln.CREDITSCORE, -1),
		LoanDescriptorKey = ISNULL(Descr.LoanDescriptorKey, -1),
		LoanLastPaymentDateKey =	CASE
										WHEN Ln.LASTPAYMENTDATE IS NULL THEN -1
										ELSE 10000 * YEAR(Ln.LASTPAYMENTDATE) + 100 * MONTH(Ln.LASTPAYMENTDATE) + DAY(Ln.LASTPAYMENTDATE)
									END,
		LoanNextPaymentDateKey =	CASE
										WHEN Ln.BALANCE = 0 THEN -2
										WHEN Ln.DUEDATE IS NULL THEN -1
										ELSE 10000 * YEAR(Ln.DUEDATE) + 100 * MONTH(Ln.DUEDATE) + DAY(Ln.DUEDATE)
									END,
		LoanOpenDateKey =	CASE
								WHEN Ln.OPENDATE IS NULL THEN -1
								ELSE 10000 * YEAR(Ln.OPENDATE) + 100 * MONTH(Ln.OPENDATE) + DAY(Ln.OPENDATE)
							END,
		LoanOriginationBranchKey = ISNULL(OrigBr.BranchKey, -1),
		LoanScheduledCloseDateKey = -1,
		LoanStatusKey =	CASE
							WHEN Ln.CHARGEOFFDATE IS NOT NULL THEN 3
							WHEN Ln.CLOSEDATE IS NOT NULL THEN 2
							WHEN Ln.OPENDATE IS NOT NULL THEN 1
							ELSE -1
						END,
		MemberKey = ISNULL(Mem.MemberKey, -1),
		MemberBranchKey = ISNULL(MemBr.BranchKey, -1),
		OriginatedByUserKey =	CASE
									WHEN Ln.OPENDATE < '2012-04-15' THEN -2		--	Pre-Conversion
									ELSE ISNULL(OrigUsr.UserKey, -1)
								END,
		ChargedOffLoanCount =	CASE
									WHEN Ln.CHARGEOFFDATE IS NULL THEN 0
									ELSE 1
								END,
		ClosedLoanCount =	CASE
								WHEN Ln.CLOSEDATE IS NULL THEN 0
								ELSE 1
							END,
		DelinquentLoanCount = 0,
		LoanChargeOffAmount = Ln.CHARGEOFFAMOUNT - CAST(Ln.CHARGEOFFAMOUNT / 10.00 AS DECIMAL(16, 2)),
		LoanCreditScore = ISNULL(Ln.CREDITSCORE, 0),
		LoanCurrentBalance = Ln.BALANCE - CAST(Ln.BALANCE / 10.00 AS DECIMAL(16, 2)),
		LoanCurrentRate = Ln.INTERESTRATE / 100000.0,
		LoanDelinquentAmount = 0,
		LoanOriginalBalance = Ln.ORIGINALBALANCE - CAST(Ln.ORIGINALBALANCE / 10.00 AS DECIMAL(16, 2)),
		LoanOriginalRate = Ln.OriginalRate / 100000.0,
		LoanUndisbursedAmount = 0,
		OpenLoanCount =	0,
		TotalLoanCount = 0,
		LoanSourceSystem = 'ARCU',
		LoanSourceID = 'L' + RTRIM(Ln.PARENTACCOUNT) + RTRIM(Ln.ID)
	FROM
		Staging.arcusym000.dbo_LOAN Ln
			INNER JOIN
		Staging.arcusym000.arcu_vwARCUMemberAccounts MemAcct
			ON Ln.PARENTACCOUNT = MemAcct.AccountNumber AND MemAcct.ProcessDate = @ProcessDateInt
			LEFT JOIN
		USEagleDW.dim.AccountType AcctTyp
			ON AcctTyp.AccountTypeSourceSystem = 'ARCU' AND 'Loan|' + CAST(Ln.TYPE AS VARCHAR) + '|Y' = AcctTyp.AccountTypeSourceID AND AcctTyp.AccountTypeActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch LnBr
			ON LnBr.BranchSourceSystem = 'ARCU' AND Ln.BRANCH = LnBr.BranchSourceID AND LnBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch MemBr
			ON MemBr.BranchSourceSystem = 'ARCU' AND MemAcct.AccountBranch = MemBr.BranchSourceID AND MemBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch OrigBr
			ON OrigBr.BranchSourceSystem = 'ARCU' AND Ln.CREATEDATBRANCH = OrigBr.BranchSourceID AND OrigBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.LoanDescriptor Descr
			ON Descr.LoanDescriptorSourceSystem = 'ARCU' AND 'L' + RTRIM(Ln.PARENTACCOUNT) + RTRIM(Ln.ID) = Descr.LoanDescriptorSourceID AND Descr.LoanDescriptorActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Member Mem
			ON Mem.MemberSourceSystem = 'ARCU' AND Ln.PARENTACCOUNT = Mem.MemberSourceID AND Mem.MemberActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.[User] AppUsr
			ON AppUsr.UserSourceSystem = 'ARCU' AND Ln.APPROVALCODE = AppUsr.UserSourceID AND AppUsr.UserActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.[User] OrigUsr
			ON OrigUsr.UserSourceSystem = 'ARCU' AND Ln.CREATEDBYUSER = OrigUsr.UserSourceID AND OrigUsr.UserActiveRecordFlag = 'Y'

	WHERE
		Ln.ProcessDate = @ProcessDateInt
		AND
		Ln.OPENDATE <> ISNULL(Ln.CLOSEDATE, '2077-12-31')
		AND
		Ln.PARTICIPATIONNUMBER = 3
		AND
		Ln.TYPE IN (9, 23)
	ORDER BY
		Ln.etlSurrogateKey;


	--	Insert loan records for Vantiv credit card data
	INSERT INTO
		fact.CurrentLoan
	(
		AccountTypeKey,
		ApprovedByUserKey,
		LoanBranchKey,
		LoanChargeOffDateKey,
		LoanCloseDateKey,
		LoanCreditScoreKey,
		LoanDescriptorKey,
		LoanLastPaymentDateKey,
		LoanNextPaymentDateKey,
		LoanOpenDateKey,
		LoanOriginationBranchKey,
		LoanScheduledCloseDateKey,
		LoanStatusKey,
		MemberKey,
		MemberBranchKey,
		OriginatedByUserKey,
		ChargedOffLoanCount,
		ClosedLoanCount,
		DelinquentLoanCount,
		LoanChargeOffAmount,
		LoanCreditScore,
		LoanCurrentBalance,
		LoanCurrentRate,
		LoanDelinquentAmount,
		LoanOriginalBalance,
		LoanOriginalRate,
		LoanUndisbursedAmount,
		OpenLoanCount,
		TotalLoanCount,
		LoanSourceSystem,
		LoanSourceID
	)
	SELECT
		AccountTypeKey =	CASE
								WHEN LEFT(DlyTrk.USERCHAR1, 6) IN ('401126', '411252', '415748', '431787') THEN @CreditCardPlatinumAccountTypeKey
								WHEN LEFT(DlyTrk.USERCHAR1, 6) = '444752' THEN @CreditCardCreditBuilderAccountTypeKey
								WHEN LEFT(DlyTrk.USERCHAR1, 6) = '476743' THEN @CreditCardBusinessAccountTypeKey
								ELSE -1
							END,
		ApprovedByUserKey = -1,
		LoanBranchKey = ISNULL(@CreditCardBranchKey, -1),
		LoanChargeOffDateKey =	CASE
									WHEN MthTrk.USERDATE3 IS NULL THEN -1
									ELSE CAST(CONVERT(VARCHAR, MthTrk.USERDATE3, 112) AS INT)
								END,
		LoanCloseDateKey = -1,
		LoanCreditScoreKey = -1,
		LoanDescriptorKey = ISNULL(Descr.LoanDescriptorKey, -1),
		LoanLastPaymentDateKey =	CASE
										WHEN DlyTrk.USERDATE2 IS NULL THEN -1
										ELSE CAST(CONVERT(VARCHAR, DlyTrk.USERDATE2, 112) AS INT)
									END,
		LoanNextPaymentDateKey =	CASE
										WHEN ISNULL(CAST(DlyTrk.USERAMOUNT1 AS DECIMAL(12, 2)), 0) = 0 THEN -2
										WHEN DlyTrk.USERDATE1 IS NULL THEN -1
										ELSE CAST(CONVERT(VARCHAR, DlyTrk.USERDATE1, 112) AS INT)
									END,
		LoanOpenDateKey =	CASE
								WHEN DlyTrk.USERDATE4 IS NULL THEN -1
								ELSE CAST(CONVERT(VARCHAR, DlyTrk.USERDATE4, 112) AS INT)
							END,
		LoanOriginationBranchKey = ISNULL(@CreditCardBranchKey, -1),
		LoanScheduledCloseDateKey = -1,
		LoanStatusKey =	1,
		MemberKey = ISNULL(Mem.MemberKey, -1),
		MemberBranchKey = ISNULL(MemBr.BranchKey, -1),
		OriginatedByUserKey = -1,
		ChargedOffLoanCount =	CASE
									WHEN MthTrk.USERDATE3 IS NULL THEN 0
									ELSE 1
								END,
		ClosedLoanCount = 0,
		DelinquentLoanCount =	CASE
									WHEN DlyTrk.USERAMOUNT9 > 0 THEN 1
									ELSE 0
								END,
		LoanChargeOffAmount = ISNULL(CAST(MthTrk.USERAMOUNT9 AS DECIMAL(12, 2)), 0),
		LoanCreditScore = 0,
		LoanCurrentBalance =	CASE
									WHEN MthTrk.USERCHAR9 = 'S' THEN 0
									ELSE ISNULL(CAST(DlyTrk.USERAMOUNT1 AS DECIMAL(12, 2)), 0)
								END,
		LoanCurrentRate = ISNULL(TRY_CAST(	CASE
												WHEN ISNULL(CAST(MthTrk.USERAMOUNT8 AS DECIMAL(12, 2)), 0) = 0 OR ISNULL(CAST(DlyTrk.USERAMOUNT1 AS DECIMAL(12, 2)), 0) = 0 THEN CAST(ISNULL(MthTrk.USERRATE1, 0) AS DECIMAL(9, 3)) / 100000.0
												ELSE (((ISNULL(CAST(DlyTrk.USERAMOUNT1 AS DECIMAL(12, 2)), 0) - ISNULL(CAST(MthTrk.USERAMOUNT8 AS DECIMAL(12, 2)), 0)) * CAST(ISNULL(MthTrk.USERRATE1, 0) AS DECIMAL(9, 3)))
													+ (ISNULL(CAST(MthTrk.USERAMOUNT8 AS DECIMAL(12, 2)), 0)) * CAST(ISNULL(MthTrk.USERRATE2, 0) AS DECIMAL(9, 3)))
													/ ISNULL(CAST(DlyTrk.USERAMOUNT1 AS DECIMAL(12, 2)), 0) / 100000.0
											END AS DECIMAL(8, 6)), 0),
		LoanDelinquentAmount =	CASE
									WHEN DlyTrk.USERAMOUNT9 > 0 THEN DlyTrk.USERAMOUNT9
									ELSE 0
								END,
		LoanOriginalBalance = 0,
		LoanOriginalRate = ISNULL(CAST(MthTrk.USERRATE1 AS DECIMAL(9, 3)), 0) / 100000.0,
		LoanUndisbursedAmount = 0,
		OpenLoanCount =	CASE
							WHEN MthTrk.USERDATE3 IS NOT NULL THEN 0
							ELSE 1
						END,
		TotalLoanCount = 1,
		LoanSourceSystem = 'ARCU',
		LoanSourceID = 'T' + RTRIM(DlyTrk.PARENTACCOUNT) + RIGHT(RTRIM(DlyTrk.USERCHAR1), 4)
	FROM
		Staging.arcusym000.dbo_TRACKING DlyTrk
			INNER JOIN
		Staging.arcusym000.dbo_ACCOUNT MemAcct
			ON DlyTrk.PARENTACCOUNT = MemAcct.ACCOUNTNUMBER AND MemAcct.ProcessDate = @ProcessDateInt
			LEFT JOIN
		Staging.arcusym000.dbo_TRACKING MthTrk
			ON DlyTrk.USERCHAR1 = MthTrk.USERCHAR1 AND MthTrk.ProcessDate = @ProcessDateInt AND MthTrk.TYPE = 32 AND ISNULL(MthTrk.EXPIREDATE, '2049-12-31') >= CAST(SYSDATETIME() AS DATE)
			LEFT JOIN
		USEagleDW.dim.Branch MemBr
			ON MemBr.BranchSourceSystem = 'ARCU' AND MemAcct.BRANCH = MemBr.BranchSourceID AND MemBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.LoanDescriptor Descr
			ON Descr.LoanDescriptorSourceSystem = 'ARCU' AND 'T' + RTRIM(DlyTrk.PARENTACCOUNT) + RIGHT(RTRIM(DlyTrk.USERCHAR1), 4) = Descr.LoanDescriptorSourceID AND Descr.LoanDescriptorActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Member Mem
			ON Mem.MemberSourceSystem = 'ARCU' AND DlyTrk.PARENTACCOUNT = Mem.MemberSourceID AND Mem.MemberActiveRecordFlag = 'Y'
	WHERE
		DlyTrk.ProcessDate = @ProcessDateInt
		AND
		DlyTrk.TYPE = 30
		AND
		DlyTrk.USERCHAR1 IS NOT NULL
		AND
		ISNULL(DlyTrk.EXPIREDATE, '2049-12-31') >= CAST(SYSDATETIME() AS DATE)
		AND
		MemAcct.CLOSEDATE IS NULL
	ORDER BY
		DlyTrk.etlSurrogateKey;

END;
