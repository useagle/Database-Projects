USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_CPorNSF')
	DROP PROCEDURE dbo.USEagle_extract_CPorNSF;
GO


CREATE PROCEDURE dbo.USEagle_extract_CPorNSF

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <12/11/2017>    
-- Modify Date: 
-- Description:	<File maintenance for users based on funds availability category.> 
-- ======================================================================

AS
BEGIN

	DECLARE
		@ProcessDateInt			INT,
		@TransactionStartDate	DATE;

	SELECT
		@ProcessDateInt = MAX(ProcessDate)
	FROM
		ARCUSYM000.dbo.SAVINGS;

	SET @TransactionStartDate = DATEADD(yy, -1, SYSDATETIME());


	WITH NSF_Or_CP AS
	(
		SELECT
			Txn.PARENTACCOUNT,
			Txn.PARENTID,
			CPCount = SUM(	CASE
								WHEN Txn.DESCRIPTION = 'Courtesy Pay Fee' THEN 1
								WHEN Txn.COMMENT LIKE '[%][%] Fee Waived: 0[34]%' THEN 1
								ELSE 0
							END),
			NSFCount = SUM(	CASE
								WHEN LEFT(Txn.Description, 7) = 'NSF Fee' THEN 1
								WHEN Txn.COMMENT LIKE '[%][%] Fee Waived: 0[12]%' THEN 1
								ELSE 0
							END)
		FROM
			ARCUSYM000.dbo.SAVINGSTRANSACTION Txn
		WHERE
			Txn.EFFECTIVEDATE >= @TransactionStartDate
			AND
			((Txn.ACTIONCODE = 'W'
				AND
				Txn.SOURCECODE = 'F'
				AND
				Txn.BALANCECHANGE < 0
				AND
				(Txn.DESCRIPTION = 'Courtesy Pay Fee'
					OR
					LEFT(Txn.Description, 7) = 'NSF Fee'))
				OR
				(Txn.COMMENTCODE = 1
				AND
				Txn.COMMENT LIKE '[%][%] Fee Waived: 0[1234]%'))
		GROUP BY
			Txn.PARENTACCOUNT,
			Txn.PARENTID
	)
	SELECT
		MemberNumber = Share.PARENTACCOUNT,
		AccountID = Share.ID,
		CPCount = ISNULL(NSF_Or_CP.CPCount, 0),
		NSFCount = ISNULL(NSF_Or_CP.NSFCount, 0)
	FROM
		ARCUSYM000.dbo.SAVINGS Share
			LEFT JOIN
		NSF_Or_CP
			ON Share.PARENTACCOUNT = NSF_Or_CP.PARENTACCOUNT AND Share.ID = NSF_Or_CP.PARENTID
	WHERE
		Share.ProcessDate = @ProcessDateInt
		AND
		Share.CLOSEDATE IS NULL
		AND
		Share.SHARECODE IN (0, 1)
	ORDER BY
		1, 2;

END;
GO


