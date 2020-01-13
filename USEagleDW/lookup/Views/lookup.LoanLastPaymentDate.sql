USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanLastPaymentDate')
	DROP VIEW lookup.LoanLastPaymentDate;
GO


CREATE VIEW
	lookup.LoanLastPaymentDate
AS
WITH LastPaymentDateRange AS
(
	SELECT
		MinLoanLastPaymentDateKey = MIN(LoanLastPaymentDateKey),
		MaxLoanLastPaymentDateKey = MAX(LoanLastPaymentDateKey)
	FROM
		fact.CurrentLoan
	WHERE
		LoanLastPaymentDateKey >= 19000101
)
SELECT
	LoanLastPaymentDateKey = CalendarKey,
	LoanLastPaymentDate = CalendarDate,
	LoanLastPaymentDateString = CalendarDateString,
	LoanLastPaymentDateYearNum = YearNum,
	LoanLastPaymentDateQuarterNum = QuarterNum,
	LoanLastPaymentDateQuarterShortName = QuarterShortName,
	LoanLastPaymentDateQuarterLongName = QuarterLongName,
	LoanLastPaymentDateMonthNum = MonthNum,
	LoanLastPaymentDateMonthShortName = MonthShortName,
	LoanLastPaymentDateMonthLongName = MonthLongName,
	LoanLastPaymentDateDayNum = DayNum,
	LoanLastPaymentDateDayOfWeekNum = DayOfWeekNum,
	LoanLastPaymentDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	LastPaymentDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinLoanLastPaymentDateKey AND Rng.MaxLoanLastPaymentDateKey;
