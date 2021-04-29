--CIS Microsoft SQL Server 2012 Database Engine
--January 6, 2014 1.0.0 Initial release.
--Chapter 3

--3.1 Revoke Execute on 'xp_availablemedia' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_availablemedia TO PUBLIC;

--3.2 Set the 'xp_cmdshell' option to disabled (Scored)
EXECUTE sp_configure 'show advanced options', 1; 
RECONFIGURE; 
EXECUTE sp_configure 'Xp_cmdshell', 0; 
RECONFIGURE; 
GO 
EXECUTE sp_configure 'show advanced options', 0;
RECONFIGURE; 

--3.3 Revoke Execute on 'xp_dirtree' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_dirtree TO PUBLIC;

--3.4 Revoke Execute on 'xp_enumgroups' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_enumgroups to PUBLIC;

--3.5 Revoke Execute on 'xp_fixeddrives' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_fixeddrives TO PUBLIC;

--3.6 Revoke Execute on 'xp_servicecontrol' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_servicecontrol TO PUBLIC;

--3.7 Revoke Execute on 'xp_subdirs' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_subdirs TO PUBLIC;

--3.8 Revoke Execute on 'xp_regaddmultistring' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_regaddmultistring TO PUBLIC;

--3.9 Revoke Execute on 'xp_regdeletekey' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_regdeletekey TO PUBLIC;

--3.10 Revoke Execute on 'xp_regdeletevalue' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_regdeletevalue TO PUBLIC;

--3.11 Revoke Execute on 'xp_regenumvalues' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_regenumvalues TO PUBLIC;

--3.12 Revoke Execute on 'xp_regremovemultistring' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_regremovemultistring TO PUBLIC;

--3.13 Revoke Execute on 'xp_regwrite' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_regwrite TO PUBLIC;

--3.14 Revoke Execute on 'xp_regread' to PUBLIC (Scored)
REVOKE EXECUTE ON xp_regread TO PUBLIC;

