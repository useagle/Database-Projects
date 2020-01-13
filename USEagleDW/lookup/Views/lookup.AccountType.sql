USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'AccountType')
	DROP VIEW lookup.AccountType;
GO


CREATE VIEW
	lookup.AccountType
AS
SELECT
	AccountTypeKey = AccountTypeKey,
	AccountType = AccountType,
	ProductNumber = ProductNumber,
	ProductName = ProductName,
	ProductNumberAndName = ProductNumberAndName,
	ProductSortOrder = ProductSortOrder,
	ProductCategory1 = ProductCategory1,
	ProductCategory2 = ProductCategory2,
	ProductCategory3 = ProductCategory3,
	ProductCategory4 = ProductCategory4,
	ProductCategory5 = ProductCategory5,
	MarketingProductCategoryName = MarketingProductCategoryName,
	MarketingProductCategoryAbbreviation = MarketingProductCategoryAbbreviation,
	ParticipationPortionFlag = ParticipationPortionFlag,
	ParticipationPortionFlagSortOrder = ParticipationPortionFlagSortOrder,
	AccountTypeSourceSystem = AccountTypeSourceSystem,
	AccountTypeSourceID = AccountTypeSourceID,
	AccountTypeHash = AccountTypeHash,
	AccountTypeStartEffectiveDate = AccountTypeStartEffectiveDate,
	AccountTypeEndEffectiveDate = AccountTypeEndEffectiveDate,
	AccountTypeActiveRecordFlag = AccountTypeActiveRecordFlag
FROM
	dim.AccountType;
