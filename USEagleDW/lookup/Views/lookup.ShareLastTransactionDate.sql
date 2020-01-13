USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'ShareLastTransactionDate')
	DROP VIEW lookup.ShareLastTransactionDate;
GO


CREATE VIEW
	lookup.ShareLastTransactionDate
AS
WITH CloseDateRange AS
(
	SELECT
		MinShareLastTransactionDateKey = MIN(ShareLastTransactionDateKey),
		MaxShareLastTransactionDateKey = MAX(ShareLastTransactionDateKey)
	FROM
		fact.CurrentShare
	WHERE
		ShareLastTransactionDateKey >= 19000101
)
SELECT
	ShareLastTransactionDateKey = CalendarKey,
	ShareLastTransactionDate = CalendarDate,
	ShareLastTransactionDateString = CalendarDateString,
	ShareLastTransactionDateYearNum = YearNum,
	ShareLastTransactionDateQuarterNum = QuarterNum,
	ShareLastTransactionDateQuarterShortName = QuarterShortName,
	ShareLastTransactionDateQuarterLongName = QuarterLongName,
	ShareLastTransactionDateMonthNum = MonthNum,
	ShareLastTransactionDateMonthShortName = MonthShortName,
	ShareLastTransactionDateMonthLongName = MonthLongName,
	ShareLastTransactionDateDayNum = DayNum,
	ShareLastTransactionDateDayOfWeekNum = DayOfWeekNum,
	ShareLastTransactionDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	CloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinShareLastTransactionDateKey AND Rng.MaxShareLastTransactionDateKey;
