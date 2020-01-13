USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_ufn_ActiveAccountWarnings')
	DROP FUNCTION dbo.USEagle_ufn_ActiveAccountWarnings;
GO


CREATE FUNCTION dbo.USEagle_ufn_ActiveAccountWarnings
(
	@ProcessDateInt		INT
)
RETURNS @ActiveLoanWarnings TABLE
(
	AccountNumber		VARCHAR(10),
	AccountCloseDate	DATE,
	WarningCode1		SMALLINT,
	WarningCode2		SMALLINT,
	WarningCode3		SMALLINT,
	WarningCode4		SMALLINT,
	WarningCode5		SMALLINT,
	WarningCode6		SMALLINT,
	WarningCode7		SMALLINT,
	WarningCode8		SMALLINT,
	WarningCode9		SMALLINT,
	WarningCode10		SMALLINT,
	WarningCode11		SMALLINT,
	WarningCode12		SMALLINT,
	WarningCode13		SMALLINT,
	WarningCode14		SMALLINT,
	WarningCode15		SMALLINT,
	WarningCode16		SMALLINT,
	WarningCode17		SMALLINT,
	WarningCode18		SMALLINT,
	WarningCode19		SMALLINT,
	WarningCode20		SMALLINT
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
		@ActiveLoanWarnings
	(
		AccountNumber,
		AccountCloseDate,
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
		AccountNumber = Acct.ACCOUNTNUMBER,
		AccountCloseDate = CAST(Acct.CLOSEDATE AS DATE),
		WarningCode1 =	CASE
							WHEN Acct.WARNINGEXPIRATION1 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE1
						END,
		WarningCode2 =	CASE
							WHEN Acct.WARNINGEXPIRATION2 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE2
						END,
		WarningCode3 =	CASE
							WHEN Acct.WARNINGEXPIRATION3 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE3
						END,
		WarningCode4 =	CASE
							WHEN Acct.WARNINGEXPIRATION4 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE4
						END,
		WarningCode5 =	CASE
							WHEN Acct.WARNINGEXPIRATION5 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE5
						END,
		WarningCode6 =	CASE
							WHEN Acct.WARNINGEXPIRATION6 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE6
						END,
		WarningCode7 =	CASE
							WHEN Acct.WARNINGEXPIRATION7 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE7
						END,
		WarningCode8 =	CASE
							WHEN Acct.WARNINGEXPIRATION8 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE8
						END,
		WarningCode9 =	CASE
							WHEN Acct.WARNINGEXPIRATION9 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE9
						END,
		WarningCode10 =	CASE
							WHEN Acct.WARNINGEXPIRATION10 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE10
						END,
		WarningCode11 =	CASE
							WHEN Acct.WARNINGEXPIRATION11 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE11
						END,
		WarningCode12 =	CASE
							WHEN Acct.WARNINGEXPIRATION12 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE12
						END,
		WarningCode13 =	CASE
							WHEN Acct.WARNINGEXPIRATION13 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE13
						END,
		WarningCode14 =	CASE
							WHEN Acct.WARNINGEXPIRATION14 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE14
						END,
		WarningCode15 =	CASE
							WHEN Acct.WARNINGEXPIRATION15 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE15
						END,
		WarningCode16 =	CASE
							WHEN Acct.WARNINGEXPIRATION16 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE16
						END,
		WarningCode17 =	CASE
							WHEN Acct.WARNINGEXPIRATION17 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE17
						END,
		WarningCode18 =	CASE
							WHEN Acct.WARNINGEXPIRATION18 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE18
						END,
		WarningCode19 =	CASE
							WHEN Acct.WARNINGEXPIRATION19 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE19
						END,
		WarningCode20 =	CASE
							WHEN Acct.WARNINGEXPIRATION20 < @ProcessDate THEN 0
							ELSE Acct.WARNINGCODE20
						END
	FROM
		ARCUSYM000.dbo.ACCOUNT Acct
	WHERE
		Acct.ProcessDate = @ProcessDateInt;

	RETURN;

END;
GO
