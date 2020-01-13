USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'data' AND name = 'CurrentMember')
	DROP VIEW data.CurrentMember;
GO


CREATE VIEW
	data.CurrentMember
AS
SELECT
	CurrentMemberKey,
	MemberKey,
	MemberBranchKey,
	MemberCloseDateKey,
	MemberOpenDateKey,
	AllMembersCount,
	ClosedMembersCount,
	OpenMembersCount,
	OpenLoansCount,
	OpenSharesCount,
	TotalLoanBalance,
	TotalShareBalance,
	CurrentMemberSourceSystem,
	CurrentMemberSourceID
FROM
	fact.CurrentMember;
