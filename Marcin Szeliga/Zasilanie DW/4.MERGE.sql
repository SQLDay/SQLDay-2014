-- ==================================================
-- Slowly Changing Dimension script by SCD Merge Wizard
-- Author: Miljan Radovic
-- Official web site: https://scdmergewizard.codeplex.com/
-- Version: 4.0.0.0
-- Publish date: 2013-07-27 16:29:11
-- Script creation date: 2014-04-21 14:50:19
-- ==================================================


-- ==================================================
-- TRANSFORMATIONS
-- ==================================================

-- Source : [StageV1].[dbo].[DimCustomers]
-- Target : [DW].[dbo].[DimCustomers]
-- 
-- | Source Column         | Transformation | Target Column         | Custom Insert Value | Custom Update Value | Custom Delete Value |
-- ------------------------------------------------------------------------------------------------------------------------------------
-- | [BirthDate]           | SCD0           | [BirthDate]           |                     |                     |                     |
-- | [CustomerBusinessKey] | Business Key   | [CustomerBusinessKey] |                     |                     |                     |
-- |                       | SCD2 Date To   | [EndDate]             | @NullDateTime       | @CurrentDateTime    | @NullDateTime       |
-- | [EnglishEducation]    | SCD2           | [EnglishEducation]    |                     |                     |                     |
-- | [FirstName]           | SCD1           | [FirstName]           |                     |                     |                     |
-- | [LastName]            | SCD1           | [LastName]            |                     |                     |                     |
-- | [Phone]               | SCD0           | [Phone]               |                     |                     |                     |
-- |                       | SCD2 Date From | [StartDate]           | @NullDateTime       | @NullDateTime       |                     |
-- | [Title]               | SCD1           | [Title]               |                     |                     |                     |
-- ------------------------------------------------------------------------------------------------------------------------------------
-- 

-- ==================================================
-- USER VARIABLES
-- ==================================================
DECLARE @CurrentDateTime date
DECLARE @NullDateTime date

SELECT
	@CurrentDateTime = cast(getdate() as datetime),
	@NullDateTime = cast(null as datetime)


-- ==================================================
-- SCD1
-- ==================================================
MERGE [DW].[dbo].[DimCustomers] as [target]
USING
(
	SELECT
		[BirthDate],
		[CustomerBusinessKey],
		[EnglishEducation],
		[FirstName],
		[LastName],
		[Phone],
		[Title]
	FROM [StageV1].[dbo].[DimCustomers]
) as [source]
ON
(
	[source].[CustomerBusinessKey] = [target].[CustomerBusinessKey]
)

WHEN MATCHED AND
(
	([target].[EndDate] = @NullDateTime OR ([target].[EndDate] IS NULL AND @NullDateTime IS NULL))
)
AND
(
	([source].[FirstName] <> [target].[FirstName] OR ([source].[FirstName] IS NULL AND [target].[FirstName] IS NOT NULL) OR ([source].[FirstName] IS NOT NULL AND [target].[FirstName] IS NULL)) OR
	([source].[LastName] <> [target].[LastName] OR ([source].[LastName] IS NULL AND [target].[LastName] IS NOT NULL) OR ([source].[LastName] IS NOT NULL AND [target].[LastName] IS NULL)) OR
	([source].[Title] <> [target].[Title] OR ([source].[Title] IS NULL AND [target].[Title] IS NOT NULL) OR ([source].[Title] IS NOT NULL AND [target].[Title] IS NULL))
)
AND
(
	([source].[EnglishEducation] = [target].[EnglishEducation] OR ([source].[EnglishEducation] IS NULL AND [target].[EnglishEducation] IS NULL))
)
THEN UPDATE
SET
	[target].[FirstName] = [source].[FirstName],
	[target].[LastName] = [source].[LastName],
	[target].[Title] = [source].[Title]
;


-- ==================================================
-- SCD2
-- ==================================================
INSERT INTO [DW].[dbo].[DimCustomers]
(
	[BirthDate],
	[CustomerBusinessKey],
	[EndDate],
	[EnglishEducation],
	[FirstName],
	[LastName],
	[Phone],
	[StartDate],
	[Title]
)
SELECT
	[BirthDate],
	[CustomerBusinessKey],
	[EndDate],
	[EnglishEducation],
	[FirstName],
	[LastName],
	[Phone],
	[StartDate],
	[Title]
FROM
(
	MERGE [DW].[dbo].[DimCustomers] as [target]
	USING
	(
		SELECT
			[BirthDate],
			[CustomerBusinessKey],
			[EnglishEducation],
			[FirstName],
			[LastName],
			[Phone],
			[Title]
		FROM [StageV1].[dbo].[DimCustomers]

	) as [source]
	ON
	(
		[source].[CustomerBusinessKey] = [target].[CustomerBusinessKey]
	)

	WHEN NOT MATCHED BY TARGET
	THEN INSERT
	(
		[BirthDate],
		[CustomerBusinessKey],
		[EndDate],
		[EnglishEducation],
		[FirstName],
		[LastName],
		[Phone],
		[StartDate],
		[Title]
	)
	VALUES
	(
		[BirthDate],
		[CustomerBusinessKey],
		@NullDateTime,
		[EnglishEducation],
		[FirstName],
		[LastName],
		[Phone],
		@NullDateTime,
		[Title]
	)


WHEN MATCHED AND
(
	([EndDate] = @NullDateTime OR ([EndDate] IS NULL AND @NullDateTime IS NULL))
)
AND
(
	([target].[EnglishEducation] <> [source].[EnglishEducation] OR ([target].[EnglishEducation] IS NULL AND [source].[EnglishEducation] IS NOT NULL) OR ([target].[EnglishEducation] IS NOT NULL AND [source].[EnglishEducation] IS NULL))

)
	THEN UPDATE
	SET
		[EndDate] = @CurrentDateTime


	OUTPUT
		$Action as [MERGE_ACTION_7a1a05c2-d678-473e-b932-708241fc6996],
		[source].[BirthDate] AS [BirthDate],
		[source].[CustomerBusinessKey] AS [CustomerBusinessKey],
		@NullDateTime AS [EndDate],
		[source].[EnglishEducation] AS [EnglishEducation],
		[source].[FirstName] AS [FirstName],
		[source].[LastName] AS [LastName],
		[source].[Phone] AS [Phone],
		@NullDateTime AS [StartDate],
		[source].[Title] AS [Title]

)MERGE_OUTPUT
WHERE MERGE_OUTPUT.[MERGE_ACTION_7a1a05c2-d678-473e-b932-708241fc6996] = 'UPDATE' 
	AND MERGE_OUTPUT.[CustomerBusinessKey] IS NOT NULL
;