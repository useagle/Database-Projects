USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'TransactionTime')
	DROP VIEW lookup.TransactionTime;
GO


CREATE VIEW
	lookup.TransactionTime
AS
SELECT
	TransactionTimeKey = Tm.TimeKey,
	TransactionTime = Tm.Time,
	TransactionTimeHour = Tm.Hour,
	TransactionTimeHourSortOrder = Tm.HourSortOrder,
	TransactionTimeHalfHour = Tm.HalfHour,
	TransactionTimeHalfHourSortOrder = Tm.HalfHourSortOrder,
	TransactionTimeQuarterHour = Tm.QuarterHour,
	TransactionTimeQuarterHourSortOrder = Tm.QuarterHourSortOrder
FROM
	dim.Time Tm;
