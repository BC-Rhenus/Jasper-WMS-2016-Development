SET SERVEROUTPUT OFF
SET FEEDBACK OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

SET PAGESIZE 0
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF

execute cnl_sys.cnl_cto_pck.force_carrier_update_p( '&1','&2','&3','&4','&5',&6);

exit;


