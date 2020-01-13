USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'lookup' AND name = 'CreditScore')
	DROP VIEW lookup.CreditScore;
GO


CREATE VIEW
	lookup.CreditScore
AS
SELECT
	CreditScoreKey = CreditScoreKey,
	CreditScore= CreditScore,
	CreditScoreTierShortDescription = CreditScoreTierShortDescription,
	CreditScoreTierLongDescription = CreditScoreTierLongDescription
FROM
	dim.CreditScore;
