USE lms
GO

SET DATEFIRST 7
GO




-- Create the procedures
CREATE OR ALTER PROCEDURE [dbo].[selectUser]
	@id INT,
	@withDetails BIT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	DECLARE @type CHAR(2) = (SELECT type FROM [dbo].[user] WHERE id = @id)

	IF @withDetails = 0 OR (@type) = 'AD'
	BEGIN;
		SELECT id, email, name, type FROM [dbo].[user] WHERE id = @id
	END
	ELSE IF (@type) = 'LN'
	BEGIN;
		SELECT u.id, u.email, u.name, u.type, b.* FROM [dbo].[user] u
		LEFT JOIN [dbo].[bankAccount] b ON u.Id = b.ownerId
		WHERE Id = @Id
	END
	ELSE
	BEGIN;
		SELECT
			u.id, u.email, u.name, u.type,
			l.dob, l.gender, l.homeAddress, l.workAddress,
			l.nationality, l.phone, l.introduction, l.annualIncome,
			l.academicRank, l.academicDegree, l.profileImage,
			l.status, l.demandVerificationDate,
			b.*,
			(
				SELECT title, image FROM [dbo].[certificate]
				WHERE lecturerId = u.Id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS certificates,
			(
				SELECT * FROM [dbo].[workExperience]
				WHERE lecturerId = u.Id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS workExperiences
		FROM [dbo].[user] u
		LEFT JOIN [dbo].[bankAccount] b ON u.Id = b.ownerId
		LEFT JOIN [dbo].[lecturer] l ON u.Id = l.Id
		WHERE u.Id = @Id
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

	DECLARE @id INT = (SELECT SCOPE_IDENTITY())

	IF @type = 'LN'
	BEGIN;
		INSERT INTO [dbo].[learner]
		VALUES(@id)
	END

	SELECT *
	FROM [dbo].[user]
	WHERE id = @id
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateUser]
	@id INT,
	@oldPassword VARCHAR(128),
	@password VARCHAR(128),
	@name NVARCHAR(128)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF @oldPassword <> (SELECT password FROM [dbo].[user] WHERE id = @id)
	BEGIN;
		THROW 51000, 'Incorrect password.', 1;
	END

	UPDATE [dbo].[user]
	SET password = @password, name = @name
	WHERE id = @id
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateUserAndBankAccount]
	@id INT,
	@type CHAR(2),
	@accountNumber VARCHAR(16),
	@goodThru DATE,
	@cvc VARCHAR(3),
	@cardholderName VARCHAR(128),
	@zip VARCHAR(16),
	@regionId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF @type = 'AD'
	BEGIN;
		THROW 51000, 'Admin bank accounts cannot be updated.', 1;
	END

	IF NOT EXISTS(SELECT * FROM [dbo].[bankAccount] WHERE ownerId = @id)
	BEGIN;
		INSERT INTO [dbo].[bankAccount](accountNumber, goodThru, cvc, cardholderName, zip, ownerId, regionId)
		VALUES(@accountNumber, @goodThru, @cvc, @cardholderName, @zip, @id, @regionId)
	END
	ELSE
	BEGIN;
		UPDATE [dbo].[bankAccount]
		SET
			accountNumber = @accountNumber,
			goodThru = @goodThru,
			cvc = @cvc,
			cardholderName = @cardholderName,
			zip = @zip,
			regionId = @regionId
		WHERE ownerId = @id
	END
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateLecturer]
	@id INT,
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

	IF NOT EXISTS(SELECT * FROM [dbo].[lecturer] WHERE id = @id)
	BEGIN;
		INSERT INTO [dbo].[lecturer]
		VALUES(
			@id, @dob, @gender, @homeAddress, @workAddress, @nationality, @phone, @introduction,
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
		WHERE id = @id
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
	WHERE lecturerId = @id

	INSERT INTO [dbo].[certificate]
	SELECT @id, title, image
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
	WHERE lecturerId = @id

	INSERT INTO [dbo].[workExperience]
	SELECT @id, topic, role, organizationName, fromDate, toDate
	FROM #workExperiences

	DROP TABLE #workExperiences
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[demandLecturerVerification]
	@id INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	UPDATE [dbo].[lecturer]
	SET
		status = 'P',
		demandVerificationDate = GETDATE()
	WHERE id = @id

	IF @@ROWCOUNT = 0
	BEGIN;
		THROW 51000, 'Lecturer has not filled out the profile form.', 1;
	END
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertCourse]
	@title NVARCHAR(64),
	@subtitle NVARCHAR(128),
	@ownerId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF @title IS NULL OR @subtitle IS NULL OR @ownerId IS NULL
	BEGIN;
		THROW 51000, 'Title, subtitle, and owner id are required.', 1;
	END

	IF (SELECT status FROM [dbo].[lecturer] WHERE id = @ownerId) <> 'V'
	BEGIN;
		THROW 51000, 'Lecturer is not verified.', 1;
	END

	INSERT INTO [dbo].[course](title, subtitle, status)
	VALUES(@title, @subtitle, 'C')

	DECLARE @courseId INT = SCOPE_IDENTITY()
	INSERT INTO [dbo].[ownedCourse] VALUES (@ownerId, @courseId, 1)

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




CREATE OR ALTER PROCEDURE [dbo].[searchRegions]
	@name VARCHAR(64)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT TOP 20 *
	FROM [dbo].[region]
	WHERE name LIKE @name + '%'
	ORDER BY name
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[searchLecturer]
	@name NVARCHAR(128),
	@status CHAR(1),
	@offset INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[lecturer] l
	JOIN [dbo].[user] u ON l.id = u.id
	WHERE name LIKE @name + '%' AND (@status IS NULL OR status = @status)
	ORDER BY l.demandVerificationDate
	OFFSET @offset ROWS
	FETCH NEXT 40 ROWS ONLY
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[verifyLecturer]
	@id INT,
	@status CHAR(1),
	@verifierId INT,
	@notificationTitle NVARCHAR(64),
	@notificationContent NVARCHAR(512)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF (NOT EXISTS (SELECT * FROM [dbo].[bankAccount] WHERE ownerId = @id))
	BEGIN;
		THROW 51000, 'Please fill in your bank account information.', 1;
	END

	UPDATE [dbo].[lecturer]
	SET status = @status
	WHERE id = @id

	IF @@ROWCOUNT = 0
	BEGIN;
		THROW 51000, 'Please fill in your lecturer information.', 1;
	END

	INSERT INTO [dbo].[notification](senderId, receiverId, title, content)
	VALUES(@verifierId, @id, @notificationTitle, @notificationContent)
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[enrollInCourse]
	@learnerId INT,
	@courseId INT,
	@couponId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF (NOT EXISTS (SELECT * FROM [dbo].[bankAccount] WHERE ownerId = @learnerId))
	BEGIN;
		THROW 51000, 'Please fill in your bank account information.', 1;
	END

	INSERT INTO [dbo].[enrolledCourse](learnerId, courseId)
	VALUES(@learnerId, @courseId)

	DECLARE @paidAmount MONEY = (SELECT price FROM [dbo].[course] WHERE id = @courseId)

	DECLARE @discountPercentage FLOAT = COALESCE(
		(SELECT discountPercentage
		FROM [dbo].[ownedCoupon] oc
		JOIN [dbo].[coupon] c ON oc.couponId = c.id
		WHERE oc.couponId = @couponId AND oc.ownerId = @learnerId AND oc.expirationDate >= GETDATE()),
		0
	)
	DELETE FROM [dbo].[ownedCoupon] WHERE couponId = @couponId AND ownerId = @learnerId

	INSERT INTO [dbo].[transaction]
	(initiatorId, receiverId, courseId, paidAmount, taxPercentage, transactionFee, sharePercentage, discountPercentage)
	SELECT @learnerId, ownerId, @courseId, @paidAmount, 0.1, 10, sharePercentage, @discountPercentage
	FROM [dbo].[ownedCourse]
	WHERE courseId = @courseId

	-- HERE
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[reviewCourse]
	@learnerId INT,
	@courseId INT,
	@rating TINYINT,
	@content NVARCHAR(512)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT * FROM [dbo].[enrolledCourse] WHERE learnerId = @learnerId AND courseId = @courseId)
	BEGIN;
		THROW 51000, 'Learner is not enrolled in the course.', 1;
	END

	INSERT INTO [dbo].[courseReview](learnerId, courseId, rating, content)
	VALUES(@learnerId, @courseId, @rating, @content)
COMMIT TRANSACTION
GO