USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_Mediastruction_Shares')
	DROP PROCEDURE dbo.USEagle_extract_Mediastruction_Shares;
GO


CREATE PROCEDURE dbo.USEagle_extract_Mediastruction_Shares

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <03/28/2019>    
-- Modify Date: 
-- Description:	<extract of shares data for Mediastruction>
-- ======================================================================

AS
BEGIN

	SELECT
		Typ.ProductNumber,
		Typ.ProductName,
		NumberOfOpenShares = COUNT(*),
		TotalCurrentBalance = SUM(Sh.ShareCurrentBalance),
		AverageCurrentBalance = CAST(SUM(Sh.ShareCurrentBalance) / COUNT(*) AS DECIMAL(12, 2))
	FROM
		USEagleDW.fact.CurrentShare Sh
			INNER JOIN
		USEagleDW.dim.AccountType Typ
			ON Sh.AccountTypeKey = Typ.AccountTypeKey
	WHERE
		Sh.ShareChargeOffDateKey < 0
		AND
		Sh.ShareCloseDateKey < 0
		AND
		Typ.ProductCategory3 <> 'Business Checking'
	GROUP BY
		Typ.ProductNumber,
		Typ.ProductName
	ORDER BY
		Typ.ProductNumber;

END;
GO


