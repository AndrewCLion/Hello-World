SELECT        sys.syslogins.loginname, sys.syslogins.name, sys.syslogins.dbname, sys.syslogins.sid, sys.syslogins.status, sys.syslogins.createdate, sys.syslogins.updatedate, sys.syslogins.accdate, 
                         sys.syslogins.language, sys.syslogins.denylogin, sys.syslogins.hasaccess, sys.syslogins.isntname, sys.syslogins.isntgroup, 
                         sys.syslogins.isntuser, sys.syslogins.sysadmin, sys.syslogins.securityadmin, sys.syslogins.serveradmin, sys.syslogins.setupadmin, 
                         sys.syslogins.processadmin, sys.syslogins.diskadmin, sys.syslogins.dbcreator, sys.syslogins.bulkadmin, 
                         sys.databases.state_desc
FROM            sys.syslogins LEFT OUTER JOIN
                         sys.databases ON sys.syslogins.dbname = sys.databases.name
WHERE        (ISNULL(sys.databases.state_desc, N'OFFLINE') = N'OFFLINE')