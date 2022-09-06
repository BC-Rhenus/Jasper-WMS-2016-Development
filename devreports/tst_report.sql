/******************************************************************************/
/*                                                                            */
/*                          TMI ICT Services                                  */
/*                                                                            */
/*     FILE NAME  :     eachlineordpickbydate.sql                             */
/*                                                                            */
/*     DESCRIPTION:     Outputs the eaches, lines and orders picked.		*/
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   20/01/03 BB   DCS    NEW	     New							*/
/******************************************************************************/


SET FEEDBACK ON
SET VERIFY OFF 

/* Clear previous settings */
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

/* Set up page and line */
SET PAGESIZE 62
SET NEWPAGE 0
SET LINESIZE 140

/* Top Title */
COLUMN LIST_LOCATIONS NEW_VALUE LISTL NOPRINT
TTITLE LEFT 'List of Locations: ' LISTL
BREAK ON LIST_LOCATIONS SKIP PAGE
BTITLE OFF 

/* Column Headings and Formats */
BREAK ON MAX_PRIO skip 0 ON SITE_ID skip 0 ON CLIENT_ID skip 1

/* Column headers*/
COLUMN MAX_PRIO HEADING 'Order Priority'
COLUMN CLIENT_ID HEADING 'Client id'
COLUMN SITE_ID HEADING 'Site id'
COLUMN TAG_ID HEADING 'Tag id'
COLUMN FROM_LOC_ID HEADING 'From location'

/* Column width*/
COLUMN MAX_PRIO FORMAT A20
COLUMN CLIENT_ID FORMAT A15
COLUMN SITE_ID FORMAT A15
COLUMN TAG_ID FORMAT A20
COLUMN FROM_LOC_ID FORMAT A15


select 	to_char(max_prio) MAX_PRIO
,	cnl_sys.list_locations(max_prio, site_id, client_id) LIST_LOCATIONS
,	site_id
,	client_id
,	tag_id
,	from_loc_id
from	(
	select	distinct 
		m4.from_loc_id
	,	m4.client_id
	,	m4.site_id
	,	m4.tag_id
	,	nvl(	(
			select 	max(o.priority)
			from	dcsdba.move_task o
			where	o.site_id = m4.site_id
			and	o.client_id = m4.client_id
			and	o.task_type = 'O'
			and	o.from_loc_id = m4.from_loc_id
			and	o.from_loc_id in 	(
							select	distinct 
								m3.from_loc_id
							from	dcsdba.move_task m3
							where	m3.task_type = 'M'
							and	m3.tag_id = o.tag_id
							and	m3.sku_id = o.sku_id
							and	m3.site_id = o.site_id
							and	m3.client_id = o.client_id
							and	m3.from_loc_id = o.from_loc_id
							)
			)
		,50) max_prio
	from	dcsdba.move_task m4
	inner
	join	dcsdba.location l
	on	l.location_id = m4.from_loc_id
	and	l.site_id = m4.site_id 
	and	l.loc_type in ('Tag-FIFO','Tag-Operator')
	and	m4.task_type = 'O'
	where	m4.from_loc_id in 	(
					select	distinct 
						m5.from_loc_id
					from	dcsdba.move_task m5
					where	m5.task_type = 'M'
					and	m5.tag_id = m4.tag_id
					and	m5.sku_id = m4.sku_id
					and	m5.site_id = m4.site_id
					and	m5.client_id = m4.client_id
					and	m5.from_loc_id = m4.from_loc_id
					)
	and 	m4.pallet_id is null
	and	m4.container_id is null
	and	m4.client_id not like 'SBR%'
	and 	m4.from_loc_id not in ('30APICK','3DINB-VAS','ASMISSING','TROUBLESHOOT')
	group by 
		m4.from_loc_id
	,	m4.client_id
	,	m4.site_id
	,	m4.tag_id
	)
order 
by 	max_prio desc;

SET TERMOUT ON

/* The complex where statement is to get over the fact that Oracle stores    */
/* dates and times as part of the date field. Depending on how it was stored */
/* it might have the seconds after midnight, or might be set as midnight     */
/* The expression 1 will default to midnight  at the beginning of the day    */
/* specified. The 2 expression adds 1 day minus 1 second, so effectively     */
/* causing the between to be between day1 0 seconds after midnight and       */
/* day2 1 second before midnight!                                            */

