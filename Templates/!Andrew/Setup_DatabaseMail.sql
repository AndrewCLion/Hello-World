-------------------------------------------------------------
--  Database Mail Simple Configuration Template.
--
--  This template creates a Database Mail profile, an SMTP account and 
--  associates the account to the profile.
--  The template does not grant access to the new profile for
--  any database principals.  Use msdb.dbo.sysmail_add_principalprofile
--  to grant access to the new profile for users who are not
--  members of sysadmin.

--  Version Updates:
--  06.03.2015: Andrew Craven
-------------------------------------------------------------

-- check rights:  sysmail_help_principalprofile_sp

DECLARE @profile_name sysname,
        @account_name sysname,
        @SMTP_servername sysname,
        @email_address NVARCHAR(128),
        @replyto_address NVARCHAR(128),
	    @display_name NVARCHAR(128),
		@msg NVARCHAR(4000);

-- Profile name. Replace with the name for your profile
        SET @profile_name = 'MS-SQL Server ' + CAST(SERVERPROPERTY('Servername') AS sysname);

-- Account information. Replace with the information for your account.

		SET @account_name = CAST(SERVERPROPERTY('Servername') AS sysname) + ' Mailer';
		SET @SMTP_servername = CAST(N'exsmtp.de.bayer.cnb' AS sysname);
		SET @email_address = 'bdc-database@bayerbbs.com';
		SET @replyto_address = 'apm-mssql@bayer.com';
        SET @display_name = 'BDC-Database';


-- Verify the specified account and profile do not already exist.
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = @profile_name)
BEGIN
  SET @msg = 'The specified Database Mail profile ( ' + @profile_name + ' ) already exists.';
  RAISERROR(@msg, 16, 1);
  GOTO done;
END;

IF EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = @account_name )
BEGIN
  SET @msg = 'The specified Database Mail account ( ' + @account_name + ' ) already exists.' ;
  RAISERROR(@msg, 16, 1);
 GOTO done;
END;

-- Start a transaction before adding the account and the profile
BEGIN TRANSACTION ;

DECLARE @rv INT;

-- Add the account
EXECUTE @rv=msdb.dbo.sysmail_add_account_sp
    @account_name = @account_name,
    @email_address = @email_address,
	@replyto_address = @replyto_address,
    @display_name = @display_name,
    @mailserver_name = @SMTP_servername;

IF @rv<>0
BEGIN
    SET @msg = 'Failed to create the specified Database Mail account ( ' + @account_name + ' ).' ;
	RAISERROR(@msg, 16, 1);
    GOTO done;
END

-- Add the profile
EXECUTE @rv=msdb.dbo.sysmail_add_profile_sp
    @profile_name = @profile_name ;

IF @rv<>0
BEGIN
    SET @msg = 'Failed to create the specified Database Mail profile ( ' + @profile_name + ' ).';
	RAISERROR(@msg, 16, 1);
	ROLLBACK TRANSACTION;
    GOTO done;
END;

-- Associate the account with the profile.
EXECUTE @rv=msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @profile_name,
    @account_name = @account_name,
    @sequence_number = 1 ;

IF @rv<>0
BEGIN
    SET @msg = 'Failed to associate the speficied profile ( ' + @profile_name + ' ) with the specified account ( ' + @account_name + ' ).' ;
	RAISERROR(@msg, 16, 1);
	ROLLBACK TRANSACTION;
    GOTO done;
END;

COMMIT TRANSACTION;

done:

GO

/*
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO
--sp_configure 'show advanced options', 0;
--GO
--RECONFIGURE;
--GO
*/

/*
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @principal_name = 'ApplicationUser',
    @profile_name = 'AdventureWorks2008R2 Administrator Profile',
    @is_default = 1 ;
*/
/*
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @principal_name = 'public',
    @profile_name = 'AdventureWorks2008R2 Public Profile',
    @is_default = 1 ;
*/