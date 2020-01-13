USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'ShareDescriptor')
	DROP VIEW lookup.ShareDescriptor;
GO


CREATE VIEW
	lookup.ShareDescriptor
AS
SELECT
	ShareDescriptorKey = ShareDescriptorKey,
	ShareAccountNumber = ShareAccountNumber,
	ShareID = ShareID,
	ShareDescriptorSourceSystem = ShareDescriptorSourceSystem,
	ShareDescriptorSourceID = ShareDescriptorSourceID,
	ShareDescriptorHash = ShareDescriptorHash,
	ShareDescriptorStartEffectiveDate = ShareDescriptorStartEffectiveDate,
	ShareDescriptorEndEffectiveDate = ShareDescriptorEndEffectiveDate,
	ShareDescriptorActiveRecordFlag = ShareDescriptorActiveRecordFlag
FROM
	dim.ShareDescriptor;
