USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'AccountBranch')
	DROP VIEW lookup.AccountBranch;
GO


CREATE VIEW
	lookup.AccountBranch
AS
SELECT
	AccountBranchKey = BranchKey,
	AccountBranchNumber = BranchNumber,
	AccountBranchName = BranchName,
	AccountBranchNumberAndName = BranchNumberAndName,
	AccountBranchCategory = BranchCategory,
	AccountBranchCategoryOrder = BranchCategoryOrder,
	AccountBranchHiddenFlag = BranchHiddenFlag,
	AccountBranchSourceSystem = BranchSourceSystem,
	AccountBranchSourceID = BranchSourceID,
	AccountBranchHash = BranchHash,
	AccountBranchStartEffectiveDate = BranchStartEffectiveDate,
	AccountBranchEndEffectiveDate = BranchEndEffectiveDate,
	AccountBranchActiveRecordFlag = BranchActiveRecordFlag
FROM
	dim.Branch
WHERE
	BranchActiveRecordFlag = 'Y';
