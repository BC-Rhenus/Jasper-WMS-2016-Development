/******************************************************************************/
/*                                                                            */
/*                          Rhenus Contract Logistics                         */
/*                                                                            */
/*     FILE NAME  :     rcl_short_ship_orders_by_trailer.sql                  */
/*                                                                            */
/*     DESCRIPTION:     Report to identify short shipped orders               */
/*                      for trailer shipping                                  */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   25/06/19 TAG         NEW      New                                        */
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
LEFT 'ShortShip Orders by Trailer report - &2 - &3' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
/* Column Headings and Formats */
COLUMN client_id	HEADING 'Client ID'		FORMAT A10
COLUMN order_id		HEADING 'Order ID'		FORMAT A20

select distinct odc.client_id client_id,odc.order_id order_id
from dcsdba.inventory inv
inner join dcsdba.order_container odc on inv.pallet_id=odc.pallet_id and inv.client_id=odc.client_id
inner join dcsdba.order_header odh on odc.order_id=odh.order_id and odc.client_id=odh.client_id
inner join dcsdba.order_line odl on odh.order_id=odl.order_id and odh.client_id=odl.client_id
where inv.site_id='&2'
and inv.location_id='&3'
and nvl(odl.qty_picked,0)<>odl.qty_ordered
and odh.disallow_short_ship is not null
order by 1
                            
/

SET TERMOUT ON

