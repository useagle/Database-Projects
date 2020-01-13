USE USEagleDW;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'etl' AND name = 'uspFact_CurrentShare_FullRefresh')
	DROP PROCEDURE etl.uspFact_CurrentShare_FullRefresh;
GO


CREATE PROCEDURE etl.uspFact_CurrentShare_FullRefresh
AS
BEGIN

	DECLARE
		@ProcessDate		DATE,
		@ProcessDateInt		INT;

	SELECT
		@ProcessDateInt = MAX(ProcessDate)
	FROM
		Staging.arcusym000.dbo_SAVINGS


	SET @ProcessDate = CONVERT(DATE, CAST(@ProcessDateInt AS VARCHAR), 112);



	DELETE
	FROM
		dim.ShareDescriptor
	WHERE
		ShareDescriptorKey >= 0;


	DBCC CHECKIDENT('dim.ShareDescriptor', RESEED, 0);



	WITH Shares AS
	(
		SELECT
			ShareAccountNumber = Share.PARENTACCOUNT + '-' + CAST(Share.ID AS VARCHAR),
			ShareID = RTRIM(Share.ID),
			ShareDescriptorSourceSystem = 'ARCU',
			ShareDescriptorSourceID = Share.etlSurrogateKey
		FROM
			Staging.arcusym000.dbo_SAVINGS Share
		WHERE
			Share.ProcessDate = @ProcessDateInt
			AND
			Share.OPENDATE <> ISNULL(Share.CLOSEDATE, '2077-12-31')
	)
	INSERT INTO
		dim.ShareDescriptor
	(
		ShareAccountNumber,
		ShareID,
		ShareDescriptorSourceSystem,
		ShareDescriptorSourceID,
		ShareDescriptorHash,
		ShareDescriptorStartEffectiveDate,
		ShareDescriptorEndEffectiveDate,
		ShareDescriptorActiveRecordFlag
	)
	SELECT
		ShareAccountNumber,
		ShareID,
		ShareDescriptorSourceSystem,
		ShareDescriptorSourceID,
		ShareDescriptorHash = HASHBYTES('SHA2_512', ShareAccountNumber),
		ShareDescriptorStartEffectiveDate = CAST(SYSDATETIME() AS DATE),
		ShareDescriptorEndEffectiveDate = '2099-12-31',
		ShareDescriptorActiveRecordFlag = 'Y'
	FROM
		Shares
	ORDER BY
		ShareDescriptorSourceID;


	TRUNCATE TABLE fact.CurrentShare;


	WITH ShareHolds AS
	(
		SELECT
			Hld.PARENTACCOUNT,
			Hld.PARENTID,
			HoldAmount = SUM(Hld.AMOUNT)
		FROM
			Staging.arcusym000.dbo_SAVINGSHOLD Hld
		WHERE
			Hld.ProcessDate = @ProcessDateInt
			AND
			(Hld.EXPIRATIONDATE > @ProcessDate
				OR
				Hld.EXPIRATIONDATE IS NULL)
			AND
			Hld.MATCHDATE IS NULL
			AND
			Hld.TYPE <> 18
		GROUP BY
			Hld.PARENTACCOUNT,
			Hld.PARENTID
	)
	INSERT INTO
		fact.CurrentShare
	(
		AccountTypeKey,
		MemberKey,
		MemberBranchKey,
		OriginatedByUserKey,
		ShareBranchKey,
		ShareChargeOffDateKey,
		ShareCloseDateKey,
		ShareDescriptorKey,
		ShareLastTransactionDateKey,
		ShareOpenDateKey,
		ShareOriginationBranchKey,
		ShareStatusKey,
		ChargedOffShareCount,
		ClosedShareCount,
		ShareAvailableBalance,
		ShareChargeOffAmount,
		ShareCurrentBalance,
		ShareDividendRate,
		ShareHoldAmount,
		ShareMinimumBalance,
		ShareOriginalBalance,
		ShareTerm,
		OpenShareCount,
		TotalShareCount,
		ShareSourceSystem,
		ShareSourceID
	)
	SELECT
		AccountTypeKey = ISNULL(AcctTyp.AccountTypeKey, -1),
		MemberKey = ISNULL(Mem.MemberKey, -1),
		MemberBranchKey = ISNULL(MemBr.BranchKey, -1),
		OriginatedByUserKey = ISNULL(Usr.UserKey, -1),
		ShareBranchKey = ISNULL(ShareBr.BranchKey, -1),
		ShareChargeOffDateKey =	CASE
									WHEN Share.CHARGEOFFDATE IS NULL AND Share.CHARGEOFFAMOUNT = 0 THEN -2
									WHEN Share.CHARGEOFFDATE IS NULL AND Share.CHARGEOFFAMOUNT > 0 THEN -1
									ELSE 10000 * YEAR(Share.CHARGEOFFDATE) + 100 * MONTH(Share.CHARGEOFFDATE) + DAY(Share.CHARGEOFFDATE)
								END,
		ShareCloseDateKey =	CASE
								WHEN Share.CLOSEDATE IS NULL THEN -2
								ELSE 10000 * YEAR(Share.CLOSEDATE) + 100 * MONTH(Share.CLOSEDATE) + DAY(Share.CLOSEDATE)
							END,
		ShareDescriptorKey = ISNULL(Descr.ShareDescriptorKey, -1),
		ShareLastTransactionDateKey =	CASE
											WHEN Share.ACTIVITYDATE IS NULL THEN -1
											ELSE 10000 * YEAR(Share.ACTIVITYDATE) + 100 * MONTH(Share.ACTIVITYDATE) + DAY(Share.ACTIVITYDATE)
										END,
		ShareOpenDateKey =	CASE
								WHEN Share.OPENDATE IS NULL THEN -1
								ELSE 10000 * YEAR(Share.OPENDATE) + 100 * MONTH(Share.OPENDATE) + DAY(Share.OPENDATE)
							END,
		ShareOriginationBranchKey = ISNULL(OrigBr.BranchKey, -1),
		ShareStatusKey =	CASE
							WHEN Share.CHARGEOFFDATE IS NOT NULL THEN 3
							WHEN Share.CLOSEDATE IS NOT NULL THEN 2
							WHEN Share.OPENDATE IS NOT NULL THEN 1
							ELSE -1
						END,
		ChargedOffShareCount =	CASE
									WHEN Share.CHARGEOFFDATE IS NULL THEN 0
									ELSE 1
								END,
		ClosedShareCount =	CASE
								WHEN Share.CLOSEDATE IS NULL THEN 0
								ELSE 1
							END,
		ShareAvailableBalance = Share.BALANCE - Share.MINIMUMBALANCE - ISNULL(Hld.HoldAmount, 0),
		ShareChargeOffAmount = Share.CHARGEOFFAMOUNT,
		ShareCurrentBalance = Share.BALANCE,
		ShareDividendRate = ShDtl.ShareDivRate / 100000.0,
		ShareHoldAmount = ISNULL(Hld.HoldAmount, 0),
		ShareMinimumBalance = Share.MINIMUMBALANCE,
		ShareOriginalBalance = Share.ORIGINALBALANCE,
		ShareTerm = Share.TERMFREQUENCY,
		OpenShareCount =	CASE
							WHEN Share.CLOSEDATE IS NULL AND Share.CHARGEOFFDATE IS NULL THEN 1
							ELSE 0
						END,
		TotalShareCount = 1,
		ShareSourceSystem = 'ARCU',
		ShareSourceID = 'S' + RTRIM(Share.PARENTACCOUNT) + RTRIM(Share.ID)
	FROM
		Staging.arcusym000.dbo_SAVINGS Share
			INNER JOIN
		Staging.arcusym000.arcu_ARCUShareDetailed ShDtl
			ON Share.PARENTACCOUNT = ShDtl.AccountNumber AND  Share.ID = ShDtl.ShareID AND ShDtl.ProcessDate = @ProcessDateInt
			INNER JOIN
		Staging.arcusym000.arcu_vwARCUMemberAccounts MemAcct
			ON Share.PARENTACCOUNT = MemAcct.AccountNumber AND MemAcct.ProcessDate = @ProcessDateInt
			LEFT JOIN
		ShareHolds Hld
			ON Share.PARENTACCOUNT = Hld.PARENTACCOUNT AND Share.ID = Hld.PARENTID
			LEFT JOIN
		USEagleDW.dim.AccountType AcctTyp
			ON AcctTyp.AccountTypeSourceSystem = 'ARCU' AND 'Share|' + CAST(Share.TYPE AS VARCHAR) + '|NA' = AcctTyp.AccountTypeSourceID AND AcctTyp.AccountTypeActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch ShareBr
			ON ShareBr.BranchSourceSystem = 'ARCU' AND Share.BRANCH = ShareBr.BranchSourceID AND ShareBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch MemBr
			ON MemBr.BranchSourceSystem = 'ARCU' AND MemAcct.AccountBranch = MemBr.BranchSourceID AND MemBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Branch OrigBr
			ON OrigBr.BranchSourceSystem = 'ARCU' AND Share.CREATEDATBRANCH = OrigBr.BranchSourceID AND OrigBr.BranchActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.ShareDescriptor Descr
			ON Descr.ShareDescriptorSourceSystem = 'ARCU' AND Share.etlSurrogateKey = Descr.ShareDescriptorSourceID AND Descr.ShareDescriptorActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.Member Mem
			ON Mem.MemberSourceSystem = 'ARCU' AND Share.PARENTACCOUNT = Mem.MemberSourceID AND Mem.MemberActiveRecordFlag = 'Y'
			LEFT JOIN
		USEagleDW.dim.[User] Usr
			ON Usr.UserSourceSystem = 'ARCU' AND Share.CREATEDBYUSER = Usr.UserSourceID AND Usr.UserActiveRecordFlag = 'Y'
	WHERE
		Share.ProcessDate = @ProcessDateInt
		AND
		Share.OPENDATE <> ISNULL(Share.CLOSEDATE, '2077-12-31')
	ORDER BY
		Share.etlSurrogateKey;

END;
