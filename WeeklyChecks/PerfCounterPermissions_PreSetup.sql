/**
IF (SELECT LEFT (CONVERT (VARCHAR, SERVERPROPERTY('productversion')), 1)) = 9
	BEGIN
		USE master
		IF NOT EXISTS (SELECT 1 FROM master.dbo.syslogins WHERE [name] = 'NT AUTHORITY\NETWORK SERVICE')
			BEGIN
				CREATE LOGIN [NT AUTHORITY\NETWORK SERVICE] FROM WINDOWS
			END 
		
		
		USE SystemsHelpDesk
		
		
		IF NOT EXISTS (SELECT 1 FROM master.dbo.sysusers WHERE [name] = 'NT AUTHORITY\NETWORK SERVICE')
			BEGIN
				CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE]
			END 
	END
	**/

	USE master
		IF NOT EXISTS (SELECT 1 FROM master.dbo.syslogins WHERE [name] = 'NT AUTHORITY\NETWORK SERVICE')
			BEGIN
				exec sp_grantlogin N'NT AUTHORITY\NETWORK SERVICE'
			END 
		
		
		USE SystemsHelpDesk
		
		
		IF NOT EXISTS (SELECT 1 FROM master.dbo.sysusers WHERE [name] = 'NT AUTHORITY\NETWORK SERVICE')
			BEGIN
				exec sp_grantdbaccess N'NT AUTHORITY\NETWORK SERVICE', 'NT AUTHORITY\NETWORK SERVICE'
				exec sp_addrolemember  db_owner, N'NT AUTHORITY\NETWORK SERVICE'			
			END 
	

	

	

	


