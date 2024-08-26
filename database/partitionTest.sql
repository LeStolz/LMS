--PTT1
CREATE OR ALTER PROCEDURE [dbo].[selectLecturerEarningPerMonthFixed]
	@id INT,
	@date DATE,
	@courseId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT SUM(revenue) AS count FROM [dbo].[transactionFixed]
	WHERE
		receiverId = @id AND
		DATEFROMPARTS(YEAR(@date), MONTH(@date), 1) = DATEFROMPARTS(YEAR(createdAt), MONTH(createdAt), 1)
COMMIT TRANSACTION
GO
--Before
DECLARE @StartTime DATETIME2, @EndTime DATETIME2;
SET @StartTime = SYSDATETIME();

EXEC selectLecturerEarningPerMonth 66894, '2021-11-01', 56122;

SET @EndTime = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecTimeInMsBeforeDcp;

GO
--After
DECLARE @StartTime DATETIME2, @EndTime DATETIME2;
SET @StartTime = SYSDATETIME();

EXEC selectLecturerEarningPerMonthFixed 66894, '2021-11-01', null;

SET @EndTime = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecTimeInMsBeforeDcp;



--PTT2
CREATE OR ALTER PROCEDURE [dbo].[searchCourseAnnouncementFixed]
	@offset INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT courseId FROM [dbo].[courseAnnouncementFixed]
	ORDER BY createdAt DESC
	OFFSET @offset ROWS
	FETCH NEXT 40 ROWS ONLY
COMMIT TRANSACTION
GO

--Before
DECLARE @StartTime DATETIME2, @EndTime DATETIME2;
SET @StartTime = SYSDATETIME();

EXEC searchCourseAnnouncement 0

SET @EndTime = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecTimeInMsBeforeDcp;

GO
--After
DECLARE @StartTime DATETIME2, @EndTime DATETIME2;
SET @StartTime = SYSDATETIME();

EXEC searchCourseAnnouncementFixed 0;

SET @EndTime = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecTimeInMsBeforeDcp;


