CREATE PROCEDURE dbo.pGetAuditTrailData
    @tableName SYSNAME,
    @startDateTime DATETIMEOFFSET = NULL,
    @days INT = NULL, @hours INT = NULL, @minutes INT = NULL, @seconds INT = NULL,
    @captureInstance SYSNAME = NULL
AS 
-- ************************************************************************************
-- Procedure:     pGetAuditTrailData
--
-- Parameter:     @tableName - table name for which to get Audit and CDC data.
--                @startDateTime - date and time of earliest event requested;
--                      Default is NULL. See Remarks for more info.
--                @days, @hours, @minutes, @seconds - time span to substract from current
--                      Defaults are NULL for all 4 parameters. See Remarks for more info.
--                @captureInstance - the capture instance name. Default is NULL which
--                      means that the procedure has to find it.
--
-- Description:   Returns SQL Audit data and CDC data for specified table, starting
--                from given time. This procedure returns two results.
--
-- Remarks:       Date and time may be specified using either @startDateTime or relative
--                values: @days, @hours, @minutes, @seconds, which are substracted
--                from current datetime. If @startDateTime is specified, then
--                @days, @hours, @minutes, @seconds values are ignored.
--                If none is specified, all available data is returned.
--
-- Examples:
--                -- get all available data for a table
--                EXEC pGetAuditTrailData 'dbo.table1'
--                -- get data for a table changes made during the last 1,5 day
--                EXEC pGetAuditTrailData 'dbo.table1', @days = 1, @hours = 12
--                EXEC pGetAuditTrailData 'dbo.table1', @hours = 36
--                -- get data for a table changes made since given date
--                EXEC pGetAuditTrailData 'dbo.table1', @startDateTime = '20140101 12:34:56'
--                EXEC pGetAuditTrailData 'dbo.table1', @startDateTime = '20140101 12:34:56-06:00'
--
-- ************************************************************************************* 

    SET NOCOUNT ON;

    DECLARE @msg NVARCHAR(1000);

    DECLARE @objectId INT = OBJECT_ID(@tableName, N'U');
    IF @objectId IS NULL
    BEGIN;
        RAISERROR (2706, 11, 1);  -- table does not exist
    END;

    -- calculate required starting time

    DECLARE @isTimeSpanSpecified BIT = IIF(
        @startDateTime IS NOT NULL OR
        @days IS NOT NULL OR
        @hours IS NOT NULL OR
        @minutes IS NOT NULL OR
        @seconds IS NOT NULL
        , 1, 0);

    IF @startDateTime IS NULL 
    BEGIN;
        SET @startDateTime = SYSDATETIMEOFFSET();
        SET @startDateTime = DATEADD(dd, - ISNULL(@days, 0), @startDateTime);
        SET @startDateTime = DATEADD(hh, - ISNULL(@hours, 0), @startDateTime);
        SET @startDateTime = DATEADD(mi, - ISNULL(@minutes, 0), @startDateTime);
        SET @startDateTime = DATEADD(ss, - ISNULL(@seconds, 0), @startDateTime);
    END;
    ELSE
    BEGIN;
        IF DATEPART(tz, @startDateTime) = 0
            SET @startDateTime = TODATETIMEOFFSET(@startDateTime, DATENAME(tz, SYSDATETIMEOFFSET()));
    END;

    DECLARE @schemaName SYSNAME, @canonicalTableName SYSNAME;
    SELECT @schemaName = s.name, @canonicalTableName = t.name
        FROM sys.tables t JOIN sys.schemas s on t.[schema_id] = s.[schema_id]
        WHERE t.[object_id] = @objectId;

    DECLARE @quotedTableName SYSNAME = CONCAT(
        QUOTENAME(@schemaName), '.', QUOTENAME(@canonicalTableName));

    -- return SQL Audit data
    ;WITH AuditData AS (
    SELECT
        SWITCHOFFSET(CONVERT(DATETIMEOFFSET, af.event_time), 
                     DATENAME(TZOFFSET,SYSDATETIMEOFFSET())) AS local_time,
        af.sequence_number,
        af.action_id, aa.name AS action_name, 
        af.succeeded, af.session_id, 
        af.server_instance_name,
        af.database_name, af.[object_id], 
        af.[schema_name], af.[object_name],
        af.[statement],
        af.session_server_principal_name,
        af.server_principal_name,
        af.database_principal_name,
        af.target_server_principal_name,
        af.target_database_principal_name,
        af.additional_information,
        af.user_defined_event_id,
        af.user_defined_information
    FROM sys.fn_get_audit_file (
        (SELECT log_file_path FROM sys.server_file_audits
        WHERE name = 'ServerAuditName') + '*.sqlaudit', DEFAULT, DEFAULT) AS af 
    LEFT JOIN (SELECT DISTINCT action_id, name FROM sys.dm_audit_actions) AS aa
        ON af.action_id = aa.action_id
    )
    SELECT * FROM AuditData
    WHERE
        [schema_name] = @schemaName
        AND [object_name] = @canonicalTableName
        AND (@isTimeSpanSpecified = 0 OR local_time >= @startDateTime)
    ORDER BY local_time, sequence_number;

    -- get CDC data

    -- check if CDC is enabled for the table
    IF NOT EXISTS(SELECT * FROM cdc.change_tables WHERE source_object_id = @objectId)
    BEGIN;
        SET @msg = CONCAT('CDC is not enabled for table ', @quotedTableName);
        THROW 50000, @msg, 1;
        RETURN;
    END;

    -- check if there are multiple capture instances for the table
    -- in this case we require the user to provide one
    IF 1 < (SELECT COUNT(*) FROM cdc.change_tables WHERE source_object_id = @objectId)
        AND @captureInstance IS NULL
    BEGIN;
        SET @msg = CONCAT('Table ', @quotedTableName, ' has two CDC capture instances.',
            ' Please provide which one to query with @captureInstance argument.');
        THROW 50000, @msg, 1;
        RETURN;
    END;

    -- check if the provided capture instance name is valid
    IF @captureInstance IS NOT NULL AND
        NOT EXISTS(SELECT * FROM cdc.change_tables
            WHERE source_object_id = @objectId
            AND capture_instance = @captureInstance)
    BEGIN;
        -- the capture instance %s has not been enabled for the source table
        RAISERROR(22960, 16, 1, @captureInstance, @schemaName, @canonicalTableName);
        RETURN;
    END;

    -- caller did not provide capture instance name; find it
    IF @captureInstance IS NULL
    BEGIN;
        SELECT @captureInstance = capture_instance 
        FROM cdc.change_tables 
        WHERE source_object_id = @objectId;
    END;

    -- construct the statement; it's dynamic because:
    --  * functions have capture instance name in their name, and
    --  * returned rowset has different columns depending on capture instance
    DECLARE @cdcStmtTemplate NVARCHAR(4000)  = 
N'
SELECT
    TODATETIMEOFFSET(sys.fn_cdc_map_lsn_to_time (__$start_lsn),
        DATENAME(TZOFFSET,SYSDATETIMEOFFSET())) AS __ChangeTime
    , CASE cdcData.__$operation 
        WHEN 1 THEN ''Delete'' 
        WHEN 2 THEN ''Insert'' 
        WHEN 3 THEN ''Update - Before'' 
        WHEN 4 THEN ''Update - After'' 
    END AS __ChangeType
    , * 
FROM cdc.fn_cdc_get_all_changes_%%CAPTURE_INSTANCE%%(
    sys.fn_cdc_get_min_lsn(''%%CAPTURE_INSTANCE%%''),
    sys.fn_cdc_get_max_lsn(), ''all update old'') cdcData
WHERE %%IS_TIMESPAN_SPECIFIED%% = 0 OR
    sys.fn_cdc_map_lsn_to_time (__$start_lsn) >= CONVERT(DATETIME2(3), ''%%START_DATE_TIME%%'')
    -- The above conversion strips time zone information, because CDC do not use time zones

ORDER BY __$start_lsn
;';
    -- In the above code we cannot efficiently filter by from_lsn parameter of
    -- cdc.fn_cdc_get_all_changes_... function, because if the LSN obtained by
    -- sys.fn_cdc_map_time_to_lsn does not fall within the change tracking timeline
    -- for the capture instance, the function returns error 208 ("An insufficient
    -- number of arguments were supplied for the procedure or function
    -- cdc.fn_cdc_get_all_changes...").
    -- See also http://technet.microsoft.com/en-us/library/bb510627.aspx

    DECLARE @cdcStmt NVARCHAR(4000) = 
        REPLACE(REPLACE(REPLACE(@cdcStmtTemplate, 
            N'%%CAPTURE_INSTANCE%%', @captureInstance),
            N'%%IS_TIMESPAN_SPECIFIED%%', LTRIM(STR(@isTimeSpanSpecified))),
            N'%%START_DATE_TIME%%', CONVERT(NVARCHAR(100), @startDateTime, 126));

    -- return CDC data
    EXEC (@cdcStmt);

