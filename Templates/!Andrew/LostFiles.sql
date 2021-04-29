-- Afrage aller Verzeichnisse in denen sich Datenbankdateien befinden.
-- Alle darin vorhandenen Dateien werden überprüft ob sie einen Datenbank Bezug haben.

DECLARE @FilefolderTable TABLE (Folders NVARCHAR(MAX));
DECLARE @FileTable TABLE (Files NVARCHAR(MAX));
DECLARE @SQLString nvarchar(max);
--DECLARE @TempTable TABLE (Subdirectory VARCHAR(512), Depth INT);
CREATE TABLE #TempTable (Subdirectory VARCHAR(512), Depth INT, isFile Int, Folder VarChar(512));


Insert into  @FilefolderTable  SELECT  distinct PathName=LEFT(physical_name, 
LEN(physical_name) - charindex('\',reverse(physical_name),1) + 1)
from  sys.master_files
Set @SQLString =''
select @SQLString = @SQLString + 'INSERT INTO #TempTable (Subdirectory, Depth, isFile)
EXEC xp_dirtree '''+Folders +''',1, 1;Update #TempTable Set Folder = '''+Folders+''' where Folder is NULL;' from @FilefolderTable 
--Select @SQLString;
exec sp_executesql @SQLString;


Select 'Del ' + Folder + Subdirectory --as FileName, Folder 
from #TempTable 
left join sys.master_files on Subdirectory = RIGHT(physical_name,charindex('\',reverse(physical_name),1) - 1)
where 
database_id is NULL 
and Subdirectory not like '%.cer'
and Subdirectory not like '%.lnk'

and isFile = 1

--Select Subdirectory as FileName, Folder from #TempTable 
--left join sys.master_files on Subdirectory = RIGHT(physical_name,charindex('\',reverse(physical_name),1) - 1)
--where 
--database_id is NULL 
--and Subdirectory not like '%.cer'
--and Subdirectory not like '%.lnk'

--and isFile = 1

Drop TABLE #TempTable








