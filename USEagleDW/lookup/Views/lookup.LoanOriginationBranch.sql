USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'LoanOriginationBranch')
	DROP VIEW lookup.LoanOriginationBranch;
GO


CREATE VIEW
	lookup.LoanOriginationBranch
AS
SELECT
	LoanOriginationBranchKey = BranchKey,
	LoanOriginationBranchNumber = BranchNumber,
	LoanOriginationBranchName = BranchName,
	LoanOriginationBranchNumberAndName = BranchNumberAndName,
	LoanOriginationBranchCategory = BranchCategory,
	LoanOriginationBranchCategoryOrder = BranchCategoryOrder,
	LoanOriginationBranchHiddenFlag = BranchHiddenFlag,
	LoanOriginationBranchSourceSystem = BranchSourceSystem,
	LoanOriginationBranchSourceID = BranchSourceID,
	LoanOriginationBranchHash = BranchHash,
	LoanOriginationBranchStartEffectiveDate = BranchStartEffectiveDate,
	LoanOriginationBranchEndEffectiveDate = BranchEndEffectiveDate,
	LoanOriginationBranchActiveRecordFlag = BranchActiveRecordFlag
FROM
	dim.Branch
WHERE
	BranchActiveRecordFlag = 'Y';
