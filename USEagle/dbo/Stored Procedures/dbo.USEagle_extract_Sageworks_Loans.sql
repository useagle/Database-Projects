USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_Sageworks_Loans')
	DROP PROCEDURE dbo.USEagle_extract_Sageworks_Loans;
GO


CREATE PROCEDURE dbo.USEagle_extract_Sageworks_Loans

-- ======================================================================
-- Author:		<Nilam Keval>
-- Create date: <08/10/2018>    
-- Modify Date: <10/22/2018>	CJH
-- Description:	<extract of Business Loans>
-- ======================================================================

AS
BEGIN

	DECLARE @ProcessDateInt		INT;

	SELECT
		@ProcessDateInt = ProcessDate
	FROM
		ARCUSYM000.dbo.ufnARCUGetLatestProcessDate();


	SELECT 
		UniqueID = CONCAT(RIGHT(Acct.AccountNumber, 7), Nm.NameOrdinal),
		LoanID = CONCAT(RTRIM(Acct.AccountNumber), RTRIM(Ln.LoanID)),
		Balance = Ln.LoanBalance,
		LoanType = Ln.LoanType,
		LoanTypeDesc = Ln.LoanTypeDescription,
		Payment = Ln.LoanPayment,
		InterestRate = Ln.LoanInterestRate,
		OrigBalance = Ln.LoanOriginalBalance,
		OrigInterestRate = Ln.LoanOriginalRate,
		MaturityDate = Ln.LoanMaturityDate,
		CollateralCode = Ln.LoanCollateralCode,
		CollateralCodeDesc = Ln.LoanCollateralCodeDesc,
		PaymentFreq = Ln.LoanPaymentFrequency,
		PaymentFreqDesc = Ln.LoanPaymentFrequencyDesc,
		CeilingRate = Ln.LoanInterestRateMax,
		FloorRate = Ln.LoanPromoRateMin1,
		RiskRate = Ln.LoanRiskRate,
		HighRiskCode = Ln.LoanHighRiskCode,
		OrigRiskGrade = Ln.LoanOrigRiskGrade,
		VariableRate = Ln.LoanVariableRateIndicator,
		Branch = Ln.LoanBranch,
		CreatedBranch  = Ln.LoanCreatedAtBranch,
		PaymentCount = Ln.LoanPaymentCount,
		OriginalDate = Ln.LoanOriginalDate
FROM
		ARCUSYM000.arcu.vwARCUAccount Acct
			INNER JOIN
		ARCUSYM000.arcu.vwARCUName Nm 
			ON Nm.ProcessDate = @ProcessDateInt AND Nm.NameType = 0 AND Acct.AccountNumber = Nm.AccountNumber 
			INNER JOIN
		ARCUSYM000.arcu.vwARCULoan Ln
			ON Ln.ProcessDate = @ProcessDateInt AND Acct.AccountNumber = Ln.AccountNumber
	WHERE
		Acct.ProcessDate = @ProcessDateInt
		AND
		Acct.AccountType = 9 
		AND
		Acct.AccountCloseDate IS NULL
		AND
		Ln.LoanCloseDate IS NULL
		AND
		Ln.LoanChargeoffDate IS NULL
	ORDER BY
		LoanID;

END;
GO


