SET SERVEROUTPUT OFF
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

--
-- Script to select all Clients from TPB Client Group for the tpb_all_in_one shell script
--
-- variable 1 = Client_Group 
--

SPOOL tpb_clients.txt

select  client_id
from    dcsdba.client_group_clients
where   client_group = upper('&1')
;

SPOOL OFF

EXIT;
