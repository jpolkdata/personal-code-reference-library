USE master
GO
SELECT 
    (SELECT TOP 1 * from string_split (Substring(txt.TEXT, (req.statement_start_offset / 2) + 1, (
                (
                    CASE req.statement_end_offset
                        WHEN - 1 THEN Datalength(txt.TEXT)
                        ELSE req.statement_end_offset
                    END - req.statement_start_offset
                    ) / 2
                ) + 1), ',') WHERE value like '%MOVE%' OR value like '%Restore%') AS RestoreInfo,
    req.percent_complete,
    elapsed_min = CONVERT(NUMERIC(6, 2), req.[total_elapsed_time] / 1000.0 / 60.0),
    remaning_eta_min = CONVERT(NUMERIC(6, 2), req.[estimated_completion_time] / 1000.0 / 60.0),
    req.start_time,
    eta_completion_time = DATEADD(ms, req.[estimated_completion_time], GETDATE()),
    req.session_id, 
    req.status,
    req.blocking_session_id, 
    req.command,
    [sql_text] = Substring(txt.TEXT, (req.statement_start_offset / 2) + 1, (
                (
                    CASE req.statement_end_offset
                        WHEN - 1 THEN Datalength(txt.TEXT)
                        ELSE req.statement_end_offset
                    END - req.statement_start_offset
                    ) / 2
                ) + 1),
    cpu_time_sec = req.cpu_time / 1000,
    granted_query_memory_mb = CONVERT(NUMERIC(8, 2), req.granted_query_memory / 128.),
    req.reads,
    req.logical_reads,
    req.writes,
    wait_type,
    wait_time_sec = wait_time/1000, 
    wait_resource
FROM sys.dm_exec_requests as req WITH(NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) as txt 
WHERE command LIKE '%RESTORE%'
