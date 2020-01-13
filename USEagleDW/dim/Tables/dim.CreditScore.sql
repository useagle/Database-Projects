USE USEagleDW;
GO


--	Create Calendar dimension
IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'dim' AND  name = 'CreditScore')
	DROP TABLE dim.CreditScore;


CREATE TABLE
	dim.CreditScore
(
	CreditScoreKey						INT NOT NULL,
	CreditScore							SMALLINT NOT NULL,
	CreditScoreTierShortDescription		VARCHAR(25) NOT NULL,
	CreditScoreTierLongDescription		VARCHAR(25) NOT NULL
);

ALTER TABLE dim.CreditScore ADD CONSTRAINT PK_CreditScore PRIMARY KEY (CreditScoreKey);



INSERT INTO
	dim.CreditScore
(
	CreditScoreKey,
	CreditScore,
	CreditScoreTierShortDescription,
	CreditScoreTierLongDescription
)
VALUES
(
	-1,
	-1,
	'<Credit Score Missing>',
	'<Credit Score Missing>'
);



DECLARE
	@LowCreditScore		SMALLINT,
	@HighCreditScore	SMALLINT;


SET @LowCreditScore = 0;
SET @HighCreditScore = 900;


WITH Tally(SequenceNumber) AS
(
	SELECT
		ROW_NUMBER() OVER (ORDER BY t1.SequenceNumber)
	FROM
		Admin.dbo.Tally t1
			CROSS JOIN
		Admin.dbo.Tally t2
)
INSERT INTO
	dim.CreditScore
(
	CreditScoreKey,
	CreditScore,
	CreditScoreTierShortDescription,
	CreditScoreTierLongDescription
)
SELECT
	CreditScoreKey = SequenceNumber - 1,
	CreditScore = SequenceNumber - 1,
	CreditScoreTierShortDescription = Tier.CreditTierName,
	CreditScoreTierLongDescription =	CASE
											WHEN SequenceNumber = 1 THEN Tier.CreditTierName
											ELSE Tier.CreditTierName + ': ' + CAST(Tier.CreditTierLowScore AS VARCHAR) + ' - ' + CAST(Tier.CreditTierHighScore AS VARCHAR)
										END
FROM
	Tally t
		INNER JOIN
	Staging.business.CreditTiering Tier
		ON t.SequenceNumber - 1 BETWEEN Tier.CreditTierLowScore AND Tier.CreditTierHighScore
WHERE
	t.SequenceNumber <= @HighCreditScore + 1
ORDER BY
	t.SequenceNumber;
