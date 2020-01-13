USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_ufn_ActiveLoanWarnings')
	DROP FUNCTION dbo.USEagle_ufn_ActiveLoanWarnings;
GO


CREATE FUNCTION dbo.USEagle_ufn_ActiveLoanWarnings
(
	@ProcessDateInt		INT
)
RETURNS @ActiveLoanWarnings TABLE
(
	ParentAccountNumber		VARCHAR(10),
	AccountID				CHAR(4),
	LoanChargeOffDate		DATE,
	LoanCloseDate			DATE,
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
		@ActiveLoanWarnings
	(
		ParentAccountNumber,
		AccountID,
		LoanChargeOffDate,
		LoanCloseDate,
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
		ParentAccountNumber = Ln.PARENTACCOUNT,
		AccountID = Ln.ID,
		LoanChargeOffDate = CAST(Ln.CHARGEOFFDATE AS DATE),
		LoanCloseDate = CAST(Ln.CLOSEDATE AS DATE),
		WarningCode1 =	CASE
							WHEN Ln.WARNINGEXPIRATION1 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE1
						END,
		WarningCode2 =	CASE
							WHEN Ln.WARNINGEXPIRATION2 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE2
						END,
		WarningCode3 =	CASE
							WHEN Ln.WARNINGEXPIRATION3 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE3
						END,
		WarningCode4 =	CASE
							WHEN Ln.WARNINGEXPIRATION4 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE4
						END,
		WarningCode5 =	CASE
							WHEN Ln.WARNINGEXPIRATION5 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE5
						END,
		WarningCode6 =	CASE
							WHEN Ln.WARNINGEXPIRATION6 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE6
						END,
		WarningCode7 =	CASE
							WHEN Ln.WARNINGEXPIRATION7 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE7
						END,
		WarningCode8 =	CASE
							WHEN Ln.WARNINGEXPIRATION8 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE8
						END,
		WarningCode9 =	CASE
							WHEN Ln.WARNINGEXPIRATION9 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE9
						END,
		WarningCode10 =	CASE
							WHEN Ln.WARNINGEXPIRATION10 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE10
						END,
		WarningCode11 =	CASE
							WHEN Ln.WARNINGEXPIRATION11 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE11
						END,
		WarningCode12 =	CASE
							WHEN Ln.WARNINGEXPIRATION12 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE12
						END,
		WarningCode13 =	CASE
							WHEN Ln.WARNINGEXPIRATION13 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE13
						END,
		WarningCode14 =	CASE
							WHEN Ln.WARNINGEXPIRATION14 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE14
						END,
		WarningCode15 =	CASE
							WHEN Ln.WARNINGEXPIRATION15 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE15
						END,
		WarningCode16 =	CASE
							WHEN Ln.WARNINGEXPIRATION16 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE16
						END,
		WarningCode17 =	CASE
							WHEN Ln.WARNINGEXPIRATION17 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE17
						END,
		WarningCode18 =	CASE
							WHEN Ln.WARNINGEXPIRATION18 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE18
						END,
		WarningCode19 =	CASE
							WHEN Ln.WARNINGEXPIRATION19 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE19
						END,
		WarningCode20 =	CASE
							WHEN Ln.WARNINGEXPIRATION20 < @ProcessDate THEN 0
							ELSE Ln.WARNINGCODE20
						END
	FROM
		ARCUSYM000.dbo.LOAN Ln
	WHERE
		Ln.ProcessDate = @ProcessDateInt;

	RETURN;

END;
GO


