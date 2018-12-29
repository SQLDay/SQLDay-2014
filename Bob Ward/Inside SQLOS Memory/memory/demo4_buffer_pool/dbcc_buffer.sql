dbcc traceon(2588)
go
dbcc help(buffer)
go
dbcc traceon(3604)
go
dbcc buffer('willthecowboysevermakeitbacktothesuperbowl', 'canwewinwithromo', 100) with tableresults
go
dbcc dropcleanbuffers
go
dbcc buffer('willthecowboysevermakeitbacktothesuperbowl', 'canwewinwithromo', 100) with tableresults
go
dbcc buffer('willthecowboysevermakeitbacktothesuperbowl', 'canwewinwithromo', 100, 0, dirty) with tableresults
go
use willthecowboysevermakeitbacktothesuperbowl
go
update canwewinwithromo set col2 = 'Fat chance' where col1 = 1
go
dbcc buffer('willthecowboysevermakeitbacktothesuperbowl', 'canwewinwithromo', 100, 0, dirty) with tableresults
go
checkpoint
go
dbcc buffer('willthecowboysevermakeitbacktothesuperbowl', 'canwewinwithromo', 100, 0, dirty) with tableresults
go