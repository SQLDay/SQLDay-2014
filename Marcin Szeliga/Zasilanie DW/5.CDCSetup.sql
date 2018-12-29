
USE StageV1
GO

/****** Object:  Table [dbo].[DimCustomer_CDC]    Script Date: 1/31/2012 9:24:49 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DimCustomer_CDC]') AND type in (N'U'))
DROP TABLE [dbo].[DimCustomer_CDC]
GO

SELECT * 
INTO DimCustomer_CDC
FROM [dbo].[DimCustomers]
WHERE CustomerBusinessKey < 15000
GO

EXEC sp_changedbowner 'sa'
GO

EXEC sys.sp_cdc_enable_db
GO 

ALTER TABLE dbo.[DimCustomer_CDC] 
ALTER COLUMN [CustomerBusinessKey] int NOT NULL
GO

-- add a primary key to the DimCustomer_CDC table so we can enable support for net changes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DimCustomer_CDC]') AND name = N'PK_DimCustomer_CDC')  
ALTER TABLE [dbo].[DimCustomer_CDC] 
ADD CONSTRAINT [PK_DimCustomer_CDC] 
PRIMARY KEY CLUSTERED
	(    
		[CustomerBusinessKey] ASC
	)
GO 

EXEC sys.sp_cdc_enable_table
	@source_schema = N'dbo',
	@source_name = N'DimCustomer_CDC',
	@role_name = N'cdc_admin',
	@supports_net_changes = 1 
	
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DimCustomer_Destination]') AND type in (N'U'))
DROP TABLE [dbo].[DimCustomer_Destination]
GO

SELECT TOP 0 * INTO DimCustomer_Destination
FROM DimCustomer_CDC
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_DimCustomer_UPDATES]') AND type in (N'U'))
BEGIN   
	SELECT TOP 0 * INTO stg_DimCustomer_UPDATES   
	FROM DimCustomer_Destination
END 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_DimCustomer_DELETES]') AND type in (N'U'))
BEGIN   
	SELECT TOP 0 * INTO stg_DimCustomer_DELETES   
	FROM DimCustomer_Destination
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cdc_states]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[cdc_states] 
 ([name] [nvarchar](256) NOT NULL, 
 [state] [nvarchar](256) NOT NULL) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [cdc_states_name] ON 
 [dbo].[cdc_states] 
 ( [name] ASC ) 
 WITH (PAD_INDEX  = OFF) ON [PRIMARY]
END