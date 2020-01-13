USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_FIN00010_MonthOverMonthBalanceSheetExtract')
	DROP PROCEDURE dbo.USEagle_rpt_FIN00010_MonthOverMonthBalanceSheetExtract;
GO


CREATE PROCEDURE dbo.USEagle_rpt_FIN00010_MonthOverMonthBalanceSheetExtract
(
	@MonthEndDate		DATE
)
-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <10/12/2017>    
-- Modify Date: 
-- Description:	<File maintenance for users that were manually modified.> 
-- ======================================================================

AS
BEGIN

	SELECT
		Record = CAST(
						CASE
							WHEN GLAcct.NUMBER = '739100' THEN GLAcctCat.GLAccount 
							ELSE GLAcct.NUMBER + '     '
						END + ' ' +
						CAST(LEFT(	CASE
										WHEN RIGHT(GLAcct.NUMBER, 3) IN ('996', '997', '998', '999') THEN '      '
										ELSE ''
									END + MAX(GLAcctCat.GLAccountDescription), 63) AS CHAR(63)) +
						CAST(ABS(SUM(GLAcct.BALANCE) + SUM(GLAcct.BALANCENEXTPERIOD)) AS CHAR(13)) +
						CASE
							WHEN SUM(GLAcct.BALANCE) + SUM(GLAcct.BALANCENEXTPERIOD) < 0 THEN '>'
							ELSE ' '
						END
					AS CHAR(83))
	FROM
		ARCUSYM000.dbo.GLACCOUNT GLAcct
			INNER JOIN
		ARCUSYM000.arcu.ARCUGLAccountCategory GLAcctCat
			ON GLAcct.NUMBER + '-' + GLAcct.SUFFIX = GLAcctCat.GLAccount
	WHERE
		GLAcct.ProcessDate = 20180131
		AND
		GLAcctCat.GLAccountCategory1 = 'BALANCE SHEET'
	GROUP BY
		CASE
			WHEN GLAcct.NUMBER = '739100' THEN GLAcctCat.GLAccount 
			ELSE GLAcct.NUMBER
		END,
		GLAcctCat.GLAccount,
		GLAcct.NUMBER
	ORDER BY
		CASE
			WHEN GLAcct.NUMBER = '739100' THEN GLAcctCat.GLAccount 
			ELSE GLAcct.NUMBER
		END;

END;
GO


