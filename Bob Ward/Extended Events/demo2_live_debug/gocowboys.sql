use willthecowboysevermakeitbacktothesuperbowl
go
drop procedure gocowboys
go
create procedure gocowboys
as
DECLARE @romoqb table(
    col1 int,
	col2 char(5000) not null);
insert into @romoqb select * from canwewinwithromo 
where col1 < 50000
select cp.player_name, rqb.col1, rqb.col2
from @romoqb rqb
join cowboys_players cp
on cp.col1 = rqb.col1
--option (recompile)
go