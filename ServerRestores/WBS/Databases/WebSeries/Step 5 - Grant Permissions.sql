/* ---- Grant Permissions ----
SS 13/12/2010
Altered to be called from SQLCMD line
sqlcmd -S systems37\sql2005 -i "\\ldsfileproapp01\systems\Tech support shared data\SQL Server\ServerRestores\DMSPRODBA01\DMS\Step 5 - Grant Permissions.sql"
*/

SET NOCOUNT ON;
PRINT 'Step 5 - Grant Permissions - WebSeries';

-- Re-establish multi-user access
ALTER DATABASE [WebSeries] SET MULTI_USER;

USE [WebSeries];
GO
-- SQL Login Fixes

EXEC sp_change_users_login 'update_one', 'CFLWEBSYSTEM', 'CFLWEBSYSTEM';
GO 
EXEC sp_change_users_login 'update_one', 'CFLADMSYSTEM', 'CFLADMSYSTEM';
GO 
EXEC sp_change_users_login 'update_one', 'CFLARCHIVE', 'CFLARCHIVE';
GO

-- Update Passwords to Adm and Web Accounts
-- Password: Bont2c72
/*
If you want to change to "StepChange1" use this:
'd43f30c8f8033cd6d6253cab166313e5'
*/

UPDATE  ADMSYSTEM.USERS
SET     PASSWORD = '7ddce1ac9db48eea46e6aed7edd5a7fc';

UPDATE  WEBSYSTEM.USERS
SET     PASSWORD = '7ddce1ac9db48eea46e6aed7edd5a7fc';

UPDATE  WEBSYSTEM.USERS
SET     password = 'bfc0f142597877905cb77b9d6db62b75'
WHERE   [USERID] = 'BROKER';

--NEW PERMISSIONS PROCESS
-----------------------------------------------------------------------------------------
DECLARE @EnvironmentType VARCHAR(50);
DECLARE @sql NVARCHAR(1000);
DECLARE @LoginName VARCHAR(50);
DECLARE @AssociatedDatabase VARCHAR(30);
 --TestPermDB
DECLARE @Environment VARCHAR(10);
 --TEST
--DECLARE @DBRole VARCHAR(30)
DECLARE @RunDate AS DATETIME;
DECLARE @SQLLogin AS BIT;
DECLARE @SysAdmin AS BIT;
DECLARE @ViewDefinition AS BIT;
DECLARE @DBOwner AS BIT;
DECLARE @DataReader AS BIT;
DECLARE @DataWriter AS BIT;
DECLARE @AppRoleLevel AS TINYINT;


SET @RunDate = GETDATE();
SET @AssociatedDatabase = $(DBName);
SET @Environment = $(Environment);

--First Retrieve the environment type
SELECT  @EnvironmentType = Es.EnvironmentType
FROM    EnviroDataLinkedServer.EnvironmentAccess.dbo.Environments Es
WHERE   Es.Environment = @Environment;

IF @EnvironmentType IS NULL
    BEGIN
        SELECT  @EnvironmentType = Es.EnvironmentType
        FROM    EnviroDataLinkedServer.EnvironmentAccess.dbo.Environments Es
                INNER JOIN EnviroDataLinkedServer.EnvironmentAccess.dbo.EnvironmentServers ESs ON Es.Environment = ESs.Environment
        WHERE   ESs.EnvironmentServer = @@SERVERNAME;
    END;	

DECLARE dbfiles CURSOR
FOR
    SELECT  EA.LoginName ,
            EA.SQLLogin --, EA.DatabaseName
            ,
            EA.SysAdmin ,
            EA.ViewDefinition ,
            EA.DBOwner ,
            EA.DataReader ,
            EA.DataWriter ,
            EA.AppRoleLevel
    FROM    EnviroDataLinkedServer.EnvironmentAccess.dbo.LoginPermissions EA
--LEFT JOIN
--dbo.DatabaseRoles DbR
--ON EA.Permission = DbR.Permission
--AND EA.DatabaseName = DbR.DatabaseName
    WHERE   (
		--Retrieve permissions if just the environment type set (i.e. apply to all databases/servers in the environment group)
              ( ( EA.EnvironmentType = @EnvironmentType )
                AND ( EA.DatabaseName IS NULL )
                AND ( EA.Environment IS NULL )
              )
              OR --Retrieve permissions if just the environment set (i.e. apply to all databases/servers in the environment)
              ( ( EA.EnvironmentType IS NULL )
                AND ( EA.DatabaseName IS NULL )
                AND ( EA.Environment = @Environment )
              )
              OR --Retrieve permissions if just the database set (i.e. apply to all database servers everywhere for the specified database - used for _MI access)
              ( ( EA.EnvironmentType IS NULL )
                AND ( EA.DatabaseName = @AssociatedDatabase )
                AND ( EA.Environment IS NULL )
              )
              OR --Retrieve permissions if database and environment type set
              ( ( EA.EnvironmentType = @EnvironmentType )
                AND ( EA.DatabaseName = @AssociatedDatabase )
                AND ( EA.Environment IS NULL )
              )
              OR --Retrieve permissions if database and environment set
              ( ( EA.EnvironmentType IS NULL )
                AND ( EA.DatabaseName = @AssociatedDatabase )
                AND ( EA.Environment = @Environment )
              )
            )
            AND ( ( EA.StartDate < @RunDate )
                  OR ( EA.StartDate IS NULL )
                )
            AND ( ( EA.EndDate > @RunDate )
                  OR ( EA.EndDate IS NULL )
                );

OPEN dbfiles;
FETCH NEXT FROM dbfiles INTO @LoginName, @SQLLogin, @SysAdmin, @ViewDefinition,
    @DBOwner, @DataReader, @DataWriter, @AppRoleLevel;
--For each database file...
WHILE @@FETCH_STATUS = 0
    BEGIN
	--CREATE THE LOGIN (CHECK FIRST IF IT ALREADY EXISTS)
        IF @SQLLogin = 1
            BEGIN
		--NB Currently only handles SQL Logins with password same as the login name
                SET @sql = 'IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name =  N'''
                    + @LoginName + ''') CREATE LOGIN [' + @LoginName
                    + '] WITH PASSWORD=N''' + @LoginName
                    + ''', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF';
                EXEC(@sql);
            END;
        ELSE
            BEGIN
                SET @sql = 'IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name =  N'''
                    + @LoginName + ''') CREATE LOGIN [' + @LoginName
                    + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]';
                EXEC(@sql);
            END;
	--CREATE THE USER
        SET @sql = 'USE ' + @AssociatedDatabase
            + ' IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name =  N'''
            + @LoginName + ''') CREATE USER [' + @LoginName + '] FOR LOGIN ['
            + @LoginName + ']';
        EXEC(@sql);

        IF @SysAdmin = 1
            BEGIN
                SET @sql = 'EXEC master..sp_addsrvrolemember @loginame = N'''
                    + @LoginName + ''', @rolename = N''sysadmin''';
                EXEC(@sql);
            END;
        IF @DBOwner = 1
            BEGIN
                SET @sql = 'USE ' + @AssociatedDatabase
                    + ' EXEC sp_addrolemember N''db_owner'', N''' + @LoginName
                    + '''';
                EXEC(@sql);
            END;
        IF @DataReader = 1
            BEGIN
                SET @sql = 'USE ' + @AssociatedDatabase
                    + ' EXEC sp_addrolemember N''db_datareader'', N'''
                    + @LoginName + '''';
                EXEC(@sql);
            END;
        IF @DataWriter = 1
            BEGIN
                SET @sql = 'USE ' + @AssociatedDatabase
                    + ' EXEC sp_addrolemember N''db_datawriter'', N'''
                    + @LoginName + '''';
                EXEC(@sql);
            END;
        IF @ViewDefinition = 1
            BEGIN
                SET @sql = 'USE ' + @AssociatedDatabase
                    + ' GRANT VIEW DEFINITION TO [' + @LoginName + ']';
                EXEC(@sql);
            END;
	

        FETCH NEXT FROM dbfiles INTO @LoginName, @SQLLogin, @SysAdmin,
            @ViewDefinition, @DBOwner, @DataReader, @DataWriter, @AppRoleLevel;
    END;
CLOSE dbfiles; 
DEALLOCATE dbfiles; 
-----------------------------------------------------------------------------------------