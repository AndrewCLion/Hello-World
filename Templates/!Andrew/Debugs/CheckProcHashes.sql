/*** Some worker variables *********/
declare @spname nvarchar(4000) 
declare @spdefinition nvarchar(4000) 
declare @hashedVal1 varbinary(4000) 
declare @hashedVal2 varbinary(4000) 
declare @hashedVal3 varbinary(4000) 
/** Name of our stored procedure ************/
set @spname = 'DatabaseBackup' 
/** Get the object definition *************/
set @spdefinition = (SELECT OBJECT_DEFINITION (OBJECT_ID(@spname )))     
set @hashedVal1 = (select HashBytes('SHA1', @spdefinition)) 
/** Name of our stored procedure ************/
set @spname = 'IFX_Base64FromVarBinary' 
/** Get the object definition *************/
set @spdefinition = (SELECT OBJECT_DEFINITION (OBJECT_ID(@spname )))     
set @hashedVal2 = (select HashBytes('SHA1', @spdefinition)) 
/** Name of our stored procedure ************/
set @spname = 'IFX_Base64ToVarBinary' 
/** Get the object definition *************/
set @spdefinition = (SELECT OBJECT_DEFINITION (OBJECT_ID(@spname )))     
set @hashedVal3 = (select HashBytes('SHA1', @spdefinition)) 
/** Here's the hashed value of the stored procedures **********/
select @hashedVal1 As DatabaseBackup, @hashedVal2 As IFX_Base64FromVarBinary, @hashedVal3 As IFX_Base64ToVarBinary