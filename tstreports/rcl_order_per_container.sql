/******************************************************************************/
/*                                                                            */
/*                          Rhenus Contract Logistics                         */
/*                                                                            */
/*     FILE NAME  :     rcl_order_per_container.sql   			              */
/*                                                                            */
/*     DESCRIPTION:     Report to check which order is in which container     */
/*                      					                                  */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   25/05/20 TAG         NEW      New                                        */
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
SET LINESIZE 132

/* Top Title */
TTITLE CENTER _SITENAME SKIP 1 -
LEFT 'Order per Container - &2 - &3' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
/* Column Headings and Formats */
COLUMN client_id			HEADING 'Client'			FORMAT A10
COLUMN container_id			HEADING 'Container'			FORMAT A20
COLUMN order_id				HEADING 'Order'				FORMAT A20

select distinct ocr.client_id client_id,ocr.container_id container_id,ocr.order_id order_id
from dcsdba.order_container ocr
inner join dcsdba.inventory inv on ocr.pallet_id=inv.pallet_id and nvl(ocr.container_id,'N')=nvl(inv.container_id,'N')
where inv.site_id='&2'
and ocr.pallet_id='&3'
order by 2
                            
/

SET TERMOUT ON

