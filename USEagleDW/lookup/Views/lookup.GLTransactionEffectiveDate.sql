USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'GLTransactionEffectiveDate')
	DROP VIEW lookup.GLTransactionEffectiveDate;
GO


CREATE VIEW
	lookup.GLTransactionEffectiveDate
AS
WITH CloseDateRange AS
(
	SELECT
		MinGLTransactionEffectiveDateKey = MIN(GLTransactionEffectiveDateKey),
		MaxGLTransactionEffectiveDateKey = MAX(GLTransactionEffectiveDateKey)
	FROM
		fact.GLTransaction
	WHERE
		GLTransactionEffectiveDateKey >= 19000101
)
SELECT
	GLTransactionEffectiveDateKey = CalendarKey,
	GLTransactionEffectiveDate = CalendarDate,
	GLTransactionEffectiveDateString = CalendarDateString,
	GLTransactionEffectiveDateYearNum = YearNum,
	GLTransactionEffectiveDateQuarterNum = QuarterNum,
	GLTransactionEffectiveDateQuarterShortName = QuarterShortName,
	GLTransactionEffectiveDateQuarterLongName = QuarterLongName,
	GLTransactionEffectiveDateMonthNum = MonthNum,
	GLTransactionEffectiveDateMonthShortName = MonthShortName,
	GLTransactionEffectiveDateMonthLongName = MonthLongName,
	GLTransactionEffectiveDateDayNum = DayNum,
	GLTransactionEffectiveDateDayOfWeekNum = DayOfWeekNum,
	GLTransactionEffectiveDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	CloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinGLTransactionEffectiveDateKey AND Rng.MaxGLTransactionEffectiveDateKey;
