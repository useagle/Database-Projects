USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'ShareOriginationBranch')
	DROP VIEW lookup.ShareOriginationBranch;
GO


CREATE VIEW
	lookup.ShareOriginationBranch
AS
SELECT
	ShareOriginationBranchKey = BranchKey,
	ShareOriginationBranchNumber = BranchNumber,
	ShareOriginationBranchName = BranchName,
	ShareOriginationBranchNumberAndName = BranchNumberAndName,
	ShareOriginationBranchCategory = BranchCategory,
	ShareOriginationBranchCategoryOrder = BranchCategoryOrder,
	ShareOriginationBranchHiddenFlag = BranchHiddenFlag,
	ShareOriginationBranchSourceSystem = BranchSourceSystem,
	ShareOriginationBranchSourceID = BranchSourceID,
	ShareOriginationBranchHash = BranchHash,
	ShareOriginationBranchStartEffectiveDate = BranchStartEffectiveDate,
	ShareOriginationBranchEndEffectiveDate = BranchEndEffectiveDate,
	ShareOriginationBranchActiveRecordFlag = BranchActiveRecordFlag
FROM
	dim.Branch
WHERE
	BranchActiveRecordFlag = 'Y';
