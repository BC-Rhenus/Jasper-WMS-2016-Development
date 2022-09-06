/******************************************************************************/
/*                                                                            */
/*                             Rhenus ICT                                     */
/*                                                                            */
/*     FILE NAME  :     NLTLG01_Serial_Mismatch_Function.sql                  */
/*                                                                            */
/*     DESCRIPTION:     Rhenus - Serial Number Mismatch                       */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   15/11/19 TSB  BAE    N/A      initial version                            */
/******************************************************************************/
 
/* Setup time zone */
@logintimezonesetup.sql '&1'

SET FEEDBACK ON
SET VERIFY OFF
SET TAB OFF
 
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
LEFT 'Rhenus - Serial Number Mismatch' RIGHT _DATESTAMP SKIP 1 -        
RIGHT _TIMESTAMP SKIP 1 -                               
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2 - 

/* Avoid duplicate values */
BREAK ON Issues SKIP 0

/* Column Headings and Formats */
COLUMN Issues HEADING 'Issues' FORMAT A4000 WORD_WRAP


/* SQL Select statement */
select cnl_sys.get_issue_orders_f('&2') as Issues from dual
;

SET TERMOUT ON

/*
	client_id = FLIRS
, 	order_id = FL0056578514
, 	pallet_id = 21905613
, 	containers = "21905613"

, 	client_id = FLIRS
, 	order_id = FL0056578514
, 	pallet_id = 21924172
, 	containers = "21905613","21924172"
*/