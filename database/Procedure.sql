-- IF OBJECT_ID('[dbo].[RandomizeCourseDescriptionDetail]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseDescriptionDetail];
-- GO
-- CREATE PROCEDURE RandomizeCourseDescriptionDetail
-- AS
-- BEGIN
--     DECLARE @courseId INT;
--     DECLARE @content NVARCHAR(128);
--     DECLARE @type VARCHAR(16);

--     DECLARE course_cursor CURSOR FOR
--     SELECT id, subtitle
--     FROM dbo.course;

--     OPEN course_cursor;

--     FETCH NEXT FROM course_cursor INTO @courseId, @content;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SET @type = (SELECT TOP 1
--             type
--         FROM (VALUES
--                 ('PREREQUISITE'),
--                 ('OBJECTIVE'),
--                 ('SKILL'),
--                 ('TARGET_USER'),
--                 ('LANGUAGE')) AS T(type)
--         ORDER BY NEWID());
--         INSERT INTO dbo.courseDescriptionDetail
--             (courseId, content, type)
--         VALUES
--             (@courseId, @content, @type);
--         FETCH NEXT FROM course_cursor INTO @courseId, @content;
--     END

--     CLOSE course_cursor;
--     DEALLOCATE course_cursor;
-- END;
GO

-- ham nay random bang cach duyet qua tung ban ghi trong bang learner, sau do random 1 ban ghi trong bang course
IF OBJECT_ID('[dbo].[RandomizeEnrolledCourseByLearner]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeEnrolledCourseByLearner];
GO
CREATE PROCEDURE RandomizeEnrolledCourseByLearner
AS
BEGIN
    DECLARE @learnerEmail VARCHAR(256);
    DECLARE @courseId INT;
    DECLARE @status CHAR(1);
    DECLARE learner_cursor CURSOR FOR
    SELECT email
    FROM dbo.learner;

    OPEN learner_cursor;
    FETCH NEXT FROM learner_cursor INTO @learnerEmail;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @courseId = (SELECT TOP 1
            id
        FROM dbo.course
        ORDER BY NEWID());
        SET @status = (SELECT TOP 1
            status
        FROM (VALUES
                ('B'),
                ('L'),
                ('F')) AS T(status)
        ORDER BY NEWID());
        INSERT INTO dbo.enrolledCourse
            (learnerEmail, courseId, status)
        VALUES
            (@learnerEmail, @courseId, @status);

        FETCH NEXT FROM learner_cursor INTO @learnerEmail;
    END

    CLOSE learner_cursor;
    DEALLOCATE learner_cursor;
END;
GO




-- IF OBJECT_ID('[dbo].[RandomizeCourseLesson]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseLesson];
-- GO

-- CREATE PROCEDURE RandomizeCourseLesson
-- AS
-- BEGIN
--     DECLARE @id INT;
--     DECLARE @courseId INT;
--     DECLARE @isFree BIT;
--     DECLARE @durationInMinutes TINYINT;

--     DECLARE course_cursor CURSOR FOR
--     SELECT cs.id, cs.courseId
--     FROM dbo.courseSection cs
--         JOIN dbo.course c ON cs.courseId = c.id;

--     OPEN course_cursor;
--     FETCH NEXT FROM course_cursor INTO @id, @courseId;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SET @isFree = CASE WHEN RAND() > 0.5 THEN 1 ELSE 0 END;
--         SET @durationInMinutes = CAST(RAND() * 60 + 1 AS TINYINT);

--         INSERT INTO dbo.courseLesson
--             (id, courseId, isFree, durationInMinutes)
--         VALUES
--             (@id, @courseId, @isFree, @durationInMinutes);

--         FETCH NEXT FROM course_cursor INTO @id, @courseId;
--     END;

--     CLOSE course_cursor;
--     DEALLOCATE course_cursor;
-- END;
-- GO

-- IF OBJECT_ID('[dbo].[RandomizeCourseExercise]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseExercise];
-- GO

-- CREATE PROCEDURE RandomizeCourseExercise
-- AS
-- BEGIN
--     DECLARE @id INT;
--     DECLARE @courseId INT;
--     DECLARE course_section_cursor CURSOR FOR
--     SELECT id, courseId
--     FROM dbo.courseSection;

--     OPEN course_section_cursor;
--     FETCH NEXT FROM course_section_cursor INTO @id, @courseId;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         INSERT INTO dbo.courseExercise
--             (id, courseId)
--         VALUES
--             (@id, @courseId);

--         FETCH NEXT FROM course_section_cursor INTO @id, @courseId;
--     END;

--     CLOSE course_section_cursor;
--     DEALLOCATE course_section_cursor;
-- END;
-- GO

-- IF OBJECT_ID('[dbo].[RandomizeCourseQuiz]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseQuiz];
-- GO

-- CREATE PROCEDURE RandomizeCourseQuiz
-- AS
-- BEGIN
--     DECLARE @id INT;
--     DECLARE @courseId INT;
--     DECLARE @durationInMinutes TINYINT;
--     DECLARE exercise_cursor CURSOR FOR
--     SELECT id, courseId
--     FROM dbo.courseExercise;

--     OPEN exercise_cursor;
--     FETCH NEXT FROM exercise_cursor INTO @id, @courseId;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SET @durationInMinutes = ABS(CHECKSUM(NEWID())) % 60 + 1;
--         INSERT INTO dbo.courseQuiz
--             (id, courseId, durationInMinutes)
--         VALUES
--             (@id, @courseId, @durationInMinutes);

--         FETCH NEXT FROM exercise_cursor INTO @id, @courseId;
--     END;

--     CLOSE exercise_cursor;
--     DEALLOCATE exercise_cursor;
-- END;
-- GO

-- IF OBJECT_ID('[dbo].[RandomizeCourseQuizQuestion]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseQuizQuestion];
-- GO

-- CREATE PROCEDURE RandomizeCourseQuizQuestion
-- AS
-- BEGIN
--     DECLARE @id INT;
--     DECLARE @courseQuizId INT;
--     DECLARE @courseId INT;
--     DECLARE @question NVARCHAR(512);
--     DECLARE @correctAnswerIndex TINYINT;

--     DECLARE @questionPool TABLE (question NVARCHAR(512));
--     INSERT INTO @questionPool
--         (question)
--     VALUES
--         ('What is the capital of France?'),
--         ('Who wrote "To Kill a Mockingbird"?'),
--         ('What is the powerhouse of the cell?'),
--         ('What year did the Titanic sink?'),
--         ('Who painted the Mona Lisa?');
--     DECLARE quiz_cursor CURSOR FOR
--     SELECT id, courseId
--     FROM dbo.courseQuiz;

--     OPEN quiz_cursor;
--     FETCH NEXT FROM quiz_cursor INTO @courseQuizId, @courseId;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SET @id = (SELECT COALESCE(MAX(id), 0) + 1
--         FROM dbo.courseQuizQuestion);
--         SET @correctAnswerIndex = ABS(CHECKSUM(NEWID())) % 4;
--         SELECT TOP 1
--             @question = question
--         FROM @questionPool
--         ORDER BY NEWID();
--         INSERT INTO dbo.courseQuizQuestion
--             (id, courseQuizId, courseId, question, correctAnswerIndex)
--         VALUES
--             (@id, @courseQuizId, @courseId, @question, @correctAnswerIndex);

--         FETCH NEXT FROM quiz_cursor INTO @courseQuizId, @courseId;
--     END;

--     CLOSE quiz_cursor;
--     DEALLOCATE quiz_cursor;
-- END;
-- GO

-- IF OBJECT_ID('[dbo].[RandomizeCourseQuizQuestionAnswer]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseQuizQuestionAnswer];
-- GO

-- CREATE PROCEDURE RandomizeCourseQuizQuestionAnswer
-- AS
-- BEGIN
--     DECLARE @courseQuizQuestionId INT;
--     DECLARE @courseQuizId INT;
--     DECLARE @courseId INT;
--     DECLARE @symbol CHAR(1);
--     DECLARE @answer NVARCHAR(256);

--     DECLARE question_cursor CURSOR FOR
--     SELECT id, courseQuizId, courseId
--     FROM dbo.courseQuizQuestion;

--     OPEN question_cursor;
--     FETCH NEXT FROM question_cursor INTO @courseQuizQuestionId, @courseQuizId, @courseId;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SET @symbol = 'A';
--         WHILE @symbol <= 'D'
--         BEGIN
--             SET @answer = CASE @symbol
--                               WHEN 'A' THEN 'Option A answer'
--                               WHEN 'B' THEN 'Option B answer'
--                               WHEN 'C' THEN 'Option C answer'
--                               WHEN 'D' THEN 'Option D answer'
--                           END;

--             INSERT INTO dbo.courseQuizQuestionAnswer
--                 (courseQuizQuestionId, courseQuizId, courseId, symbol, answer)
--             VALUES
--                 (@courseQuizQuestionId, @courseQuizId, @courseId, @symbol, @answer);

--             SET @symbol = CHAR(ASCII(@symbol) + 1);
--         END;

--         FETCH NEXT FROM question_cursor INTO @courseQuizQuestionId, @courseQuizId, @courseId;
--     END;

--     CLOSE question_cursor;
--     DEALLOCATE question_cursor;
-- END;
-- GO


-- IF OBJECT_ID('[dbo].[RandomizeFileData]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeFileData];
-- GO

-- CREATE PROCEDURE RandomizeFileData @max_records INT
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @id INT;
--     DECLARE @path NVARCHAR(256);
--     DECLARE @name NVARCHAR(128);
--     DECLARE @counter INT = 1;

--     WHILE @counter <= @max_records
--     BEGIN
--         SET @path = '/path/to/file' + CAST(@counter AS NVARCHAR(10)) + '.txt';
--         SET @name = 'File ' + CAST(@counter AS NVARCHAR(10));

--         BEGIN TRY
--             INSERT INTO dbo.[file]
--                 (path, name)
--             VALUES
--                 (@path, @name);
--         END TRY
--         BEGIN CATCH
--             PRINT 'Error inserting record for file ' + CAST(@counter AS NVARCHAR(10));
--         END CATCH;

--         SET @counter = @counter + 1;
--     END;
-- END;
-- GO


-- IF OBJECT_ID('[dbo].[RandomizeCourseSectionFile]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseSectionFile];
-- GO

-- CREATE PROCEDURE RandomizeCourseSectionFile
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @fileId INT;
--     DECLARE @courseSectionId INT;
--     DECLARE @courseId INT;

--     -- Check if [file] table is empty
--     IF NOT EXISTS (SELECT 1 FROM dbo.[file])
--     BEGIN
--         DECLARE @counter INT = 1;
--         WHILE @counter <= 100000
--         BEGIN
--             INSERT INTO dbo.[file] (name, path)
--             VALUES ('File ' + CAST(@counter AS NVARCHAR(10)), '/path/to/file' + CAST(@counter AS NVARCHAR(10)) + '.txt');
--             SET @counter = @counter + 1;
--         END
--     END

--     -- Proceed with randomizing course section files
--     DECLARE file_cursor CURSOR FOR
--     SELECT id
--     FROM dbo.[file];

--     OPEN file_cursor;

--     FETCH NEXT FROM file_cursor INTO @fileId;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SELECT TOP 1
--             @courseSectionId = id, @courseId = courseId
--         FROM dbo.courseSection
--         ORDER BY NEWID();

--         BEGIN TRY
--             INSERT INTO dbo.courseSectionFile
--             (id, courseSectionId, courseId)
--             VALUES
--             (@fileId, @courseSectionId, @courseId);
--         END TRY
--         BEGIN CATCH
--             PRINT 'Skipping duplicate file ID ' + CAST(@fileId AS NVARCHAR(10));
--         END CATCH;

--         FETCH NEXT FROM file_cursor INTO @fileId;
--     END;

--     CLOSE file_cursor;
--     DEALLOCATE file_cursor;
-- END;
-- GO


-- IF OBJECT_ID('[dbo].[RandomizeCourseExerciseSolutionFile]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseExerciseSolutionFile];
-- GO

-- CREATE PROCEDURE RandomizeCourseExerciseSolutionFile
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @fileId INT;
--     DECLARE @courseExerciseId INT;
--     DECLARE @courseId INT;

--     IF NOT EXISTS (SELECT 1 FROM dbo.[file])
--     BEGIN
--         DECLARE @counter INT = 1;
--         WHILE @counter <= 100000
--         BEGIN
--             INSERT INTO dbo.[file] (name, path)
--             VALUES ('File ' + CAST(@counter AS NVARCHAR(10)), '/path/to/file' + CAST(@counter AS NVARCHAR(10)) + '.txt');
--             SET @counter = @counter + 1;
--         END
--     END

--     DECLARE file_cursor CURSOR FOR
--     SELECT id
--     FROM dbo.[file];

--     OPEN file_cursor;

--     FETCH NEXT FROM file_cursor INTO @fileId;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SELECT TOP 1
--             @courseExerciseId = id, @courseId = courseId
--         FROM dbo.courseExercise
--         ORDER BY NEWID();

--         BEGIN TRY
--             INSERT INTO dbo.courseExerciseSolutionFile
--             (id, courseExerciseId, courseId)
--         VALUES
--             (@fileId, @courseExerciseId, @courseId);
--         END TRY
--         BEGIN CATCH
--             PRINT 'Skipping duplicate file ID ' + CAST(@fileId AS NVARCHAR(10));
--         END CATCH;

--         FETCH NEXT FROM file_cursor INTO @fileId;
--     END;

--     CLOSE file_cursor;
--     DEALLOCATE file_cursor;
-- END;
-- GO

-- IF OBJECT_ID('[dbo].[RandomizeCourseSectionProgress]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseSectionProgress];
-- GO

-- CREATE PROCEDURE RandomizeCourseSectionProgress
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @learnerEmail VARCHAR(256);
--     DECLARE @courseId INT;
--     DECLARE @courseSectionId INT;
--     DECLARE @completionPercentage FLOAT;

--     DECLARE enrolled_cursor CURSOR FOR
--     SELECT learnerEmail, courseId
--     FROM dbo.enrolledCourse;

--     OPEN enrolled_cursor;

--     FETCH NEXT FROM enrolled_cursor INTO @learnerEmail, @courseId;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         DECLARE courseSection_cursor CURSOR FOR
--         SELECT id
--         FROM dbo.courseSection
--         WHERE courseId = @courseId;

--         OPEN courseSection_cursor;

--         FETCH NEXT FROM courseSection_cursor INTO @courseSectionId;

--         WHILE @@FETCH_STATUS = 0
--         BEGIN
--             SET @completionPercentage = CAST(RAND(CHECKSUM(NEWID())) AS FLOAT);

--             BEGIN TRY
--                 INSERT INTO dbo.courseSectionProgress
--                 (learnerEmail, courseId, courseSectionId, completionPercentage)
--             VALUES
--                 (@learnerEmail, @courseId, @courseSectionId, @completionPercentage);
--             END TRY
--             BEGIN CATCH
--                 PRINT 'Skipping duplicate entry for learnerEmail ' + @learnerEmail + ', courseId ' + CAST(@courseId AS NVARCHAR(10)) + ', courseSectionId ' + CAST(@courseSectionId AS NVARCHAR(10));
--             END CATCH;

--             FETCH NEXT FROM courseSection_cursor INTO @courseSectionId;
--         END;

--         CLOSE courseSection_cursor;
--         DEALLOCATE courseSection_cursor;

--         FETCH NEXT FROM enrolled_cursor INTO @learnerEmail, @courseId;
--     END;

--     CLOSE enrolled_cursor;
--     DEALLOCATE enrolled_cursor;
-- END;
-- GO

-- IF OBJECT_ID('[dbo].[RandomizeCourseExerciseProgress]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCourseExerciseProgress];
-- GO

-- CREATE PROCEDURE RandomizeCourseExerciseProgress
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @learnerEmail VARCHAR(256);
--     DECLARE @courseId INT;
--     DECLARE @courseSectionId INT;
--     DECLARE @savedTextSolution NVARCHAR(MAX);
--     DECLARE @grade FLOAT;

--     DECLARE progress_cursor CURSOR FOR
--     SELECT learnerEmail, courseId, courseSectionId
--     FROM dbo.courseSectionProgress;

--     OPEN progress_cursor;

--     FETCH NEXT FROM progress_cursor INTO @learnerEmail, @courseId, @courseSectionId;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SET @savedTextSolution = 'Random solution text ' + CAST(NEWID() AS NVARCHAR(36));

--         SET @grade = ROUND(RAND(CHECKSUM(NEWID())) * 10, 2);

--         BEGIN TRY
--             INSERT INTO dbo.courseExerciseProgress
--             (learnerEmail, courseId, courseSectionId, savedTextSolution, grade)
--         VALUES
--             (@learnerEmail, @courseId, @courseSectionId, @savedTextSolution, @grade);
--         END TRY
--         BEGIN CATCH
--             PRINT 'Skipping duplicate entry for learnerEmail ' + @learnerEmail + ', courseId ' + CAST(@courseId AS NVARCHAR(10)) + ', courseSectionId ' + CAST(@courseSectionId AS NVARCHAR(10));
--         END CATCH;

--         FETCH NEXT FROM progress_cursor INTO @learnerEmail, @courseId, @courseSectionId;
--     END;

--     CLOSE progress_cursor;
--     DEALLOCATE progress_cursor;
-- END;
-- GO

IF OBJECT_ID('[dbo].[RandomizePrivateChat]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizePrivateChat];
GO

CREATE PROCEDURE RandomizePrivateChat
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @counter INT = 0;
    DECLARE @max_records INT = 100000;
    DECLARE @chatId INT;

    DECLARE @email1 VARCHAR(256);
    DECLARE @email2 VARCHAR(256);

    CREATE TABLE #users
    (
        email VARCHAR(256)
    );
    INSERT INTO #users
        (email)
    SELECT email
    FROM dbo.[user];

    DECLARE user_cursor CURSOR FOR
    SELECT email
    FROM #users;

    OPEN user_cursor;
    FETCH NEXT FROM user_cursor INTO @email1;

    WHILE @counter < @max_records
    BEGIN
        SELECT TOP 1
            @email2 = email
        FROM #users
        WHERE email <> @email1
        ORDER BY NEWID();

        IF @email1 > @email2
        BEGIN
            DECLARE @tempEmail VARCHAR(256);
            SET @tempEmail = @email1;
            SET @email1 = @email2;
            SET @email2 = @tempEmail;
        END

        BEGIN TRY
            INSERT INTO dbo.chat
        DEFAULT VALUES;
            SET @chatId = SCOPE_IDENTITY();

            INSERT INTO dbo.privateChat
            (id, email1, email2)
        VALUES
            ( @chatId, @email1, @email2);
            SET @counter = @counter + 1;
        END TRY
        BEGIN CATCH
            print('error')
        END CATCH

        FETCH NEXT FROM user_cursor INTO @email1;
    END;

    CLOSE user_cursor;
    DEALLOCATE user_cursor;

    DROP TABLE #users;
END;
GO


-- IF OBJECT_ID('[dbo].[RandomizeCoupon]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeCoupon];
-- GO

-- CREATE PROCEDURE RandomizeCoupon
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @counter INT = 0;
--     DECLARE @max_records INT = 10;
--     DECLARE @code VARCHAR(16);
--     DECLARE @spawnPercentage FLOAT;
--     DECLARE @discountPercentage FLOAT;

--     WHILE @counter < @max_records
--     BEGIN
--         SET @code = LEFT(CONVERT(VARCHAR(40), NEWID()), 16);

--         SET @spawnPercentage = CAST(RAND() AS FLOAT);

--         SET @discountPercentage = CAST(RAND() AS FLOAT);

--         INSERT INTO dbo.coupon
--             (code, spawnPercentage, discountPercentage)
--         VALUES
--             (@code, @spawnPercentage, @discountPercentage);

--         SET @counter = @counter + 1;
--     END;
-- END;
-- GO

-- IF OBJECT_ID('[dbo].[RandomizeOwnedCoupon]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeOwnedCoupon];
-- GO

-- CREATE PROCEDURE RandomizeOwnedCoupon
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @couponId INT;
--     DECLARE @ownerEmail VARCHAR(256);
--     DECLARE @expirationDate DATE;

--     DECLARE @max_records INT = 100000;
--     DECLARE @counter INT = 0;

--     DECLARE coupon_cursor CURSOR LOCAL FAST_FORWARD FOR
--         SELECT id
--     FROM dbo.coupon;

--     CREATE TABLE #RandomLearners
--     (
--         email VARCHAR(256) NOT NULL,
--         CONSTRAINT PK_RandomLearners PRIMARY KEY (email)
--     );

--     INSERT INTO #RandomLearners
--         (email)
--     SELECT DISTINCT email
--     FROM dbo.learner;

--     OPEN coupon_cursor;

--     FETCH NEXT FROM coupon_cursor INTO @couponId;

--     WHILE @@FETCH_STATUS = 0 AND @counter < @max_records
--     BEGIN
--         SELECT TOP 1
--             @ownerEmail = email
--         FROM #RandomLearners
--         ORDER BY NEWID();

--         SET @expirationDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 365) + 1, GETDATE());

--         print @ownerEmail
--         print @couponId
--         print @expirationDate;

--         IF NOT EXISTS (
--             SELECT 1
--         FROM dbo.ownedCoupon
--         WHERE ownerEmail = @ownerEmail AND couponId = @couponId
--         )
--         BEGIN
--             INSERT INTO dbo.ownedCoupon
--                 (ownerEmail, couponId, expirationDate)
--             VALUES
--                 (@ownerEmail, @couponId, @expirationDate);

--             SET @counter = @counter + 1;
--         END

--         DELETE FROM #RandomLearners WHERE email = @ownerEmail;

--         FETCH NEXT FROM coupon_cursor INTO @couponId;
--     END;

--     CLOSE coupon_cursor;
--     DEALLOCATE coupon_cursor;
--     DROP TABLE #RandomLearners;
-- END;
-- GO


-- IF OBJECT_ID('[dbo].[RandomizeTransactionData]', 'P') IS NOT NULL
--     DROP PROCEDURE [dbo].[RandomizeTransactionData];
-- GO

-- CREATE PROCEDURE RandomizeTransactionData
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @max_records INT = 100000;
--     DECLARE @counter INT = 0;

--     CREATE TABLE #ValidCourseIds
--     (
--         courseId INT PRIMARY KEY
--     );

--     INSERT INTO #ValidCourseIds
--         (courseId)
--     SELECT id
--     FROM dbo.course;

--     WHILE @counter < @max_records
--     BEGIN
--         DECLARE @courseId INT;
--         DECLARE @initiatorEmail VARCHAR(256);
--         DECLARE @receiverEmail VARCHAR(256);
--         DECLARE @paidAmount MONEY;
--         DECLARE @taxPercentage FLOAT;
--         DECLARE @transactionFee MONEY;
--         DECLARE @discountPercentage FLOAT;
--         DECLARE @netAmount MONEY;
--         DECLARE @sharePercentage FLOAT;
--         DECLARE @revenue MONEY;

--         SELECT TOP 1
--             @courseId = courseId
--         FROM #ValidCourseIds
--         ORDER BY NEWID();

--         print @courseId

--         SELECT TOP 1
--             @initiatorEmail = learnerEmail
--         FROM dbo.enrolledCourse
--         WHERE courseId = @courseId
--         ORDER BY NEWID();

--         print @initiatorEmail

--         SELECT TOP 1
--             @receiverEmail = ownerEmail
--         FROM dbo.ownedCourse
--         WHERE courseId = @courseId
--         ORDER BY NEWID();

--         print @receiverEmail

--         IF EXISTS (
--                 SELECT 1
--         FROM dbo.ownedCoupon
--         WHERE ownerEmail = @receiverEmail
--             )
--             BEGIN
--             SELECT @discountPercentage = COALESCE((
--                     SELECT discountPercentage
--                     FROM dbo.coupon
--                     WHERE id IN (
--                         SELECT couponId
--                         FROM dbo.ownedCoupon
--                         WHERE ownerEmail = @receiverEmail
--                     )
--                 ), 0);
--         END
--         ELSE
--             BEGIN
--             SET @discountPercentage = 0;
--         END

--         SET @sharePercentage = 1 - @discountPercentage;

--         SET @paidAmount = CAST(ABS(CHECKSUM(NEWID())) % 100000 + 1000 AS MONEY);
--         SET @taxPercentage = CAST(RAND() AS FLOAT);
--         SET @transactionFee = CAST(ABS(CHECKSUM(NEWID())) % 10 AS MONEY);

--         SET @netAmount = CASE
--                             WHEN @paidAmount - @transactionFee - @taxPercentage * @paidAmount < 0
--                             THEN 0 
--                             ELSE @paidAmount - @transactionFee - @taxPercentage * @paidAmount
--                         END;
--         SET @revenue = @netAmount * @sharePercentage;

--         INSERT INTO dbo.[transaction]
--             (initiatorEmail, receiverEmail, courseId, createdAt, paidAmount, taxPercentage, transactionFee, sharePercentage, discountPercentage, netAmount, revenue)
--         VALUES
--             (@initiatorEmail, @receiverEmail, @courseId, GETDATE(), @paidAmount, @taxPercentage, @transactionFee, @sharePercentage, @discountPercentage, @netAmount, @revenue);

--         SET @counter = @counter + 1;
--     END;

--     DROP TABLE #ValidCourseIds;
-- END;
-- GO


-- EXEC RandomizeCourseDescriptionDetail;
-- EXEC RandomizeCourseAnnouncement;
EXEC RandomizeEnrolledCourseByLearner;
-- EXEC RandomizeCourseReview;
-- EXEC RandomizeCourseSection;
-- EXEC RandomizeCourseLesson;
-- EXEC RandomizeCourseExercise;
-- EXEC RandomizeCourseQuiz;
-- EXEC RandomizeCourseQuizQuestion;
-- EXEC RandomizeCourseQuizQuestionAnswer;
-- EXEC RandomizeFileData;
-- EXEC RandomizeCourseSectionFile;
-- EXEC RandomizeCourseExerciseSolutionFile;
-- EXEC RandomizeCourseExerciseProgress;
-- EXEC RandomizeCourseChat;
-- EXEC RandomizeCourseChatMember;
EXEC RandomizePrivateChat;
-- EXEC RandomizeMessageAndNotification;
-- EXEC RandomizeCoupon;
-- EXEC RandomizeOwnedCoupon;
-- EXEC RandomizeTransactionData;




