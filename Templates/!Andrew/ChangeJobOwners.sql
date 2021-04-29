--select s.name AS Jobname ,l.name as Ownername from  msdb..sysjobs s left join master.sys.syslogins l on s.owner_sid = l.sid
--select s.name as SSISname,l.name  AS Ownername from msdb..sysssispackages s left join master.sys.syslogins l on s.ownersid = l.sid ORDER BY s.name
--EXEC msdb.dbo.sp_help_job

USE [msdb];

SET NOCOUNT ON;

DECLARE @OldOwnerLoginName [sysname] = N'JobOwnerMig' --// <-- Specify user to own all SQL Server Agent jobs
DECLARE @NewOwnerLoginName [sysname] = N'JobOwnerATLAS' --// <-- Specify user to own all SQL Server Agent jobs

----------------------------------------------------------------------------------------------------
--// Internal script local variables											               //--
----------------------------------------------------------------------------------------------------
DECLARE @SQLStatementID01	[int] ,
		@CurrentCommand01	[nvarchar](MAX) ,
		@ErrorMessage		[varchar](MAX) 

IF OBJECT_ID(N'TempDb.dbo.#Work_To_Do') IS NOT NULL
    DROP TABLE #Work_To_Do 
CREATE TABLE #Work_To_Do
    (
      [SQLID] [int] IDENTITY(1, 1)
                    PRIMARY KEY ,
      [JobName] [sysname] ,
      [TSQL_Text] [varchar](1024) ,
      [Completed] [bit]
    )

INSERT  INTO #Work_To_Do
        ( [JobName] ,
          [TSQL_Text] ,
          [Completed]
        )
        SELECT  s.[name] ,
                'EXEC [msdb]..[sp_update_job] @job_name = N''' + s.[name]
                + N''', @owner_login_name = N''' + @NewOwnerLoginName + N''';' ,
                0
        FROM    [msdb].[dbo].[sysjobs] s left join master.sys.syslogins l on s.owner_sid = l.sid WHERE l.name = @OldOwnerLoginName

SELECT  @SQLStatementID01 = MIN([SQLID])
FROM    #Work_To_Do
WHERE   [Completed] = 0

WHILE @SQLStatementID01 IS NOT NULL
    BEGIN

        SELECT  @CurrentCommand01 = [TSQL_TEXT]
        FROM    #Work_To_Do
        WHERE   [SQLID] = @SQLStatementID01

        BEGIN TRY
            --EXEC [sys].[sp_executesql] @CurrentCommand01
			print  @CurrentCommand01
        END TRY
        BEGIN CATCH

            SET @ErrorMessage = N'"Oops, an error occurred that could not be resolved. For more information, see below:'
                + CHAR(13) + ERROR_MESSAGE() 

            RAISERROR(@ErrorMessage,16,1) WITH NOWAIT

            GOTO ChooseNextCommand
        END CATCH

        ChooseNextCommand:

        UPDATE  #Work_To_Do
        SET     [Completed] = 1
        WHERE   [SQLID] = @SQLStatementID01

        SELECT  @SQLStatementID01 = MIN([SQLID])
        FROM    #Work_To_Do
        WHERE   [Completed] = 0
    END

DROP TABLE #Work_To_Do

SET NOCOUNT OFF;