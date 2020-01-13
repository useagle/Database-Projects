USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'MemberCloseDate')
	DROP VIEW lookup.MemberCloseDate;
GO


CREATE VIEW
	lookup.MemberCloseDate
AS
WITH CloseDateRange AS
(
	SELECT
		MinMemberCloseDateKey = MIN(MemberCloseDateKey),
		MaxMemberCloseDateKey = MAX(MemberCloseDateKey)
	FROM
		fact.CurrentMember
	WHERE
		MemberCloseDateKey >= 19000101
)
SELECT
	MemberCloseDateKey = CalendarKey,
	MemberCloseDate = CalendarDate,
	MemberCloseDateString = CalendarDateString,
	MemberCloseDateYearNum = YearNum,
	MemberCloseDateQuarterNum = QuarterNum,
	MemberCloseDateQuarterShortName = QuarterShortName,
	MemberCloseDateQuarterLongName = QuarterLongName,
	MemberCloseDateMonthNum = MonthNum,
	MemberCloseDateMonthShortName = MonthShortName,
	MemberCloseDateMonthLongName = MonthLongName,
	MemberCloseDateDayNum = DayNum,
	MemberCloseDateDayOfWeekNum = DayOfWeekNum,
	MemberCloseDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	CloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinMemberCloseDateKey AND Rng.MaxMemberCloseDateKey;
