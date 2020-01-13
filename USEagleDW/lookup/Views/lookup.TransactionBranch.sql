USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'TransactionBranch')
	DROP VIEW lookup.TransactionBranch;
GO


CREATE VIEW
	lookup.TransactionBranch
AS
SELECT
	TransactionBranchKey = BranchKey,
	TransactionBranchNumber = BranchNumber,
	TransactionBranchName = BranchName,
	TransactionBranchNumberAndName = BranchNumberAndName,
	TransactionBranchCategory = BranchCategory,
	TransactionBranchCategoryOrder = BranchCategoryOrder,
	TransactionBranchHiddenFlag = BranchHiddenFlag,
	TransactionBranchSourceSystem = BranchSourceSystem,
	TransactionBranchSourceID = BranchSourceID,
	TransactionBranchHash = BranchHash,
	TransactionBranchStartEffectiveDate = BranchStartEffectiveDate,
	TransactionBranchEndEffectiveDate = BranchEndEffectiveDate,
	TransactionBranchActiveRecordFlag = BranchActiveRecordFlag
FROM
	dim.Branch
WHERE
	BranchActiveRecordFlag = 'Y';
