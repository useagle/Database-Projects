USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'TransactionDescriptor')
	DROP VIEW lookup.TransactionDescriptor;
GO


CREATE VIEW
	lookup.TransactionDescriptor
AS
SELECT
	TransactionDescriptorKey,
	TransactionConsoleNumber,
	TransactionParentID,
	TransactionSequenceNumber,
	TransactionDescriptorSourceSystem,
	TransactionDescriptorSourceID,
	TransactionDescriptorHash,
	TransactionDescriptorStartEffectiveDate,
	TransactionDescriptorEndEffectiveDate,
	TransactionDescriptorActiveRecordFlag
FROM
	dim.TransactionDescriptor
WHERE
	TransactionDescriptorActiveRecordFlag = 'Y';
