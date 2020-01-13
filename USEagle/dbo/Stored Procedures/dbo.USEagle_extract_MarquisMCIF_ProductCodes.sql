USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_MarquisMCIF_ProductCodes')
	DROP PROCEDURE dbo.USEagle_extract_MarquisMCIF_ProductCodes;
GO


CREATE PROCEDURE dbo.USEagle_extract_MarquisMCIF_ProductCodes

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <04/22/2019>    
-- Modify Date: 
-- Description:	<extract ofproduct code lookup data for Marquis MCIF>
-- ======================================================================

AS
BEGIN

	SELECT DISTINCT
		Val = LEFT(RTRIM(AcctTyp.MarketingProductCategoryName) + SPACE(25), 25)				--	Product Name (25, 1-25)
			+ LEFT(RTRIM(AcctTyp.MarketingProductCategoryAbbreviation) + SPACE(5), 5)		--	Abbreviation (5, 26-30)	
	FROM
		USEagleDW.dim.AccountType AcctTyp
	WHERE
		AcctTyp.AccountTypeKey > 0
		AND
		AcctTyp.AccountTypeActiveRecordFlag = 'Y'
		AND
		AcctTyp.MarketingProductCategoryName IS NOT NULL
	ORDER BY
		Val;

END;
GO


