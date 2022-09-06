/******************************************************************************/
/*                                                                            */
/*                      Rhenus Contract Logistics      	                      */
/*                                                                            */
/*     FILE NAME  :     eachlineordshipbydate.sql                             */
/*                                                                            */
/*     DESCRIPTION:     Output the eaches, lines and po's received.			  */
/*						From inventory transaction table.					  */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   20/01/03 BB   DCS    NEW      User Report								  */
/*   04/05/16 TAG  DCS    CHANGE   Exclude Archived							  */
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
LEFT 'Received Eaches, PO Lines and PO By Site, Client And Date Range' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
/* Column Headings and Formats */
COLUMN OrderByReceiptDay NEW_VALUE nOrderByReceiptDay NOPRINT
COLUMN Site_ID HEADING 'Site' FORMAT A10
COLUMN Client_ID HEADING 'Client' FORMAT A10
COLUMN Month NOPRINT
COLUMN Receipt_Date HEADING 'Date' FORMAT A12
COLUMN Receipt_Eaches HEADING 'Eaches Received' FORMAT 999999999
COLUMN Receipt_Lines HEADING 'PO Lines Received' FORMAT 999999999
COLUMN Receipt_Orders HEADING 'PO Received' FORMAT 999999999

BREAK ON Site_ID SKIP PAGE ON Client_ID SKIP PAGE ON Month SKIP 2

COMPUTE SUM OF Receipt_Eaches ON Client_ID 
COMPUTE SUM OF Receipt_Lines ON Client_ID
COMPUTE SUM OF Receipt_Orders ON Client_ID
COMPUTE SUM OF Receipt_Eaches ON Site_ID
COMPUTE SUM OF Receipt_Lines ON Site_ID
COMPUTE SUM OF Receipt_Orders ON Site_ID
COMPUTE SUM OF Receipt_Eaches ON Month
COMPUTE SUM OF Receipt_Lines ON Month
COMPUTE SUM OF Receipt_Orders ON Month


SELECT	Site_ID,
	Client_ID,
	TO_CHAR (Dstamp,'YYYYMM') Month,
	TO_CHAR (DStamp, 'YYYYMMDD') OrderByReceiptDay,
	TO_CHAR (DStamp, 'DD-MON-YYYY') Receipt_Date,
	SUM (Update_QTY) Receipt_Eaches,
	COUNT (DISTINCT Reference_ID || Line_ID) Receipt_Lines,
	COUNT (DISTINCT Reference_ID) Receipt_Orders 
FROM Inventory_transaction
WHERE Code = 'Receipt'
and archived='N'
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
