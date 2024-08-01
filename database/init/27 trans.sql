USE lms
GO

SET DATEFIRST 7
GO




-- Create the procedures
CREATE OR ALTER PROCEDURE [dbo].[selectUser] @email VARCHAR(256)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT email, name, type
	FROM [dbo].[user]
	WHERE email = @email
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[selectUserByCred]
	@email VARCHAR(256),
	@password VARCHAR(128)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT *
	FROM [dbo].[user]
	WHERE email = @email AND password = @password
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertUser]
	@email VARCHAR(256),
	@password VARCHAR(128),
	@name NVARCHAR(128),
	@type CHAR(2)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF @type = 'AD'
	BEGIN;
		THROW 51000, 'Admin users cannot be created.', 1;
	END

	INSERT INTO [dbo].[user]
	VALUES(@email, @password, @name, @type)

	SELECT *
	FROM [dbo].[user]
	WHERE email = @email AND password = @password
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertCourse]
	@title NVARCHAR(64),
	@subtitle NVARCHAR(128),
	@ownerEmail VARCHAR(256)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF @title IS NULL OR @subtitle IS NULL OR @ownerEmail IS NULL
	BEGIN;
		THROW 51000, 'Title, subtitle, and owner email are required.', 1;
	END

	INSERT INTO [dbo].[course](title, subtitle, status)
	VALUES(@title, @subtitle, 'C')

	DECLARE @courseId INT = SCOPE_IDENTITY()
	-- INSERT INTO [dbo].[ownedCourse] VALUES (@ownerEmail, @courseId, 1)

	SELECT *
	FROM [dbo].[course]
	WHERE id = @courseId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[selectCourse]
	@id INT,
	@withCategories BIT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF (@withCategories = 1)
	BEGIN
		SELECT
			co.*,
			(
				SELECT ca.id, ca.title, ca.parentId
				FROM [dbo].[courseCategory] cc
				LEFT JOIN [dbo].[category] ca ON cc.categoryId = ca.id
				WHERE cc.courseId = co.id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) as categories
		FROM [dbo].[course] co
		WHERE co.id = @id

		COMMIT TRANSACTION
		RETURN
	END

	SELECT *
	FROM [dbo].[course]
	WHERE id = @id
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateCourseCategories]
	@id INT,
	@categoryIds NVARCHAR(MAX)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

  	CREATE TABLE #categoryIds (categoryId INT)

    INSERT INTO #categoryIds (categoryId)
    SELECT value
    FROM OPENJSON(@categoryIds)
    WITH (value INT '$')

	DELETE FROM [dbo].[courseCategory]
	WHERE courseId = @id

	INSERT INTO [dbo].[courseCategory]
	SELECT @id, categoryId
	FROM #categoryIds

	DROP TABLE #categoryIds
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateCourse]
	@id INT,
	@title NVARCHAR(64),
	@subtitle NVARCHAR(128),
	@description NVARCHAR(MAX),
	@price MONEY,
	@level CHAR(1),
	@thumbnail NVARCHAR(256),
	@advertisementVideo NVARCHAR(256),
	@updatedAt DATETIME,
	@categoryIds NVARCHAR(MAX)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	UPDATE [dbo].[course]
	SET
	title = @title,
	subtitle = @subtitle,
	description = @description,
	price = @price,
	level = @level,
	thumbnail = COALESCE(@thumbnail, thumbnail),
	advertisementVideo = COALESCE(@advertisementVideo, advertisementVideo),
	updatedAt = @updatedAt
	WHERE id = @id

	-- INSERT INTO [dbo].[ownedCourse] VALUES (@ownerEmail, @courseId, 1)

	EXEC [dbo].[updateCourseCategories] @id, @categoryIds

	SELECT *
	FROM [dbo].[course]
	WHERE id = @id
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[searchCategories]
	@title NVARCHAR(64)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT TOP 20 id, title, parentId
	FROM [dbo].[category]
	WHERE title LIKE @title + '%'
	ORDER BY title
COMMIT TRANSACTION
GO