USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_Mediastruction_Members')
	DROP PROCEDURE dbo.USEagle_extract_Mediastruction_Members;
GO


CREATE PROCEDURE dbo.USEagle_extract_Mediastruction_Members

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <04/03/2019>    
-- Modify Date: 
-- Description:	<extract of members data for Mediastruction>
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
		USEagleDW.fact.CurrentMember Mem

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

--	NO 4, 5, 6, 8

END;
GO


