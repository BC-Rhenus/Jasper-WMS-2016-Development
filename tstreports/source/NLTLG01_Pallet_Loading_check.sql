Select distinct t1.task_id, t1.Consignment, t1.order_header_status
, (select status from dcsdba.order_container where mt.pallet_id = pallet_id and order_id = mt.task_id and mt.container_id = container_id)Container_status
, mt.pallet_id, mt.container_id, Mt.From_Loc_Id, Mt.To_Loc_Id, Mt.Final_Loc_Id, (Mt.Status) task_status, t1.Check_String From 
(
Select Distinct mt.task_id, Oh.Consignment, (oh.status) order_header_status, (Oc.Status) Container_status,mt.container_id, Mt.From_Loc_Id, Mt.To_Loc_Id, Mt.Final_Loc_Id, (Mt.Status) task_status, L.Check_String From DCSDBA.Order_Container oc
inner join dcsdba.move_task mt on mt.task_id = oc.order_id and mt.container_id = oc.container_id
inner join dcsdba.order_header oh  on oh.order_id = oc.order_id and oh.status = nvl(:OH_Status, oh.status)
inner join dcsdba.location l on l.location_id = Mt.from_Loc_Id
where mt.pallet_id in (:Pallet_id, '21941133')--mt.pallet_id like ('2%')
--
)t1
inner join dcsdba.move_task mt
on mt.task_id = t1.task_id 
order by t1.task_id
;

Select distinct t1.task_id as TASK_ID, 
		        t1.Consignment, 
		        t1.order_header_status,
                (select status from dcsdba.order_container where mt.pallet_id = pallet_id and order_id = mt.task_id and mt.container_id = container_id) Container_status,
                mt.pallet_id, 
                mt.container_id, 
                Mt.From_Loc_Id, 
                Mt.To_Loc_Id, 
                Mt.Final_Loc_Id, 
               (Mt.Status) task_status 
From 

   (
   Select Distinct 
                  mt.task_id, 
                  Oh.Consignment, 
                  (oh.status) order_header_status, 
                  (Oc.Status) Container_status,
                  mt.container_id, 
                  Mt.From_Loc_Id, 
                  Mt.To_Loc_Id, 
                  Mt.Final_Loc_Id, 
                  (Mt.Status) task_status, 
                  L.Check_String 
     From DCSDBA.Order_Container oc
                 inner join dcsdba.move_task mt on mt.task_id = oc.order_id and mt.container_id = oc.container_id
                 inner join dcsdba.order_header oh  on oh.order_id = oc.order_id and oh.status = nvl('', oh.status)
                 inner join dcsdba.location l on l.location_id = Mt.from_Loc_Id
     where mt.pallet_id like '2%'
     --mt.pallet_id in ('21941133')
     ) t1
inner join dcsdba.move_task mt
on mt.task_id = t1.task_id 
order by t1.task_id