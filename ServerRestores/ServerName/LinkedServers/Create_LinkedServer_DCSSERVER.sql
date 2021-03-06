--SCRIPT IS GOOD ONLY FOR ENVIRONMENTS
--BEGINNING VMxx

DECLARE @ENVNAME VARCHAR(15)
--SET @ENVNAME = LEFT(@@SERVERNAME, 4) + 'DCSSERVER'
SET @ENVNAME = LEFT(@@SERVERNAME, 4) + 'DCSPRODBA01'

/****** Object:  LinkedServer [DCSSERVER]    Script Date: 03/30/2009 10:51:52 ******/
--EXEC master.dbo.sp_addlinkedserver @server = N'DCSSERVER', @srvproduct=N'<Server to link to e.g. VM01DCSSERVER, varchar(15), VMxxDCSSERVER>', @provider=N'SQLOLEDB', @datasrc=N'<Server to link to e.g. VM01DCSSERVER, varchar(15), VMxxDCSSERVER>'
EXEC master.dbo.sp_addlinkedserver @server = N'DCSSERVER', @srvproduct=@ENVNAME, @provider=N'SQLNCLI', @datasrc=@ENVNAME
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DCSSERVER',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqlserverlink',@rmtpassword='sqlserverlink'

EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'collation compatible', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'data access', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'dist', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'pub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'rpc', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'rpc out', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'sub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'connect timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'collation name', @optvalue=null
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'lazy schema validation', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'query timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=N'DCSSERVER', @optname=N'use remote collation', @optvalue=N'true'