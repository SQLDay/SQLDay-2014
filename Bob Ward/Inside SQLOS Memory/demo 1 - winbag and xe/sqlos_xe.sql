-- Note that most sqlos events are Debug
-- Debug is not a default choice in SSMS and should only be used for what the name applies "Debugging"
-- Therefore if you turn a bunch of these on you could impact the performance of the server
--
select o.object_type, o.name, m.map_value as channel
from sys.dm_xe_objects o
join sys.dm_xe_packages p
on o.package_guid = p.guid
and p.name = 'sqlos'
join sys.dm_xe_object_columns oc
on oc.object_name = o.name
and oc.name = 'CHANNEL'
join sys.dm_xe_map_values m
on m.map_key = oc.column_value
and m.name = 'etw_channel'
group by o.object_type, o.name, m.map_value
order by o.object_type, o.name, m.map_value
go

-- Are there any actions or pred_sources?
--
select o.object_type, o.name
from sys.dm_xe_objects o
join sys.dm_xe_packages p
on o.package_guid = p.guid
and p.name = 'sqlos'
and o.object_type != 'event'
group by o.object_type, o.name
order by o.object_type, o.name
go
