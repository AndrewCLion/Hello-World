--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect BY0JYE\BIP

USE [master]

GO

ALTER AVAILABILITY GROUP [BY-ATLAS-PROD-1]
ADD DATABASE [ATLAS_FDT_CFG];

GO

:Connect BY0JYE\BIP

BACKUP DATABASE [ATLAS_FDT_CFG] TO  DISK = N'\\By0jye\share_1\HAG\ATLAS_FDT_CFG.bak' WITH  COPY_ONLY, FORMAT, INIT, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect BY0JYF\BIDETAILSP

RESTORE DATABASE [ATLAS_FDT_CFG] FROM  DISK = N'\\By0jye\share_1\HAG\ATLAS_FDT_CFG.bak' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect BY0JYE\BIP

BACKUP LOG [ATLAS_FDT_CFG] TO  DISK = N'\\By0jye\share_1\HAG\ATLAS_FDT_CFG_20150623164511.trn' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect BY0JYF\BIDETAILSP

RESTORE LOG [ATLAS_FDT_CFG] FROM  DISK = N'\\By0jye\share_1\HAG\ATLAS_FDT_CFG_20150623164511.trn' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect BY0JYF\BIDETAILSP


-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'BY-ATLAS-PROD-1'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			-- exit loop when the replica is connected, or if the query cannot find the replica status
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	-- If the wait loop fails, do not stop execution of the alter database statement
end catch
ALTER DATABASE [ATLAS_FDT_CFG] SET HADR AVAILABILITY GROUP = [BY-ATLAS-PROD-1];

GO


GO


