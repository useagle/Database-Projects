USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanStatus')
	DROP VIEW lookup.LoanStatus;
GO


CREATE VIEW
	lookup.LoanStatus
AS
SELECT
	LoanStatusKey = AccountStatusKey,
	LoanStatusNumber = AccountStatusNumber,
	LoanStatusName = AccountStatusName,
	LoanStatusNumberAndName = AccountStatusNumberAndName,
	LoanStatusSourceSystem = AccountStatusSourceSystem,
	LoanStatusSourceID = AccountStatusSourceID,
	LoanStatusHash = AccountStatusHash,
	LoanStatusStartEffectiveDate = AccountStatusStartEffectiveDate,
	LoanStatusEndEffectiveDate = AccountStatusEndEffectiveDate,
	LoanStatusActiveRecordFlag = AccountStatusActiveRecordFlag
FROM
	dim.AccountStatus;
