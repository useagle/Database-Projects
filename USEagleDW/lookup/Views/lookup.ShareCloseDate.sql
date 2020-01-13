USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'ShareCloseDate')
	DROP VIEW lookup.ShareCloseDate;
GO


CREATE VIEW
	lookup.ShareCloseDate
AS
WITH CloseDateRange AS
(
	SELECT
		MinShareCloseDateKey = MIN(ShareCloseDateKey),
		MaxShareCloseDateKey = MAX(ShareCloseDateKey)
	FROM
		fact.CurrentShare
	WHERE
		ShareCloseDateKey >= 19000101
)
SELECT
	ShareCloseDateKey = CalendarKey,
	ShareCloseDate = CalendarDate,
	ShareCloseDateString = CalendarDateString,
	ShareCloseDateYearNum = YearNum,
	ShareCloseDateQuarterNum = QuarterNum,
	ShareCloseDateQuarterShortName = QuarterShortName,
	ShareCloseDateQuarterLongName = QuarterLongName,
	ShareCloseDateMonthNum = MonthNum,
	ShareCloseDateMonthShortName = MonthShortName,
	ShareCloseDateMonthLongName = MonthLongName,
	ShareCloseDateDayNum = DayNum,
	ShareCloseDateDayOfWeekNum = DayOfWeekNum,
	ShareCloseDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	CloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinShareCloseDateKey AND Rng.MaxShareCloseDateKey;
