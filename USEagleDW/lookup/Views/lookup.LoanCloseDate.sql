USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanCloseDate')
	DROP VIEW lookup.LoanCloseDate;
GO


CREATE VIEW
	lookup.LoanCloseDate
AS
WITH CloseDateRange AS
(
	SELECT
		MinLoanCloseDateKey = MIN(LoanCloseDateKey),
		MaxLoanCloseDateKey = MAX(LoanCloseDateKey)
	FROM
		fact.CurrentLoan
	WHERE
		LoanCloseDateKey >= 19000101
)
SELECT
	LoanCloseDateKey = CalendarKey,
	LoanCloseDate = CalendarDate,
	LoanCloseDateString = CalendarDateString,
	LoanCloseDateYearNum = YearNum,
	LoanCloseDateQuarterNum = QuarterNum,
	LoanCloseDateQuarterShortName = QuarterShortName,
	LoanCloseDateQuarterLongName = QuarterLongName,
	LoanCloseDateMonthNum = MonthNum,
	LoanCloseDateMonthShortName = MonthShortName,
	LoanCloseDateMonthLongName = MonthLongName,
	LoanCloseDateDayNum = DayNum,
	LoanCloseDateDayOfWeekNum = DayOfWeekNum,
	LoanCloseDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	CloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinLoanCloseDateKey AND Rng.MaxLoanCloseDateKey;
