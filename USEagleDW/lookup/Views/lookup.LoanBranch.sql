USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanBranch')
	DROP VIEW lookup.LoanBranch;
GO


CREATE VIEW
	lookup.LoanBranch
AS
SELECT
	LoanBranchKey = BranchKey,
	LoanBranchNumber = BranchNumber,
	LoanBranchName = BranchName,
	LoanBranchNumberAndName = BranchNumberAndName,
	LoanBranchCategory = BranchCategory,
	LoanBranchCategoryOrder = BranchCategoryOrder,
	LoanBranchHiddenFlag = BranchHiddenFlag,
	LoanBranchSourceSystem = BranchSourceSystem,
	LoanBranchSourceID = BranchSourceID,
	LoanBranchHash = BranchHash,
	LoanBranchStartEffectiveDate = BranchStartEffectiveDate,
	LoanBranchEndEffectiveDate = BranchEndEffectiveDate,
	LoanBranchActiveRecordFlag = BranchActiveRecordFlag
FROM
	dim.Branch
WHERE
	BranchActiveRecordFlag = 'Y';
