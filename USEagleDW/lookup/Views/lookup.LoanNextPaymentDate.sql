USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanNextPaymentDate')
	DROP VIEW lookup.LoanNextPaymentDate;
GO


CREATE VIEW
	lookup.LoanNextPaymentDate
AS
WITH NextPaymentDateRange AS
(
	SELECT
		MinLoanNextPaymentDateKey = MIN(LoanNextPaymentDateKey),
		MaxLoanNextPaymentDateKey = MAX(LoanNextPaymentDateKey)
	FROM
		fact.CurrentLoan
	WHERE
		LoanNextPaymentDateKey >= 19000101
)
SELECT
	LoanNextPaymentDateKey = CalendarKey,
	LoanNextPaymentDate = CalendarDate,
	LoanNextPaymentDateString = CalendarDateString,
	LoanNextPaymentDateYearNum = YearNum,
	LoanNextPaymentDateQuarterNum = QuarterNum,
	LoanNextPaymentDateQuarterShortName = QuarterShortName,
	LoanNextPaymentDateQuarterLongName = QuarterLongName,
	LoanNextPaymentDateMonthNum = MonthNum,
	LoanNextPaymentDateMonthShortName = MonthShortName,
	LoanNextPaymentDateMonthLongName = MonthLongName,
	LoanNextPaymentDateDayNum = DayNum,
	LoanNextPaymentDateDayOfWeekNum = DayOfWeekNum,
	LoanNextPaymentDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	NextPaymentDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinLoanNextPaymentDateKey AND Rng.MaxLoanNextPaymentDateKey;
