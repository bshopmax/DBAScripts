USE [msdb];
GO

/* Show existing job step flags first */
SELECT	'' AS Job,
		'' AS Step,
		'*** Existing Job Step Flags ***' AS [Step Name],
		'' AS [Step Flags]
UNION ALL
SELECT	j.name AS Job,
		CAST(js.step_id AS VARCHAR) AS Step,
		js.step_name AS [Step Name],
		CAST(js.flags AS VARCHAR) AS [Step Flags]
FROM	[dbo].[sysjobsteps] js
INNER JOIN
		[dbo].[sysjobs] j
ON		js.job_id = j.job_id
ORDER BY
		Job, Step
GO

/* Update the flags */
UPDATE	[dbo].[sysjobsteps]
SET		flags = (flags | 8) & (~16) -- Tick the "Log to table" check box and untick the "Append output to existing entry in table" check box
GO

/* Show new job step flags */
SELECT	'' AS Job,
		'' AS Step,
		'*** New Job Step Flags ***' AS [Step Name],
		'' AS [Step Flags]
UNION ALL
SELECT	j.name AS Job,
		CAST(js.step_id AS VARCHAR) AS Step,
		js.step_name AS [Step Name],
		CAST(js.flags AS VARCHAR) AS [Step Flags]
FROM	[dbo].[sysjobsteps] js
INNER JOIN
		[dbo].[sysjobs] j
ON		js.job_id = j.job_id
ORDER BY
		Job, Step
GO



-- Example usage:

-- EXEC msdb..sp_help_jobsteplog @job_name = 'CWS Data Refresh'