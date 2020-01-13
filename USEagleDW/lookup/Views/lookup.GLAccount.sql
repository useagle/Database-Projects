USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'GLAccount')
	DROP VIEW lookup.GLAccount;
GO


CREATE VIEW
	lookup.GLAccount
AS
SELECT
	GLAccountKey,
	GLAccountNumber,
	GLAccountNumberCode,
	GLAccountSuffix,
	GLAccountBranchNumber,
	GLAccountBranchName,
	GLAccountBranchNumberAndName,
	GLAccountBranchCategory,
	GLAccountBranchCategoryOrder,
	GLAccountName,
	GLAccountSourceSystem,
	GLAccountSourceID,
	GLAccountHash,
	GLAccountStartEffectiveDate,
	GLAccountEndEffectiveDate,
	GLAccountActiveRecordFlag
FROM
	dim.GLAccount
WHERE
	GLAccountActiveRecordFlag = 'Y';
