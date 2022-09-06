/******************************************************************************/
/*                                                                            */
/*                          Rhenus Contract Logistics                         */
/*                                                                            */
/*     FILE NAME  :     rcl_mr_field_use.sql   	                   	  		  */
/*                                                                            */
/*     DESCRIPTION:     Report to indicate which field is used in which rule  */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   18/08/21 TAG         NEW      New                                        */
/*																			  */
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
SET PAGESIZE 500
SET NEWPAGE 0
SET LINESIZE 150

/* Top Title */
TTITLE CENTER _SITENAME SKIP 1 -
LEFT 'Merge Rule - Field Use - &2 - &3 - &4 - &5' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
/* Column Headings and Formats */
COLUMN table_ind		HEADING 'Table'				FORMAT A20
COLUMN client_id		HEADING 'Client'			FORMAT A10
COLUMN site_id			HEADING 'Site'				FORMAT A10
COLUMN hit				HEADING 'Hit'				FORMAT A5
COLUMN rule_name		HEADING 'Rule Name'			FORMAT A40
COLUMN search_value		HEADING 'Search Value'		FORMAT A40

select (case when omr.type='H' then 'Order Header' when omr.type='L' then 'Order Line' else 'Order' end) table_ind,omr.client_id,omr.site_id,'Where' hit,omr.name rule_name,upper('&5') search_value
from dcsdba.order_mr omr
where (omr.client_id='&2' or '&2' is null)
and (omr.site_id='&3' or '&3' is null)
and ('&4'='Order' or '&4' is null)
and upper(omr.where_clause) like upper('%&5%')
union all
select (case when omr.type='H' then 'Order Header' when omr.type='L' then 'Order Line' else 'Order' end) table_ind,omr.client_id,omr.site_id,'Do' hit,omr.name rule_name,upper('&5') search_value
from dcsdba.order_mr omr
where (omr.client_id='&2' or '&2' is null)
and (omr.site_id='&3' or '&3' is null)
and ('&4'='Order' or '&4' is null)
and upper(omr.action_clause) like upper('%&5%')
union all
select (case when pmr.type='H' then 'Pre-Advice Header' when pmr.type='L' then 'Pre-Advice Line' else 'Pre-Advice' end) table_ind,pmr.client_id,pmr.site_id,'Where' hit,pmr.name rule_name,upper('&5') search_value
from dcsdba.pre_advice_mr pmr
where (pmr.client_id='&2' or '&2' is null)
and (pmr.site_id='&3' or '&3' is null)
and ('&4'='Pre-Advice' or '&4' is null)
and upper(pmr.where_clause) like upper('%&5%')
union all
select (case when pmr.type='H' then 'Pre-Advice Header' when pmr.type='L' then 'Pre-Advice Line' else 'Pre-Advice' end) table_ind,pmr.client_id,pmr.site_id,'Do' hit,pmr.name rule_name,upper('&5') search_value
from dcsdba.pre_advice_mr pmr
where (pmr.client_id='&2' or '&2' is null)
and (pmr.site_id='&3' or '&3' is null)
and ('&4'='Pre-Advice' or '&4' is null)
and upper(pmr.action_clause) like upper('%&5%')
union all
select 'SKU' table_ind,smr.client_id,smr.site_id,'Where' hit,smr.name rule_name,upper('&5') search_value
from dcsdba.sku_mr smr
where (smr.client_id='&2' or '&2' is null)
and ('&4'='SKU' or '&4' is null)
and upper(smr.where_clause) like upper('%&5%')
union all
select 'SKU' table_ind,smr.client_id,smr.site_id,'Do' hit,smr.name rule_name,upper('&5') search_value
from dcsdba.sku_mr smr
where (smr.client_id='&2' or '&2' is null)
and ('&4'='SKU' or '&4' is null)
and upper(smr.action_clause) like upper('%&5%')
union all
select 'Pack Config' table_ind,cmr.client_id,cmr.site_id,'Where' hit,cmr.name rule_name,upper('&5') search_value
from dcsdba.sku_config_mr cmr
where (cmr.client_id='&2' or '&2' is null)
and ('&4'='Pack Config' or '&4' is null)
and upper(cmr.where_clause) like upper('%&5%')
union all
select 'Pack Config' table_ind,cmr.client_id,cmr.site_id,'Do' hit,cmr.name rule_name,upper('&5') search_value
from dcsdba.sku_config_mr cmr
where (cmr.client_id='&2' or '&2' is null)
and ('&4'='Pack Config' or '&4' is null)
and upper(cmr.action_clause) like upper('%&5%')
order by 3,2,1,4 desc,5

                            
/

SET TERMOUT ON
