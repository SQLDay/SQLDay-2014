declare @x int
declare @y varchar(1000)
declare @z varchar(1000)
set @x = 0
while (@x < 500000)
begin
	set @z = 'select * from sys.objects where object_id = '+cast(@x as varchar(50))
	exec (@z)
	set @x = @x + 1
end
go