-- Needs to be in SQLCMD Mode!!
-- Andrew Craven, 2014-2105
-- CP Update 2015.09.22
-- Andrew Craven 2016.07.07 Adjustments

:SetVar _Principal    BY-SP2K13MP01\MP01
:SetVar _PrincipalTCP BY-SP2K13MP01.de.bayer.cnb
:SetVar _PrincipalPort 5022
:SetVar _PrincipalSQLAcc BYACCOUNT\MYUOT                  

:SetVar _Mirror    BY-SP2K13MP02\MP02
:SetVar _MirrorTCP BY-SP2K13MP02.de.bayer.cnb
:SetVar _MirrorPort 5022
:SetVar _MirrorSQLAcc BYACCOUNT\MYUOT

:SetVar _Share \\BY-SP2K13MP02\Xfer
:SetVar _ShareLocal F:\Xfer

:SetVar _DirDataFile F:\Data_01\Data
:SetVar _DirLogFile  F:\Tlog_01\Tlog

:SetVar _Database EMMYBBSPROD_MSS_ProfileDB_BBS1_D_1


--BACKUP FROM
:connect $(_Principal)
Print '-->BackUp $(_Database)'
BACKUP DATABASE $(_Database) TO  DISK = N'$(_Share)\$(_Database).BAK' 
           WITH  COPY_ONLY, 
                NOFORMAT, INIT,  NAME = N'$(_Database)-Vollständig Datenbank Sichern', 
                SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
Print ''
GO

--RESTORE TO
:connect $(_Mirror)
Print '-->Restore $(_Database)'
RESTORE DATABASE $(_Database) FROM  DISK = N'$(_ShareLocal)\$(_Database).BAK' WITH  FILE = 1,  
           MOVE N'$(_Database)'     TO N'$(_DirDataFile)\$(_Database).mdf',  
                MOVE N'$(_Database)_log' TO N'$(_DirLogFile)\$(_Database)_log.LDF',  
                NORECOVERY,  NOUNLOAD,  STATS = 5
GO
Print ''
GO

--BACKUP LOG FROM
:connect $(_Principal)
Print '-->BackUp LOG $(_Database)'
BACKUP LOG      $(_Database) TO  DISK = N'$(_Share)\$(_Database).TRN' 
            WITH  COPY_ONLY, 
                    NOFORMAT, INIT,  NAME = N'$(_Database)-TLog Sichern', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
Print ''
GO

--RESTORE TO
:connect $(_Mirror)
Print '-->Restore LOG $(_Database)'
RESTORE LOG      $(_Database) FROM  DISK = N'$(_ShareLocal)\$(_Database).TRN' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5
GO

--SET Mirror TO
:connect $(_Mirror)
--Create Login SQL-Account FROM
USE [master]
GO
CREATE LOGIN [$(_PrincipalSQLAcc)] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
GRANT CONNECT ON ENDPOINT::[Mirroring] TO [$(_PrincipalSQLAcc)]
GO
ALTER DATABASE [$(_Database)] SET PARTNER = 'TCP://$(_PrincipalTCP):(_PrincipalPort)'
GO

--SET Mirror FROM
:connect $(_Principal)
USE [master]
GO
--Create Login SQL-Account TO
CREATE LOGIN [$(_MirrorSQLAcc)] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
GRANT CONNECT ON ENDPOINT::[Mirroring] TO [$(_MirrorSQLAcc)]
GO

ALTER DATABASE $(_Database) SET PARTNER = 'TCP://$(_MirrorTCP):(_MirrorPort)'
GO
ALTER DATABASE $(_Database) SET SAFETY OFF
GO

--Löschen Share
:connect $(_Mirror)
!!DEL $(_Share)\$(_Database).*
--!!DIR $(_Share)
