SET SERVEROUTPUT OFF
SET FEEDBACK OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

SET PAGESIZE 0
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF

execute cnl_sys.cnl_cto_pck.create_cto_log_record('&1','&2');

exit;
