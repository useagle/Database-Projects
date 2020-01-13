USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'ShareChargeOffDate')
	DROP VIEW lookup.ShareChargeOffDate;
GO


CREATE VIEW
	lookup.ShareChargeOffDate
AS
WITH ChargeOffDateRange AS
(
	SELECT
		MinShareChargeOffDateKey = MIN(ShareChargeOffDateKey),
		MaxShareChargeOffDateKey = MAX(ShareChargeOffDateKey)
	FROM
		fact.CurrentShare
	WHERE
		ShareChargeOffDateKey >= 19000101
)
SELECT
	ShareChargeOffDateKey = CalendarKey,
	ShareChargeOffDate = CalendarDate,
	ShareChargeOffDateString = CalendarDateString,
	ShareChargeOffDateYearNum = YearNum,
	ShareChargeOffDateQuarterNum = QuarterNum,
	ShareChargeOffDateQuarterShortName = QuarterShortName,
	ShareChargeOffDateQuarterLongName = QuarterLongName,
	ShareChargeOffDateMonthNum = MonthNum,
	ShareChargeOffDateMonthShortName = MonthShortName,
	ShareChargeOffDateMonthLongName = MonthLongName,
	ShareChargeOffDateDayNum = DayNum,
	ShareChargeOffDateDayOfWeekNum = DayOfWeekNum,
	ShareChargeOffDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	ChargeOffDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinShareChargeOffDateKey AND Rng.MaxShareChargeOffDateKey;
