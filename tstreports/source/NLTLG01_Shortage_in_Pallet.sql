Select t1.order_id, t1.line_id, t1.sku_id, t1.qty_ordered, nvl (t1.qty_tasked, 0) qty_tasked, nvl (t1.qty_picked, 0) qty_picked, nvl (t1.qty_shipped, 0) qty_shipped
From
(
select ol.order_id, ol.line_id, ol.sku_id, ol.qty_ordered, ol.qty_tasked, ol.qty_picked, ol.qty_shipped from dcsdba.order_line ol
where ol.order_id in 
(
select distinct mt.task_id from dcsdba.move_task mt
where mt.pallet_id like '21923812%'
))t1
where nvl (t1.qty_tasked, 0) + nvl (t1.qty_picked, 0) != t1.qty_ordered