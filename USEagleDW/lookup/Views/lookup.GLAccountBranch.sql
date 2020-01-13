USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'GLAccountBranch')
	DROP VIEW lookup.GLAccountBranch;
GO


CREATE VIEW
	lookup.GLAccountBranch
AS
SELECT
	GLAccountBranchKey = BranchKey,
	GLAccountBranchNumber = BranchNumber,
	GLAccountBranchName = BranchName,
	GLAccountBranchNumberAndName = BranchNumberAndName,
	GLAccountBranchCategory = BranchCategory,
	GLAccountBranchCategoryOrder = BranchCategoryOrder,
	GLAccountBranchHiddenFlag = BranchHiddenFlag,
	GLAccountBranchSourceSystem = BranchSourceSystem,
	GLAccountBranchSourceID = BranchSourceID,
	GLAccountBranchHash = BranchHash,
	GLAccountBranchStartEffectiveDate = BranchStartEffectiveDate,
	GLAccountBranchEndEffectiveDate = BranchEndEffectiveDate,
	GLAccountBranchActiveRecordFlag = BranchActiveRecordFlag
FROM
	dim.Branch
WHERE
	BranchActiveRecordFlag = 'Y';
