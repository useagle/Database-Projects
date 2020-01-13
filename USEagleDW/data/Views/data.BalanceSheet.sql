USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'data' AND name = 'BalanceSheet')
	DROP VIEW data.BalanceSheet;
GO


CREATE VIEW
	data.BalanceSheet
AS
SELECT
	Bal.BalanceSheetKey,
	Bal.GLAccountKey,
	Bal.GLAccountBranchKey,
	Bal.PeriodKey,
	Bal.AccountBalance,
	Bal.BalanceSheetSourceSystem,
	Bal.BalanceSheetSourceID
FROM
	fact.BalanceSheet Bal;
