USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'data' AND name = 'Budget')
	DROP VIEW data.Budget;
GO


CREATE VIEW
	data.Budget
AS
SELECT
	Budg.BudgetKey,
	Budg.BudgetDateKey,
	Budg.GLAccountKey,
	Budg.GLAccountBranchKey,
	Budg.BudgetAmount,
	Budg.BudgetSourceSystem,
	Budg.BudgetSourceID
FROM
	fact.Budget Budg;
