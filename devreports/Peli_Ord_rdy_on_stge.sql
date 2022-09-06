/******************************************************************************/
/*                                                                            */
/*                          Rhenus Contract Logistics                         */
/*                                                                            */
/*     FILE NAME  :     Peli_Ord_rdy_on_stge       	                    	  	  */
/*                                                                            */
/*     DESCRIPTION:     Report for checking if orders are completely picked and on a stage or repack location		          */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   15/09/16 TAG         NEW      New                                        */
/*   19/09/16 TAG                  Change layout                              */
/*   01/11/16 TAG                  Change field                               */
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
SET LINESIZE 150

/* Top Title */
TTITLE CENTER _SITENAME SKIP 1 -
LEFT 'Orders completely picked' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
/* Column Headings and Formats */
COLUMN from_location				HEADING 'LOCATION'					FORMAT A20
COLUMN order_id				      HEADING 'ORDER'					    FORMAT A20
COLUMN pallet_id					  HEADING 'PALLLET'					  FORMAT A20
COLUMN container_id			    HEADING 'CONTAINER'				  FORMAT A20
COLUMN comeplet	            HEADING 'COMPLETE'			    FORMAT A10
COLUMN Total_pallets				HEADING 'TOTAL_PALLETS'			FORMAT 9999

with my_data as
(
select  distinct m.task_id  as order_id
,       m.from_loc_id       as from_location
,       m.pallet_id         as pallet_id
,       m.container_id      as container_id
from    move_task m
where   
(       m.status = 'Consol'
and     m.task_id not in (  select  m2.task_id
                            from    move_task m2
                            where   m2.task_id = m.task_id
                            and     status <> 'Consol')
and    (  select  count(m3.from_loc_id)
          from    move_task m3
          where   m3.task_id = m.task_id
          and     from_loc_id in (select  l.location_id
                                  from    location l  
                                  where   work_zone not in ('STAGE','SHIPDOCK')
                                 )
        ) = 0
and     from_loc_id like 'PELI%'
) 
or 
(       m.task_id = (select o.order_id 
                     from   order_header o
                     where  o.repack = 'Y' 
                     and    o.order_id = m.task_id
                    )
and     m.from_loc_id = ( select o.repack_loc_id 
                          from   order_header o
                          where  o.repack = 'Y' 
                          and    o.order_id = m.task_id
                        )
and     m.task_id not in ( select m5.task_id
                           from   move_task m5
                           where  from_loc_id not in (  select  location_id
                                                        from    location 
                                                        where   work_zone in ('HAL3-REP','SHIPDOCK','STAGE')
                                                      )
                          )
)
)
select  k.from_location
,       k.order_id
,       k.pallet_id
,       k.container_id
,       'Complete' complete
,       (select count(distinct l.pallet_id) from my_data l where l.order_id = k.order_id) as total_pallets
from    my_data k
order by k.from_location asc
                                            
/

SET TERMOUT ON
