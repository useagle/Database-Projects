USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'BudgetDate')
	DROP VIEW lookup.BudgetDate;
GO


CREATE VIEW
	lookup.BudgetDate
AS
WITH CloseDateRange AS
(
	SELECT
		MinBudgetDateKey = MIN(BudgetDateKey),
		MaxBudgetDateKey = MAX(BudgetDateKey)
	FROM
		fact.Budget
	WHERE
		BudgetDateKey >= 19000101
)
SELECT
	BudgetDateKey = CalendarKey,
	BudgetDate = CalendarDate,
	BudgetDateString = CalendarDateString,
	BudgetDateYearNum = YearNum,
	BudgetDateQuarterNum = QuarterNum,
	BudgetDateQuarterShortName = QuarterShortName,
	BudgetDateQuarterLongName = QuarterLongName,
	BudgetDateMonthNum = MonthNum,
	BudgetDateMonthShortName = MonthShortName,
	BudgetDateMonthLongName = MonthLongName,
	BudgetDateDayNum = DayNum,
	BudgetDateDayOfWeekNum = DayOfWeekNum,
	BudgetDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	CloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinBudgetDateKey AND Rng.MaxBudgetDateKey;
