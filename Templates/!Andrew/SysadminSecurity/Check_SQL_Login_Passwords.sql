-- There are three options for SQL Server logins:
--    The SQL Server login doesn't do any password policy enforcement at all.
--    The SQL Server login enforces password complexity and lockout, but not password expiration.
--    The SQL Server login enforces password complexity, lockout, and expiration. 
SELECT	sqll.name, sqll.type_desc, sqll.is_disabled, sysl.sysadmin, sysl.securityadmin, 
	PWDCOMPARE('',password_hash) AS [PwdIsEmpty], 
	PWDCOMPARE(sqll.name,password_hash) AS [Pwd=login], 
	PWDCOMPARE(UPPER(sqll.name),password_hash) AS [Pwd=UPPER(Login)], 
	PWDCOMPARE(LOWER(sqll.name),password_hash) AS [Pwd=LOWER(Login)], 
	PWDCOMPARE(UPPER(LEFT(sqll.name,1))+LOWER(SUBSTRING(sqll.name,2,4000)),password_hash) AS [Pwd=L+ogin],
	PWDCOMPARE('sa',password_hash)AS [Pwd=sa], 
	PWDCOMPARE('SA',password_hash) AS [Pwd=SA], 
	sqll.is_policy_checked, sqll.is_expiration_checked,
	sqll.create_date, sqll.modify_date
FROM	sys.sql_logins AS sqll INNER JOIN
		sys.syslogins AS sysl ON sqll.sid = sysl.sid
WHERE PWDCOMPARE('',password_hash)=1 --blank
	OR PWDCOMPARE('sa',password_hash)=1
	OR PWDCOMPARE('SA',password_hash)=1
	OR PWDCOMPARE(sqll.name,password_hash)=1
	OR PWDCOMPARE(sqll.name+sqll.name,password_hash)=1
	OR PWDCOMPARE(UPPER(sqll.name),password_hash)=1
	OR PWDCOMPARE(LOWER(sqll.name),password_hash)=1
	OR PWDCOMPARE(UPPER(LEFT(sqll.name,1))+LOWER(SUBSTRING(sqll.name,2,4000)),password_hash)=1
	OR ((sqll.is_policy_checked = 0) AND (sqll.is_expiration_checked = 0) AND (sqll.is_disabled = 0) AND ((sysl.sysadmin = 1) OR (sysl.securityadmin = 1)));
---- Finding Logins which have no policy/expiration -----------
--SELECT	sqll.name, 'no policy/expire' AS Exception, sqll.type_desc, sqll.create_date, sqll.modify_date, sqll.is_policy_checked, sqll.is_expiration_checked, sqll.is_disabled, 
--		sysl.sysadmin, sysl.securityadmin
--FROM	sys.sql_logins AS sqll INNER JOIN
--		sys.syslogins AS sysl ON sqll.sid = sysl.sid
--WHERE	(sqll.is_policy_checked = 0) AND (sqll.is_expiration_checked = 0) AND (sqll.is_disabled = 0) AND ((sysl.sysadmin = 1) OR (sysl.securityadmin = 1))

-- http://www.mssqltips.com/sqlservertip/2775/identify-blank-and-weak-passwords-for-sql-server-logins/
-- http://www.mssqltips.com/sqlservertip/1909/how-to-configure-password-enforcement-options-for-standard-sql-server-logins/
