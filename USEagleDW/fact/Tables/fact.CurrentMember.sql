USE USEagleDW;
GO


IF NOT EXISTS(SELECT * FROM sys.objects WHERE SCHEMA_NAME(schema_id) = 'fact' AND name = 'CurrentMember')
BEGIN

	CREATE TABLE
		fact.CurrentMember
	(
		CurrentMemberKey				INT IDENTITY(1, 1),
		MemberBranchKey				INT NOT NULL,
		MemberCloseDateKey				INT NOT NULL,
		MemberDescriptorKey			INT NOT NULL,
		MemberOpenDateKey				INT NOT NULL,
		AllMembersCount				INT NOT NULL,
		ClosedMembersCount				INT NOT NULL,
		OpenMembersCount				INT NOT NULL,
		OpenLoansCount					INT NOT NULL,
		OpenSharesCount					INT NOT NULL,
		TotalLoanBalance				DECIMAL(16, 2) NOT NULL,
		TotalShareBalance				DECIMAL(16, 2) NOT NULL,
		CurrentMemberSourceSystem		VARCHAR(25) NOT NULL,
		CurrentMemberSourceID			VARCHAR(10) NOT NULL
	);

	ALTER TABLE fact.CurrentMember ADD CONSTRAINT PK_CurrentMember
	PRIMARY KEY CLUSTERED (CurrentMemberKey);

	ALTER TABLE fact.CurrentMember ADD CONSTRAINT FK_CurrentMember_MemberBranch
	FOREIGN KEY (MemberBranchKey) REFERENCES dim.Branch (BranchKey);

	ALTER TABLE fact.CurrentMember ADD CONSTRAINT FK_CurrentMember_MemberCloseDate
	FOREIGN KEY (MemberCloseDateKey) REFERENCES dim.Calendar (CalendarKey);

	ALTER TABLE fact.CurrentMember ADD CONSTRAINT FK_CurrentMember_MemberDescriptor
	FOREIGN KEY (MemberDescriptorKey) REFERENCES dim.MemberDescriptor (MemberDescriptorKey);

	ALTER TABLE fact.CurrentMember ADD CONSTRAINT FK_CurrentMember_MemberOpenDate
	FOREIGN KEY (MemberOpenDateKey) REFERENCES dim.Calendar (CalendarKey);

END;
