-- Find all events
select  * from sys.dm_xe_objects where object_type = 'event' order by name
go
-- Find the fields for the page_split event
select * from sys.dm_xe_object_columns where object_name = 'page_split'
go
-- Using the keyword concept, find me all events associated with the keyword
-- "errors"
select xeop.name as package, xeo.name as event, xeo.description
from sys.dm_xe_objects xeo
join sys.dm_xe_object_columns xeoc
on xeo.name = xeoc.object_name
and xeoc.name = 'keyword'
and xeo.object_type = 'event'
join sys.dm_xe_map_values xem
on xem.map_key = xeoc.column_value
and xem.object_package_guid = xeoc.type_package_guid
and xem.map_value = 'errors'
and xem.name = 'keyword_map'
join sys.dm_xe_packages xeop
on xeop.guid = xeo.package_guid
order by xeop.name, xem.map_value