USE CDC_SQLDay2014
GO

CREATE TABLE [dbo].[PersonCopy](
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
 CONSTRAINT [PK_PersonCopy] PRIMARY KEY CLUSTERED 
(
	[BusinessEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



--Table: [cdc_states]

CREATE TABLE [dbo].[cdc_states](
   [name] [nvarchar](100) NOT NULL,
   [state] [nvarchar](256) NOT NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[cdc_states] ADD  CONSTRAINT [PK_cdc_states] PRIMARY KEY CLUSTERED 
(
   [name] ASC
) WITH (PAD_INDEX = OFF) ON [PRIMARY]
GO



