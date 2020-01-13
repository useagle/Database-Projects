USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'SurveyDate')
	DROP VIEW lookup.SurveyDate;
GO


CREATE VIEW
	lookup.SurveyDate
AS
WITH CloseDateRange AS
(
	SELECT
		MinSurveyDateKey = MIN(SurveyDateKey),
		MaxSurveyDateKey = MAX(SurveyDateKey)
	FROM
		fact.TransactionSurvey
	WHERE
		SurveyDateKey >= 19000101
)
SELECT
	SurveyDateKey = CalendarKey,
	SurveyDate = CalendarDate,
	SurveyDateString = CalendarDateString,
	SurveyDateYearNum = YearNum,
	SurveyDateQuarterNum = QuarterNum,
	SurveyDateQuarterShortName = QuarterShortName,
	SurveyDateQuarterLongName = QuarterLongName,
	SurveyDateMonthNum = MonthNum,
	SurveyDateMonthShortName = MonthShortName,
	SurveyDateMonthLongName = MonthLongName,
	SurveyDateDayNum = DayNum,
	SurveyDateDayOfWeekNum = DayOfWeekNum,
	SurveyDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	CloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinSurveyDateKey AND Rng.MaxSurveyDateKey;
