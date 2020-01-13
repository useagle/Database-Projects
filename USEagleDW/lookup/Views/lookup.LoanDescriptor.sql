USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanDescriptor')
	DROP VIEW lookup.LoanDescriptor;
GO


CREATE VIEW
	lookup.LoanDescriptor
AS
SELECT
	LoanDescriptorKey = LoanDescriptorKey,
	LoanAccountNumber = LoanAccountNumber,
	LoanDescription = LoanDescription,
	LoanID = LoanID,
	LoanIsIndirectFlag = LoanIsIndirectFlag,
	LoanTerm = LoanTerm,
	LoanDescriptorSourceSystem = LoanDescriptorSourceSystem,
	LoanDescriptorSourceID = LoanDescriptorSourceID,
	LoanDescriptorHash = LoanDescriptorHash,
	LoanDescriptorStartEffectiveDate = LoanDescriptorStartEffectiveDate,
	LoanDescriptorEndEffectiveDate = LoanDescriptorEndEffectiveDate,
	LoanDescriptorActiveRecordFlag = LoanDescriptorActiveRecordFlag
FROM
	dim.LoanDescriptor;
