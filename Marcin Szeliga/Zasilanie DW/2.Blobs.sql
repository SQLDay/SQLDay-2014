USE master
GO

ALTER DATABASE StageV1
ADD FILEGROUP FSStorage CONTAINS FILESTREAM;
GO

ALTER DATABASE StageV1 
SET FILESTREAM (NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = N'Blobs'); 
GO

ALTER DATABASE StageV1
ADD FILE
  (NAME = FsFile, FILENAME = N'C:\SQL\FileTable' )
TO FILEGROUP FSStorage;
GO

USE StageV1
GO

CREATE TABLE Blobs AS FileTable 
WITH (filetable_directory = N'Blobs')
GO

/*
WITH Names AS
	(SELECT REPLACE([EnglishProductName],'/','-') AS EnglishProductName, [LargePhoto]
	FROM [dbo].[DimProducts])
INSERT INTO [dbo].[Blobs] (name, file_stream)
SELECT REPLACE([EnglishProductName],'.','-') + '.jpg', [LargePhoto]
FROM Names;
*/

--Export Column Snippet
/*
WITH Names AS
	(SELECT REPLACE([EnglishProductName],'/','-') AS EnglishProductName, [LargePhoto]
	FROM [dbo].[DimProducts])
SELECT 'C:\SQL\BLOBS\' + REPLACE([EnglishProductName],'.','-') + '.jpg' AS Path, [LargePhoto]
FROM Names;
*/