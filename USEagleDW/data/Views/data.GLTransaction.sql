USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'data' AND name = 'GLTransaction')
	DROP VIEW data.GLTransaction;
GO


CREATE VIEW
	data.GLTransaction
AS
SELECT
	Trans.GLTransactionKey,
	Trans.GLAccountKey,
	Trans.GLAccountBranchKey,
	Trans.GLTransactionDetailKey,
	Trans.GLTransactionEffectiveDateKey,
	Trans.GLTransactionPostingDateKey,
	Trans.UserKey,
	Dtl.Comment,
	Trans.CreditAmount,
	Trans.DebitAmount,
	Dtl.GLTransactionPostDate,
	Dtl.Reference,
	Dtl.SequenceNumber,
	Trans.TransactionAmount,
	Trans.TransactionCount,
	Trans.GLTransactionSourceSystem,
	Trans.GLTransactionSourceID
FROM
	fact.GLTransaction Trans
		INNER JOIN
	dim.GLTransactionDetail Dtl
		ON Trans.GLTransactionDetailKey = Dtl.GLTransactionDetailKey;
