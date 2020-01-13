USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'ApprovedByUser')
	DROP VIEW lookup.ApprovedByUser;
GO


CREATE VIEW
	lookup.ApprovedByUser
AS
SELECT
	ApprovedByUserKey = UserKey,
	ApprovedByUserNumber = UserNumber,
	ApprovedByUserName = UserName,
	ApprovedByUserNumberAndName = UserNumberAndName,
	ApprovedByUserSourceSystem = UserSourceSystem,
	ApprovedByUserSourceID = UserSourceID,
	ApprovedByUserCheckSum = UserCheckSum,
	ApprovedByUserStartEffectiveDate = UserStartEffectiveDate,
	ApprovedByUserEndEffectiveDate = UserEndEffectiveDate,
	ApprovedByUserActiveRecordFlag = UserActiveRecordFlag
FROM
	dim.[User]
WHERE
	UserActiveRecordFlag = 'Y';
