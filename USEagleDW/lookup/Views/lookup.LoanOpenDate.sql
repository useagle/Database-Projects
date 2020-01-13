USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanOpenDate')
	DROP VIEW lookup.LoanOpenDate;
GO


CREATE VIEW
	lookup.LoanOpenDate
AS
WITH OpenDateRange AS
(
	SELECT
		MinLoanOpenDateKey = MIN(LoanOpenDateKey),
		MaxLoanOpenDateKey = MAX(LoanOpenDateKey)
	FROM
		fact.CurrentLoan
	WHERE
		LoanOpenDateKey >= 19000101
)
SELECT
	LoanOpenDateKey = CalendarKey,
	LoanOpenDate = CalendarDate,
	LoanOpenDateString = CalendarDateString,
	LoanOpenDateYearNum = YearNum,
	LoanOpenDateQuarterNum = QuarterNum,
	LoanOpenDateQuarterShortName = QuarterShortName,
	LoanOpenDateQuarterLongName = QuarterLongName,
	LoanOpenDateMonthNum = MonthNum,
	LoanOpenDateMonthShortName = MonthShortName,
	LoanOpenDateMonthLongName = MonthLongName,
	LoanOpenDateDayNum = DayNum,
	LoanOpenDateDayOfWeekNum = DayOfWeekNum,
	LoanOpenDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	OpenDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinLoanOpenDateKey AND Rng.MaxLoanOpenDateKey;
