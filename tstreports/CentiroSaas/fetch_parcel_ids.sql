SET FEEDBACK OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

SET PAGESIZE 0
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF

SET LINESIZE 32767
SET WRAP ON
SET TRIMOUT ON
SET TRIMSPOOL ON




SPOOL &2




select parcel_id, shipment_id, nvl(printer_name,'X'), nvl(copies,1), decode(to_char(substr(shp_label_base64,1,1)),null,'ZPL','BASE64')
from cnl_sys.cnl_cto_ship_labels
where run_task_key = &1
and dws = 'N'
union
select 'X','X','X',0,'X'
from dual;




SPOOL OFF
EXIT;

