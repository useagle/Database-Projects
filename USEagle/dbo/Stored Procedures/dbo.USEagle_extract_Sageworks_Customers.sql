USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_extract_Sageworks_Customers')
	DROP PROCEDURE dbo.USEagle_extract_Sageworks_Customers;
GO


CREATE PROCEDURE dbo.USEagle_extract_Sageworks_Customers

-- ======================================================================
-- Author:		<Nilam Keval>
-- Create date: <08/10/2018>    
-- Modify Date: <11/15/2018>	CJH
-- Description:	<extract of Business Customers>
-- ======================================================================

AS
BEGIN

	DECLARE @ProcessDateInt		INT;

	SELECT
		@ProcessDateInt = ProcessDate
	FROM
		ARCUSYM000.dbo.ufnARCUGetLatestProcessDate();


	WITH Loans AS
	(
		SELECT
			Ln.AccountNumber,
			Ln.LoanCreatedByUser,
			Ln.LoanCreatedByUserName,
			LoanOrder = ROW_NUMBER() OVER (PARTITION BY Ln.AccountNumber ORDER BY Ln.LoanOpenDate)
		FROM
			ARCUSYM000.arcu.vwARCULoan Ln
		WHERE
			Ln.ProcessDate = @ProcessDateInt
	)
	SELECT
		ExtractDate = Acct.ProcessDate,
		UniqueID = CONCAT(RIGHT(Acct.AccountNumber, 7), Nm.NameOrdinal),
		MemberNumber = Acct.ACCOUNTNUMBER,
		NameType = Nm.NameType,
		NameTypeDesc = Nm.NameTypeDescription,
		FirstName = Nm.NameFirst,
		LastName = Nm.NameLast,
		AccountType = Nm.NameSSNType,
		AccountTypeDesc = Nm.NameSSNTypeDescription,
		Address1 = Nm.NameStreet,
		City = Nm.NameCity,
		ZipCode = LEFT(Nm.NameZipcode, 5),
		Phone =	ISNULL(Nm.NameWorkPhone, Nm.NameHomePhone),
		Mobile = Nm.NameMobilePhone,
		Email = Nm.NameEmail,
		TaxID = Nm.NameSSN,
		Branch = Acct.AccountBranch,
		BranchDesc = Acct.AccountBranchExtraAddress,
		EmployeeNumber = Acct.AccountCreatedByUser,
		EmployeeName = Acct.AccountCreatedByUserName
	FROM
		ARCUSYM000.arcu.vwARCUAccount Acct
			INNER JOIN
		ARCUSYM000.arcu.vwARCUName Nm 
			ON Nm.ProcessDate = @ProcessDateInt AND Acct.AccountNumber = Nm.AccountNumber AND Nm.NameType NOT IN (2, 4)
			LEFT JOIN
		Loans
			ON Acct.ACCOUNTNUMBER = Loans.AccountNumber AND Loans.LoanOrder = 1
	WHERE
		Acct.ProcessDate = @ProcessDateInt
		AND
		Acct.AccountType = 9 
		AND
		Acct.AccountCloseDate IS NULL
	ORDER BY
		UniqueID;

END;
GO


