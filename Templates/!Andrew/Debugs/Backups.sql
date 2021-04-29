select database_name, type, backup_start_date, backup_size, compressed_backup_size, DATEDIFF(ss, backup_start_date, backup_finish_date) [Sekunden] from msdb.dbo.backupset 
where 1=1
--and backup_size <> compressed_backup_size
--and type = 'D' --'I' 'L'
--and database_name = 'MOSS_CONTENT_BBS1_D_01'
order by backup_start_date desc

--BACKUP DATABASE [MART_Analytics_DW] TO DISK = 'K:\Delete_me.bak' WITH COPY_ONLY, COMPRESSION, INIT, MAXTRANSFERSIZE = 4194304
