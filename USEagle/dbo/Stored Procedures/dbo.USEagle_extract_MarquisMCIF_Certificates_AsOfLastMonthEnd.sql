USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_MarquisMCIF_Certificates_AsOfLastMonthEnd')
	DROP PROCEDURE dbo.USEagle_extract_MarquisMCIF_Certificates_AsOfLastMonthEnd;
GO


CREATE PROCEDURE dbo.USEagle_extract_MarquisMCIF_Certificates_AsOfLastMonthEnd

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <05/06/2019>    
-- Modify Date: 
-- Description:	<extract of certificate data for Marquis MCIF>
-- ======================================================================

AS
BEGIN

	DECLARE @ProcessDateInt	INT;

	SET @ProcessDateInt = CAST(CONVERT(VARCHAR(8), DATEADD(dd, -1 * DAY(SYSDATETIME()), CAST(SYSDATETIME() AS DATE)), 112) AS INT);


	WITH JointAccounts AS
	(
		SELECT
			Nm.PARENTACCOUNT,
			Nm.LAST,
			Nm.FIRST,
			Nm.MIDDLE,
			AccountOrder = 1 + ROW_NUMBER() OVER (PARTITION BY Nm.PARENTACCOUNT ORDER BY Nm.ORDINAL)
		FROM
			ARCUSYM000.dbo.NAME Nm
		WHERE
			Nm.ProcessDate = @ProcessDateInt
			AND
			Nm.TYPE = 1
			AND
			Nm.EXPIRATIONDATE IS NULL
	),
	MailingAddress AS
	(
		SELECT
			Mail.PARENTACCOUNT,
			Mail.STREET,
			Mail.CITY,
			Mail.STATE,
			Mail.ZIPCODE,
			MailOrder = ROW_NUMBER() OVER (PARTITION BY Mail.PARENTACCOUNT ORDER BY Mail.etlSurrogateKey)
		FROM
			ARCUSYM000.dbo.[NAME] Mail
		WHERE
			Mail.ProcessDate = @ProcessDateInt
			AND
			Mail.TYPE <> 0
			AND
			Mail.MAILOVERRIDE <> 0
			AND
			Mail.EXPIRATIONDATE IS NULL
	)
	SELECT
		Val = LEFT(RTRIM(Mem.PrimaryMemberFullName) + SPACE(75), 75)											--	Name #1 (Primary Member Full Name) (75, 1-75)
			+ LEFT(LTRIM(RTRIM(ISNULL(Sec.LAST, '')))
					+ CASE WHEN ISNULL(Sec.FIRST, '') <> '' THEN ', ' + LTRIM(RTRIM(Sec.FIRST)) ELSE '' END
					+ CASE WHEN ISNULL(Sec.MIDDLE, '') <> '' THEN ' ' + LTRIM(RTRIM(Sec.MIDDLE)) ELSE '' END
					+ SPACE(75), 75)																			--	Name #2 (Secondary Member Full Name) (75, 76-150)
			+ LEFT(LTRIM(RTRIM(ISNULL(Tert.LAST, '')))
					+ CASE WHEN ISNULL(Tert.FIRST, '') <> '' THEN ', ' + LTRIM(RTRIM(Tert.FIRST)) ELSE '' END
					+ CASE WHEN ISNULL(Tert.MIDDLE, '') <> '' THEN ' ' + LTRIM(RTRIM(Tert.MIDDLE)) ELSE '' END
					+ SPACE(75), 75)																			--	Name #3 (Tertiary Member Full Name) (75, 151-225)
			+ LEFT(RTRIM(ISNULL(Addr.STREET, Mem.MemberStreetAddress)) + SPACE(40), 40)							--	Address (Primary Member Mailing Address) (40, 226 - 265)
			+ LEFT(RTRIM(ISNULL(Addr.CITY, Mem.MemberCity)) + SPACE(40), 40)									--	City (Primary Member Mailing Address) (40, 266 - 305)
			+ LEFT(RTRIM(ISNULL(Addr.STATE, Mem.MemberState)) + SPACE(10), 10)									--	State (Primary Member Mailing Address) (10, 306 - 315)
			+ LEFT(RTRIM(ISNULL(Addr.ZIPCODE, Mem.MemberZipCode)) + SPACE(10), 10)								--	Zip+4 (Primary Member Mailing Address) (10, 316 - 325)
			+ LEFT(RTRIM(Mem.MemberEmail) + SPACE(40), 40)														--	Account Email (Primary Member Email) (40, 326 - 365)
			+ SPACE(16)																							--	<PHONE> (16, 366 - 381)
			+ ISNULL(CONVERT(VARCHAR(10), Mem.MemberBirthDate, 101), SPACE(10))									--	Holder Birth Date (Primary Member Birth Date) (10, 382 - 391)
			+ LEFT(RTRIM(ShDesc.ShareAccountNumber) + SPACE(16), 16)											--	Account Number (16, 392 - 407)
			+ SPACE(5)																							--	Account Number Part 2 (Primary Member Email) (5, 408 - 412)
			+ LEFT(RTRIM(Mem.MemberNumber) + SPACE(10), 10)														--	Customer Number (Member Number) (10, 413 - 422)
			+ LEFT(RTRIM(Nm.SSN) + SPACE(9), 9)																	--	Tax ID Number (Primary Member SSN) (9, 423 - 431)
			+ SPACE(1)																							--	Status Code (1, 432 - 432)
			+	CASE
					WHEN Sh.AccountTypeKey = -1 THEN SPACE(5)
					ELSE LEFT(Typ.AccountType, 1) + RIGHT('000' + CAST(Typ.ProductNumber AS VARCHAR), 4)	
				END																								--	Account Type Code (Product Number) (5, 433 - 437)
			+ SPACE(5)																							--	Account Type Code Part B (5, 438 - 442)
			+	CASE
					WHEN Typ.MarketingProductCategoryName = 'Business Checking' THEN 'B'
					ELSE 'R'
				END																								--	Business or Retail Flag (1, 443 - 443)
			+	CASE
					WHEN Sh.ShareOpenDateKey = -1 THEN SPACE(10)
					ELSE CONVERT(VARCHAR(10), CONVERT(DATE, CAST(Sh.ShareOpenDateKey AS VARCHAR), 112), 101)
				END																								--	Open Date (10, 444 - 453)
			+	CASE
					WHEN ShDtl.MATURITYDATE IS NULL THEN SPACE(10)
					ELSE CONVERT(VARCHAR(10), ShDtl.MATURITYDATE, 101)
				END																								--	Maturity Date (10, 454 - 463)
			+	CASE
					WHEN ShDtl.ACTIVITYDATE IS NULL THEN SPACE(10)
					ELSE CONVERT(VARCHAR(10), ShDtl.ACTIVITYDATE, 101)
				END																								--	Last Transaction Date (10, 464 - 473)
			+	CASE
					WHEN Sh.ShareOpenDateKey = -1 THEN SPACE(10)
					ELSE CONVERT(VARCHAR(10), CONVERT(DATE, CAST(Sh.ShareOpenDateKey AS VARCHAR), 112), 101)
				END																								--	Original Certificate Open Date (10, 474 - 483)
			+	CASE
					WHEN Sh.ShareOpenDateKey = -1 THEN SPACE(10)
					ELSE CONVERT(VARCHAR(10), CONVERT(DATE, CAST(Sh.ShareOpenDateKey AS VARCHAR), 112), 101)
				END																								--	Last Renewal Date (10, 484 - 493)
			+	CASE
					WHEN ShDtl.MATURITYDATE IS NULL THEN SPACE(10)
					ELSE CONVERT(VARCHAR(10), ShDtl.MATURITYDATE, 101)
				END																								--	Next Renewal Date (10, 494 - 503)
			+ ISNULL(RIGHT('000' + CAST(Brn.BranchNumber AS VARCHAR), 4), SPACE(4))								--	Branch Code (4, 504 - 507)
			+	CASE
					WHEN Usr.UserNumber < 0 THEN SPACE(4)
					ELSE ISNULL(RIGHT('000' + CAST(Usr.UserNumber AS VARCHAR), 4), SPACE(4))
				END																								--	Officer Code (4, 508 - 511)
			+ RIGHT(SPACE(11) + CAST(CAST(ISNULL(ShDtl.ORIGINALBALANCE, 0) AS DECIMAL(12, 2)) AS VARCHAR), 15)	--	Original Balance (15, 512 - 526) (right-justified)
			+ RIGHT(SPACE(11) + CAST(CAST(ISNULL(ShDtl.BALANCE, 0) AS DECIMAL(12, 2)) AS VARCHAR), 15)			--	Current Balance (15, 527 - 541) (right-justified)
			+ SPACE(3)																							--	Term (3, 542 - 544)
			+ RIGHT(SPACE(3) + CAST(CAST(ISNULL(ShDtl.DIVRATE, 0) / 1000 AS DECIMAL(7, 4)) AS VARCHAR), 7) + '%'			--	Rate (8, 545 - 556) (right-justified)
			+	CASE
					WHEN Mem.MemberTypeName = 'Employee' THEN 'Y'
					ELSE 'N'
				END																								--	Employee Flag (1, 557 - 557)
			+	Mem.MemberNoMailFlag																			--	No Mail Flag (1, 558 - 558)
			+	CASE	
					WHEN Nm.DEATHDATE IS NULL THEN SPACE(10)
					ELSE CONVERT(VARCHAR(10), Nm.DEATHDATE, 101)
				END																								--	Deceased Date (10, 559 - 568)
			+	Mem.MemberMarketingOptOutFlag																	--	Opt-Out Flag (1, 569 - 569)
			+	CASE
					WHEN Sh.ShareChargeOffDateKey < 0 THEN 'N'
					ELSE 'Y'
				END																								--	Charge-Off Flag (1, 570 - 570)
			+	CASE
					WHEN Sh.ShareChargeOffDateKey < 0 THEN SPACE(10)
					ELSE CONVERT(VARCHAR(10), CONVERT(DATE, CAST(Sh.ShareChargeOffDateKey AS VARCHAR), 112), 101)
				END																								--	Charge-Off Date (10, 571 - 580)
			+ Mem.MemberBankruptcyFlag																			--	Bankruptcy Flag (1, 581 - 581)
			+ Mem.MemberDelinquencyFlag																			--	Delinquency Flag (1, 582 - 582)
			+ SPACE(5)																							--	31-60 Day Delinquency (5, 583 - 587)
			+ SPACE(5)																							--	61-90 Day Delinquency (5, 588 - 592)
			+ SPACE(5)																							--	91-120 Day Delinquency (5, 593 - 597)
			+	CASE
					WHEN Addr.STREET IS NOT NULL THEN SPACE(40)
					ELSE LEFT(RTRIM(Mem.MemberStreetAddress) + SPACE(40), 40)
				END																								--	Address (Primary Member Mailing Address) (40, 598 - 637)
			+	CASE
					WHEN Addr.CITY IS NOT NULL THEN SPACE(40)
					ELSE LEFT(RTRIM(Mem.MemberCity) + SPACE(40), 40)
				END																								--	City (Primary Member Mailing Address) (40, 638 - 637)
			+	CASE
					WHEN Addr.STATE IS NOT NULL THEN SPACE(40)
					ELSE LEFT(RTRIM(Mem.MemberState) + SPACE(40), 40)
				END																								--	State (Primary Member Mailing Address) (10, 678 - 687)
			+	CASE
					WHEN Addr.ZIPCODE IS NOT NULL THEN SPACE(40)
					ELSE LEFT(RTRIM(Mem.MemberZipCode) + SPACE(40), 40)
				END																								--	Zip+4 (Primary Member Mailing Address) (10, 688 - 697)
	FROM
		USEagleDW.fact.CurrentShare Sh
			INNER JOIN
		USEagleDW.dim.AccountType Typ
			ON Sh.AccountTypeKey = Typ.AccountTypeKey
			INNER JOIN
		USEagleDW.dim.Branch Brn
			ON Sh.ShareBranchKey = Brn.BranchKey
			INNER JOIN
		USEagleDW.dim.ShareDescriptor ShDesc
			ON Sh.ShareDescriptorKey = ShDesc.ShareDescriptorKey
			INNER JOIN
		USEagleDW.dim.Member Mem
			ON Sh.MemberKey = Mem.MemberKey
			INNER JOIN
		USEagleDW.dim.[User] Usr
			ON Sh.OriginatedByUserKey = Usr.UserKey
			INNER JOIN
		Staging.arcusym000.dbo_NAME Nm
			ON Mem.MemberNumber = Nm.PARENTACCOUNT AND Nm.TYPE = 0		--	Staging load uses MAX(ProcessDate) for each member
			LEFT JOIN
		MailingAddress Addr
			ON Mem.MemberNumber = Addr.PARENTACCOUNT AND MailOrder = 1
			LEFT JOIN
		ARCUSYM000.dbo.SAVINGS ShDtl
			ON Mem.MemberNumber = ShDtl.PARENTACCOUNT And ShDesc.ShareID = ShDtl.ID AND ShDtl.ProcessDate = @ProcessDateInt
			LEFT JOIN
		JointAccounts Sec
			ON Mem.MemberNumber = Sec.PARENTACCOUNT AND Sec.AccountOrder = 2
			LEFT JOIN
		JointAccounts Tert
			ON Mem.MemberNumber = Tert.PARENTACCOUNT AND Tert.AccountOrder = 3
			LEFT JOIN
		Staging.business.TestAndCorporateMemberNumber Test
			ON Mem.MemberNumber = Test.MemberNumber
	WHERE
		Sh.ShareOpenDateKey <= @ProcessDateInt
		AND
		(Typ.ProductCategory2 = 'Share Certificates'
			OR
			Typ.ProductCategory3 = 'Certificates')
	ORDER BY
		Val;

END;
GO


