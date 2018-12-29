USE CDC_SQLDay2014
GO

--DROP TABLE [dbo].[DimPerson]
--GO

CREATE TABLE [dbo].[DimPerson](
     [ID] int IDENTITY(1,1) NOT NULL,
	[BusinessEntityID] [int] NOT NULL,
	[PersonType] [nchar](2) NOT NULL,
	[NameStyle] [bit] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[EmailPromotion] [int] NOT NULL,
--	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[StartDate] [datetime] not null,
	[EndDate] [datetime] null
 CONSTRAINT [PK_DimPerson] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

