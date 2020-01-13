USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_MarquisMCIF_AccountTypes')
	DROP PROCEDURE dbo.USEagle_extract_MarquisMCIF_AccountTypes;
GO


CREATE PROCEDURE dbo.USEagle_extract_MarquisMCIF_AccountTypes

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <04/22/2019>    
-- Modify Date: 
-- Description:	<extract of account type lookup data for Marquis MCIF>
-- ======================================================================

AS
BEGIN

	SELECT DISTINCT
		Val = LEFT(AcctTyp.ProductCategory1, 1) + RIGHT('000' + CAST(AcctTyp.ProductNumber AS VARCHAR), 4)		--	Account Type Code (5, 1-5)
			+ LEFT(RTRIM(AcctTyp.ProductName) + SPACE(40), 40)													--	Account Type Description (40, 6-45)
			+ LEFT(RTRIM(AcctTyp.MarketingProductCategoryAbbreviation) + SPACE(5), 5)							--	Product Code Abbreviation (5, 46-50)
	FROM
		USEagleDW.dim.AccountType AcctTyp
	WHERE
		AcctTyp.AccountTypeKey > 0
		AND
		AcctTyp.AccountTypeActiveRecordFlag = 'Y'
		AND
		AcctTyp.MarketingProductCategoryAbbreviation IS NOT NULL
	ORDER BY
		Val;

END;
GO


