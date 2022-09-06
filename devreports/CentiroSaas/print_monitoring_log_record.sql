SET SERVEROUTPUT OFF
SET FEEDBACK OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

SET PAGESIZE 0
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF

execute cnl_sys.cnl_cto_pck.print_monitoring_log_record(p_run_task_key_i => &1, p_add_or_update_i => '&2', p_send_to_printer_i => '&3', p_finished_i => '&4');

exit;
