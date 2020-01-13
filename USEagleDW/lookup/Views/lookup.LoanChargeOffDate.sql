USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanChargeOffDate')
	DROP VIEW lookup.LoanChargeOffDate;
GO


CREATE VIEW
	lookup.LoanChargeOffDate
AS
WITH ChargeOffDateRange AS
(
	SELECT
		MinLoanChargeOffDateKey = MIN(LoanChargeOffDateKey),
		MaxLoanChargeOffDateKey = MAX(LoanChargeOffDateKey)
	FROM
		fact.CurrentLoan
	WHERE
		LoanChargeOffDateKey >= 19000101
)
SELECT
	LoanChargeOffDateKey = CalendarKey,
	LoanChargeOffDate = CalendarDate,
	LoanChargeOffDateString = CalendarDateString,
	LoanChargeOffDateYearNum = YearNum,
	LoanChargeOffDateQuarterNum = QuarterNum,
	LoanChargeOffDateQuarterShortName = QuarterShortName,
	LoanChargeOffDateQuarterLongName = QuarterLongName,
	LoanChargeOffDateMonthNum = MonthNum,
	LoanChargeOffDateMonthShortName = MonthShortName,
	LoanChargeOffDateMonthLongName = MonthLongName,
	LoanChargeOffDateDayNum = DayNum,
	LoanChargeOffDateDayOfWeekNum = DayOfWeekNum,
	LoanChargeOffDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	ChargeOffDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinLoanChargeOffDateKey AND Rng.MaxLoanChargeOffDateKey;
