Select oc.order_id, oc.container_id
,(Select consignment From dcsdba.order_header where oc.order_id = order_id)consignment
From DCSDBA.Order_Container oc where oc.order_id in
(
Select distinct mt.Task_Id From dcsdba.move_task mt
where mt.task_id in
(
Select oh.order_id From dcsdba.order_header oh
where oh.order_id in (Select order_id From dcsdba.order_container where pallet_id like '2%') --= :Pallet_id)
and oh.status != 'Ready to Load'
)
and mt.from_loc_id not in (select location_id from dcsdba.location where zone_1 like '%DS%DOCK')
)
--and pallet_id = :Pallet_id
order by oc.order_id, consignment, oc.container_id