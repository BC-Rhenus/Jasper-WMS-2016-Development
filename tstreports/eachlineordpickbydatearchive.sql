
/******************************************************************************/
/*                                                                            */
/*                          TMI ICT Services                                  */
/*                                                                            */
/*     FILE NAME  :     eachlineordpickbydatearchive.sql                      */
/*                                                                            */
/*     DESCRIPTION:     Outputs the eaches, lines and orders picked.		*/
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   20/01/03 BB   DCS    NEW	     New							*/
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
LEFT 'Picked Eaches, PO Lines and PO By Site, Client And Date Range' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
/* Column Headings and Formats */
COLUMN OrderByPickedDay NEW_VALUE nOrderByPickedDay NOPRINT
COLUMN Site_ID HEADING 'Site' FORMAT A10
COLUMN Client_ID HEADING 'Client' FORMAT A10
COLUMN Month NOPRINT
COLUMN Picked_Date HEADING 'Date' FORMAT A12
COLUMN Picked_Eaches HEADING 'Eaches Picked' FORMAT 999999999
COLUMN Picked_Lines HEADING 'OrderLines Picked' FORMAT 999999999
COLUMN Picked_Orders HEADING 'Orders Picked' FORMAT 999999999

BREAK ON Site_ID SKIP PAGE ON Client_ID SKIP PAGE ON Month SKIP 2

COMPUTE SUM OF Picked_Eaches ON Client_ID 
COMPUTE SUM OF Picked_Lines ON Client_ID
COMPUTE SUM OF Picked_Orders ON Client_ID
COMPUTE SUM OF Picked_Tasks ON Client_ID
COMPUTE SUM OF Picked_Eaches ON Site_ID
COMPUTE SUM OF Picked_Lines ON Site_ID
COMPUTE SUM OF Picked_Orders ON Site_ID
COMPUTE SUM OF Picked_Eaches ON Month
COMPUTE SUM OF Picked_Lines ON Month
COMPUTE SUM OF Picked_Orders ON Month


SELECT	Site_ID,
	Client_ID,
	TO_CHAR (Dstamp,'YYYYMM') Month,
	TO_CHAR (DStamp, 'YYYYMMDD') OrderByPickedDay,
	TO_CHAR (DStamp, 'DD-MON-YYYY') Picked_Date,
	SUM (Update_QTY) Picked_Eaches,
	COUNT (DISTINCT Reference_ID || Line_ID) Picked_Lines,
	COUNT (DISTINCT Reference_ID) Picked_Orders  
FROM INVENTORY_TRANSACTION_ARCHIVE
WHERE Code = 'Pick'
AND To_Loc_ID like 'REPACK%'
AND DStamp BETWEEN TO_DATE('&5', 'DD-MON-YYYY')
AND TO_DATE('&6', 'DD-MON-YYYY') + (1 - (1/86400))
AND (('&2' IS NULL) OR (Site_ID = '&2'))
AND (('&4' IS NULL) OR (Owner_ID = '&4'))
AND ((('&3' IS NULL) AND ('&7' IS NULL))
OR  (Client_ID = '&3')
OR  (('&3' IS NULL) AND Client_ID IN
(SELECT Client_ID 
FROM Client_Group_Clients
WHERE Client_Group = '&7')))  
GROUP BY Site_ID,
	 Client_ID,
	 TO_CHAR (Dstamp,'YYYYMM'), 
	 TO_CHAR (DStamp, 'YYYYMMDD'),
	 TO_CHAR (DStamp, 'DD-MON-YYYY')
ORDER BY 1,2,3,4
/

SET TERMOUT ON

/* The complex where statement is to get over the fact that Oracle stores    */
/* dates and times as part of the date field. Depending on how it was stored */
/* it might have the seconds after midnight, or might be set as midnight     */
/* The expression 1 will default to midnight  at the beginning of the day    */
/* specified. The 2 expression adds 1 day minus 1 second, so effectively     */
/* causing the between to be between day1 0 seconds after midnight and       */
/* day2 1 second before midnight!                                            */

