/******************************************************************************/
/*                                                                            */
/*                          Rhenus Contract Logistics                         */
/*                                                                            */
/*     FILE NAME  :     rcl_sd_list_locked.sql 		                          */
/*                                                                            */
/*     DESCRIPTION:     Report for check which user/station					  */
/*						has a system directed list open			              */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   13/08/20 TAG         NEW      New                                        */
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
SET PAGESIZE 5000
SET NEWPAGE 0
SET LINESIZE 500

/* Top Title */
TTITLE CENTER _SITENAME SKIP 1 -
LEFT 'SystemDirected List Opened/Locked report' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
/* Column Headings and Formats */
COLUMN work_list		HEADING 'LIST'		FORMAT A10
COLUMN station_id		HEADING 'STATION'	FORMAT A20
COLUMN user_id			HEADING 'USER'		FORMAT A10

select distinct sdl.work_list,usl.station_id,usl.user_id
from dcsdba.work_list sdl
inner join dcsdba.user_log usl on sdl.station_updating=usl.station_id
where sdl.station_updating is not null
and sdl.site_id='&2'
and trunc(usl.dstamp)=trunc(sysdate)
order by 1
                            
/

SET TERMOUT ON

