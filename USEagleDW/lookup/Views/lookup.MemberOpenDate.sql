USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'MemberOpenDate')
	DROP VIEW lookup.MemberOpenDate;
GO


CREATE VIEW
	lookup.MemberOpenDate
AS
WITH OpenDateRange AS
(
	SELECT
		MinMemberOpenDateKey = MIN(MemberOpenDateKey),
		MaxMemberOpenDateKey = MAX(MemberOpenDateKey)
	FROM
		fact.CurrentMember
	WHERE
		MemberOpenDateKey >= 19000101
)
SELECT
	MemberOpenDateKey = CalendarKey,
	MemberOpenDate = CalendarDate,
	MemberOpenDateString = CalendarDateString,
	MemberOpenDateYearNum = YearNum,
	MemberOpenDateQuarterNum = QuarterNum,
	MemberOpenDateQuarterShortName = QuarterShortName,
	MemberOpenDateQuarterLongName = QuarterLongName,
	MemberOpenDateMonthNum = MonthNum,
	MemberOpenDateMonthShortName = MonthShortName,
	MemberOpenDateMonthLongName = MonthLongName,
	MemberOpenDateDayNum = DayNum,
	MemberOpenDateDayOfWeekNum = DayOfWeekNum,
	MemberOpenDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	OpenDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinMemberOpenDateKey AND Rng.MaxMemberOpenDateKey;
