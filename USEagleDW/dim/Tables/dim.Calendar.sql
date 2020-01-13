USE USEagleDW;
GO


--	Create Calendar dimension
IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND  name = 'Calendar')
	DROP TABLE dim.Calendar;


CREATE TABLE
	dim.Calendar
(
	CalendarKey			INT NOT NULL,
	CalendarDate		DATE NULL,
	CalendarDateString	CHAR(10) NOT NULL,
	YearNum				SMALLINT NOT NULL,
	QuarterNum			SMALLINT NOT NULL,
	QuarterShortName	CHAR(2) NOT NULL,
	QuarterLongName		CHAR(7) NOT NULL,
	MonthNum			SMALLINT NOT NULL,
	MonthShortName		VARCHAR(3) NOT NULL,
	MonthLongName		VARCHAR(10) NOT NULL,
	DayNum				SMALLINT NOT NULL,
	DayOfWeekNum		SMALLINT NOT NULL,
	DayOfWeekName		VARCHAR(10) NOT NULL,
	MonthEndFlag		CHAR(1) NOT NULL
);

ALTER TABLE dim.Calendar ADD CONSTRAINT PK_Calendar PRIMARY KEY (CalendarKey);


--	Populate Calendar dimension
INSERT INTO dim.Calendar
(CalendarKey, CalendarDate, CalendarDateString, YearNum, QuarterNum, QuarterShortName, QuarterLongName, MonthNum, MonthShortName, MonthLongName, DayNum, DayOfWeekNum, DayOfWeekName, MonthEndFlag)
VALUES (-1, NULL, 'Unknown', 0, 0, 'Q0', 'Q0 0000', 0, 'N/A', 'N/A', 0, 0, 'N/A', 'N')


DECLARE
	@StartDate		DATE,
	@EndDate		DATE;


SET @StartDate = '1900-01-01';
SET @EndDate = '2099-12-31';


WITH Tally(SequenceNumber) AS
(
	SELECT
		ROW_NUMBER() OVER (ORDER BY t1.SequenceNumber)
	FROM
		Admin.dbo.Tally t1
			CROSS JOIN
		Admin.dbo.Tally t2
)
INSERT INTO
	dim.Calendar
(
	CalendarKey,
	CalendarDate,
	CalendarDateString,
	YearNum,
	QuarterNum,
	QuarterShortName,
	QuarterLongName,
	MonthNum,
	MonthShortName,
	MonthLongName,
	DayNum,
	DayOfWeekNum,
	DayOfWeekName,
	MonthEndFlag
)
SELECT
	CalendarKey = CAST(10000 * DATEPART(yyyy,   DATEADD(dd, t.SequenceNumber - 1, @StartDate)  )
				+ 100 * DATEPART(mm,   DATEADD(dd, t.SequenceNumber - 1, @StartDate)  )
				+ DATEPART(dd, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS INT),
	CalendarDate = DATEADD(dd, t.SequenceNumber - 1, @StartDate),
	CalendarDateString = CONVERT(CHAR(10), DATEADD(dd, t.SequenceNumber - 1, @StartDate), 120),
	YearNum = CAST(DATEPART(yyyy,   DATEADD(dd, t.SequenceNumber - 1, @StartDate)  ) AS SMALLINT),
	QuarterNum = CAST(DATENAME(quarter, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS SMALLINT),
	QuarterShortName = CAST ('Q' + CAST(DATENAME(quarter, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR(3)) AS CHAR(2)),
	QuarterLongName = CAST(CAST(DATEPART(yyyy, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR) + ' Q'
					+ CAST(DATENAME(quarter, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR(3)) AS CHAR(7)),
	MonthNum = CAST(MONTH(DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS SMALLINT),
	MonthShortName = CAST(DATENAME(month, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR(3)),
	MonthLongName = CAST(DATENAME(month, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR(10)),
	DayNum = CAST(DAY(DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS SMALLINT),
	DayOfWeekNum = CAST(DATEPART(dw, (DATEADD(dd, t.SequenceNumber - 1, @StartDate))) AS SMALLINT),
	DayOfWeekName = CAST(DATENAME(dw, (DATEADD(dd, t.SequenceNumber - 1, @StartDate))) AS VARCHAR(10)),
	MonthEndFlag =	CASE
						WHEN DAY(DATEADD(dd, t.SequenceNumber, @StartDate)) = 1 THEN 'Y'
						ELSE 'N'
					END
FROM
	Tally t
WHERE
	t.SequenceNumber <= DATEDIFF(dd, @StartDate, @EndDate) + 1
ORDER BY
	t.SequenceNumber;
