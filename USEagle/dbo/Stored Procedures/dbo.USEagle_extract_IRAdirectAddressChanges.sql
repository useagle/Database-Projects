USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_IRAdirectAddressChanges')
	DROP PROCEDURE dbo.USEagle_extract_IRAdirectAddressChanges;
GO


CREATE PROCEDURE dbo.USEagle_extract_IRAdirectAddressChanges

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <04/19/2018>    
-- Modify Date: <05/07/2018>
-- Description:	<File maintenance for users based on funds availability category.> 
-- ======================================================================

AS
BEGIN

	DECLARE
		@MonthStartDate		DATE,
		@ProcessDateInt		INT;


	SELECT
		@ProcessDateInt = MAX(ProcessDate)
	FROM
		ARCUSYM000.dbo.SAVINGS;



	--	If run on the fifth calendar day of the month or before, the prcoedure will look for
	--	changes starting at the beginning of the previous month, otherwise it will look from the
	--	beginning of the current month.

	IF DAY(SYSDATETIME()) <= 5
		SET @MonthStartDate = DATEADD(mm, -1, DATEADD(dd, 1 - DAY(SYSDATETIME()), SYSDATETIME()));
	ELSE
		SET @MonthStartDate = DATEADD(dd, 1 - DAY(SYSDATETIME()), SYSDATETIME());



	--	The EligibleAccounts CTE returns all open shares with an IRS Code indicating an eligible
	--	IRA account.  This is then used by the Updates CTE to find all FM name updates for the
	--	pertinent fields for those accounts.  The RawData CTE then organizes this data into a form
	--	that can be pivoted to produce the appropriate fixed-width output.

	--	Note that the current data from the name record is used rather than the updated data from
	--	the name FM history table, as these updates cannot be tied back to specific name records.

	WITH EligibleAccounts AS
	(
		SELECT DISTINCT
			Share.PARENTACCOUNT,
			BatchCode =	CASE
							WHEN Share.IRSCODE IN ('01', '03') THEN 'T'		--	Traditional
							WHEN Share.IRSCODE IN ('06', '11') THEN 'R'		--	Roth
							WHEN Share.IRSCODE = '08' THEN 'E'				--	Coverdell ESA
							WHEN Share.IRSCODE IN ('14', '15') THEN 'H'		--	Health Savings Account
						END
		FROM
			ARCUSYM000.dbo.SAVINGS Share
		WHERE
			Share.ProcessDate = @ProcessDateInt
			AND
			Share.CLOSEDATE IS NULL
			AND
			Share.IRSCODE IN ('01', '03', '06', '08', '11', '14', '15')
	),
	Updates AS
	(
		SELECT
			AccountNumber = FM.PARENTACCOUNT,
			Acct.BatchCode,
			UpdateDate = FM.POSTDATE,
			UpdatedField = Lkup.[Field Name],
			UpdatedValue = FM.NEWCHARACTER
		FROM
			ARCUSYM000.dbo.FMHISTORY FM
				INNER JOIN
			EligibleAccounts Acct
				ON FM.PARENTACCOUNT = Acct.PARENTACCOUNT
				INNER JOIN
			ExternalMisc.dbo.FMFieldNumberNameLookup Lkup
				ON Lkup.FMHistoryRecordType = 2 AND FM.FIELDNUMBER = Lkup.FMHistoryFieldNumber AND FM.SUBFIELDNUMBER = Lkup.FMHistorySubFieldNumber
		WHERE
			FM.RECORDTYPE = 2		--	Name Record
			AND
			FM.POSTDATE >= @MonthStartDate
			AND
			(Lkup.[Field Name] = 'Street'
				OR
				Lkup.[Field Name] = 'City'
				OR
				Lkup.[Field Name] = 'State'
				OR
				Lkup.[Field Name] = 'Zip Code'
				OR
				Lkup.[Field Name] = 'Last Name/Non Indiv Name'
				OR
				Lkup.[Field Name] = 'Middle Name'
				OR
				Lkup.[Field Name] = 'First Name')
			AND
			FM.OLDCHARACTER IS NOT NULL
			AND
			FM.OLDCHARACTER <> '(NEW ACCOUNT)'
	),
	RawData AS
	(
		SELECT
			LastName = Nm.LAST,
			CurrentSSN = Nm.SSN,
			Country = Nm.COUNTRY,
			SignatureDate = Upd.UpdateDate,
			Upd.BatchCode,
			Upd.UpdatedField,
			UpdatedValue =	CASE
								WHEN Upd.UpdatedField = 'Street' THEN Nm.STREET
								WHEN Upd.UpdatedField = 'City' THEN Nm.CITY
								WHEN Upd.UpdatedField = 'State' THEN Nm.STATE
								WHEN Upd.UpdatedField = 'Zip Code' THEN Nm.ZIPCODE
								WHEN Upd.UpdatedField = 'Middle Name' THEN Nm.MIDDLE
								WHEN Upd.UpdatedField = 'First Name' THEN Nm.FIRST
							END
		FROM
			Updates Upd
				INNER JOIN
			ARCUSYM000.dbo.NAME Nm
				ON Upd.AccountNumber = Nm.PARENTACCOUNT AND Nm.TYPE = 0 AND Nm.ProcessDate = @ProcessDateInt
		WHERE
			Upd.UpdateDate = Nm.LASTFMDATE
	)
	SELECT
		SSN = CurrentSSN,
		FirstName = CAST(ISNULL([First Name], '') AS VARCHAR(30)),
		MiddleInitial = CAST(LEFT(ISNULL([Middle Name], ''), 1) AS VARCHAR(1)),
		LastName = CAST(LastName AS VARCHAR(30)),
		AddressLine1 = CAST(ISNULL([Street], '') AS VARCHAR(40)),
		AddressLine2 = '',
		City = CAST(ISNULL([City], '') AS VARCHAR(25)),
		State = CAST(ISNULL([State], '') AS VARCHAR(2)),
		ZipCode = CAST(LEFT(ISNULL([Zip Code], ''), 5) AS VARCHAR(5)),
		Country = CAST(ISNULL(Country, '') AS VARCHAR(25))
/*
		FixedWidthData = '23316'									--	CID
		+ CurrentSSN												--	Current SSN
		+ CAST(ISNULL([First Name], '') AS CHAR(30))				--	First Name
		+ CAST(LEFT(ISNULL([Middle Name], ''), 1) AS CHAR(1))		--	Middle Name
		+ CAST(LastName AS CHAR(30))								--	Last Name
		+ CAST(ISNULL([Street], '') AS CHAR(40))					--	Address 1
		+ SPACE(40)													--	Address 2
		+ CAST(ISNULL([City], '') AS CHAR(25))						--	City
		+ CAST(ISNULL([State], '') AS CHAR(2))						--	State
		+ CAST(LEFT(ISNULL([Zip Code], ''), 5) AS CHAR(5))			--	Zip
		+ REPLACE(CONVERT(CHAR(10), SignatureDate, 110), '-', '')	--	Signature Date
		+ BatchCode													--	
		+ CAST(ISNULL(Country, '') AS CHAR(25))						--	Country
*/
	FROM
		(SELECT * FROM RawData) AS SourceTable
	PIVOT
	(
		MAX(UpdatedValue)
		FOR UpdatedField IN ([Street], [City], [State], [Zip Code], [Middle Name], [First Name])
	) AS PivotTable
	ORDER BY
		LastName,
		BatchCode;

END;
GO
