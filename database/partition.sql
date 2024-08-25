-------------------------USER----------------------------------------------------------------
--create six new file groups
ALTER DATABASE lms
ADD FILEGROUP user_20000;

ALTER DATABASE lms
ADD FILEGROUP user_20000_40000;

ALTER DATABASE lms
ADD FILEGROUP user_40000_60000;

ALTER DATABASE lms
ADD FILEGROUP user_60000_80000;

ALTER DATABASE lms
ADD FILEGROUP user_80000_100000;

ALTER DATABASE lms
ADD FILEGROUP user_100000;

GO

--Second, map the filegroups with the physical files.
ALTER DATABASE lms
ADD FILE (
    NAME = user_20000,
    FILENAME = 'E:\data\user\user_20000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP user_20000;

ALTER DATABASE lms
ADD FILE (
    NAME = user_20000_40000,
    FILENAME = 'E:\data\user\user_20000_40000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP user_20000_40000;

ALTER DATABASE lms
ADD FILE (
    NAME = user_40000_60000,
    FILENAME = 'E:\data\user\user_40000_60000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP user_40000_60000;

ALTER DATABASE lms
ADD FILE (
    NAME = user_60000_80000,
    FILENAME = 'E:\data\user\user_60000_80000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP user_60000_80000;

ALTER DATABASE lms
ADD FILE (
    NAME = user_80000_100000,
    FILENAME = 'E:\data\user\user_80000_100000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP user_80000_100000;

ALTER DATABASE lms
ADD FILE (
    NAME = user_100000,
    FILENAME = 'E:\data\user\user_100000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP user_100000;

GO

--Third, create the partitioning function and scheme.
CREATE PARTITION FUNCTION pf_UserId(int)
AS RANGE LEFT FOR VALUES (20000, 40000, 60000, 80000, 100000);

CREATE PARTITION SCHEME ps_UserId
AS PARTITION pf_UserId
TO ([user_20000], [user_20000_40000], [user_40000_60000], [user_60000_80000], [user_80000_100000], [user_100000]);

GO
--Fourth, create the partitioned table.
CREATE TABLE [dbo].[userFixed]
(
	id INT IDENTITY(1, 1) NOT NULL,
	email VARCHAR(256) NOT NULL,
	password VARCHAR(128) NOT NULL,
	name NVARCHAR(128) NOT NULL,
	type CHAR(2) NOT NULL CHECK(type IN ('AD', 'LN', 'LT')),

	CONSTRAINT [pk_userFixed] PRIMARY KEY(id)
) ON ps_UserId(id);
GO

SET IDENTITY_INSERT [dbo].[userFixed] ON;

INSERT INTO [dbo].[userFixed] (id, email, password, name, type)
SELECT id, email, password, name, type
FROM [dbo].[user];

SET IDENTITY_INSERT [dbo].[userFixed] OFF;
GO


SELECT 
    t.name AS TableName,
    p.partition_number,
    p.rows AS NumberOfRows
FROM 
    sys.partitions p
JOIN 
    sys.tables t ON p.object_id = t.object_id
WHERE 
    t.name = 'userFixed'
AND 
    p.index_id IN (0, 1);

-------------------------BANK ACCOUNT----------------------------------------------------------------
--create six new file groups
ALTER DATABASE lms
ADD FILEGROUP bankAccount_30000;

ALTER DATABASE lms
ADD FILEGROUP bankAccount_30000_60000;

ALTER DATABASE lms
ADD FILEGROUP bankAccount_60000_90000;

ALTER DATABASE lms
ADD FILEGROUP bankAccount_90000_120000;

ALTER DATABASE lms
ADD FILEGROUP bankAccount_120000_150000;

ALTER DATABASE lms
ADD FILEGROUP bankAccount_150000;

GO


--Second, map the filegroups with the physical files.
ALTER DATABASE lms
ADD FILE (
    NAME = bankAccount_30000,
    FILENAME = 'E:\data\bankAccount\bankAccount_30000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP bankAccount_30000;

ALTER DATABASE lms
ADD FILE (
    NAME = bankAccount_30000_60000,
    FILENAME = 'E:\data\bankAccount\bankAccount_30000_60000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP bankAccount_30000_60000;

ALTER DATABASE lms
ADD FILE (
    NAME = bankAccount_60000_90000,
    FILENAME = 'E:\data\bankAccount\bankAccount_60000_90000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP bankAccount_60000_90000;

ALTER DATABASE lms
ADD FILE (
    NAME = bankAccount_90000_120000,
    FILENAME = 'E:\data\bankAccount\bankAccount_90000_120000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP bankAccount_90000_120000;

ALTER DATABASE lms
ADD FILE (
    NAME = bankAccount_120000_150000,
    FILENAME = 'E:\data\bankAccount\bankAccount_120000_150000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP bankAccount_120000_150000;

ALTER DATABASE lms
ADD FILE (
    NAME = bankAccount_150000,
    FILENAME = 'E:\data\bankAccount\bankAccount_150000.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP bankAccount_150000;

GO
CREATE PARTITION FUNCTION pf_ownerIdRange(int)
AS RANGE LEFT FOR VALUES (30000, 60000, 90000, 120000, 150000);

CREATE PARTITION SCHEME ps_ownerId
AS PARTITION pf_ownerIdRange
TO ([bankAccount_30000], [bankAccount_30000_60000], 
    [bankAccount_60000_90000], [bankAccount_90000_120000], 
    [bankAccount_120000_150000], [bankAccount_150000]);

GO
--Fourth, create the partitioned table.
CREATE TABLE [dbo].[bankAccountFixed]
(
	ownerId INT NOT NULL,
	accountNumber VARCHAR(16) NOT NULL,
	goodThru DATE NOT NULL,
	cvc VARCHAR(3) NOT NULL,
	cardholderName VARCHAR(128) NOT NULL,
	regionId INT NOT NULL,
	zip VARCHAR(8) NOT NULL,
	inAppBalance MONEY NOT NULL DEFAULT 0,

	CONSTRAINT [pk_bankAccountFixed] PRIMARY KEY(ownerId),
) ON ps_ownerId(ownerId);
GO

INSERT INTO [dbo].[bankAccountFixed]
SELECT *
FROM [dbo].[bankAccount];
GO


SELECT 
    t.name AS TableName,
    p.partition_number,
    p.rows AS NumberOfRows
FROM 
    sys.partitions p
JOIN 
    sys.tables t ON p.object_id = t.object_id
WHERE 
    t.name = 'bankAccountFixed'
AND 
    p.index_id IN (0, 1);

-------------------------transaction----------------------------------------------------------------
--create file groups
ALTER DATABASE lms
ADD FILEGROUP transaction_2021_1;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_2;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_3;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_4;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_5;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_6;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_7;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_8;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_9;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_10;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_11;

ALTER DATABASE lms
ADD FILEGROUP transaction_2021_12;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_1;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_2;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_3;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_4;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_5;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_6;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_7;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_8;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_9;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_10;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_11;

ALTER DATABASE lms
ADD FILEGROUP transaction_2022_12;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_1;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_2;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_3;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_4;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_5;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_6;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_7;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_8;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_9;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_10;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_11;

ALTER DATABASE lms
ADD FILEGROUP transaction_2023_12;

ALTER DATABASE lms
ADD FILEGROUP transaction_2024_1;

ALTER DATABASE lms
ADD FILEGROUP transaction_2024_2;

ALTER DATABASE lms
ADD FILEGROUP transaction_2024_3;

ALTER DATABASE lms
ADD FILEGROUP transaction_2024_4;

ALTER DATABASE lms
ADD FILEGROUP transaction_2024_5;

ALTER DATABASE lms
ADD FILEGROUP transaction_2024_6;

ALTER DATABASE lms
ADD FILEGROUP transaction_2024_7;

ALTER DATABASE lms
ADD FILEGROUP transaction_2024_8;

GO

--Second, map the filegroups with the physical files.

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_1,
    FILENAME = 'E:\data\transaction\transaction_2021_1.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_1;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_2,
    FILENAME = 'E:\data\transaction\transaction_2021_2.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_2;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_3,
    FILENAME = 'E:\data\transaction\transaction_2021_3.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_3;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_4,
    FILENAME = 'E:\data\transaction\transaction_2021_4.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_4;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_5,
    FILENAME = 'E:\data\transaction\transaction_2021_5.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_5;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_6,
    FILENAME = 'E:\data\transaction\transaction_2021_6.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_6;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_7,
    FILENAME = 'E:\data\transaction\transaction_2021_7.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_7;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_8,
    FILENAME = 'E:\data\transaction\transaction_2021_8.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_8;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_9,
    FILENAME = 'E:\data\transaction\transaction_2021_9.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_9;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_10,
    FILENAME = 'E:\data\transaction\transaction_2021_10.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_10;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_11,
    FILENAME = 'E:\data\transaction\transaction_2021_11.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_11;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2021_12,
    FILENAME = 'E:\data\transaction\transaction_2021_12.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2021_12;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_1,
    FILENAME = 'E:\data\transaction\transaction_2022_1.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_1;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_2,
    FILENAME = 'E:\data\transaction\transaction_2022_2.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_2;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_3,
    FILENAME = 'E:\data\transaction\transaction_2022_3.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_3;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_4,
    FILENAME = 'E:\data\transaction\transaction_2022_4.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_4;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_5,
    FILENAME = 'E:\data\transaction\transaction_2022_5.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_5;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_6,
    FILENAME = 'E:\data\transaction\transaction_2022_6.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_6;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_7,
    FILENAME = 'E:\data\transaction\transaction_2022_7.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_7;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_8,
    FILENAME = 'E:\data\transaction\transaction_2022_8.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_8;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_9,
    FILENAME = 'E:\data\transaction\transaction_2022_9.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_9;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_10,
    FILENAME = 'E:\data\transaction\transaction_2022_10.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_10;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_11,
    FILENAME = 'E:\data\transaction\transaction_2022_11.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_11;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2022_12,
    FILENAME = 'E:\data\transaction\transaction_2022_12.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2022_12;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_1,
    FILENAME = 'E:\data\transaction\transaction_2023_1.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_1;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_2,
    FILENAME = 'E:\data\transaction\transaction_2023_2.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_2;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_3,
    FILENAME = 'E:\data\transaction\transaction_2023_3.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_3;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_4,
    FILENAME = 'E:\data\transaction\transaction_2023_4.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_4;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_5,
    FILENAME = 'E:\data\transaction\transaction_2023_5.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_5;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_6,
    FILENAME = 'E:\data\transaction\transaction_2023_6.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_6;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_7,
    FILENAME = 'E:\data\transaction\transaction_2023_7.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_7;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_8,
    FILENAME = 'E:\data\transaction\transaction_2023_8.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_8;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_9,
    FILENAME = 'E:\data\transaction\transaction_2023_9.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_9;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_10,
    FILENAME = 'E:\data\transaction\transaction_2023_10.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_10;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_11,
    FILENAME = 'E:\data\transaction\transaction_2023_11.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_11;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2023_12,
    FILENAME = 'E:\data\transaction\transaction_2023_12.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2023_12;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2024_1,
    FILENAME = 'E:\data\transaction\transaction_2024_1.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2024_1;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2024_2,
    FILENAME = 'E:\data\transaction\transaction_2024_2.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2024_2;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2024_3,
    FILENAME = 'E:\data\transaction\transaction_2024_3.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2024_3;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2024_4,
    FILENAME = 'E:\data\transaction\transaction_2024_4.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2024_4;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2024_5,
    FILENAME = 'E:\data\transaction\transaction_2024_5.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2024_5;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2024_6,
    FILENAME = 'E:\data\transaction\transaction_2024_6.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2024_6;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2024_7,
    FILENAME = 'E:\data\transaction\transaction_2024_7.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2024_7;

ALTER DATABASE lms
ADD FILE (
    NAME = transaction_2024_8,
    FILENAME = 'E:\data\transaction\transaction_2024_8.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP transaction_2024_8;

CREATE PARTITION FUNCTION pf_createdAtRange(datetime)
AS RANGE RIGHT FOR VALUES (
    '2021-02-01', '2021-03-01', '2021-04-01', '2021-05-01', '2021-06-01', '2021-07-01',
    '2021-08-01', '2021-09-01', '2021-10-01', '2021-11-01', '2021-12-01',
    '2022-01-01', '2022-02-01', '2022-03-01', '2022-04-01', '2022-05-01', '2022-06-01',
    '2022-07-01', '2022-08-01', '2022-09-01', '2022-10-01', '2022-11-01', '2022-12-01',
    '2023-01-01', '2023-02-01', '2023-03-01', '2023-04-01', '2023-05-01', '2023-06-01',
    '2023-07-01', '2023-08-01', '2023-09-01', '2023-10-01', '2023-11-01', '2023-12-01',
    '2024-01-01', '2024-02-01', '2024-03-01', '2024-04-01', '2024-05-01', '2024-06-01', 
    '2024-07-01', '2024-08-01'
);

CREATE PARTITION SCHEME ps_createdAt
AS PARTITION pf_createdAtRange
TO ([transaction_2021_1], [transaction_2021_2], [transaction_2021_3], [transaction_2021_4], 
    [transaction_2021_5], [transaction_2021_6], [transaction_2021_7], [transaction_2021_8],
    [transaction_2021_9], [transaction_2021_10], [transaction_2021_11], [transaction_2021_12],
    [transaction_2022_1], [transaction_2022_2], [transaction_2022_3], [transaction_2022_4], 
    [transaction_2022_5], [transaction_2022_6], [transaction_2022_7], [transaction_2022_8],
    [transaction_2022_9], [transaction_2022_10], [transaction_2022_11], [transaction_2022_12],
    [transaction_2023_1], [transaction_2023_2], [transaction_2023_3], [transaction_2023_4], 
    [transaction_2023_5], [transaction_2023_6], [transaction_2023_7], [transaction_2023_8],
    [transaction_2023_9], [transaction_2023_10], [transaction_2023_11], [transaction_2023_12],
    [transaction_2024_1], [transaction_2024_2], [transaction_2024_3], [transaction_2024_4], 
    [transaction_2024_5], [transaction_2024_6], [transaction_2024_7], [transaction_2024_8]);
GO

CREATE TABLE [dbo].[transactionFixed]
(
	initiatorId INT,
	receiverId INT,
	courseId INT,
	createdAt DATETIME NOT NULL DEFAULT GETDATE(),
	paidAmount MONEY NOT NULL,
	taxPercentage FLOAT NOT NULL,
	transactionFee MONEY NOT NULL,
	sharePercentage FLOAT NOT NULL,
	discountPercentage FLOAT NOT NULL,
	netAmount AS ((paidAmount - transactionFee - taxPercentage * paidAmount) * (1 - discountPercentage)),
	revenue AS (((paidAmount - transactionFee - taxPercentage * paidAmount) * (1 - discountPercentage)) * sharePercentage),

	CONSTRAINT [pk_transactionFixed] PRIMARY KEY(initiatorId, receiverId, courseId, createdAt)
) ON ps_createdAt(createdAt);
GO

INSERT INTO [dbo].[transactionFixed] (initiatorId, receiverId, courseId, createdAt, paidAmount, taxPercentage, transactionFee, sharePercentage, discountPercentage)
SELECT initiatorId, receiverId, courseId, createdAt, paidAmount, taxPercentage, transactionFee, sharePercentage, discountPercentage
FROM [dbo].[transaction];
GO

SELECT 
    t.name AS TableName,
    p.partition_number,
    p.rows AS NumberOfRows
FROM 
    sys.partitions p
JOIN 
    sys.tables t ON p.object_id = t.object_id
WHERE 
    t.name = 'transactionFixed'
AND 
    p.index_id IN (0, 1);


select $PARTITION.pf_createdAtRange(createdAt) AS PartitionNumber, count(*) AS TotalRows
from dbo.transactionFixed
group by $PARTITION.pf_createdAtRange(createdAt)
order by $PARTITION.pf_createdAtRange(createdAt);

-------------------------courseAnnoucement----------------------------------------------------------------
--create file groups
ALTER DATABASE lms
ADD FILEGROUP courseAnnouncement_2021;

ALTER DATABASE lms
ADD FILEGROUP courseAnnouncement_2022;

ALTER DATABASE lms
ADD FILEGROUP courseAnnouncement_2023;

ALTER DATABASE lms
ADD FILEGROUP courseAnnouncement_2024;

ALTER DATABASE lms
ADD FILEGROUP courseAnnouncement_others;

GO

--Second, map the filegroups with the physical files.
ALTER DATABASE lms
ADD FILE (
    NAME = courseAnnouncement_2021,
    FILENAME = 'E:\data\courseAnnouncement\courseAnnouncement_2021.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP courseAnnouncement_2021;

ALTER DATABASE lms
ADD FILE (
    NAME = courseAnnouncement_2022,
    FILENAME = 'E:\data\courseAnnouncement\courseAnnouncement_2022.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP courseAnnouncement_2022;

ALTER DATABASE lms
ADD FILE (
    NAME = courseAnnouncement_2023,
    FILENAME = 'E:\data\courseAnnouncement\courseAnnouncement_2023.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP courseAnnouncement_2023;

ALTER DATABASE lms
ADD FILE (
    NAME = courseAnnouncement_2024,
    FILENAME = 'E:\data\courseAnnouncement\courseAnnouncement_2024.ndf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024 KB
) TO FILEGROUP courseAnnouncement_2024

GO
CREATE PARTITION FUNCTION pf_createdAtRange_courseAnnouncement(date)
AS RANGE RIGHT FOR VALUES (
    '2022-01-01', '2023-01-01', '2024-01-01'
);

CREATE PARTITION SCHEME ps_createdAt_courseAnnouncement
AS PARTITION pf_createdAtRange_courseAnnouncement
TO ([courseAnnouncement_2021], [courseAnnouncement_2022], [courseAnnouncement_2023], [courseAnnouncement_2024]);

GO

CREATE TABLE [dbo].[courseAnnouncementFixed]
(
	senderId INT,
	courseId INT NOT NULL,
	createdAt DATE NOT NULL DEFAULT GETDATE(),
	title NVARCHAR(64) NOT NULL,
	content NVARCHAR(512) NOT NULL,

	CONSTRAINT [pk_courseAnnouncementFixed] PRIMARY KEY(courseId, createdAt)
) ON ps_createdAt_courseAnnouncement(createdAt);
GO

INSERT INTO [dbo].[courseAnnouncementFixed]
SELECT *
FROM [dbo].[courseAnnouncement];
GO

SELECT 
    t.name AS TableName,
    p.partition_number,
    p.rows AS NumberOfRows
FROM 
    sys.partitions p
JOIN 
    sys.tables t ON p.object_id = t.object_id
WHERE 
    t.name = 'courseAnnouncementFixed'
AND 
    p.index_id IN (0, 1);

