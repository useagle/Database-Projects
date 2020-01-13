USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'ShareStatus')
	DROP VIEW lookup.ShareStatus;
GO


CREATE VIEW
	lookup.ShareStatus
AS
SELECT
	ShareStatusKey = AccountStatusKey,
	ShareStatusNumber = AccountStatusNumber,
	ShareStatusName = AccountStatusName,
	ShareStatusNumberAndName = AccountStatusNumberAndName,
	ShareStatusSourceSystem = AccountStatusSourceSystem,
	ShareStatusSourceID = AccountStatusSourceID,
	ShareStatusHash = AccountStatusHash,
	ShareStatusStartEffectiveDate = AccountStatusStartEffectiveDate,
	ShareStatusEndEffectiveDate = AccountStatusEndEffectiveDate,
	ShareStatusActiveRecordFlag = AccountStatusActiveRecordFlag
FROM
	dim.AccountStatus;
