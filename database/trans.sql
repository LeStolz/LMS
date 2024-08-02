USE lms
GO

SET DATEFIRST 7
GO




-- Create the procedures
CREATE OR ALTER PROCEDURE [dbo].[selectUser]
	@email VARCHAR(256),
	@withDetails BIT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	DECLARE @type CHAR(2) = (SELECT type FROM [dbo].[user] WHERE email = @email)

	IF @withDetails = 0 OR (@type) = 'AD'
	BEGIN;
		SELECT email, name, type FROM [dbo].[user] WHERE email = @email
	END
	ELSE IF (@type) = 'LN'
	BEGIN;
		SELECT u.email, u.name, u.type, b.* FROM [dbo].[user] u
		LEFT JOIN [dbo].[bankAccount] b ON u.email = b.ownerEmail
		WHERE email = @email
	END
	ELSE
	BEGIN;
		SELECT
			u.email, u.name, u.type,
			l.dob, l.gender, l.homeAddress, l.workAddress,
			l.nationality, l.phone, l.introduction, l.annualIncome,
			l.academicRank, l.academicDegree, l.profileImage,
			l.status, l.demandVerificationDate,
			b.*,
			(
				SELECT title, image FROM [dbo].[certificate]
				WHERE lecturerEmail = u.email
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS certificates,
			(
				SELECT * FROM [dbo].[workExperience]
				WHERE lecturerEmail = u.email
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS workExperiences
		FROM [dbo].[user] u
		LEFT JOIN [dbo].[bankAccount] b ON u.email = b.ownerEmail
		LEFT JOIN [dbo].[lecturer] l ON u.email = l.email
		WHERE u.email = @email
	END
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

	IF @type = 'LN'
	BEGIN;
		INSERT INTO [dbo].[learner]
		VALUES(@email)
	END

	SELECT *
	FROM [dbo].[user]
	WHERE email = @email AND password = @password
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateUser]
	@email VARCHAR(256),
	@oldPassword VARCHAR(128),
	@password VARCHAR(128),
	@name NVARCHAR(128)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF @oldPassword <> (SELECT password FROM [dbo].[user] WHERE email = @email)
	BEGIN;
		THROW 51000, 'Incorrect password.', 1;
	END

	UPDATE [dbo].[user]
	SET password = @password, name = @name
	WHERE email = @email
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateUserAndBankAccount]
	@email VARCHAR(256),
	@oldPassword VARCHAR(128),
	@name NVARCHAR(128),
	@type CHAR(2),
	@accountNumber VARCHAR(16),
	@goodThru DATE,
	@cvc VARCHAR(3),
	@cardholderName VARCHAR(128),
	@zip VARCHAR(16)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF @type = 'AD'
	BEGIN;
		THROW 51000, 'Admin bank accounts cannot be updated.', 1;
	END

	IF @oldPassword <> (SELECT password FROM [dbo].[user] WHERE email = @email)
	BEGIN;
		THROW 51000, 'Incorrect password.', 1;
	END

	IF NOT EXISTS(SELECT * FROM [dbo].[bankAccount] WHERE ownerEmail = @email)
	BEGIN;
		INSERT INTO [dbo].[bankAccount](accountNumber, goodThru, cvc, cardholderName, zip, ownerEmail)
		VALUES(@accountNumber, @goodThru, @cvc, @cardholderName, @zip, @email)
	END
	ELSE
	BEGIN;
		UPDATE [dbo].[bankAccount]
		SET
			accountNumber = @accountNumber,
			goodThru = @goodThru,
			cvc = @cvc,
			cardholderName = @cardholderName,
			zip = @zip
		WHERE ownerEmail = @email
	END
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateLecturer]
	@email VARCHAR(256),
	@oldPassword VARCHAR(128),
	@name NVARCHAR(128),
	@type CHAR(2),
	@accountNumber VARCHAR(16),
	@goodThru DATE,
	@cvc VARCHAR(3),
	@cardholderName VARCHAR(128),
	@zip VARCHAR(16),
	@dob DATE,
	@gender CHAR(1),
	@homeAddress NVARCHAR(256),
	@workAddress NVARCHAR(256),
	@nationality CHAR(2),
	@phone CHAR(10),
	@introduction NVARCHAR(512),
	@annualIncome MONEY,
	@academicRank CHAR(1),
	@academicDegree CHAR(1),
	@profileImage NVARCHAR(256),
	@certificates NVARCHAR(MAX),
	@workExperiences NVARCHAR(MAX)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT * FROM [dbo].[lecturer] WHERE email = @email)
	BEGIN;
		INSERT INTO [dbo].[lecturer]
		VALUES(
			@email, @dob, @gender, @homeAddress, @workAddress, @nationality, @phone, @introduction,
			@annualIncome, @academicRank, @academicDegree, @profileImage, 'R', GETDATE()
		)
	END
	ELSE
	BEGIN;
		UPDATE [dbo].[lecturer]
		SET
			dob = @dob,
			gender = @gender,
			homeAddress = @homeAddress,
			workAddress = @workAddress,
			nationality = @nationality,
			phone = @phone,
			introduction = @introduction,
			annualIncome = @annualIncome,
			academicRank = @academicRank,
			academicDegree = @academicDegree,
			profileImage = @profileImage
		WHERE email = @email
	END

  	CREATE TABLE #certificates (title NVARCHAR(128), image NVARCHAR(256))

    INSERT INTO #certificates
    SELECT title, image
    FROM OPENJSON(@certificates)
	WITH (
		title NVARCHAR(128) '$.title',
		image NVARCHAR(256) '$.image'
	)

	DELETE FROM [dbo].[certificate]
	WHERE lecturerEmail = @email

	INSERT INTO [dbo].[certificate]
	SELECT @email, title, image
	FROM #certificates

	DROP TABLE #certificates

  	CREATE TABLE #workExperiences (
		topic NVARCHAR(128),
		role NVARCHAR(128),
		organizationName NVARCHAR(128),
		fromDate DATE,
		toDate DATE
	)

    INSERT INTO #workExperiences
    SELECT topic, role, organizationName, fromDate, toDate
    FROM OPENJSON(@workExperiences)
	WITH (
		topic NVARCHAR(128) '$.topic',
		role NVARCHAR(128) '$.role',
		organizationName NVARCHAR(128) '$.organizationName',
		fromDate DATE '$.fromDate',
		toDate DATE '$.toDate'
	)

	DELETE FROM [dbo].[workExperience]
	WHERE lecturerEmail = @email

	INSERT INTO [dbo].[workExperience]
	SELECT @email, topic, role, organizationName, fromDate, toDate
	FROM #workExperiences

	DROP TABLE #workExperiences
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[demandLecturerVerification]
	@email VARCHAR(256)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	UPDATE [dbo].[lecturer]
	SET status = 'P'
	WHERE email = @email

	IF @@ROWCOUNT = 0
	BEGIN;
		THROW 51000, 'Lecturer has not filled out the profile form.', 1;
	END
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