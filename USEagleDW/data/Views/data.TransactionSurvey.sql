USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'data' AND name = 'TransactionSurvey')
	DROP VIEW data.TransactionSurvey;
GO


CREATE VIEW
	data.TransactionSurvey
AS
SELECT
	Txn.TransactionSurveyKey,
	Txn.MemberKey,
	Txn.SurveyDateKey,
	Txn.TransactionBranchKey,
	Txn.TransactionDateKey,
	Txn.UserKey,
	Txn.CompletedSurveyCount,
	Txn.EmployeeAddressedNeeds,
	Txn.EmployeeAppreciation,
	Txn.EmployeePolite,
	Txn.EmployeeReferral,
	Txn.EmployeeRespectful,
	Txn.EmployeeSkill,
	Txn.EmployeeThankedByName,
	Txn.EmployeeUnderstandsMe,
	Txn.LikelyToRecommend,
	Txn.OverallSatisfaction,
	Txn.SentSurveyCount,
	Txn.TransactionSurveySourceSystem,
	Txn.TransactionSurveySourceID
FROM
	fact.TransactionSurvey Txn;
