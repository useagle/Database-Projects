USE USEagleDW;

IF EXISTS (SELECT * FROM sys.sysobjects WHERE name = 'Time')
	DROP TABLE dim.Time;


CREATE TABLE
	dim.Time
(
	TimeKey			INT NOT NULL,
	Time			VARCHAR(7) NOT NULL,
	Hour			VARCHAR(20) NOT NULL,
	HalfHour		VARCHAR(20) NOT NULL,
	QuarterHour		VARCHAR(20) NOT NULL
)

ALTER TABLE dim.Time ADD CONSTRAINT PK_Time PRIMARY KEY (TimeKey);


INSERT INTO
	dim.Time
SELECT
	TimeKey	= -1,
	Time = 'N/A',
	Hour = 'N/A',
	HalfHour = 'N/A',
	QuarterHour = 'N/A';


WITH Tally AS
(
	SELECT
		SequenceNumber = Tl.SequenceNumber - 1
	FROM
		Admin.dbo.Tally Tl
	WHERE
		Tl.SequenceNumber <= 1440
)
INSERT INTO
	dim.Time
(
	TimeKey,
	Time,
	Hour,
	HalfHour,
	QuarterHour
)
SELECT
	TimeKey = (100 * FLOOR(SequenceNumber / 60)) + SequenceNumber % 60,
	Time = CONVERT(VARCHAR(7), CAST(DATEADD(mi, Tally.SequenceNumber, '00:00') AS TIME), 100),
	Hour = CONVERT(VARCHAR(5), CAST(DATEADD(mi, Tally.SequenceNumber - Tally.SequenceNumber % 60, '00:00') AS TIME), 100)
		+ ' - ' + CONVERT(VARCHAR(7), CAST(DATEADD(mi, Tally.SequenceNumber + 59 - Tally.SequenceNumber % 60, '00:00') AS TIME), 100),
	HalfHour = CONVERT(VARCHAR(5), CAST(DATEADD(mi, Tally.SequenceNumber  - Tally.SequenceNumber % 30, '00:00') AS TIME), 100)
		+ ' - ' + CONVERT(VARCHAR(7), CAST(DATEADD(mi, Tally.SequenceNumber + 29 - Tally.SequenceNumber % 30, '00:00') AS TIME), 100),
	QuarterHour = CONVERT(VARCHAR(5), CAST(DATEADD(mi, Tally.SequenceNumber - Tally.SequenceNumber % 15, '00:00') AS TIME), 100)
		+ ' - ' + CONVERT(VARCHAR(7), CAST(DATEADD(mi, Tally.SequenceNumber + 14 - Tally.SequenceNumber % 15, '00:00') AS TIME), 100)
FROM
	Tally
ORDER BY
	TimeKey;


/*
UPDATE
	dim.Time
SET
	HourSortOrder = FLOOR(TimeKey / 100) + 1
WHERE
	TimeKey >= 0;


UPDATE
	dim.Time
SET
	HalfHourSortOrder = FLOOR(TimeKey / 100) * 2 + 1
			+ CASE WHEN TimeKey % 100 >= 30 THEN 1 ELSE 0 END
WHERE
	TimeKey >= 0;


UPDATE
	dim.Time
SET
	QuarterHourSortOrder = FLOOR(TimeKey / 100) * 4 + 1
							+	CASE
									WHEN TimeKey % 100 >= 45 THEN 3
									WHEN TimeKey % 100 >= 30 THEN 2
									WHEN TimeKey % 100 >= 15 THEN 1
									ELSE 0
								END
WHERE
	TimeKey >= 0;
*/
