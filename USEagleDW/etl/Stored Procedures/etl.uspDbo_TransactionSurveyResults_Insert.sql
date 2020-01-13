USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspDbo_TransactionSurveyResults_Insert')
	DROP PROCEDURE etl.uspDbo_TransactionSurveyResults_Insert;
GO


CREATE PROCEDURE etl.uspDbo_TransactionSurveyResults_Insert
AS
BEGIN

	INSERT INTO
		dbo.TransactionSurveyResults
	(
		SurveyDateTime,
		UniqueID,
		OverallSatisfactionRaw,
		OverallSatisfactionTranslated,
		LikelyToRecommendRaw,
		LikelyToRecommendTranslated,
		EmployeeSkillRaw,
		EmployeeSkillTranslated,
		EmployeePoliteRaw,
		EmployeePoliteTranslated,
		EmployeeReferralRaw,
		EmployeeReferralTranslated,
		EmployeeUnderstandsMeRaw,
		EmployeeUnderstandsMeTranslated,
		EmployeeAddressedNeedsRaw,
		EmployeeAddressedNeedsTranslated,
		EmployeeRespectfulRaw,
		EmployeeRespectfulTranslated,
		EmployeeThankedByNameRaw,
		EmployeeThankedByNameTranslated,
		EmployeeAppreciationRaw,
		EmployeeAppreciationTranslated,
		MemberNeedsAdditionalHelpRaw,
		MemberNeedsAdditionalHelpTranslated,
		Comments,
		Name,
		EmailAddress,
		PhoneNumber,
		PreferredContactMethod
	)
	SELECT
		Res.SurveyDateTime,
		Res.UniqueID,
		OverallSatisfactionRaw = Res.OverallSatisfaction,
		OverallSatisfactionTranslated =	CASE
											WHEN Res.OverallSatisfaction <= 2 THEN 6 - Res.OverallSatisfaction
											ELSE 5 - Res.OverallSatisfaction
										END,
		LikelyToRecommendRaw = Res.LikelyToRecommend,
		LikelyToRecommendTranslated = Res.LikelyToRecommend / 2.0,
		EmployeeSkillRaw = Res.EmployeeSkill,
		EmployeeSkillTranslated = 6 - Res.EmployeeSkill,
		EmployeePoliteRaw = Res.EmployeePolite,
		EmployeePoliteTranslated = 6 - Res.EmployeePolite,
		EmployeeReferralRaw =  Res.EmployeeReferral,
		EmployeeReferralTranslated = 6 - Res.EmployeeReferral,
		EmployeeUnderstandsMeRaw = Res.EmployeeUnderstandsMe,
		EmployeeUnderstandsMeTranslated = 6 - Res.EmployeeUnderstandsMe,
		EmployeeAddressedNeedsRaw = Res.EmployeeAddressedNeeds,
		EmployeeAddressedNeedsTranslated = 6 - Res.EmployeeAddressedNeeds,
		EmployeeRespectfulRaw = Res.EmployeeRespectful,
		EmployeeRespectfulTranslated = 9 - 4 * Res.EmployeeRespectful,
		EmployeeThankedByNameRaw = Res.EmployeeThankedByName,
		EmployeeThankedByNameTranslated = 9 - 4 * Res.EmployeeThankedByName,
		EmployeeAppreciationRaw = Res.EmployeeAppreciation,
		EmployeeAppreciationTranslated = 9 - 4 * Res.EmployeeAppreciation,
		MemberNeedsAdditionalHelpRaw = Res.EmployeeNeedAdditionalHelp,
		MemberNeedsAdditionalHelpTranslated = 9 - 4 * Res.EmployeeNeedAdditionalHelp,
		Res.Comments,
		Res.Name,
		Res.EmailAddress,
		Res.PhoneNumber,
		Res.PreferredContactMethod
	FROM
		Staging.import.TransactionSurveyResults Res
	ORDER BY
		Res.SurveyDateTime;

END;
