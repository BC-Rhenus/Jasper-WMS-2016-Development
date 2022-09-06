/******************************************************************************/
/*                                                                            */
/*                          CL-IT                                             */
/*                                                                            */
/*     FILE NAME  :     C_ENTREPOT_INVENTORY_CHK.sql                          */
/*                                                                            */
/*     DESCRIPTION:                                                           */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   10/07/17 MS   DCS    NEW      New                                        */
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
SET LINESIZE 186

/* Top Title */
TTITLE CENTER _SITENAME SKIP 1 -
LEFT 'C-Entrepot Inventory Check' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
 
/* Column Headings and Formats */
COLUMN inb_dossier_id				HEADING		'Dossier'			FORMAT A10
COLUMN csl_business_unit			HEADING		'Bus.Unit'			FORMAT A10
COLUMN inb_status					HEADING		'Inb.Status'		FORMAT A10
COLUMN mut_status					HEADING		'Mut.Status'		FORMAT A10
COLUMN c_date						HEADING		'Date'				FORMAT A10
COLUMN c_time						HEADING		'Time'				FORMAT A5
COLUMN client_id					HEADING		'Client'			FORMAT A10
COLUMN wms_pre_advice_id			HEADING		'Pre-Advice'		FORMAT A10
COLUMN wms_inv_location_id			HEADING		'Location'			FORMAT A10
COLUMN wms_inv_tag_id				HEADING		'Tag ID'			FORMAT A20
COLUMN wms_entrepot_type_location	HEADING		'Loc Type'			FORMAT A8
COLUMN hours_old					HEADING		'Hrs Open'			FORMAT A8

BREAK ON inb_dossier_id SKIP 1 ON csl_business_unit SKIP 0 ON inb_status SKIP 0 ON mut_status SKIP 0 ON c_date SKIP 0 ON c_time SKIP 0 ON client_id SKIP 0 ON wms_pre_advice_id SKIP 0

select rpad(inb_dossier_id || decode( mutation_yn, 'Y', 'M', ' ') ,10)             inb_dossier_id
,      rpad(substr(csl_business_unit,1,10),10)                                     csl_business_unit
,      rpad(inb_dossier_status,10)                                                 inb_status 
,      rpad(mut_dossier_status,10)                                                 mut_status
,      rpad(substr(inb_creation_date,7,2) 
       || '-'
       || substr(inb_creation_date,5,2) 
       || '-'
       || substr(inb_creation_date,1,4),10)                                        c_date
,      rpad(substr(inb_creation_date,9,2) 
       || ':'
       || substr(inb_creation_date,11,2),5)                                        c_time
,      rpad(wms_client_id,10)                                                      client_id
,      rpad(wms_pre_advice_id,10)                                                  wms_pre_advice_id
,      rpad(wms_inv_location_id,10)                                                wms_inv_location_id
,      rpad(wms_inv_tag_id,20)                                                     wms_inv_tag_id
,      rpad(wms_entrepot_type_location,8)                                          wms_entrepot_type_location
,      rpad((case when floor(24*(sysdate-to_date(inb_creation_date,'yyyymmddhh24miss'))) >= 48 
                  then '> 48 hrs' 
                  else to_char(floor(24*(sysdate-to_date(inb_creation_date,'yyyymmddhh24miss')))) || ' hrs' 
             end) 
            ,8) hours_old
from   cnl_sys.cnl_c_entrepot_chk
where  (
       (
       inb_dossier_status != 'OK'
       or
       (
       inb_dossier_status = 'OK'
       and
       nvl(line_available_amount,0) > 0
       )
       or 
       num_lines = 0
       )
or     (
       (
       mut_dossier_status is not null
       and
       mut_dossier_status != 'OK'
       )
       or
       (
       mut_dossier_status is not null
       and
       mut_dossier_status = 'OK'
       and
       nvl(mut_line_available_amount,0) > 0
       )
       or
       (
       mut_dossier_status is not null
       and 
       mut_num_lines = 0
       )
       )
       )
order  by 1
/

SET TERMOUT ON

/* The complex where statement is to get over the fact that Oracle stores    */
/* dates and times as part of the date field. Depending on how it was stored */
/* it might have the seconds after midnight, or might be set as midnight     */
/* The expression 1 will default to midnight  at the beginning of the day    */
/* specified. The 2 expression adds 1 day minus 1 second, so effectively     */
/* causing the between to be between day1 0 seconds after midnight and       */
/* day2 1 second before midnight!                                            */

