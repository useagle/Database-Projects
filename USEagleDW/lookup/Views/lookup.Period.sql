USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'Period')
	DROP VIEW lookup.Period;
GO


CREATE VIEW
	lookup.Period
AS
WITH PeriodRange AS
(
	SELECT
		PeriodKey = -1

	UNION

	SELECT
		PeriodKey = Dt.CalendarKey
	FROM
		USEagleDW.dim.Calendar Dt
	WHERE
		Dt.CalendarKey >= 20160331
		AND
		Dt.CalendarKey <= (SELECT MAX(ProcessDate) FROM Staging.arcusym000.dbo_GLACCOUNT)
)
SELECT
	PeriodKey = Dt.CalendarKey,
	PeriodDate = Dt.CalendarDate,
	PeriodString = Dt.CalendarDateString,
	PeriodYearNum = Dt.YearNum,
	PeriodQuarterNum = Dt.QuarterNum,
	PeriodQuarterShortName = Dt.QuarterShortName,
	PeriodQuarterLongName = Dt.QuarterLongName,
	PeriodMonthNum = Dt.MonthNum,
	PeriodMonthShortName = Dt.MonthShortName,
	PeriodMonthLongName = Dt.MonthLongName,
	PeriodDayNum = Dt.DayNum,
	PeriodDayOfWeekNum = Dt.DayOfWeekNum,
	PeriodDayOfWeekName = Dt.DayOfWeekName
FROM
	dim.Calendar Dt
		INNER JOIN
	PeriodRange Rng
		ON Dt.CalendarKey = Rng.PeriodKey;

