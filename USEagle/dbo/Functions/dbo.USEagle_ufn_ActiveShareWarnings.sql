USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_ufn_ActiveShareWarnings')
	DROP FUNCTION dbo.USEagle_ufn_ActiveShareWarnings;
GO


CREATE FUNCTION dbo.USEagle_ufn_ActiveShareWarnings
(
	@ProcessDateInt		INT
)
RETURNS @ActiveShareWarnings TABLE
(
	ParentAccountNumber		VARCHAR(10),
	AccountID				CHAR(4),
	ShareChargeOffDate		DATE,
	ShareCloseDate			DATE,
	WarningCode1			SMALLINT,
	WarningCode2			SMALLINT,
	WarningCode3			SMALLINT,
	WarningCode4			SMALLINT,
	WarningCode5			SMALLINT,
	WarningCode6			SMALLINT,
	WarningCode7			SMALLINT,
	WarningCode8			SMALLINT,
	WarningCode9			SMALLINT,
	WarningCode10			SMALLINT,
	WarningCode11			SMALLINT,
	WarningCode12			SMALLINT,
	WarningCode13			SMALLINT,
	WarningCode14			SMALLINT,
	WarningCode15			SMALLINT,
	WarningCode16			SMALLINT,
	WarningCode17			SMALLINT,
	WarningCode18			SMALLINT,
	WarningCode19			SMALLINT,
	WarningCode20			SMALLINT
)

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <12/13/2017>    
-- Modify Date: 
-- Description:	<File maintenance for users that were manually modified.> 
-- ======================================================================

AS
BEGIN

	DECLARE @ProcessDate	SMALLDATETIME;
	SET @ProcessDate = CAST(CAST(@ProcessDateInt AS VARCHAR) AS SMALLDATETIME);


	INSERT INTO
		@ActiveShareWarnings
	(
		ParentAccountNumber,
		AccountID,
		ShareChargeOffDate,
		ShareCloseDate,
		WarningCode1,
		WarningCode2,
		WarningCode3,
		WarningCode4,
		WarningCode5,
		WarningCode6,
		WarningCode7,
		WarningCode8,
		WarningCode9,
		WarningCode10,
		WarningCode11,
		WarningCode12,
		WarningCode13,
		WarningCode14,
		WarningCode15,
		WarningCode16,
		WarningCode17,
		WarningCode18,
		WarningCode19,
		WarningCode20
	)
	SELECT
		ParentAccountNumber = Share.PARENTACCOUNT,
		AccountID = Share.ID,
		ShareChargeOffDate = CAST(Share.CHARGEOFFDATE AS DATE),
		ShareCloseDate = CAST(Share.CLOSEDATE AS DATE),
		WarningCode1 =	CASE
							WHEN Share.WARNINGEXPIRATION1 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE1
						END,
		WarningCode2 =	CASE
							WHEN Share.WARNINGEXPIRATION2 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE2
						END,
		WarningCode3 =	CASE
							WHEN Share.WARNINGEXPIRATION3 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE3
						END,
		WarningCode4 =	CASE
							WHEN Share.WARNINGEXPIRATION4 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE4
						END,
		WarningCode5 =	CASE
							WHEN Share.WARNINGEXPIRATION5 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE5
						END,
		WarningCode6 =	CASE
							WHEN Share.WARNINGEXPIRATION6 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE6
						END,
		WarningCode7 =	CASE
							WHEN Share.WARNINGEXPIRATION7 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE7
						END,
		WarningCode8 =	CASE
							WHEN Share.WARNINGEXPIRATION8 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE8
						END,
		WarningCode9 =	CASE
							WHEN Share.WARNINGEXPIRATION9 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE9
						END,
		WarningCode10 =	CASE
							WHEN Share.WARNINGEXPIRATION10 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE10
						END,
		WarningCode11 =	CASE
							WHEN Share.WARNINGEXPIRATION11 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE11
						END,
		WarningCode12 =	CASE
							WHEN Share.WARNINGEXPIRATION12 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE12
						END,
		WarningCode13 =	CASE
							WHEN Share.WARNINGEXPIRATION13 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE13
						END,
		WarningCode14 =	CASE
							WHEN Share.WARNINGEXPIRATION14 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE14
						END,
		WarningCode15 =	CASE
							WHEN Share.WARNINGEXPIRATION15 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE15
						END,
		WarningCode16 =	CASE
							WHEN Share.WARNINGEXPIRATION16 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE16
						END,
		WarningCode17 =	CASE
							WHEN Share.WARNINGEXPIRATION17 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE17
						END,
		WarningCode18 =	CASE
							WHEN Share.WARNINGEXPIRATION18 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE18
						END,
		WarningCode19 =	CASE
							WHEN Share.WARNINGEXPIRATION19 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE19
						END,
		WarningCode20 =	CASE
							WHEN Share.WARNINGEXPIRATION20 < @ProcessDate THEN 0
							ELSE Share.WARNINGCODE20
						END
	FROM
		ARCUSYM000.dbo.SAVINGS Share
	WHERE
		Share.ProcessDate = @ProcessDateInt;

	RETURN;

END;
GO


