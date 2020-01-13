USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_StrategyCorps_ShareDrafts')
	DROP PROCEDURE dbo.USEagle_extract_StrategyCorps_ShareDrafts;
GO


CREATE PROCEDURE dbo.USEagle_extract_StrategyCorps_ShareDrafts

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <11/27/2018>    
-- Modify Date: 
-- Description:	<extract of share drafts>
-- ======================================================================

AS
BEGIN

	DECLARE @ProcessDateInt		INT;

	SELECT
		@ProcessDateInt = MAX(Dt.CalendarKey)
	FROM
		USEagleDW.dim.Calendar Dt
	WHERE
		Dt.MonthEndFlag = 'Y'
		AND
--		Dt.CalendarDate < CAST(SYSDATETIME() AS DATE);
		Dt.CalendarDate < '2018-11-30';


	WITH MonthEndDates AS
	(
		SELECT TOP 12
			ProcessDateInt = Dt.CalendarKey
		FROM
			USEagleDW.dim.Calendar Dt
		WHERE
			Dt.MonthEndFlag = 'Y'
			AND
	--		Dt.CalendarDate < CAST(SYSDATETIME() AS DATE);
			Dt.CalendarDate < '2018-11-30'
		ORDER BY
			Dt.CalendarKey DESC
	),
	AverageBalance AS
	(
		SELECT
			Share.PARENTACCOUNT,
			Share.ID,
			AverageBalance = AVG(Share.BALANCE)
		FROM
			ARCUSYM000.dbo.SAVINGS Share
				INNER JOIN
			MonthEndDates Dts
				ON Share.ProcessDate = Dts.ProcessDateInt
		GROUP BY
			Share.PARENTACCOUNT,
			Share.ID
	),
	Secondaries AS
	(
		SELECT
			Sec.PARENTACCOUNT,
			SecondaryName = ISNULL(RTRIM(Sec.FIRST) + ' ', '') + RTRIM(Sec.LAST),
			SecondaryTaxID = RTRIM(Sec.SSN),
			SecondaryOrder = ROW_NUMBER() OVER (PARTITION BY Sec.PARENTACCOUNT ORDER BY Sec.ORDINAL)
		FROM
			ARCUSYM000.dbo.NAME Sec
		WHERE
			Sec.ProcessDate = @ProcessDateInt
			AND
			Sec.TYPE = 1
			AND
			Sec.EXPIRATIONDATE IS NULL AND Sec.ProcessDate = @ProcessDateInt
	),
	OnlineRegistrations AS
	(
		SELECT
			Trk.PARENTACCOUNT,
			OnlineStatusFlag  =	CASE
									WHEN Trk.USERDATE10 IS NOT NULL THEN 'Y'
									ELSE 'N'
								END,
			BillPayStatusFlag =	CASE
									WHEN Trk.USERDATE3 IS NOT NULL AND Trk.USERDATE4 IS NULL THEN 'Y'
									ELSE 'N'
								END,
			RegistrationOrder = ROW_NUMBER() OVER (PARTITION BY Trk.PARENTACCOUNT ORDER BY Trk.CREATIONDATE)
		FROM
			ARCUSYM000.dbo.TRACKING Trk
		WHERE
			Trk.ProcessDate = @ProcessDateInt
			AND
			Trk.TYPE = 80
	)
	SELECT
		AccountNumber = Share.PARENTACCOUNT + '-' + RTRIM(Share.ID),
		AccountStatus =	CASE
							WHEN Share.CHARGEOFFDATE IS NOT NULL THEN 'CHARGED-OFF'
							WHEN Share.CLOSEDATE IS NOT NULL THEN 'CLOSED'
							ELSE 'OPEN'
						END,
		ProductOrTypeCode = Share.TYPE,
		ProductName = Share.DESCRIPTION,
		DateAccountOpened = CAST(Share.OPENDATE AS DATE),
		HouseholdOrPortfolioKey = '',
		Name = ISNULL(RTRIM(Prim.FIRST) + ' ', '') + RTRIM(Prim.LAST),
		Name2 = ISNULL(Sec.SecondaryName, ''),
		Name3 = ISNULL(Tert.SecondaryName, ''),
		TaxID = RTRIM(Prim.SSN),
		TaxID2 = ISNULL(Sec.SecondaryTaxID, ''),
		TaxID3 = ISNULL(Tert.SecondaryTaxID, ''),
		DateOfBirth = CAST(Prim.BIRTHDATE AS DATE),
		EmailAddress = ISNULL(Prim.EMAIL, ''),
		StreetAddress = ISNULL(RTRIM(Prim.STREET), ''),
		City = ISNULL(RTRIM(Prim.CITY), ''),
		State = ISNULL(RTRIM(Prim.STATE), ''),
		Zip = ISNULL(RTRIM(Prim.ZIPCODE), ''),
		MailingStreetAddress = ISNULL(RTRIM(Mail.STREET), ''),
		MailingCity = ISNULL(RTRIM(Mail.CITY), ''),
		MailingState = ISNULL(RTRIM(Mail.STATE), ''),
		MailingZip = ISNULL(RTRIM(Mail.ZIPCODE), ''),
		BranchCode = Share.BRANCH,
		RegionCode = '',
		ServiceChargeWaiverCode = '',
		PYTDorYTDAverageBalance = ISNULL(AvBal.AverageBalance, 0),
		PYTDorYTDInterestPaid = Share.DIVYTD,
		PYTDorYTDServiceCharge = '',
		PYTDorYTDServiceChargesWaived = '',
		PYTDorYTDServiceChargesRefunded = '',
		PYTDorYTDODNSFCharges = SHARE.NSFYTD + Share.COURTESYPAYYTD,
		PYTDorYTDODNSFChargesWaived = '',
		PYTDorYTDODNSFChargesRefunded = '',
		PYTDorYTDMiscFees = '',
		eStatementStatusFlag =	CASE
									WHEN Acct.ESTMTENABLE = 1 THEN 'Y'
									ELSE 'N'
								END,
		Reg.OnlineStatusFlag,
		Reg.BillPayStatusFlag,
		MobileBankingStatusFlag = '',
		POSTransactionsCount = ''
	FROM
		ARCUSYM000.dbo.SAVINGS Share
			INNER JOIN
		ARCUSYM000.dbo.ACCOUNT Acct
			ON Share.PARENTACCOUNT = Acct.ACCOUNTNUMBER AND Acct.ProcessDate = @ProcessDateInt
			LEFT JOIN
		ARCUSYM000.dbo.NAME Prim
			ON Share.PARENTACCOUNT = Prim.PARENTACCOUNT AND Prim.TYPE = 0 AND Prim.EXPIRATIONDATE IS NULL AND Prim.ProcessDate = @ProcessDateInt
			LEFT JOIN
		ARCUSYM000.dbo.NAME Mail
			ON Share.PARENTACCOUNT = Mail.PARENTACCOUNT AND Mail.TYPE = 2 AND Mail.EXPIRATIONDATE IS NULL AND Mail.ProcessDate = @ProcessDateInt
			LEFT JOIN
		AverageBalance AvBal
			ON Share.PARENTACCOUNT = AvBal.PARENTACCOUNT AND Share.ID = AvBal.ID 
			LEFT JOIN
		Secondaries Sec
			ON Share.PARENTACCOUNT = Sec.PARENTACCOUNT AND Sec.SecondaryOrder = 1
			LEFT JOIN
		Secondaries Tert
			ON Share.PARENTACCOUNT = Tert.PARENTACCOUNT AND Tert.SecondaryOrder = 2
			LEFT JOIN
		OnlineRegistrations Reg
			ON Share.PARENTACCOUNT = Reg.PARENTACCOUNT AND Reg.RegistrationOrder = 1
	WHERE
		Share.ProcessDate = @ProcessDateInt
		AND
		Share.SHARECODE = 1
		AND
		Acct.TYPE NOT IN (9, 10)
	ORDER BY
		Share.PARENTACCOUNT,
		Share.ID;

END;
GO


