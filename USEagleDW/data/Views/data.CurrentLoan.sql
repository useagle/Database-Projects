USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'data' AND name = 'CurrentLoan')
	DROP VIEW data.CurrentLoan;
GO


CREATE VIEW
	data.CurrentLoan
AS
SELECT
	LoanKey = LoanKey,
	AccountTypeKey = AccountTypeKey,
	ApprovedByUserKey = ApprovedByUserKey,
	LoanBranchKey = LoanBranchKey,
	LoanChargeOffDateKey = LoanChargeOffDateKey,
	LoanCloseDateKey = LoanCloseDateKey,
	LoanCreditScoreKey = LoanCreditScoreKey,
	LoanDescriptorKey = LoanDescriptorKey,
	LoanLastPaymentDateKey = LoanLastPaymentDateKey,
	LoanNextPaymentDateKey = LoanNextPaymentDateKey,
	LoanOpenDateKey = LoanOpenDateKey,
	LoanOriginationBranchKey = LoanOriginationBranchKey,
	LoanScheduledCloseDateKey = LoanScheduledCloseDateKey,
	LoanStatusKey = LoanStatusKey,
	MemberKey = MemberKey,
	MemberBranchKey = MemberBranchKey,
	OriginatedByUserKey = OriginatedByUserKey,
	ChargedOffLoanCount = ChargedOffLoanCount,
	ClosedLoanCount = ClosedLoanCount,
	DelinquentLoanCount = DelinquentLoanCount,
	LoanChargeOffAmount = LoanChargeOffAmount,
	LoanCreditScore = LoanCreditScore,
	LoanCurrentBalance = LoanCurrentBalance,
	LoanCurrentRate = LoanCurrentRate,
	LoanDelinquentAmount = LoanDelinquentAmount,
	LoanOriginalBalance = LoanOriginalBalance,
	LoanOriginalRate = LoanOriginalRate,
	LoanUndisbursedAmount = LoanUndisbursedAmount,
	OpenLoanCount = OpenLoanCount,
	TotalLoanCount = TotalLoanCount,
	LoanSourceSystem = LoanSourceSystem,
	LoanSourceID = LoanSourceID
FROM
	fact.CurrentLoan;
