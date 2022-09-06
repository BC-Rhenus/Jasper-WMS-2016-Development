/******************************************************************************/
/*                                                                            */
/*                             Rhenus ICT                                     */
/*                                                                            */
/*     FILE NAME  :     cl_rma_handover.sql                                   */
/*                                                                            */
/*     DESCRIPTION:     Kit instruction report Raymarine                      */
/*                                                                            */
/*   DATE     BY   PROJ   ID       DESCRIPTION                                */
/*   ======== ==== ====== ======== =============                              */
/*   12/02/16 BB   RIS    N/A      initial version                            */
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
LEFT 'Rhenus - Raymarine Kit instruction' RIGHT _DATESTAMP SKIP 1 -        
RIGHT _TIMESTAMP SKIP 1 -                               
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2 - 

/* Avoid duplicate values */
BREAK ON order_id SKIP 0 ON kit_id SKIP PAGE ON sku_desc SKIP 0 ON qty SKIP 0 ON container SKIP 1 ON serial SKIP 0

/* Column Headings and Formats */
COLUMN order_id HEADING 'Order ID' FORMAT A20 WORD_WRAP
COLUMN kit_id HEADING 'KIT' FORMAT A20 WORD_WRAP
COLUMN sku_desc HEADING 'SKU/|Description' FORMAT A40 WORD_WRAP
COLUMN qty HEADING '   Qty' FORMAT 999999
COLUMN serial HEADING 'Serial Nrs' FORMAT A30
COLUMN container HEADING 'Container' FORMAT A10

/* SQL Select statement */
select  rpad(ohr.order_id,20,' ')                           order_id
,       substr(nvl(ole.customer_sku_desc2,'No KIT'),1,20)   kit_id
,       rpad(mtk.sku_id,40,' ')                             
||      ole.customer_sku_desc1                              sku_desc
,       mtk.qty_to_move                                     qty
,       snr.serial_number                                   serial
,       mtk.container_id                                    container
from    order_container     ocr
,       order_header        ohr
,       order_line          ole
,       move_task           mtk
,       serial_number       snr
,       (
        select  client_id
        ,       order_id
        from    order_container
        where   client_id    = 'FLIRB'
        and     container_id = '&2'
        )   oc1
where   oc1.client_id       = ocr.client_id
and     oc1.order_id        = ocr.order_id
and     ocr.client_id       = ole.client_id
and     ocr.order_id        = ole.order_id
and     ocr.client_id       = ohr.client_id
and     ocr.order_id        = ohr.order_id
and     mtk.client_id       = ole.client_id
and     mtk.task_id         = ole.order_id
and     mtk.line_id         = ole.line_id
and     mtk.container_id    = ocr.container_id
and     mtk.task_type       = 'O'                   -- Repack
and     mtk.client_id       = snr.client_id (+)
and     mtk.task_id         = snr.order_id (+)
and     mtk.line_id         = snr.line_id (+)
and     mtk.sku_id          = snr.sku_id (+)
and     mtk.tag_id          = snr.tag_id (+)
and     mtk.container_id    = snr.container_id (+)
order   by order_id
,       ole.customer_sku_desc2 nulls last
,       sku_desc
,       qty
,       serial nulls last
,       container
;

SET TERMOUT ON
