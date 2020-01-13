USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'ShareBranch')
	DROP VIEW lookup.ShareBranch;
GO


CREATE VIEW
	lookup.ShareBranch
AS
SELECT
	ShareBranchKey = BranchKey,
	ShareBranchNumber = BranchNumber,
	ShareBranchName = BranchName,
	ShareBranchNumberAndName = BranchNumberAndName,
	ShareBranchCategory = BranchCategory,
	ShareBranchCategoryOrder = BranchCategoryOrder,
	ShareBranchHiddenFlag = BranchHiddenFlag,
	ShareBranchSourceSystem = BranchSourceSystem,
	ShareBranchSourceID = BranchSourceID,
	ShareBranchHash = BranchHash,
	ShareBranchStartEffectiveDate = BranchStartEffectiveDate,
	ShareBranchEndEffectiveDate = BranchEndEffectiveDate,
	ShareBranchActiveRecordFlag = BranchActiveRecordFlag
FROM
	dim.Branch
WHERE
	BranchActiveRecordFlag = 'Y';
