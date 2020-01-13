USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'GLTransactionPostingDate')
	DROP VIEW lookup.GLTransactionPostingDate;
GO


CREATE VIEW
	lookup.GLTransactionPostingDate
AS
WITH CloseDateRange AS
(
	SELECT
		MinGLTransactionPostingDateKey = MIN(GLTransactionPostingDateKey),
		MaxGLTransactionPostingDateKey = MAX(GLTransactionPostingDateKey)
	FROM
		fact.GLTransaction
	WHERE
		GLTransactionPostingDateKey >= 19000101
)
SELECT
	GLTransactionPostingDateKey = CalendarKey,
	GLTransactionPostingDate = CalendarDate,
	GLTransactionPostingDateString = CalendarDateString,
	GLTransactionPostingDateYearNum = YearNum,
	GLTransactionPostingDateQuarterNum = QuarterNum,
	GLTransactionPostingDateQuarterShortName = QuarterShortName,
	GLTransactionPostingDateQuarterLongName = QuarterLongName,
	GLTransactionPostingDateMonthNum = MonthNum,
	GLTransactionPostingDateMonthShortName = MonthShortName,
	GLTransactionPostingDateMonthLongName = MonthLongName,
	GLTransactionPostingDateDayNum = DayNum,
	GLTransactionPostingDateDayOfWeekNum = DayOfWeekNum,
	GLTransactionPostingDateDayOfWeekName = DayOfWeekName
FROM
	dim.Calendar
		CROSS JOIN
	CloseDateRange Rng
WHERE
	CalendarKey = -1
	OR
	CalendarKey BETWEEN Rng.MinGLTransactionPostingDateKey AND Rng.MaxGLTransactionPostingDateKey;
