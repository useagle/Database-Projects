USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspFact_Transaction_Delta')
	DROP PROCEDURE etl.uspFact_Transaction_Delta;
GO


CREATE PROCEDURE etl.uspFact_Transaction_Delta
AS
BEGIN

	ALTER TABLE fact.[Transaction] DROP CONSTRAINT FK_Transaction_AccountType;
	ALTER TABLE fact.[Transaction] DROP CONSTRAINT FK_Transaction_Member;
	ALTER TABLE fact.[Transaction] DROP CONSTRAINT FK_Transaction_MemberBranch;
	ALTER TABLE fact.[Transaction] DROP CONSTRAINT FK_Transaction_TransactionBranch;
	ALTER TABLE fact.[Transaction] DROP CONSTRAINT FK_Transaction_TransactionDate;
	ALTER TABLE fact.[Transaction] DROP CONSTRAINT FK_Transaction_TransactionDescriptor;
	ALTER TABLE fact.[Transaction] DROP CONSTRAINT FK_Transaction_TransactionTime;
	ALTER TABLE fact.[Transaction] DROP CONSTRAINT FK_Transaction_TransactionType;
	ALTER TABLE fact.[Transaction] DROP CONSTRAINT FK_Transaction_User;


	--TRUNCATE TABLE fact.[Transaction];



	IF EXISTS(SELECT * FROM tempdb.sys.objects WHERE name LIKE '%TempTxn%')
		DROP TABLE #TempTxn;


	CREATE TABLE
		#TempTxn
	(
		MemberNumber				VARCHAR(10),
		AccountID					CHAR(4),
		MemberBranchNumber			INT,
		AccountTypeSourceID			VARCHAR(20),
		TransactionBranchNumber		INT,
		TransactionDateKey			INT,
		TransactionTimeKey			INT,
		TransactionTypeSourceID		VARCHAR(15),
		TransactionUserNumber		INT,
		TransactionAmount			DECIMAL(16, 2),
		TransactionSourceSystem		VARCHAR(25),
		TransactionSourceID			VARCHAR(50)
	);



	INSERT INTO	#TempTxn
	EXEC Staging.etl.uspTransaction_GetData;


	/*
	WITH TransactionDetail AS
	(
		SELECT
			AccountNumber = LnTxn.PARENTACCOUNT,
			TransactionBranchNumber = LnTxn.BRANCH,
			TransactionDateKey = CAST(CONVERT(VARCHAR(8), LnTxn.POSTDATE, 112) AS INT),
			TransactionTimeKey = LnTxn.POSTTIME,
			TransactionTypeSourceID = 'Loan|' + ISNULL(LnTxn.ACTIONCODE, 'N/A') + '|' + ISNULL(LnTxn.SOURCECODE, 'N/A'),
			TransactionUserNumber = LnTxn.USERNUMBER,
			TransactionAmount = LnTxn.BALANCECHANGE,
			TransactionSourceSystem = 'ARCU',
			TransactionSourceID = 'Loan|' + LnTxn.PARENTACCOUNT + '|' + Lntxn.PARENTID + '|' + CAST(LnTxn.SEQUENCENUMBER AS VARCHAR)
									+ '|' + CONVERT(VARCHAR(10), LnTxn.POSTDATE, 120)
		FROM
			Staging.arcusym000.dbo_LOANTRANSACTION LnTxn
		WHERE
			LnTxn.ACTIONCODE <> 'C'		--	Do not include Comments
			AND
			LnTxn.VOIDCODE = 0
			AND
			'Loan|' + LnTxn.PARENTACCOUNT + '|' + Lntxn.PARENTID + '|' + CAST(LnTxn.SEQUENCENUMBER AS VARCHAR)
					+ '|' + CONVERT(VARCHAR(10), LnTxn.POSTDATE, 120) NOT IN (SELECT TransactionSourceID FROM USEagleDW.fact.[Transaction])

		UNION ALL

		SELECT
			AccountNumber = ShareTxn.PARENTACCOUNT,
			TransactionBranchNumber = ShareTxn.BRANCH,
			TransactionDateKey = CAST(CONVERT(VARCHAR(8), ShareTxn.POSTDATE, 112) AS INT),
			TransactionTimeKey = ShareTxn.POSTTIME,
			TransactionTypeSourceID = 'Share|' + ISNULL(ShareTxn.ACTIONCODE, 'N/A') + '|' + ISNULL(ShareTxn.SOURCECODE, 'N/A'),
			TransactionUserNumber = ShareTxn.USERNUMBER,
			TransactionAmount = ShareTxn.BALANCECHANGE,
			TransactionSourceSystem = 'ARCU',
			TransactionSourceID = 'Share|' + ShareTxn.PARENTACCOUNT + '|' + ShareTxn.PARENTID + '|' + CAST(ShareTxn.SEQUENCENUMBER AS VARCHAR)
									+ '|' + CONVERT(VARCHAR(10), ShareTxn.POSTDATE, 120)
		FROM
			Staging.arcusym000.dbo_SAVINGSTRANSACTION ShareTxn
		WHERE
			ShareTxn.ACTIONCODE <> 'C'		--	Do not include Comments
			AND
			ShareTxn.VOIDCODE = 0
			AND
			'Share|' + ShareTxn.PARENTACCOUNT + '|' + ShareTxn.PARENTID + '|' + CAST(ShareTxn.SEQUENCENUMBER AS VARCHAR)
				+ '|' + CONVERT(VARCHAR(10), ShareTxn.POSTDATE, 120) NOT IN (SELECT TransactionSourceID FROM USEagleDW.fact.[Transaction])
	)
	INSERT INTO
		#TempTxn
	SELECT
		AccountNumber,
		TransactionBranchNumber,
		TransactionDateKey,
		TransactionTimeKey,
		TransactionTypeSourceID,
		TransactionUserNumber,
		TransactionAmount,
		TransactionSourceSystem,
		TransactionSourceID
	FROM
		TransactionDetail
	ORDER BY
		TransactionDateKey,
		TransactionTimeKey,
		TransactionSourceID;
	*/


	INSERT INTO
		fact.[Transaction]
	(
		AccountTypeKey,
		MemberKey,
		MemberBranchKey,
		TransactionBranchKey,
		TransactionDateKey,
		TransactionDescriptorKey,
		TransactionTimeKey,
		TransactionTypeKey,
		UserKey,
		TransactionAmount,
		TransactionCount,
		TransactionSourceSystem,
		TransactionSourceID
	)
	SELECT
		AccountTypeKey = ISNULL(AcctTyp.AccountTypeKey, -1),
		MemberKey = ISNULL(Mem.MemberKey, -1),
		MemberBranchKey = ISNULL(MemBr.BranchKey, -1),
		TransactionBranchKey = ISNULL(TxnBr.BranchKey, -1),
		TransactionDateKey = ISNULL(Txn.TransactionDateKey, -1),
		TransactionDescriptorKey = ISNULL(TxnDesc.TransactionDescriptorKey, -1),
		TransactionTimeKey = ISNULL(Txn.TransactionTimeKey, -1),
		TransactionTypeKey = ISNULL(TxnType.TransactionTypeKey, -1),
		UserKey = ISNULL(Usr.UserKey, -1),
		Txn.TransactionAmount,
		TransactionCount = 1,
		Txn.TransactionSourceSystem,
		Txn.TransactionSourceID
	FROM
		#TempTxn Txn
			LEFT JOIN
		dim.AccountType AcctTyp
			ON AcctTyp.AccountTypeSourceSystem = 'ARCU' AND Txn.AccountTypeSourceID = AcctTyp.AccountTypeSourceID AND AcctTyp.AccountTypeActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.Member Mem
			ON Mem.MemberSourceSystem = 'ARCU' AND Txn.MemberNumber = Mem.MemberSourceID AND Mem.MemberActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.Branch MemBr
			ON MemBr.BranchSourceSystem = 'ARCU' AND Txn.MemberBranchNumber = MemBr.BranchSourceID AND MemBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.Branch TxnBr
			ON TxnBr.BranchSourceSystem = 'ARCU' AND Txn.TransactionBranchNumber = TxnBr.BranchSourceID AND TxnBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.TransactionDescriptor TxnDesc
			ON TxnDesc.TransactionDescriptorSourceSystem = 'ARCU' AND Txn.TransactionSourceID = TxnDesc.TransactionDescriptorSourceID AND TxnDesc.TransactionDescriptorActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.TransactionType TxnType
			ON TxnType.TransactionTypeSourceSystem = 'ARCU' AND Txn.TransactionTypeSourceID = TxnType.TransactionTypeSourceID AND TxnType.TransactionTypeActiveRecordFlag = 'Y'
			LEFT JOIN
		dim.[User] Usr
			ON Usr.UserSourceSystem = 'ARCU' AND Txn.TransactionUserNumber = Usr.UserSourceID AND Usr.UserActiveRecordFlag = 'Y'
	ORDER BY
		Txn.TransactionDateKey,
		Txn.TransactionTimeKey,
		Txn.TransactionSourceID;



	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_AccountType
	FOREIGN KEY (AccountTypeKey) REFERENCES dim.AccountType (AccountTypeKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_Member
	FOREIGN KEY (MemberKey) REFERENCES dim.Member (MemberKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_MemberBranch
	FOREIGN KEY (MemberBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionBranch
	FOREIGN KEY (TransactionBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionDate
	FOREIGN KEY (TransactionDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionDescriptor
	FOREIGN KEY (TransactionDescriptorKey) REFERENCES dim.TransactionDescriptor (TransactionDescriptorKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionTime
	FOREIGN KEY (TransactionTimeKey) REFERENCES dim.Time (TimeKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_TransactionType
	FOREIGN KEY (TransactionTypeKey) REFERENCES dim.TransactionType (TransactionTypeKey);

	ALTER TABLE fact.[Transaction] ADD CONSTRAINT FK_Transaction_User
	FOREIGN KEY (UserKey) REFERENCES dim.[User] (UserKey);

END;
