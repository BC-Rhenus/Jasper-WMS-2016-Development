/******************************************************************************/
/*                                                                            */
/*                          CL-IT                                 */
/*                                                                            */
/*     FILE NAME  :     C_ENTREPOT_INVENTORY_CHK.sql                             */
/*                                                                            */
/*     DESCRIPTION:     		*/
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   10/07/17 MS   DCS    NEW	     New							*/
/******************************************************************************/

/* Setup time zone */
@logintimezonesetup.sql '&1'

SET FEEDBACK ON
SET VERIFY OFF 

/* Clear previous settings */
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

/* Set up page and line */
SET PAGESIZE 62
SET NEWPAGE 0
SET LINESIZE 176

/* Top Title */
TTITLE CENTER _SITENAME SKIP 1 -
LEFT 'C-Entrepot Location Check' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
 
/* Column Headings and Formats */
COLUMN tag_id 			HEADING 	'Tag ID' 		FORMAT A20
COLUMN client_id		HEADING 	'Client' 		FORMAT A10
COLUMN location_id		HEADING 	'Location' 		FORMAT A10
COLUMN pre_advice		HEADING		'Pre-Advice'	FORMAT A20
COLUMN dossier			HEADING		'Dossier'		FORMAT A10
COLUMN status			HEADING 	'Status' 		FORMAT A20
COLUMN hours_old		HEADING 	'Hrs Open'		FORMAT A15
COLUMN bonded_status	HEADING 	'Bonded Status'	FORMAT A20


BREAK ON tag_id SKIP 0 ON client_id SKIP 0 ON location_id SKIP 0 ON pre_advice SKIP 0 ON dossier SKIP 1

select  rpad(wms_tag_id,20)         tag_id
,       rpad(wms_client_id,10)      client_id
,       rpad(wms_location_id,10)    location_id
,       rpad(wms_pre_advice,20)     pre_advice
,       rpad(to_char(dossier),10)   dossier
,       rpad(status,20)             status
,       rpad(hours_old,15)          hours_old  
,       rpad(entrepot,20)           bonded_status
from    cnl_sys.cnl_c_entrepot_location_chk
order   by 3
/

SET TERMOUT ON

/* The complex where statement is to get over the fact that Oracle stores    */
/* dates and times as part of the date field. Depending on how it was stored */
/* it might have the seconds after midnight, or might be set as midnight     */
/* The expression 1 will default to midnight  at the beginning of the day    */
/* specified. The 2 expression adds 1 day minus 1 second, so effectively     */
/* causing the between to be between day1 0 seconds after midnight and       */
/* day2 1 second before midnight!                                            */

