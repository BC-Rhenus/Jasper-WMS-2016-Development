/******************************************************************************/
/*                                                                            */
/*                      Rhenus Contract Logistics      	                      */
/*                                                                            */
/*     FILE NAME  :     eachlineordshipbydate.sql                             */
/*                                                                            */
/*     DESCRIPTION:     Output the eaches, lines and po's shipped. 			  */
/*						From shipping manifest table.						  */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   28/06/01 MJT  DCS    NEW5486  Client ID added							  */
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
LEFT 'Shipped Eaches, Order Lines and Orders By Site, Client, Owner and Date Range' RIGHT _DATESTAMP SKIP 1 -
RIGHT _TIMESTAMP SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
 
/* Column Headings and Formats */
COLUMN OrderByShipDay NEW_VALUE nOrderByShipDay NOPRINT
COLUMN Site_ID HEADING 'Site' FORMAT A10
COLUMN Client_ID HEADING 'Client' FORMAT A10
COLUMN Owner_ID HEADING 'Owner' FORMAT A10
COLUMN Shipped_Hour HEADING 'Date' FORMAT A12
COLUMN Shipped_Eaches HEADING 'Eaches Shipped' FORMAT 999999999
COLUMN Shipped_Lines HEADING 'Lines Shipped' FORMAT 999999999
COLUMN Shipped_Orders HEADING 'Orders Shipped' FORMAT 999999999

BREAK ON Site_ID SKIP PAGE ON Client_ID SKIP PAGE ON Owner_ID SKIP 2 ON OrderByShipDay

COMPUTE SUM OF Shipped_Eaches ON Owner_ID 
COMPUTE SUM OF Shipped_Lines ON Owner_ID
COMPUTE SUM OF Shipped_Orders ON Owner_ID
COMPUTE SUM OF Shipped_Eaches ON Client_ID 
COMPUTE SUM OF Shipped_Lines ON Client_ID
COMPUTE SUM OF Shipped_Orders ON Client_ID
COMPUTE SUM OF Shipped_Eaches ON Site_ID
COMPUTE SUM OF Shipped_Lines ON Site_ID
COMPUTE SUM OF Shipped_Orders ON Site_ID


SELECT  Site_ID
,       Client_ID
,       Owner_ID
,       TO_CHAR (Shipped_DStamp, 'YYYYMMDD')    OrderByShipDay
,       TO_CHAR (Shipped_DStamp, 'DD-MON-YYYY') Shipped_Hour
,       SUM (QTY_Shipped)                       Shipped_Eaches
,       COUNT (DISTINCT Order_ID || Line_ID)    Shipped_Lines
,       COUNT (DISTINCT Order_ID)               Shipped_Orders 
FROM    Shipping_Manifest 
WHERE   Shipped = 'Y'
and archived='N'
AND     Shipped_DStamp BETWEEN TO_DATE('&5', 'DD-MON-YYYY')
AND     TO_DATE('&6', 'DD-MON-YYYY') + (1 - (1/86400))
AND     (('&2' IS NULL) OR (Site_ID = '&2'))
AND     (('&4' IS NULL) OR (Owner_ID = '&4'))
AND     ((('&3' IS NULL) AND ('&7' IS NULL))
OR      (Client_ID = '&3')
OR      (('&3' IS NULL) AND Client_ID IN    (SELECT Client_ID 
                                            FROM Client_Group_Clients
                                            WHERE Client_Group = '&7')))  
GROUP   BY Site_ID
,       Client_ID
,       Owner_ID
,       TO_CHAR (Shipped_DStamp, 'YYYYMMDD')
,       TO_CHAR (Shipped_DStamp, 'DD-MON-YYYY')
ORDER   BY 1,2,3,4,5
/

SET TERMOUT ON
