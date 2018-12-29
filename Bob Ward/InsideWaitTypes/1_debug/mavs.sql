use master
go
drop database mavstothenbafinals
go
create database mavstothenbafinals
go
use mavstothenbafinals
go
drop table themavsstarters
go
create table themavsstarters (name varchar(100), description varchar(200))
go
insert into themavsstarters values ('Dirk Nowitski', 'The MVP of the team')
insert into themavsstarters values ('Caron Butler', 'Im the new guy')
insert into themavsstarters values ('Tyson Chandler', 'The energy that propels this team')
insert into themavsstarters values ('Jason Terry', 'The Jet is on the runway')
insert into themavsstarters values ('Jason Kidd', 'I still don''t know why we made that trade')
go
