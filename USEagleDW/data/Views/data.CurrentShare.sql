USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'data' AND name = 'CurrentShare')
	DROP VIEW data.CurrentShare;
GO


CREATE VIEW
	data.CurrentShare
AS
SELECT
	ShareKey = ShareKey,
	AccountTypeKey = AccountTypeKey,
	MemberKey = MemberKey,
	MemberBranchKey = MemberBranchKey,
	OriginatedByUserKey = OriginatedByUserKey,
	ShareBranchKey = ShareBranchKey,
	ShareChargeOffDateKey = ShareChargeOffDateKey,
	ShareCloseDateKey = ShareCloseDateKey,
	ShareDescriptorKey = ShareDescriptorKey,
	ShareLastTransactionDateKey = ShareLastTransactionDateKey,
	ShareOpenDateKey = ShareOpenDateKey,
	ShareOriginationBranchKey = ShareOriginationBranchKey,
	ShareStatusKey = ShareStatusKey,
	ChargedOffShareCount = ChargedOffShareCount,
	ClosedShareCount = ClosedShareCount,
	ShareAvailableBalance = ShareAvailableBalance,
	ShareChargeOffAmount = ShareChargeOffAmount,
	ShareCurrentBalance = ShareCurrentBalance,
	ShareDividendRate = ShareDividendRate,
	ShareHoldAmount = ShareHoldAmount,
	ShareMinimumBalance = ShareMinimumBalance,
	ShareOriginalBalance = ShareOriginalBalance,
	ShareTerm = ShareTerm,
	OpenShareCount = OpenShareCount,
	TotalShareCount = TotalShareCount,
	ShareSourceSystem = ShareSourceSystem,
	ShareSourceID = ShareSourceID
FROM
	fact.CurrentShare;
