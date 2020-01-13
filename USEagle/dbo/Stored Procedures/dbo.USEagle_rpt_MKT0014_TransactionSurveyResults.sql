USE USEagle;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'USEagle_rpt_MKT0014_TransactionSurveyResults')
	DROP PROCEDURE dbo.USEagle_rpt_MKT0014_TransactionSurveyResults;
GO


CREATE PROCEDURE dbo.USEagle_rpt_MKT0014_TransactionSurveyResults
(
	@SurveyStartDate		DATE = NULL,
	@SurveyEndDate			DATE = NULL,
	@BranchNumber			SMALLINT = -1,
	@RequiresFollowUp		SMALLINT = -1,
	@ShowExcluded			CHAR(1) = 'N'
)

-- ======================================================================
-- Author:		<Chris Hyde>
-- Create date: <10/25/2018>    
-- Modify Date: 
-- Description:	<> 
-- ======================================================================

AS
BEGIN

	DECLARE
		@SurveyStartDateTime	DATETIME,
		@SurveyEndDateTime		DATETIME;


	IF @SurveyStartDate IS NOT NULL
		SET @SurveyStartDateTime = CAST(@SurveyStartDate AS DATETIME);
	ELSE
		SET @SurveyStartDateTime = CAST(DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE)) AS DATETIME);


	IF @SurveyStartDateTime <= '2018-10-22'
		SET @SurveyStartDateTime = '2018-10-23 00:00';


	IF @SurveyEndDate IS NULL
		SET @SurveyEndDateTime = DATEADD(ss, -1, DATEADD(dd, 1, @SurveyStartDateTime));
	ELSE
		SET @SurveyEndDateTime = DATEADD(ss, -1, DATEADD(dd, 1, CAST(@SurveyEndDate AS DATETIME)));


	IF @SurveyEndDateTime < @SurveyStartDateTime
		SET @SurveyEndDateTime = DATEADD(ss, -1, DATEADD(dd, 1, @SurveyStartDateTime));


	WITH Loans AS
	(
		SELECT
			UniqueID = Ln.LoanSourceID,
			TransactionDateTime = CONVERT(DATETIME, CAST(Ln.LoanOpenDateKey AS VARCHAR), 112),
			Ln.MemberKey,
			Ln.LoanOriginationBranchKey,
			Ln.OriginatedByUserKey
		FROM
			USEagleDW.fact.CurrentLoan Ln
		WHERE
			Ln.LoanOpenDateKey >= 20181022
	),
	Transactions AS
	(
		SELECT
			UniqueID = 'T' + CAST(Txn.TransactionKey AS VARCHAR),
			TransactionDateTime = DATEADD(mi, Txn.TransactionTimeKey % 100, DATEADD(hh, FLOOR(Txn.TransactionTimeKey / 100), CONVERT(DATETIME, CAST(Txn.TransactionDateKey AS VARCHAR), 112))),
			Txn.MemberKey,
			Txn.TransactionBranchKey,
			Txn.UserKey
		FROM
			USEagleDW.fact.[Transaction] Txn
		WHERE
			Txn.TransactionDateKey >= 20181022
	)
	SELECT
		[Transaction Date/Time] = Txn.TransactionDateTime,
		[Branch] = Brn.BranchNumberAndName,
		[User] = Usr.UserNumberAndName,
		[Member Number] = Mem.MemberNumber,
		[Primary Member Full Name] = Mem.PrimaryMemberFullName,
		[Member Type] = Mem.MemberTypeNumberAndName,
		[Survey Date/Time] = Res.SurveyDateTime,
		[Unique ID] = Res.UniqueID,
		[Overall Satisfaction] = CAST(Res.OverallSatisfactionTranslated AS VARCHAR) + ' - ' + OvrDesc.OverallSatisfactionDescription,
		[Likely To Recommend] = CAST(Res.LikelyToRecommendTranslated AS VARCHAR) + ' - ' + RecommDesc.LikelyToRecommendDescription,
		[Employee Skill] = CAST(Res.EmployeeSkillTranslated AS VARCHAR) + ' - ' + SkillDesc.ComparisonDescription,
		[Employee Polite] = CAST(Res.EmployeePoliteTranslated AS VARCHAR) + ' - ' + PoliteDesc.ComparisonDescription,
		[Employee Referral] = CAST(Res.EmployeeReferralTranslated AS VARCHAR) + ' - ' + ReferralDesc.ComparisonDescription,
		[Employee Understands Me] = CAST(Res.EmployeeUnderstandsMeTranslated AS VARCHAR) + ' - ' + UnderDesc.ComparisonDescription,
		[Employee Addressed Needs] = CAST(Res.EmployeeAddressedNeedsTranslated AS VARCHAR) + ' - ' + NeedsDesc.ComparisonDescription,
		[Employee Respectful] = CAST(Res.EmployeeRespectfulTranslated AS VARCHAR) + ' - ' + RespectDesc.YesNoDescription,
		[Employee Thanked By Name] = CAST(Res.EmployeeThankedByNameTranslated AS VARCHAR) + ' - ' + ThankedDesc.YesNoDescription,
		[Employee Appreciation] = CAST(Res.EmployeeAppreciationTranslated AS VARCHAR) + ' - ' + ApprecDesc.YesNoDescription,
		[Comments] = Res.Comments,
		[Follow-Up Required?] = CAST(Res.MemberNeedsAdditionalHelpTranslated AS VARCHAR) + ' - ' + FollowUpDesc.YesNoDescription,
		[Results Email] = Res.EmailAddress,
		[Member Email] = Mem.MemberEmail,
		[Results Phone] = Res.PhoneNumber,
		[Contact Method] =	CASE
								WHEN Res.PreferredContactMethod = 1 THEN 'Email'
								WHEN Res.PreferredContactMethod = 2 THEN 'Phone'
								ELSE 'N/A'
							END,
		[Exclude From Analysis?] = ISNULL(Res.ExcludeFromAnalysisFlag, ''),
		[Notes] = '',
		[Branch Sort Order] = ISNULL(Brn.BranchNumber, 99)
	FROM
		USEagleDW.dbo.TransactionSurveyResults Res
			INNER JOIN
		USEagleDW.extract.TransactionSurvey Ext
			ON Res.UniqueID = Ext.TransactionID
			LEFT JOIN
		Transactions Txn
			ON Res.UniqueID = Txn.UniqueID
			LEFT JOIN
		USEagleDW.dim.Branch Brn
			ON Txn.TransactionBranchKey = Brn.BranchKey
			LEFT JOIN
		USEagleDW.dim.Member Mem
			ON Txn.MemberKey = Mem.MemberKey
			LEFT JOIN
		USEagleDW.dim.[User] Usr
			ON Txn.UserKey = Usr.UserKey
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription OvrDesc
			ON Res.OverallSatisfactionTranslated = OvrDesc.OverallSatisfactionValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription RecommDesc
			ON Res.LikelyToRecommendTranslated = RecommDesc.LikelyToRecommendValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription SkillDesc
			ON Res.EmployeeSkillTranslated = SkillDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription PoliteDesc
			ON Res.EmployeePoliteTranslated = PoliteDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription ReferralDesc
			ON Res.EmployeeReferralTranslated = ReferralDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription UnderDesc
			ON Res.EmployeeUnderstandsMeTranslated = UnderDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription NeedsDesc
			ON Res.EmployeeAddressedNeedsTranslated = NeedsDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription RespectDesc
			ON Res.EmployeeRespectfulTranslated = RespectDesc.YesNoValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription ThankedDesc
			ON Res.EmployeeThankedByNameTranslated = ThankedDesc.YesNoValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription ApprecDesc
			ON Res.EmployeeAppreciationTranslated = ApprecDesc.YesNoValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription FollowUpDesc
			ON Res.MemberNeedsAdditionalHelpTranslated = FollowUpDesc.YesNoValue
	WHERE
		Res.SurveyDateTime BETWEEN @SurveyStartDateTime AND @SurveyEndDateTime
		AND
		LEFT(Res.UniqueID, 1) = 'T'
		AND
		(Brn.BranchNumber = @BranchNumber
			OR
			@BranchNumber = -1)
		AND
		(Res.MemberNeedsAdditionalHelpTranslated = @RequiresFollowUp
			OR
			@RequiresFollowUp = -1)
		AND
		(Res.ExcludeFromAnalysisFlag = @ShowExcluded
			OR
			Res.ExcludeFromAnalysisFlag IS NULL
			OR
			@ShowExcluded = 'X')

	UNION ALL

	SELECT
		[Transaction Date/Time] = Ln.TransactionDateTime,
		[Branch] = Brn.BranchNumberAndName,
		[User] = Usr.UserNumberAndName,
		[Member Number] = Mem.MemberNumber,
		[Primary Member Full Name] = Mem.PrimaryMemberFullName,
		[Member Type] = Mem.MemberTypeNumberAndName,
		[Survey Date/Time] = Res.SurveyDateTime,
		[Unique ID] = Res.UniqueID,
		[Overall Satisfaction] = CAST(Res.OverallSatisfactionTranslated AS VARCHAR) + ' - ' + OvrDesc.OverallSatisfactionDescription,
		[Likely To Recommend] = CAST(Res.LikelyToRecommendTranslated AS VARCHAR) + ' - ' + RecommDesc.LikelyToRecommendDescription,
		[Employee Skill] = CAST(Res.EmployeeSkillTranslated AS VARCHAR) + ' - ' + SkillDesc.ComparisonDescription,
		[Employee Polite] = CAST(Res.EmployeePoliteTranslated AS VARCHAR) + ' - ' + PoliteDesc.ComparisonDescription,
		[Employee Referral] = CAST(Res.EmployeeReferralTranslated AS VARCHAR) + ' - ' + ReferralDesc.ComparisonDescription,
		[Employee Understands Me] = CAST(Res.EmployeeUnderstandsMeTranslated AS VARCHAR) + ' - ' + UnderDesc.ComparisonDescription,
		[Employee Addressed Needs] = CAST(Res.EmployeeAddressedNeedsTranslated AS VARCHAR) + ' - ' + NeedsDesc.ComparisonDescription,
		[Employee Respectful] = CAST(Res.EmployeeRespectfulTranslated AS VARCHAR) + ' - ' + RespectDesc.YesNoDescription,
		[Employee Thanked By Name] = CAST(Res.EmployeeThankedByNameTranslated AS VARCHAR) + ' - ' + ThankedDesc.YesNoDescription,
		[Employee Appreciation] = CAST(Res.EmployeeAppreciationTranslated AS VARCHAR) + ' - ' + ApprecDesc.YesNoDescription,
		[Comments] = Res.Comments,
		[Follow-Up Required?] = CAST(Res.MemberNeedsAdditionalHelpTranslated AS VARCHAR) + ' - ' + FollowUpDesc.YesNoDescription,
		[Results Email] = Res.EmailAddress,
		[Member Email] = Mem.MemberEmail,
		[Results Phone] = Res.PhoneNumber,
		[Contact Method] =	CASE
								WHEN Res.PreferredContactMethod = 1 THEN 'Email'
								WHEN Res.PreferredContactMethod = 2 THEN 'Phone'
								ELSE 'N/A'
							END,
		[Exclude From Analysis?] = ISNULL(Res.ExcludeFromAnalysisFlag, ''),
		[Notes] = '',
		[Branch Sort Order] = ISNULL(Brn.BranchNumber, 99)
	FROM
		USEagleDW.dbo.TransactionSurveyResults Res
			INNER JOIN
		USEagleDW.extract.TransactionSurvey Ext
			ON Res.UniqueID = Ext.TransactionID
			LEFT JOIN
		Loans Ln
			ON Res.UniqueID = Ln.UniqueID
			LEFT JOIN
		USEagleDW.dim.Branch Brn
			ON Ln.LoanOriginationBranchKey = Brn.BranchKey
			LEFT JOIN
		USEagleDW.dim.Member Mem
			ON Ln.MemberKey = Mem.MemberKey
			LEFT JOIN
		USEagleDW.dim.[User] Usr
			ON Ln.OriginatedByUserKey = Usr.UserKey
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription OvrDesc
			ON Res.OverallSatisfactionTranslated = OvrDesc.OverallSatisfactionValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription RecommDesc
			ON Res.LikelyToRecommendTranslated = RecommDesc.LikelyToRecommendValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription SkillDesc
			ON Res.EmployeeSkillTranslated = SkillDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription PoliteDesc
			ON Res.EmployeePoliteTranslated = PoliteDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription ReferralDesc
			ON Res.EmployeeReferralTranslated = ReferralDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription UnderDesc
			ON Res.EmployeeUnderstandsMeTranslated = UnderDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription NeedsDesc
			ON Res.EmployeeAddressedNeedsTranslated = NeedsDesc.ComparisonValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription RespectDesc
			ON Res.EmployeeRespectfulTranslated = RespectDesc.YesNoValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription ThankedDesc
			ON Res.EmployeeThankedByNameTranslated = ThankedDesc.YesNoValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription ApprecDesc
			ON Res.EmployeeAppreciationTranslated = ApprecDesc.YesNoValue
			LEFT JOIN
		Staging.business.TransactionSurveyResultsDescription FollowUpDesc
			ON Res.MemberNeedsAdditionalHelpTranslated = FollowUpDesc.YesNoValue
	WHERE
		Res.SurveyDateTime BETWEEN @SurveyStartDateTime AND @SurveyEndDateTime
		AND
		LEFT(Res.UniqueID, 1) = 'L'
		AND
		(Brn.BranchNumber = @BranchNumber
			OR
			@BranchNumber = -1)
		AND
		(Res.MemberNeedsAdditionalHelpTranslated = @RequiresFollowUp
			OR
			@RequiresFollowUp = -1)
		AND
		(Res.ExcludeFromAnalysisFlag = @ShowExcluded
			OR
			Res.ExcludeFromAnalysisFlag IS NULL
			OR
			@ShowExcluded = 'X')

	ORDER BY
		[Branch Sort Order],
		[Survey Date/Time];

END;
GO
