USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'MemberBranch')
	DROP VIEW lookup.MemberBranch;
GO


CREATE VIEW
	lookup.MemberBranch
AS
SELECT
	MemberBranchKey = BranchKey,
	MemberBranchNumber = BranchNumber,
	MemberBranchName = BranchName,
	MemberBranchNumberAndName = BranchNumberAndName,
	MemberBranchCategory = BranchCategory,
	MemberBranchCategoryOrder = BranchCategoryOrder,
	MemberBranchHiddenFlag = BranchHiddenFlag,
	MemberBranchSourceSystem = BranchSourceSystem,
	MemberBranchSourceID = BranchSourceID,
	MemberBranchHash = BranchHash,
	MemberBranchStartEffectiveDate = BranchStartEffectiveDate,
	MemberBranchEndEffectiveDate = BranchEndEffectiveDate,
	MemberBranchActiveRecordFlag = BranchActiveRecordFlag
FROM
	dim.Branch
WHERE
	BranchActiveRecordFlag = 'Y';
