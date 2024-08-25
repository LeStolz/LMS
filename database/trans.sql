USE lms
GO

SET DATEFIRST 7
GO


Update [dbo].[course] set type = 'P' where id = 1

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

	SELECT id
	FROM [dbo].[user]
	WHERE email = @email AND password = @password
COMMIT TRANSACTION
GO


IF OBJECT_ID('[dbo].[insertUser]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[insertUser];
GO
CREATE OR ALTER PROCEDURE [dbo].[insertUser]
	@email VARCHAR(256),
	@name NVARCHAR(128),
	@password VARCHAR(128),
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




CREATE OR ALTER PROCEDURE [dbo].[demandCourseVerification]
	@id INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF
		(SELECT price FROM [dbo].[course] WHERE id = @id) = 0 AND
		(SELECT minutesToComplete FROM [dbo].[course] WHERE id = @id) > 90
	BEGIN;
		THROW 51000, 'Free course content must be less than 90 minutes.', 1;
	END

	IF COALESCE((
		SELECT SUM(durationInMinutes)
		FROM [dbo].[courseLesson]
		WHERE isFree = 1 AND courseId = @id
	), 0) < 10
	BEGIN;
		THROW 51000, 'Course must have at least 10 minutes of free content.', 1;
	END

	UPDATE [dbo].[course]
	SET status = 'P'
	WHERE id = @id AND status <> 'V'
COMMIT TRANSACTION
GO

---------------------
CREATE OR ALTER PROCEDURE [dbo].[selectAllCourses]
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[course]
COMMIT TRANSACTION
GO

CREATE OR ALTER PROCEDURE [dbo].[getCoursesById]
	@id INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[course]
	WHERE id = @id
COMMIT TRANSACTION
GO

CREATE OR ALTER PROCEDURE [dbo].[selectCourseByOwner]
	@ownerId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[course]
	WHERE id IN (SELECT courseId FROM [dbo].[ownedCourse] WHERE ownerId = @ownerId)
COMMIT TRANSACTION
GO
---------------------


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
	INSERT INTO [dbo].[chat](type) VALUES ('C')
	-- INSERT INTO [dbo].[chat] DEFAULT VALUES

	DECLARE @chatId INT = SCOPE_IDENTITY()

	INSERT INTO [dbo].[courseChat] VALUES (@chatId, @courseId)
	INSERT INTO [dbo].[courseChatMember] VALUES (@ownerId, @chatId)

	SELECT *
	FROM [dbo].[course]
	WHERE id = @courseId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[selectCourse]
	@id INT,
	@withCategories BIT,
	@withOwners BIT,
	@withSections BIT,
	@withDescriptionDetails BIT,
	@withReviews BIT,
	@learnerId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT
		co.*,
		(
			SELECT ca.id, ca.title, ca.parentId
			FROM [dbo].[courseCategory] cc
			LEFT JOIN [dbo].[category] ca ON cc.categoryId = ca.id
			WHERE @withCategories = 1 AND cc.courseId = co.id
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as categories,
		(
			SELECT u.id, u.email, u.name, oc.sharePercentage
			FROM [dbo].[ownedCourse] oc
			JOIN [dbo].[user] u ON oc.ownerId = u.id
			WHERE @withOwners = 1 AND oc.courseId = co.id
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as owners,
		(
			SELECT *, (
				SELECT TOP 1 completionPercentage FROM [dbo].[courseSectionProgress]
				WHERE learnerId = @learnerId AND courseId = co.id AND courseSectionId = cs.id
			) as completionPercentage
			FROM [dbo].[courseSection] cs
			WHERE @withSections = 1 AND cs.courseId = co.id
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as sections,
		(
			SELECT *
			FROM [dbo].[courseDescriptionDetail] cdd
			WHERE @withDescriptionDetails = 1 AND cdd.courseId = co.id
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as descriptionDetails,
		(
			SELECT cr.*, u.email, u.name
			FROM [dbo].[courseReview] cr
			LEFT JOIN [dbo].[user] u ON cr.learnerId = u.id
			WHERE @withReviews = 1 AND cr.courseId = co.id
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as reviews
	FROM [dbo].[course] co
	WHERE co.id = @id
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




CREATE OR ALTER PROCEDURE [dbo].[updateOwnerSharePercentages]
	@id INT,
	@ownerSharePercentages NVARCHAR(MAX)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

  	CREATE TABLE #ownerSharePercentages (ownerId INT, sharePercentage FLOAT)

    INSERT INTO #ownerSharePercentages
    SELECT ownerId, sharePercentage
    FROM OPENJSON(@ownerSharePercentages)
	WITH (
		ownerId INT '$.ownerId',
		sharePercentage FLOAT '$.sharePercentage'
	)

	IF (SELECT SUM(sharePercentage) FROM #ownerSharePercentages) <> 1
	BEGIN;
		THROW 51000, 'Share percentages must add up to 1.', 1;
	END

	IF (EXISTS(
		SELECT * FROM #ownerSharePercentages osp
		JOIN [dbo].lecturer l ON l.id = osp.ownerId
		WHERE l.status <> 'V'
	))
	BEGIN;
		THROW 51000, 'At least one lecturer is not verified.', 1;
	END

	DELETE FROM [dbo].[ownedCourse]
	WHERE courseId = @id

	DELETE ccm
	FROM [dbo].[courseChatMember] ccm
	JOIN [dbo].[courseChat] cc ON ccm.chatId = cc.id AND cc.courseId = @id
	JOIN #ownerSharePercentages osp ON ccm.userId = osp.ownerId

	INSERT INTO [dbo].[ownedCourse]
	SELECT ownerId, @id, sharePercentage
	FROM #ownerSharePercentages

	INSERT INTO [dbo].[courseChatMember]
	SELECT ownerId, id
	FROM #ownerSharePercentages
	JOIN [dbo].[courseChat] cc ON cc.courseId = @id

	DROP TABLE #ownerSharePercentages
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertMessage]
	@senderId INT,
	@chatId INT,
	@content NVARCHAR(512)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	INSERT INTO [dbo].[message] (senderId, chatId, content)
	VALUES (@senderId, @chatId, @content)
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[selectChatMessages]
	@chatId INT,
	@offset INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[message]
	WHERE chatId = @chatId
	ORDER BY createdAt DESC
	OFFSET @offset ROWS
	FETCH NEXT 40 ROWS ONLY
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[selectUserCourseChats]
	@userId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[courseChat] cc
	JOIN [dbo].[courseChatMember] ccm ON cc.id = ccm.chatId
	WHERE ccm.userId = @userId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[selectUserPrivateChats]
	@userId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[privateChat]
	WHERE userId1 = @userId OR userId2 = @userId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertPrivateChat]
	@user1Id INT,
	@user2Id INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	INSERT INTO [dbo].[chat] DEFAULT VALUES

	INSERT INTO [dbo].[privateChat] VALUES (SCOPE_IDENTITY(), @user1Id, @user2Id)
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertCourseSection]
	@courseId INT,
	@pos SMALLINT,
	@title NVARCHAR(64),
	@description NVARCHAR(512)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	INSERT INTO [dbo].[courseSection]
	VALUES((SELECT MAX(id) + 1 FROM [dbo].[courseSection]), @courseId, @pos, @title, @description, 'M')
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertCourseLesson]
    @courseId INT,
    @pos SMALLINT,
    @title NVARCHAR(64),
    @description NVARCHAR(512),
    @isFree BIT,
    @durationInMinutes TINYINT
AS
BEGIN
    SET XACT_ABORT ON
    SET NOCOUNT ON
    BEGIN TRANSACTION

    INSERT INTO [dbo].[courseSection]
	VALUES((SELECT MAX(id) + 1 FROM [dbo].[courseSection]), @courseId, @pos, @title, @description, 'L')

    DECLARE @sectionId SMALLINT
    SELECT @sectionId = id
    FROM [dbo].[courseSection]
    WHERE pos = @pos AND courseId = @courseId AND title = @title AND description = @description

	print @sectionId

    INSERT INTO [dbo].[courseLesson] (id, courseId, isFree, durationInMinutes) VALUES (
        @sectionId,
        @courseId,
        @isFree,
        @durationInMinutes
    )

    COMMIT TRANSACTION
END
GO



CREATE OR ALTER PROCEDURE [dbo].[updateCourseSection]
	@id SMALLINT,
	@courseId INT,
	@pos SMALLINT,
	@title NVARCHAR(64),
	@description NVARCHAR(512)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	DECLARE @temp SMALLINT

	SET @temp = (SELECT pos FROM [dbo].[courseSection] WHERE id = @id AND courseId = @courseId)

	IF (SELECT pos FROM [dbo].[courseSection] WHERE pos = @pos AND courseId = @courseId) > 0
	BEGIN
		UPDATE [dbo].[courseSection]
		SET pos = -ABS(pos)
		WHERE pos = @pos AND courseId = @courseId
	END

	UPDATE [dbo].[courseSection]
	SET
	pos = @pos,
	title = @title,
	description = @description
	WHERE id = @id AND courseId = @courseId

	UPDATE [dbo].[courseSection]
	SET
	pos = @temp
	WHERE pos = -ABS(@pos) AND courseId = @courseId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertCourseQuizQuestionAndAnswer]
	@courseQuizId SMALLINT,
	@courseId INT,
	@question NVARCHAR(512),
	@correctAnswerSymbol CHAR(1),
	@answers NVARCHAR(MAX)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	INSERT INTO [dbo].[courseQuizQuestion]
	VALUES (
		(SELECT MAX(id) + 1 FROM [dbo].[courseQuizQuestion] WHERE courseQuizId = @courseQuizId AND courseId = @courseId),
		@courseQuizId,
		@courseId,
		@question,
		@correctAnswerSymbol
	)

  	CREATE TABLE #answers (symbol CHAR(1), answer NVARCHAR(256))

    INSERT INTO #answers
    SELECT symbol, answer
    FROM OPENJSON(@answers)
	WITH (
		symbol CHAR(1) '$.symbol',
		answer NVARCHAR(256) '$.answer'
	)

	INSERT INTO [dbo].[courseQuizQuestionAnswer]
	SELECT
		(SELECT MAX(id) FROM [dbo].[courseQuizQuestion] WHERE courseQuizId = @courseQuizId AND courseId = @courseId),
		@courseQuizId,
		@courseId,
		symbol,
		answer
	FROM #answers

	DROP TABLE #answers
COMMIT TRANSACTION
GO
-----
CREATE OR ALTER PROCEDURE [dbo].[deleteCourse]
	@id INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	DELETE FROM [dbo].[course]
	WHERE id = @id
COMMIT TRANSACTION
GO
-------




CREATE OR ALTER PROCEDURE [dbo].[deleteCourseQuizQuestionAndAnswer]
	@id TINYINT,
	@courseQuizId SMALLINT,
	@courseId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	DELETE FROM [dbo].[courseQuizQuestion]
	WHERE id = @id AND courseQuizId = @courseQuizId AND courseId = @courseId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertCourseSectionFile]
	@id SMALLINT,
	@courseSectionId INT,
	@courseId INT,
	@path NVARCHAR(256),
	@name NVARCHAR(128)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	INSERT INTO [dbo].[file](name, path) VALUES (@name, @path)

	INSERT INTO [dbo].[courseSectionFile] VALUES (
		SCOPE_IDENTITY(),
		@courseSectionId,
		@courseId
	)
COMMIT TRANSACTION
GO

------
CREATE OR ALTER PROCEDURE [dbo].[selectCourseSectionFile]
	@courseSectionId INT,
	@courseId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT
		*,
		(
			SELECT f.*
			FROM [dbo].[courseSectionFile] csf
			JOIN [dbo].[file] f ON csf.id = f.id
			WHERE csf.courseSectionId = @courseSectionId AND csf.courseId = @courseId
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as files
	FROM [dbo].[courseSectionFile]
	WHERE courseSectionId = @courseSectionId AND courseId = @courseId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[deleteCourseSectionFile]
	@id SMALLINT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	DELETE [dbo].[file] WHERE id = @id
COMMIT TRANSACTION
GO



CREATE OR ALTER PROCEDURE [dbo].[insertCourseExerciseSolutionFile]
	@id SMALLINT,
	@courseSectionId INT,
	@courseId INT,
	@path NVARCHAR(256),
	@name NVARCHAR(128)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	INSERT INTO [dbo].[file](name, path) VALUES (@name, @path)

	INSERT INTO [dbo].[courseExerciseSolutionFile] VALUES (
		SCOPE_IDENTITY(),
		@courseSectionId,
		@courseId
	)
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateCourseLesson]
	@id SMALLINT,
	@courseId INT,
	@pos SMALLINT,
	@title NVARCHAR(64),
	@description NVARCHAR(512),
	@isFree BIT,
	@durationInMinutes TINYINT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	EXEC [dbo].[updateCourseSection] @id, @courseId, @pos, @title, @description

	UPDATE [dbo].[courseLesson]
	SET
	isFree = @isFree,
	durationInMinutes = @durationInMinutes
	WHERE id = @id AND courseId = @courseId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[updateCourseQuiz]
	@id SMALLINT,
	@courseId INT,
	@pos SMALLINT,
	@title NVARCHAR(64),
	@description NVARCHAR(512),
	@durationInMinutes TINYINT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	EXEC [dbo].[updateCourseSection] @id, @courseId, @pos, @title, @description

	UPDATE [dbo].[courseQuiz]
	SET
	durationInMinutes = @durationInMinutes
	WHERE id = @id AND courseId = @courseId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[deleteCourseSection]
	@id SMALLINT,
	@courseId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	DELETE FROM [dbo].[courseSection]
	WHERE id = @id AND courseId = @courseId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertCourseExercise]
	@courseId INT,
	@pos SMALLINT,
	@title NVARCHAR(64),
	@description NVARCHAR(512),
	@type CHAR(1)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	INSERT INTO [dbo].[courseSection]
	VALUES((SELECT MAX(id) + 1 FROM [dbo].[courseSection]), @courseId, @pos, @title, @description, 'E')

    DECLARE @sectionId SMALLINT
    SELECT @sectionId = id
    FROM [dbo].[courseSection]
    WHERE pos = @pos AND courseId = @courseId AND title = @title AND description = @description

	print @sectionId

	INSERT INTO [dbo].[courseExercise] VALUES (
		@sectionId,
		@courseId,
		COALESCE(@type, 'E')
	)
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertCourseQuiz]
	@courseId INT,
	@pos SMALLINT,
	@title NVARCHAR(64),
	@description NVARCHAR(512),
	@durationInMinutes TINYINT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	EXEC [dbo].[insertCourseExercise] @courseId, @pos, @title, @description, 'Q'

	DECLARE @sectionId SMALLINT = SCOPE_IDENTITY()

	INSERT INTO [dbo].[courseQuiz] VALUES (
		@sectionId,
		@courseId,
		@durationInMinutes
	)
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[deleteCourseSection]
	@id SMALLINT,
	@courseId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	DELETE FROM [dbo].[courseSection]
	WHERE id = @id AND courseId = @courseId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[selectCourseSection]
	@id SMALLINT,
	@courseId INT,
	@learnerId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT
		*,
		(
			SELECT f.*
			FROM [dbo].[courseSectionFile] csf
			JOIN [dbo].[file] f ON csf.id = f.id
			WHERE csf.courseSectionId = @id AND csf.courseId = @courseId
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as files,
		(
			SELECT *
			FROM [dbo].[courseLesson] cl
			WHERE cs.[type] = 'L' AND cl.id = @id AND cl.courseId = @courseId
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as lessonInfo,
		(
			SELECT
				ce.*, cq.durationInMinutes,
				(
					SELECT
						*,
						(
							SELECT cqqa.answer, cqqa.symbol FROM [dbo].[courseQuizQuestionAnswer] cqqa
							WHERE courseQuizQuestionId = cqqa.courseQuizQuestionId
							AND courseQuizId = cqqa.courseQuizId
							AND courseId = cqqa.courseId
							FOR JSON PATH, INCLUDE_NULL_VALUES
						) as answers
					FROM [dbo].[courseQuizQuestion]
					WHERE courseQuizId = cq.id AND courseId = cq.courseId
					FOR JSON PATH, INCLUDE_NULL_VALUES
				) as questions,
				(
					SELECT * FROM [dbo].[courseExerciseProgress]
					WHERE learnerId = @learnerId AND courseId = @courseId AND courseSectionId = cs.id
					FOR JSON PATH, INCLUDE_NULL_VALUES
				) as exerciseProgress
			FROM [dbo].[courseExercise] ce
			LEFT JOIN [dbo].courseQuiz cq ON ce.id = cq.id AND ce.courseId = cq.courseId
			WHERE cs.[type] = 'E' AND ce.id = @id AND ce.courseId = @courseId
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as exerciseInfo,
		(
			SELECT *
			FROM [dbo].[courseExerciseSolutionFile] cesf
			WHERE cs.[type] = 'E' AND cesf.courseExerciseId = @id AND cesf.courseId = @courseId
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as courseExerciseSolutionFiles
	FROM [dbo].[courseSection] cs
	WHERE cs.id = @id AND cs.courseId = @courseId
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
	-- @ownerSharePercentages NVARCHAR(MAX)
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

	-- EXEC [dbo].[updateOwnerSharePercentages] @id, @ownerSharePercentages

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


-----
CREATE OR ALTER PROCEDURE [dbo].[selectRegion]
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[region]
COMMIT TRANSACTION
GO

CREATE OR ALTER PROCEDURE [dbo].[searchRegionById]
	@id INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT name FROM [dbo].[region]
	WHERE id = @id
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


CREATE OR ALTER PROCEDURE [dbo].[searchCourses]
	@title NVARCHAR(64),
	@status CHAR(1),
	@offset INT,
	@categoryIds NVARCHAR(MAX),
	@lecturerId INT,
	@learnerId INT,
	@learningStatus CHAR(1),
	@orderBy CHAR(1)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

  	CREATE TABLE #categoryIds (categoryId INT)

    INSERT INTO #categoryIds (categoryId)
    SELECT value
    FROM OPENJSON(@categoryIds)
    WITH (value INT '$')

	SELECT *, (CASE
            WHEN c.visitorCount = 0 THEN 0
            ELSE c.learnerCount / c.visitorCount
        END) AS conversionRate FROM [dbo].[course] c
	WHERE title LIKE @title + '%' AND (@status IS NULL OR status = @status)
	AND (@lecturerId IS NULL OR EXISTS(
		SELECT * FROM [dbo].[ownedCourse] oc
		WHERE oc.courseId = c.id AND oc.ownerId = @lecturerId
	))
	AND (@learnerId IS NULL OR EXISTS(
		SELECT * FROM [dbo].[enrolledCourse] ec
		WHERE ec.courseId = c.id AND ec.learnerId = @learnerId AND status = @learningStatus
	))
	AND NOT EXISTS(
		SELECT * FROM #categoryIds
		EXCEPT
		SELECT categoryId FROM [dbo].[courseCategory] cc
		WHERE cc.courseId = c.id
	)
	ORDER BY
        (CASE WHEN @orderBy = 'L' THEN learnerCount END) DESC,
        (CASE WHEN @orderBy = 'C' THEN createdAt END) DESC,
        (CASE WHEN @orderBy = 'R' THEN rating END) DESC,
        (CASE WHEN @orderBy = 'P' THEN price END) ASC,
        (CASE WHEN @orderBy = 'M' THEN minutesToComplete END) DESC
	OFFSET @offset ROWS
	FETCH NEXT 40 ROWS ONLY

	DROP TABLE #categoryIds
COMMIT TRANSACTION
GO



CREATE OR ALTER PROCEDURE [dbo].[searchCategoriesByStats]
	@title NVARCHAR(64),
	@offset INT,
	@orderBy CHAR(1)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[category] c
	WHERE c.title LIKE @title + '%'
	ORDER BY (
		CASE @orderBy
			WHEN 'C' THEN c.courseCount
			WHEN 'L' THEN c.learnerCount
			WHEN 'R' THEN c.rating
			WHEN 'M' THEN c.monthlyRevenueGenerated
		END
	) DESC
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




CREATE OR ALTER PROCEDURE [dbo].[verifyCourse]
	@id INT,
	@status CHAR(1),
	@verifierId INT,
	@notificationTitle NVARCHAR(64),
	@notificationContent NVARCHAR(512)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	UPDATE [dbo].[course]
	SET status = @status
	WHERE id = @id

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

	INSERT INTO [dbo].[courseChatMember] VALUES (
		@learnerId,
		(SELECT id FROM [dbo].[courseChat] WHERE courseId = @courseId)
	)

	DECLARE @paidAmount MONEY = (SELECT price FROM [dbo].[course] WHERE id = @courseId)
	DECLARE @date DATETIME = GETDATE()

	DECLARE @discountPercentage FLOAT = COALESCE(
		(SELECT discountPercentage
		FROM [dbo].[ownedCoupon] oc
		JOIN [dbo].[coupon] c ON oc.couponId = c.id
		WHERE oc.couponId = @couponId AND oc.ownerId = @learnerId AND oc.expirationDate >= GETDATE()),
		0
	)
	DELETE FROM [dbo].[ownedCoupon] WHERE couponId = @couponId AND ownerId = @learnerId

	INSERT INTO [dbo].[transaction]
	(initiatorId, receiverId, courseId, paidAmount, taxPercentage, transactionFee, sharePercentage, discountPercentage, createdAt)
	SELECT @learnerId, ownerId, @courseId, @paidAmount, 0.1, 10, sharePercentage, @discountPercentage, @date
	FROM [dbo].[ownedCourse]
	WHERE courseId = @courseId

	UPDATE [dbo].[bankAccount]
	SET inAppBalance = inAppBalance - @paidAmount
	WHERE ownerId = @learnerId

	UPDATE [dbo].[bankAccount]
	SET inAppBalance += revenue
	FROM [dbo].[bankAccount] ba
	JOIN [dbo].[transaction] t
	ON t.initiatorId = @learnerId AND ba.ownerId = t.receiverId AND t.courseId = @courseId AND t.createdAt = @date
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




CREATE OR ALTER PROCEDURE [dbo].[selectTransaction]
	@initiatorId INT,
	@receiverId INT,
	@courseId INT,
	@createdAt DATETIME
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT t.*, c.title, u.name FROM [dbo].[transaction] t
	LEFT JOIN [dbo].[course] c ON t.courseId = c.id
	LEFT JOIN [dbo].[user] u ON t.initiatorId = u.id
	WHERE
		initiatorId = @initiatorId AND receiverId = @receiverId AND
		courseId = @courseId AND t.createdAt = @createdAt
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[withdrawBalance]
	@ownerId INT,
	@amount MONEY
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	UPDATE [dbo].[bankAccount]
	SET inAppBalance = inAppBalance - @amount
	WHERE ownerId = @ownerId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[receiveBalance]
	@ownerId INT,
	@amount MONEY
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	UPDATE [dbo].[bankAccount]
	SET inAppBalance = inAppBalance + @amount
	WHERE ownerId = @ownerId
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[searchTransaction]
	@receiverId INT,
	@offset INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[transaction]
	WHERE receiverId = @receiverId
	ORDER BY createdAt DESC
	OFFSET @offset ROWS
	FETCH NEXT 40 ROWS ONLY
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[searchCourseAnnouncement]
	@id INT,
	@offset INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[courseAnnouncement]
	WHERE courseId = @id
	ORDER BY createdAt DESC
	OFFSET @offset ROWS
	FETCH NEXT 40 ROWS ONLY
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[selectLecturerEarningPerMonth]
	@id INT,
	@date DATE,
	@courseId INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT SUM(revenue) FROM [dbo].[transaction]
	WHERE
		receiverId = @id AND (courseId IS NULL OR courseId = @courseId) AND
		DATEFROMPARTS(YEAR(@date), MONTH(@date), 1) = DATEFROMPARTS(YEAR(createdAt), MONTH(createdAt), 1)
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[selectCoupon]
	@id INT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[coupon] WHERE id = @id
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[upsertCourseSectionProgress]
	@learnerId INT,
	@courseId INT,
	@courseSectionId INT,
	@completionPercentage FLOAT,
	@savedTextSolution NVARCHAR(MAX),
	@grade FLOAT
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF (NOT EXISTS(
		SELECT * FROM [dbo].[courseSectionProgress]
		WHERE learnerId = @learnerId AND courseId = @courseId AND courseSectionId = @courseSectionId
	))
	BEGIN;
		INSERT INTO [dbo].[courseSectionProgress](learnerId, courseId, courseSectionId, completionPercentage)
		VALUES(@learnerId, @courseId, @courseSectionId, @completionPercentage)
	END
	ELSE
	BEGIN;
		UPDATE [dbo].[courseSectionProgress]
		SET completionPercentage = @completionPercentage
		WHERE learnerId = @learnerId AND courseId = @courseId AND courseSectionId = @courseSectionId
	END

	IF (SELECT type FROM [dbo].[courseSection] WHERE id = @courseSectionId AND courseId = @courseId) = 'E'
	BEGIN;
	IF (NOT EXISTS(
		SELECT * FROM [dbo].[courseExerciseProgress]
		WHERE learnerId = @learnerId AND courseId = @courseId AND courseSectionId = @courseSectionId
	))
		BEGIN;
			INSERT INTO [dbo].[courseExerciseProgress]
			(learnerId, courseId, courseSectionId, savedTextSolution, grade)
			VALUES(@learnerId, @courseId, @courseSectionId, @savedTextSolution, @grade)
		END
		ELSE
		BEGIN;
			UPDATE [dbo].[courseExerciseProgress]
			SET savedTextSolution = @savedTextSolution, grade = @grade
			WHERE learnerId = @learnerId AND courseId = @courseId AND courseSectionId = @courseSectionId
		END
	END
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertOwnedCoupon]
	@couponId INT,
	@ownerId INT,
	@expirationDate DATE
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	INSERT INTO [dbo].[ownedCoupon](couponId, ownerId, expirationDate)
	VALUES(@couponId, @ownerId, @expirationDate)
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[createCourseAnnouncement]
	@senderId INT,
	@courseId INT,
	@title NVARCHAR(64),
	@content NVARCHAR(512)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	INSERT INTO [dbo].[courseAnnouncement](senderId, courseId, title, content)
	VALUES(@senderId, @courseId, @title, @content)
COMMIT TRANSACTION
GO


create or alter PROCEDURE [dbo].[selectLecturer]
	@status CHAR(1)
AS	
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT * FROM [dbo].[lecturer] l
	JOIN [dbo].[user] u ON l.id = u.id
	WHERE status = @status
COMMIT TRANSACTION
GO
