USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'data' AND name = 'Transaction')
	DROP VIEW data.[Transaction];
GO


CREATE VIEW
	data.[Transaction]
AS
SELECT
	Txn.TransactionKey,
	Txn.AccountTypeKey,
	Txn.MemberKey,
	Txn.MemberBranchKey,
	Txn.TransactionBranchKey,
	Txn.TransactionDateKey,
	Txn.TransactionTimeKey,
	Txn.TransactionTypeKey,
	Txn.UserKey,
	TxnDesc.TransactionConsoleNumber,
	TxnDesc.TransactionParentID,
	TxnDesc.TransactionSequenceNumber,
	Txn.TransactionAmount,
	Txn.TransactionCount,
	Txn.TransactionSourceSystem,
	Txn.TransactionSourceID
FROM
	fact.[Transaction] Txn
		INNER JOIN
	dim.TransactionDescriptor TxnDesc
		ON Txn.TransactionDescriptorKey = TxnDesc.TransactionDescriptorKey;
