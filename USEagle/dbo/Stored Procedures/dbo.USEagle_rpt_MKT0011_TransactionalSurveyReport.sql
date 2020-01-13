USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_MBR0001_WarningCodeReport')
	DROP PROCEDURE dbo.USEagle_rpt_MBR0001_WarningCodeReport;
GO


CREATE PROCEDURE dbo.USEagle_rpt_MBR0001_WarningCodeReport
(
	@WarningCode						INT,
	@WarningCodeExpired					VARCHAR(5),
	@WarningCodeStartPostDate			DATE = NULL,
	@WarningCodeEndPostDate				DATE = NULL,
	@WarningCodeStartExpirationDate		DATE = NULL,
	@WarningCodeEndExpirationDate		DATE = NULL
)

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <03/14/2019>    
-- Modify Date: 
-- Description:	<Warning code history.> 
-- ======================================================================

AS
BEGIN

	IF @WarningCodeStartPostDate IS NULL
		SET @WarningCodeStartPostDate = '2014-01-01';


	IF @WarningCodeEndPostDate IS NULL
		SET @WarningCodeEndPostDate = '2099-12-31';


	IF @WarningCodeStartExpirationDate IS NULL
		SET @WarningCodeStartExpirationDate = @WarningCodeStartPostDate;


	IF @WarningCodeEndExpirationDate IS NULL
		SET @WarningCodeEndExpirationDate = '2099-12-31';


	WITH WarningCodeList AS
	(
		SELECT
			WarningCode = SequenceNumber
		FROM
			Admin.dbo.Tally
		WHERE
			SequenceNumber IN (2, 4, 5, 8, 9, 13, 14, 15, 16, 18, 22, 28, 30, 31, 32, 33, 36, 37, 40, 41, 42, 44, 45, 46, 47, 48, 49, 53, 54, 55, 56, 57, 61)
	),
	WarningCodes AS
	(
		SELECT
			Hist.PARENTACCOUNT,
			Hist.POSTDATE,
			Hist.FIELDNUMBER,
			Hist.SUBFIELDNUMBER,
			WarningCode = CAST(100 * CAST(Hist.NEWNUMBER AS DECIMAL(4, 2)) AS INT)
		FROM
			ARCUSYM000.dbo.FMHISTORY Hist
		WHERE
			Hist.FIELDNUMBER = 10
			AND
			Hist.SUBFIELDNUMBER > 0
			AND
			Hist.POSTDATE >= @WarningCodeStartPostDate
			AND
			Hist.POSTDATE <= @WarningCodeEndPostDate
	),
	WarningCodeExpirations AS
	(
		SELECT
			Hist.PARENTACCOUNT,
			Hist.POSTDATE,
			Hist.FIELDNUMBER,
			Hist.SUBFIELDNUMBER,
			WarningExpiration =	CAST(Hist.NEWDATE AS DATE)
		FROM
			ARCUSYM000.dbo.FMHISTORY Hist
		WHERE
			Hist.FIELDNUMBER = 17
			AND
			Hist.SUBFIELDNUMBER > 0
			AND
			CAST(Hist.NEWDATE AS DATE) >= @WarningCodeStartExpirationDate
			AND
			CAST(Hist.NEWDATE AS DATE) <= @WarningCodeEndExpirationDate
	)
	SELECT
		*
	FROM
		WarningCodes Code
			INNER JOIN
		WarningCodeList List
			ON Code.WarningCode = List.WarningCode
			LEFT JOIN
		WarningCodeExpirations Exp
			ON Code.PARENTACCOUNT = Exp.PARENTACCOUNT AND Code.SUBFIELDNUMBER = Exp.SUBFIELDNUMBER
	WHERE
		(Code.WarningCode = @WarningCode
			OR
			@WarningCode = -1)

END;
GO
