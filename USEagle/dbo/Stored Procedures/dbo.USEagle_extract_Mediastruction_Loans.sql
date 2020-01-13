USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_Mediastruction_Loans')
	DROP PROCEDURE dbo.USEagle_extract_Mediastruction_Loans;
GO


CREATE PROCEDURE dbo.USEagle_extract_Mediastruction_Loans

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <03/28/2019>    
-- Modify Date: 
-- Description:	<extract of loan data for Mediastruction>
-- ======================================================================

AS
BEGIN

	SELECT
		Typ.ProductNumber,
		Typ.ProductName,
		NumberOfOpenLoans = COUNT(*),
		TotalCurrentBalance = SUM(Ln.LoanCurrentBalance),
		AverageCurrentBalance = CAST(SUM(Ln.LoanCurrentBalance) / COUNT(*) AS DECIMAL(12, 2))
	FROM
		USEagleDW.fact.CurrentLoan Ln
			INNER JOIN
		USEagleDW.dim.AccountType Typ
			ON Ln.AccountTypeKey = Typ.AccountTypeKey
	WHERE
		Ln.LoanChargeOffDateKey < 0
		AND
		Ln.LoanCloseDateKey < 0
		AND
		Typ.ProductNumber <> -1
		AND
		Typ.ProductCategory2 <> 'Business'
		AND
		Typ.ProductCategory3 <> 'Indirect'
	GROUP BY
		Typ.ProductNumber,
		Typ.ProductName
	ORDER BY
		Typ.ProductNumber;

END;
GO


