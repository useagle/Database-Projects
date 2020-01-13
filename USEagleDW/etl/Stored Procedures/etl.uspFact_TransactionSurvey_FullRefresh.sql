USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspFact_TransactionSurvey_FullRefresh')
	DROP PROCEDURE etl.uspFact_TransactionSurvey_FullRefresh;
GO


CREATE PROCEDURE etl.uspFact_TransactionSurvey_FullRefresh
AS
BEGIN

	ALTER TABLE fact.TransactionSurvey DROP CONSTRAINT FK_TransactionSurvey_Member;
	ALTER TABLE fact.TransactionSurvey DROP CONSTRAINT FK_TransactionSurvey_SurveyDate;
	ALTER TABLE fact.TransactionSurvey DROP CONSTRAINT FK_TransactionSurvey_TransactionBranch;
	ALTER TABLE fact.TransactionSurvey DROP CONSTRAINT FK_TransactionSurvey_TransactionDate;
	ALTER TABLE fact.TransactionSurvey DROP CONSTRAINT FK_TransactionSurvey_User;


	TRUNCATE TABLE fact.TransactionSurvey;


	WITH Loans AS
	(
		SELECT
			UniqueID = Ln.LoanSourceID,
			Ln.LoanOpenDateKey,
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
			Txn.TransactionDateKey,
			Txn.MemberKey,
			Txn.TransactionBranchKey,
			Txn.UserKey
		FROM
			USEagleDW.fact.[Transaction] Txn
		WHERE
			Txn.TransactionDateKey >= 20181022
	)
	INSERT INTO
		fact.TransactionSurvey
	(
		MemberKey,
		SurveyDateKey,
		TransactionBranchKey,
		TransactionDateKey,
		UserKey,
		CompletedSurveyCount,
		EmployeeAddressedNeeds,
		EmployeeAppreciation,
		EmployeePolite,
		EmployeeReferral,
		EmployeeRespectful,
		EmployeeSkill,
		EmployeeThankedByName,
		EmployeeUnderstandsMe,
		LikelyToRecommend,
		OverallSatisfaction,
		SentSurveyCount,
		TransactionSurveySourceSystem,
		TransactionSurveySourceID
	)
	SELECT
		MemberKey = ISNULL(Ln.MemberKey, -1),
		SurveyDateKey = ISNULL(CAST(CONVERT(VARCHAR(8), Res.SurveyDateTime, 112) AS INT), -1),
		TransactionBranchKey = ISNULL(Ln.LoanOriginationBranchKey, -1),
		TransactionDateKey = ISNULL(Ln.LoanOpenDateKey, -1),
		UserKey = ISNULL(Ln.OriginatedByUserKey, -1),
		CompletedSurveyCount =	CASE
									WHEN Res.UniqueID IS NOT NULL THEN 1
									ELSE 0
								END,
		EmployeeAddressedNeeds = ISNULL(Res.EmployeeAddressedNeedsTranslated, 0),
		EmployeeAppreciation = ISNULL(Res.EmployeeAppreciationTranslated, 0),
		EmployeePolite = ISNULL(Res.EmployeePoliteTranslated, 0),
		EmployeeReferral = ISNULL(Res.EmployeeReferralTranslated, 0),
		EmployeeRespectful = ISNULL(Res.EmployeeRespectfulTranslated, 0),
		EmployeeSkill = ISNULL(Res.EmployeeSkillTranslated, 0),
		EmployeeThankedByName = ISNULL(Res.EmployeeThankedByNameTranslated, 0),
		EmployeeUnderstandsMe = ISNULL(Res.EmployeeUnderstandsMeTranslated, 0),
		LikelyToRecommend = ISNULL(Res.LikelyToRecommendTranslated, 0),
		OverallSatisfaction = ISNULL(Res.OverallSatisfactionTranslated, 0),
		SentSurveyCount = 1,
		TransactionSurveySourceSystem = 'TransactionSurveys',
		TransactionSurveySourceID = Ext.TransactionID
	FROM
		USEagleDW.extract.TransactionSurvey Ext
			LEFT JOIN
		dbo.TransactionSurveyResults Res
			ON Ext.TransactionID = Res.UniqueID
			LEFT JOIN
		Loans Ln
			ON Ext.TransactionID = Ln.UniqueID
	WHERE
		LEFT(Ext.TransactionID, 1) = 'L'
		AND
		Res.ExcludeFromAnalysisFlag IS NULL


	UNION ALL

	SELECT
		MemberKey = ISNULL(Txn.MemberKey, -1),
		SurveyDateKey = ISNULL(CAST(CONVERT(VARCHAR(8), Res.SurveyDateTime, 112) AS INT), -1),
		TransactionBranchKey = ISNULL(Txn.TransactionBranchKey, -1),
		TransactionDateKey = ISNULL(Txn.TransactionDateKey, -1),
		UserKey = ISNULL(Txn.UserKey, -1),
		CompletedSurveyCount =	CASE
									WHEN Res.UniqueID IS NOT NULL THEN 1
									ELSE 0
								END,
		EmployeeAddressedNeeds = ISNULL(Res.EmployeeAddressedNeedsTranslated, 0),
		EmployeeAppreciation = ISNULL(Res.EmployeeAppreciationTranslated, 0),
		EmployeePolite = ISNULL(Res.EmployeePoliteTranslated, 0),
		EmployeeReferral = ISNULL(Res.EmployeeReferralTranslated, 0),
		EmployeeRespectful = ISNULL(Res.EmployeeRespectfulTranslated, 0),
		EmployeeSkill = ISNULL(Res.EmployeeSkillTranslated, 0),
		EmployeeThankedByName = ISNULL(Res.EmployeeThankedByNameTranslated, 0),
		EmployeeUnderstandsMe = ISNULL(Res.EmployeeUnderstandsMeTranslated, 0),
		LikelyToRecommend = ISNULL(Res.LikelyToRecommendTranslated, 0),
		OverallSatisfaction = ISNULL(Res.OverallSatisfactionTranslated, 0),
		SentSurveyCount = 1,
		TransactionSurveySourceSystem = 'TransactionSurveys',
		TransactionSurveySourceID = Ext.TransactionID
	FROM
		USEagleDW.extract.TransactionSurvey Ext
			LEFT JOIN
		dbo.TransactionSurveyResults Res
			ON Ext.TransactionID = Res.UniqueID
			LEFT JOIN
		Transactions Txn
			ON Ext.TransactionID = Txn.UniqueID
	WHERE
		LEFT(Ext.TransactionID, 1) = 'T'
		AND
		Res.ExcludeFromAnalysisFlag IS NULL

	ORDER BY
		Ext.TransactionID;


	ALTER TABLE fact.TransactionSurvey ADD CONSTRAINT FK_TransactionSurvey_Member
	FOREIGN KEY (MemberKey) REFERENCES dim.Member (MemberKey);

	ALTER TABLE fact.TransactionSurvey ADD CONSTRAINT FK_TransactionSurvey_SurveyDate
	FOREIGN KEY (SurveyDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.TransactionSurvey ADD CONSTRAINT FK_TransactionSurvey_TransactionBranch
	FOREIGN KEY (TransactionBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.TransactionSurvey ADD CONSTRAINT FK_TransactionSurvey_TransactionDate
	FOREIGN KEY (TransactionDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.TransactionSurvey ADD CONSTRAINT FK_TransactionSurvey_User
	FOREIGN KEY (UserKey) REFERENCES dim.[User] (UserKey);

END;
