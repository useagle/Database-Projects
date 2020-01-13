USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'OriginatedByUser')
	DROP VIEW lookup.OriginatedByUser;
GO


CREATE VIEW
	lookup.OriginatedByUser
AS
SELECT
	OriginatedByUserKey = UserKey,
	OriginatedByUserNumber = UserNumber,
	OriginatedByUserName = UserName,
	OriginatedByUserNumberAndName = UserNumberAndName,
	OriginatedByUserSourceSystem = UserSourceSystem,
	OriginatedByUserSourceID = UserSourceID,
	OriginatedByUserCheckSum = UserCheckSum,
	OriginatedByUserStartEffectiveDate = UserStartEffectiveDate,
	OriginatedByUserEndEffectiveDate = UserEndEffectiveDate,
	OriginatedByUserActiveRecordFlag = UserActiveRecordFlag
FROM
	dim.[User]
WHERE
	UserActiveRecordFlag = 'Y';
