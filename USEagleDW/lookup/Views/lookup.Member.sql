USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'Member')
	DROP VIEW lookup.Member;
GO


CREATE VIEW
	lookup.Member
AS
SELECT
	MemberKey,
	MemberBirthDate,
	MemberCity,
	MemberCloseReason,
	MemberCloseReasonRaw,
	MemberCloseReasonText,
	MemberEmail,
	MemberJoinDate,
	MemberNumber,
	MemberSSN,
	MemberState,
	MemberStatus,
	MemberStreetAddress,
	MemberTypeNumber,
	MemberTypeName,
	MemberTypeNumberAndName,
	MemberTypeCategory1,
	MemberTypeCategory2,
	MemberTypeCategory3,
	MemberZipCode,
	PrimaryMemberFirstName,
	PrimaryMemberFullName,
	PrimaryMemberLastName,
	MemberSourceSystem,
	MemberSourceID,
	MemberHash,
	MemberStartEffectiveDate,
	MemberEndEffectiveDate,
	MemberActiveRecordFlag
FROM
	dim.Member
WHERE
	MemberActiveRecordFlag = 'Y';
