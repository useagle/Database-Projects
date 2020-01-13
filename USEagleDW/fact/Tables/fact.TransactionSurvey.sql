USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'TransactionSurvey')
BEGIN

	CREATE TABLE
		fact.TransactionSurvey
	(
		TransactionSurveyKey			INT IDENTITY(1, 1),
		MemberKey						INT NOT NULL,
		SurveyDateKey					INT NOT NULL,
		TransactionBranchKey			INT NOT NULL,
		TransactionDateKey				INT NOT NULL,
		UserKey							INT NOT NULL,
		CompletedSurveyCount			INT NOT NULL,
		EmployeeAddressedNeeds			DECIMAL(3, 1) NOT NULL,
		EmployeeAppreciation			DECIMAL(3, 1) NOT NULL,
		EmployeePolite					DECIMAL(3, 1) NOT NULL,
		EmployeeReferral				DECIMAL(3, 1) NOT NULL,
		EmployeeRespectful				DECIMAL(3, 1) NOT NULL,
		EmployeeSkill					DECIMAL(3, 1) NOT NULL,
		EmployeeThankedByName			DECIMAL(3, 1) NOT NULL,
		EmployeeUnderstandsMe			DECIMAL(3, 1) NOT NULL,
		LikelyToRecommend				DECIMAL(3, 1) NOT NULL,
		OverallSatisfaction				DECIMAL(3, 1) NOT NULL,
		SentSurveyCount					INT NOT NULL,
		TransactionSurveySourceSystem	VARCHAR(25) NOT NULL,
		TransactionSurveySourceID		VARCHAR(15) NOT NULL
	);

	ALTER TABLE fact.TransactionSurvey ADD CONSTRAINT PK_TransactionSurvey
	PRIMARY KEY CLUSTERED (TransactionSurveyKey);

END;
