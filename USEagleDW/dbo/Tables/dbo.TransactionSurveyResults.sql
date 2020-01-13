USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dbo' AND name = 'TransactionSurveyResults')
BEGIN

	CREATE TABLE
		dbo.TransactionSurveyResults
	(
		TransactionSurveyResults	INT IDENTITY(1, 1),
		SurveyDateTime				DATETIME NOT NULL,
		UniqueID					VARCHAR(10) NOT NULL,
		OverallSatisfaction			TINYINT,
		LikelyToRecommend			TINYINT,
		EmployeeSkill				TINYINT,
		EmployeePolite				TINYINT,
		EmployeeReferral			TINYINT,
		EmployeeUnderstandsMe		TINYINT,
		EmployeeAddressedNeeds		TINYINT,
		EmployeeRespectful			TINYINT,
		EmployeeThankedByName		TINYINT,
		EmployeeAppreciation		TINYINT,
		Comments					VARCHAR(500),
		Name						VARCHAR(50),
		EmailAddress				VARCHAR(50),
		PhoneNumber					VARCHAR(50),
		PreferredContactMethod		TINYINT
	);

END;
