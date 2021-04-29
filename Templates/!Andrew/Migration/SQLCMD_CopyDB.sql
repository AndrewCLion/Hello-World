-- Needs to be in SQLCMD Mode!!
-- Andrew Craven, 2014-2105
-- CP Update 2015.09.22


:SetVar _SrcInst    BY-SP2K13MP01\MP01
:SetVar _SrcInstTCP BY-SP2K13MP01.de.bayer.cnb
:SetVar _SrcInstSQLAcc BYACCOUNT\MYUOT                  

:SetVar _DestInst    BY-SP2K13MP02\MP02
:SetVar _DestInstTCP BY-SP2K13MP02.de.bayer.cnb
:SetVar _DestInstSQLAcc BYACCOUNT\MYUOT

:SetVar _Share \\BY-SP2K13MP02\Xfer

:SetVar _DirDataFile F:\Data_01\Data
:SetVar _DirLogFile  F:\Tlog_01\Tlog

:SetVar _Database EMMYBBSPROD_MSS_ProfileSyncDB_BBS1_D_1


--BACKUP FROM
:connect $(_SrcInst)
Print '-->BackUp $(_Database)'
BACKUP DATABASE $(_Database) TO  DISK = N'$(_Share)\$(_Database).BAK' 
           WITH  COPY_ONLY, 
                NOFORMAT, INIT,  NAME = N'$(_Database)-Vollständig Datenbank Sichern', 
                SKIP, NOREWIND, NOUNLOAD,  STATS = 5
GO
Print ''
GO

--RESTORE TO
:connect $(_DestInst)
Print '-->Restore $(_Database)'
RESTORE DATABASE $(_Database) FROM  DISK = N'$(_Share)\$(_Database).BAK' WITH  FILE = 1,  
           MOVE N'$(_Database)'     TO N'$(_DirDataFile)\$(_Database).mdf',  
                MOVE N'$(_Database)_log' TO N'$(_DirLogFile)\$(_Database)_log.LDF',  
                NOUNLOAD,  STATS = 5
GO
Print ''
GO

--Löschen Share
:connect $(_DestInst)
!!DEL $(_Share)\$(_Database).*
--!!DIR $(_Share)
