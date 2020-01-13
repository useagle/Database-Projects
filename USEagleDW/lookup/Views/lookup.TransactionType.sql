USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'TransactionType')
	DROP VIEW lookup.TransactionType;
GO


CREATE VIEW
	lookup.TransactionType
AS
SELECT
	TransactionTypeKey = TransactionTypeKey,
	TransactionAccountType = TransactionAccountType,
	TransactionActionCode = TransactionActionCode,
	TransactionActionName = TransactionActionName,
	TransactionSourceCode = TransactionSourceCode,
	TransactionSourceName = TransactionSourceName,
	TransactionTypeSourceSystem = TransactionTypeSourceSystem,
	TransactionTypeSourceID = TransactionTypeSourceID,
	TransactionTypeHash = TransactionTypeHash,
	TransactionTypeStartEffectiveDate = TransactionTypeStartEffectiveDate,
	TransactionTypeEndEffectiveDate = TransactionTypeEndEffectiveDate,
	TransactionTypeActiveRecordFlag = TransactionTypeActiveRecordFlag
FROM
	dim.TransactionType;
