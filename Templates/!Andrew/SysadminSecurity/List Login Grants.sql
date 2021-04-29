SELECT	sp2.name AS Grantee, sp3.name AS Grantor, sp1.class, sp1.class_desc, sp1.major_id, sp1.minor_id, sp1.grantee_principal_id, sp1.grantor_principal_id, sp1.type, sp1.permission_name, sp1.state, sp1.state_desc, 
		sl.sysadmin, sl.securityadmin, sl.dbcreator
FROM	sys.server_principals AS sp3 INNER JOIN
        sys.server_permissions AS sp1 ON sp3.principal_id = sp1.grantor_principal_id LEFT OUTER JOIN
        sys.syslogins AS sl RIGHT OUTER JOIN
        sys.server_principals AS sp2 ON sl.sid = sp2.sid ON sp1.grantee_principal_id = sp2.principal_id
WHERE   (sp1.type <> 'R')
--AND sp3.name = 'BYACCOUNT\EQZWL'
ORDER BY Grantee