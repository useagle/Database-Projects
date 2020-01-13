USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'extract' AND name = 'TransactionSurvey')
BEGIN

	CREATE TABLE
		extract.TransactionSurvey
	(
		TransactionSurveyKey		INT IDENTITY(1, 1),
		TransactionID				VARCHAR(10),
		TransactionType				VARCHAR(15),
		PrimaryMemberFirstName		VARCHAR(20),
		TransactionDate				DATE,
		MemberEmail					VARCHAR(40)
	);

	ALTER TABLE extract.TransactionSurvey ADD CONSTRAINT PK_TransactionSurvey
	PRIMARY KEY CLUSTERED (TransactionSurveyKey);

END;
