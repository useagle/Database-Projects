USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanScheduledScheduledCloseDate')
	DROP VIEW lookup.LoanScheduledScheduledCloseDate;
GO


CREATE VIEW
	lookup.LoanScheduledScheduledCloseDate
AS
WITH ScheduledCloseDateRange AS
(
	SELECT
		MinLoanScheduledCloseDateKey = MIN(LoanScheduledCloseDateKey),
		MaxLoanScheduledCloseDateKey = MAX(LoanScheduledCloseDateKey)
	FROM
		fact.CurrentLoan
	WHERE
		LoanScheduledCloseDateKey >= 19000101
)
SELECT
	LoanScheduledScheduledCloseDateKey = CalendarKey,
	LoanScheduledScheduledCloseDate = CalendarDate,
	LoanScheduledScheduledCloseDateString = CalendarDateString,
	LoanScheduledScheduledCloseDateYearNum = YearNum,
	LoanScheduledScheduledCloseDateQuarterNum = QuarterNum,
	LoanScheduledScheduledCloseDateQuarterShortName = QuarterShortName,
	LoanScheduledScheduledCloseDateQuarterLongName = QuarterLongName,
	LoanScheduledScheduledCloseDateMonthNum = MonthNum,
	LoanScheduledScheduledCloseDateMonthShortName = MonthShortName,
	LoanScheduledScheduledCloseDateMonthLongName = MonthLongName,
	LoanScheduledScheduledCloseDateDayNum = DayNum,
	LoanScheduledScheduledCloseDateDayOfWeekNum = DayOfWeekNum,
	LoanScheduledScheduledCloseDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	ScheduledCloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinLoanScheduledCloseDateKey AND Rng.MaxLoanScheduledCloseDateKey;
