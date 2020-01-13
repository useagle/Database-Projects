USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'TransactionDate')
	DROP VIEW lookup.TransactionDate;
GO


CREATE VIEW
	lookup.TransactionDate
AS
WITH CloseDateRange AS
(
	SELECT
		MinTransactionDateKey = MIN(TransactionDateKey),
		MaxTransactionDateKey = MAX(TransactionDateKey)
	FROM
		fact.[Transaction]
	WHERE
		TransactionDateKey >= 19000101
)
SELECT
	TransactionDateKey = CalendarKey,
	TransactionDate = CalendarDate,
	TransactionDateString = CalendarDateString,
	TransactionDateYearNum = YearNum,
	TransactionDateQuarterNum = QuarterNum,
	TransactionDateQuarterShortName = QuarterShortName,
	TransactionDateQuarterLongName = QuarterLongName,
	TransactionDateMonthNum = MonthNum,
	TransactionDateMonthShortName = MonthShortName,
	TransactionDateMonthLongName = MonthLongName,
	TransactionDateDayNum = DayNum,
	TransactionDateDayOfWeekNum = DayOfWeekNum,
	TransactionDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	CloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinTransactionDateKey AND Rng.MaxTransactionDateKey;
