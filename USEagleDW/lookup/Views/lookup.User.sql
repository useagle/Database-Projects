USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'User')
	DROP VIEW lookup.[User];
GO


CREATE VIEW
	lookup.[User]
AS
SELECT
	UserKey = UserKey,
	UserNumber = UserNumber,
	UserName = UserName,
	UserNumberAndName = UserNumberAndName,
	UserSourceSystem = UserSourceSystem,
	UserSourceID = UserSourceID,
	UserCheckSum = UserCheckSum,
	UserStartEffectiveDate = UserStartEffectiveDate,
	UserEndEffectiveDate = UserEndEffectiveDate,
	UserActiveRecordFlag = UserActiveRecordFlag
FROM
	dim.[User]
WHERE
	UserActiveRecordFlag = 'Y';
