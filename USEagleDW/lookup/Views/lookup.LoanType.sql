USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanType')
	DROP VIEW lookup.LoanType;
GO


CREATE VIEW
	lookup.LoanType
AS
SELECT
	LoanTypeKey = LoanTypeKey,
	LoanTypeNumber = LoanTypeNumber,
	LoanTypeName = LoanTypeName,
	LoanTypeNumberAndName = LoanTypeNumberAndName,
	LoanTypeSourceSystem = LoanTypeSourceSystem,
	LoanTypeSourceID = LoanTypeSourceID,
	LoanTypeCheckSum = LoanTypeCheckSum,
	LoanTypeStartEffectiveDate = LoanTypeStartEffectiveDate,
	LoanTypeEndEffectiveDate = LoanTypeEndEffectiveDate,
	LoanTypeActiveRecordFlag = LoanTypeActiveRecordFlag
FROM
	dim.LoanType;
