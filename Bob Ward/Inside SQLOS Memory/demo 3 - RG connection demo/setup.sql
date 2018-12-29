-- Create logins for RG demo
--
CREATE LOGIN Mavericks WITH PASSWORD = 'UserPwd', CHECK_POLICY = OFF
CREATE LOGIN Lakers WITH PASSWORD = 'UserPwd', CHECK_POLICY = OFF
CREATE USER Mavericks FOR LOGIN Mavericks
CREATE USER Lakers FOR LOGIN Lakers
go
-- Create resource pools
--
CREATE RESOURCE POOL MavericksPool
CREATE RESOURCE POOL LakersPool
-- Create workload groups
--
CREATE WORKLOAD GROUP MavericksGroup
USING MavericksPool
go
CREATE WORKLOAD GROUP LakersGroup
USING LakersPool
go
-- Affinitize sales to node 0 and marketing to node 1
--
ALTER RESOURCE POOL MavericksPool
WITH (AFFINITY NUMANODE = (0))
GO
ALTER RESOURCE POOL LakersPool
WITH (AFFINITY NUMANODE = (1))
GO

--  Create classifier function
--
CREATE FUNCTION CLASSIFIER_V1()
RETURNS SYSNAME WITH SCHEMABINDING
BEGIN
	DECLARE @val varchar(32)
	SET @val = 'default';
	IF 'Mavericks' = SUSER_SNAME()
		SET @val = 'MavericksGroup';
	ELSE IF 'Lakers' = SUSER_SNAME()
		SET @val = 'LakersGroup';
	RETURN @val;
END
go
-- Bind classifier function
--
ALTER RESOURCE GOVERNOR 
WITH (CLASSIFIER_FUNCTION = dbo.CLASSIFIER_V1)
GO

-- Reconfigure RG
--
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

