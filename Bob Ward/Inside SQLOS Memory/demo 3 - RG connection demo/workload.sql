SET NOCOUNT ON
DECLARE @i INT 
DECLARE @s VARCHAR(100)  
SET @i = 100000000
WHILE @i > 0 
BEGIN 
SELECT @s = @@version;
       SET @i = @i - 1; 
END
go