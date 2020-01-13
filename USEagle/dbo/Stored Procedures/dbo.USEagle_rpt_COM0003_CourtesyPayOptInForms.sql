USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_COM0003_CourtesyPayOptInForms')
	DROP PROCEDURE dbo.USEagle_rpt_COM0003_CourtesyPayOptInForms;
GO


CREATE PROCEDURE dbo.USEagle_rpt_COM0003_CourtesyPayOptInForms
(
	@ReportPeriodMonthEndDate	DATE,
	@OptInCategory				VARCHAR(10)
)

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <09/26/2017>    
-- Modify Date: 
-- Description:	<File maintenance for loans that were manually modified.> 
-- =============================================

AS
BEGIN

	DECLARE
		@ProcessDate	INT,
		@StartDate		DATE,
		@EndDate		DATE;


	SELECT
		@ProcessDate = MAX(ProcessDate)
	FROM
		ARCUSYM000.dbo.ACCOUNT;


	SELECT
		@StartDate = DATEADD(mm, -1, DATEADD(dd, 1, @ReportPeriodMonthEndDate)),
		@EndDate = @ReportPeriodMonthEndDate;


	WITH OptIn AS
	(
		SELECT DISTINCT
			AccountNumber = RIGHT(('000000000' + RTRIM(Opt.[ACCT NO])), 10),
			MemberName = Opt.NAME,
			DocumentDate = CAST(Opt.DATE AS DATE)
		FROM
			ExternalMisc.dbo.CPOptIn Opt
		WHERE
			CAST(Opt.DATE AS DATE) BETWEEN @StartDate AND @EndDate
	),
	ShareFM AS
	(
		SELECT DISTINCT
			AccountNumber = Share.ShareFMAccountNumber,
			MemberName =	CASE
								WHEN Acct.FIRST IS NULL THEN Acct.LAST
								WHEN Acct.MIDDLE IS NULL THEN Acct.FIRST + ' ' + Acct.LAST
								ELSE Acct.FIRST + ' ' + Acct.MIDDLE + ' ' + Acct.LAST
							END,
			BranchNumberAndName = CAST(Share.ShareFMBranch AS VARCHAR) + ' - ' + UPPER(Brn.BranchCategoryName),
			PostDate = Share.ShareFMPostDate,
			UserNumberAndName = CAST(Share.ShareFMUserNumber AS VARCHAR) + ' - ' + Cat.UserName
		FROM
			ARCUSYM000.arcu.vwARCUShareFMHistory Share
				INNER JOIN
			ARCUSYM000.dbo.NAME Acct
				ON Share.ShareFMAccountNumber = Acct.PARENTACCOUNT AND Acct.TYPE = 0 AND Acct.ProcessDate = @ProcessDate
				INNER JOIN
			ARCUSYM000.arcu.vwARCUBranchCategory Brn
				ON Share.ShareFMBranch = Brn.Branch
				LEFT JOIN
			ARCUSYM000.arcu.vwARCUUserCategory Cat
				ON Share.ShareFMUserNumber = Cat.UserNumber
		WHERE
			Share.ShareFMSubFieldNumber = 1
			AND
			Share.ShareFMFieldNumber = 173
			AND
			CAST(Share.ShareFMPostDate AS DATE) BETWEEN @StartDate AND @EndDate
			AND
			Share.ShareFMNewNumber = 0.00
	)
	SELECT
		OptInCategory = 'Opt In Matches Share FM',
		ShareFM.AccountNumber,
		ShareFM.MemberName,
		ShareFM.BranchNumberAndName,
		OptIn.DocumentDate,
		ShareFM.PostDate,
		ShareFM.UserNumberAndName
	FROM
		OptIn
			INNER JOIN
		ShareFM
			ON OptIn.AccountNumber = ShareFM.AccountNumber
	WHERE
		@OptInCategory LIKE ('%0%')
		AND
		DATEDIFF(mm, OptIn.DocumentDate, ShareFM.PostDate) = 0

	UNION ALL

	SELECT
		OptInCategory = 'Opt In Without Matching Share FM',
		OptIn.AccountNumber,
		OptIn.MemberName,
		ShareFM.BranchNumberAndName,
		OptIn.DocumentDate,
		ShareFM.PostDate,
		ShareFM.UserNumberAndName
	FROM
		OptIn
			LEFT JOIN
		ShareFM
			ON OptIn.AccountNumber = ShareFM.AccountNumber AND DATEDIFF(mm, OptIn.DocumentDate, ShareFM.PostDate) = 0
	WHERE
		@OptInCategory LIKE ('%1%')
		AND
		ShareFM.AccountNumber IS NULL

	UNION ALL

	SELECT
		OptInCategory = 'Share FM Without Matching Opt In',
		ShareFM.AccountNumber,
		ShareFM.MemberName,
		ShareFM.BranchNumberAndName,
		OptIn.DocumentDate,
		ShareFM.PostDate,
		ShareFM.UserNumberAndName
	FROM
		ShareFM
			LEFT JOIN
		OptIn
			ON ShareFM.AccountNumber = OptIn.AccountNumber AND DATEDIFF(mm, ShareFM.PostDate, OptIn.DocumentDate) = 0
	WHERE
		@OptInCategory  LIKE ('%2%')
		AND
		OptIn.AccountNumber IS NULL

	ORDER BY
		OptInCategory,
		ShareFM.AccountNumber,
		OptIn.DocumentDate,
		ShareFM.PostDate;

END;
GO


