USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'AccountDescriptor')
	DROP VIEW lookup.AccountDescriptor;
GO


CREATE VIEW
	lookup.AccountDescriptor
AS
SELECT
	AccountDescriptorKey,
	AccountCloseReason,
	AccountCloseReasonRaw,
	AccountCloseReasonText,
	AccountNumber,
	AccountPrimaryName,
	AccountStatus,
	AccountTypeNumber,
	AccountTypeName,
	AccountTypeNumberAndName,
	AccountTypeCategory1,
	AccountTypeCategory2,
	AccountTypeCategory3,
	AccountDescriptorSourceSystem,
	AccountDescriptorSourceID,
	AccountDescriptorHash,
	AccountDescriptorStartEffectiveDate,
	AccountDescriptorEndEffectiveDate,
	AccountDescriptorActiveRecordFlag
FROM
	dim.AccountDescriptor
WHERE
	AccountDescriptorActiveRecordFlag = 'Y';
