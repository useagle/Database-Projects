USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'ShareOpenDate')
	DROP VIEW lookup.ShareOpenDate;
GO


CREATE VIEW
	lookup.ShareOpenDate
AS
WITH OpenDateRange AS
(
	SELECT
		MinShareOpenDateKey = MIN(ShareOpenDateKey),
		MaxShareOpenDateKey = MAX(ShareOpenDateKey)
	FROM
		fact.CurrentShare
	WHERE
		ShareOpenDateKey >= 19000101
)
SELECT
	ShareOpenDateKey = CalendarKey,
	ShareOpenDate = CalendarDate,
	ShareOpenDateString = CalendarDateString,
	ShareOpenDateYearNum = YearNum,
	ShareOpenDateQuarterNum = QuarterNum,
	ShareOpenDateQuarterShortName = QuarterShortName,
	ShareOpenDateQuarterLongName = QuarterLongName,
	ShareOpenDateMonthNum = MonthNum,
	ShareOpenDateMonthShortName = MonthShortName,
	ShareOpenDateMonthLongName = MonthLongName,
	ShareOpenDateDayNum = DayNum,
	ShareOpenDateDayOfWeekNum = DayOfWeekNum,
	ShareOpenDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	OpenDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinShareOpenDateKey AND Rng.MaxShareOpenDateKey;
