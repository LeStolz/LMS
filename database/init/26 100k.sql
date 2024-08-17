IF OBJECT_ID('[dbo].[InsertCourseCategory]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[InsertCourseCategory];
GO

CREATE PROCEDURE InsertCourseCategory
AS
BEGIN
    DECLARE @courseId INT;
    DECLARE @categoryId INT;

    DECLARE course_cursor CURSOR FOR
    SELECT id
    FROM dbo.course;

    OPEN course_cursor;

    FETCH NEXT FROM course_cursor INTO @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @categoryId = (SELECT TOP 1
            id
        FROM dbo.category
        ORDER BY NEWID());

        INSERT INTO dbo.courseCategory
            (courseId, categoryId)
        VALUES
            (@courseId, @categoryId);

        FETCH NEXT FROM course_cursor INTO @courseId;
    END

    CLOSE course_cursor;
    DEALLOCATE course_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeBankAccount]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeBankAccount];
GO

CREATE OR ALTER PROCEDURE RandomizeBankAccount
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ownerId INT;
    DECLARE @accountNumber VARCHAR(16);
    DECLARE @goodThru DATE;
    DECLARE @cvc VARCHAR(3);
    DECLARE @cardholderName VARCHAR(128);
    DECLARE @region VARCHAR(64);
    DECLARE @zip VARCHAR(16);
    DECLARE @inAppBalance MONEY;

    -- Temporary table to hold random user emails excluding admins
    CREATE TABLE #Users
    (
        id INT NOT NULL,
        name NVARCHAR(256) NOT NULL,
        CONSTRAINT PK_UserEmails PRIMARY KEY (id)
    );

    INSERT INTO #Users (id, name)
    SELECT id, name
    FROM [dbo].[user]
    WHERE id NOT IN (SELECT id FROM [dbo].[admin]);

    DECLARE user_cursor CURSOR FOR
    SELECT id, name
    FROM #Users;

    OPEN user_cursor;

    FETCH NEXT FROM user_cursor INTO @ownerId, @cardholderName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @accountNumber = RIGHT('0000000000000000' + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(16)), 16);
        SET @goodThru = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 365) + 1, GETDATE());
        SET @cvc = RIGHT('000' + CAST(ABS(CHECKSUM(NEWID()) % 1000) AS VARCHAR(3)), 3);
        SET @region = ( SELECT TOP 1 id
                        FROM dbo.region
                        ORDER BY NEWID())
        SET @zip = RIGHT('00000' + CAST(ABS(CHECKSUM(NEWID()) % 100000) AS VARCHAR(8)), 8);
        SET @inAppBalance = FLOOR(1000 + (RAND() * (1000000 - 1000 + 1)));

        INSERT INTO dbo.bankAccount
            (ownerId, accountNumber, goodThru, cvc, cardholderName, regionId, zip, inAppBalance)
        VALUES
            (@ownerId, @accountNumber, @goodThru, @cvc, @cardholderName, @region, @zip, @inAppBalance);

        FETCH NEXT FROM user_cursor INTO @ownerId, @cardholderName;
    END;

    CLOSE user_cursor;
    DEALLOCATE user_cursor;

    DROP TABLE #Users;
END;
GO

CREATE OR ALTER PROCEDURE RandomizeRegion
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @randomString CHAR(5);
    DECLARE @max INT = 10000;
    DECLARE @count INT = 0;


    SET @randomString = 
        CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + 
        CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) +  
        CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) +  
        CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) +  
        CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65); 

    WHILE @count < @max
    BEGIN
        INSERT INTO dbo.region
        VALUES
            (@randomString);

        SET @randomString = 
                            CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + 
                            CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) +  
                            CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) +  
                            CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) +  
                            CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65); 
        SET @count = @count + 1;
    END;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseDescriptionDetail]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseDescriptionDetail];
GO
CREATE PROCEDURE RandomizeCourseDescriptionDetail
AS
BEGIN
    DECLARE @courseId INT;
    DECLARE @content NVARCHAR(128);
    DECLARE @type VARCHAR(16);

    DECLARE course_cursor CURSOR FOR
    SELECT id, subtitle
    FROM dbo.course;

    OPEN course_cursor;

    FETCH NEXT FROM course_cursor INTO @courseId, @content;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @type = (SELECT TOP 1
            type
        FROM (VALUES
                ('PREREQUISITE'),
                ('OBJECTIVE'),
                ('SKILL'),
                ('TARGET_USER'),
                ('LANGUAGE')) AS T(type)
        ORDER BY NEWID());
        INSERT INTO dbo.courseDescriptionDetail
            (courseId, content, type)
        VALUES
            (@courseId, @content, @type);
        FETCH NEXT FROM course_cursor INTO @courseId, @content;
    END

    CLOSE course_cursor;
    DEALLOCATE course_cursor;
END;
GO

-- ham nay random bang cach duyet qua tung ban ghi trong bang course, sau do random 1 ban ghi trong bang learner
IF OBJECT_ID('[dbo].[RandomizeEnrolledCourseByCourse]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeEnrolledCourseByCourse];
GO

CREATE PROCEDURE RandomizeEnrolledCourseByCourse
AS
BEGIN
    DECLARE @learnerEmail VARCHAR(256);
    DECLARE @courseId INT;
    DECLARE @status CHAR(1);

    CREATE TABLE #RandomLearnerEmails
    (
        email VARCHAR(256) NOT NULL,
        CONSTRAINT PK_RandomLearnerEmails PRIMARY KEY (email)
    );

    INSERT INTO #RandomLearnerEmails (email)
    SELECT email
    FROM dbo.learner;

    DECLARE course_cursor CURSOR FOR
    SELECT id
    FROM dbo.course;

    OPEN course_cursor;
    FETCH NEXT FROM course_cursor INTO @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT TOP 1 @learnerEmail = email
        FROM #RandomLearnerEmails
        ORDER BY NEWID();

        SET @status = (SELECT TOP 1
            status
        FROM (VALUES
                ('B'),
                ('L'),
                ('F')) AS T(status)
        ORDER BY NEWID());

        -- Insert into enrolledCourse table
        INSERT INTO dbo.enrolledCourse
            (learnerEmail, courseId, status)
        VALUES
            (@learnerEmail, @courseId, @status);

        FETCH NEXT FROM course_cursor INTO @courseId;
    END

    CLOSE course_cursor;
    DEALLOCATE course_cursor;

    DROP TABLE #RandomLearnerEmails;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseReview]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseReview];
GO
CREATE PROCEDURE RandomizeCourseReview
AS
BEGIN
    DECLARE @learnerEmail VARCHAR(256);
    DECLARE @courseId INT;
    DECLARE @courseCreatedAt DATE;
    DECLARE @reviewCreatedAt DATETIME;
    DECLARE @rating TINYINT;
    DECLARE @content NVARCHAR(512);
    DECLARE @subtitle NVARCHAR(128);
    DECLARE @reviewDays INT;
    DECLARE enrolledCourse_cursor CURSOR FOR
    SELECT learnerEmail, courseId
    FROM dbo.enrolledCourse;

    OPEN enrolledCourse_cursor;
    FETCH NEXT FROM enrolledCourse_cursor INTO @learnerEmail, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @subtitle = subtitle
        FROM dbo.course
        WHERE id = @courseId;
        SELECT @courseCreatedAt = createdAt
        FROM dbo.course
        WHERE id = @courseId;
        SET @reviewDays = DATEDIFF(DAY, @courseCreatedAt, GETDATE());
        SET @reviewCreatedAt = DATEADD(DAY, 1 + (RAND() * (@reviewDays - 1)), @courseCreatedAt);
        SET @rating = (SELECT FLOOR(RAND() * 5) + 1);
        SET @content = CASE 
                          WHEN @rating = 5 THEN @subtitle + N' bài học rất hay'
                          WHEN @rating BETWEEN 2 AND 4 THEN @subtitle + N' bài học ổn'
                          WHEN @rating = 1 THEN @subtitle + N' bài học rất tệ'
                       END;
        INSERT INTO dbo.courseReview
            (learnerEmail, courseId, createdAt, rating, content)
        VALUES
            (@learnerEmail, @courseId, @reviewCreatedAt, @rating, @content);

        FETCH NEXT FROM enrolledCourse_cursor INTO @learnerEmail, @courseId;
    END

    CLOSE enrolledCourse_cursor;
    DEALLOCATE enrolledCourse_cursor;
END;
GO
IF OBJECT_ID('[dbo].[RandomizeOwnedCourse]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeOwnedCourse];
GO
CREATE OR ALTER PROCEDURE RandomizeOwnedCourse
AS
BEGIN
    DECLARE @courseId INT;
    DECLARE @ownerId INT;
    DECLARE @numLecturer INT;
    DECLARE @i INT = 0;
    DECLARE @sharePercentage FLOAT;

    DECLARE course_cursor CURSOR FOR
    SELECT id
    FROM dbo.course;

    OPEN course_cursor;

    FETCH NEXT FROM course_cursor INTO @courseId;
    
    SET @numLecturer = FLOOR(RAND() * 3 + 1);

    WHILE @@FETCH_STATUS = 0
    BEGIN
        WHILE @i < @numLecturer
        BEGIN
            SET @ownerId = (SELECT TOP 1 id
            FROM dbo.lecturer
            ORDER BY NEWID());
            SET @sharePercentage = ROUND(RAND(), 2);            
            INSERT INTO dbo.ownedCourse
                (ownerId, courseId, sharePercentage)
            VALUES
                (@ownerId, @courseId, @sharePercentage);
            
            SET @i = @i + 1;
        END
        FETCH NEXT FROM course_cursor INTO @courseId;
        SET @numLecturer = FLOOR(RAND() * 3 + 1);
        SET @i = 0;
    END

    CLOSE course_cursor;
    DEALLOCATE course_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeOwnedCourseTop10Lecturer]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeOwnedCourseTop10Lecturer];
GO

CREATE PROCEDURE RandomizeOwnedCourseTop10Lecturer
AS
BEGIN
    DECLARE @courseId INT;
    DECLARE @ownerEmail VARCHAR(256);
    DECLARE @sharePercentage FLOAT;
    CREATE TABLE #TopLecturers (email VARCHAR(256));
    INSERT INTO #TopLecturers (email)
    SELECT TOP 10 email
    FROM dbo.lecturer
    ORDER BY NEWID();

    DECLARE course_cursor CURSOR FOR
    SELECT id
    FROM dbo.course;

    OPEN course_cursor;

    FETCH NEXT FROM course_cursor INTO @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ownerEmail = (SELECT TOP 1 email FROM #TopLecturers ORDER BY NEWID());
        SET @sharePercentage = ROUND((RAND() * 100), 2);

        INSERT INTO dbo.ownedCourse
            (ownerEmail, courseId, sharePercentage)
        VALUES
            (@ownerEmail, @courseId, @sharePercentage);

        FETCH NEXT FROM course_cursor INTO @courseId;
    END

    CLOSE course_cursor;
    DEALLOCATE course_cursor;
    DROP TABLE #TopLecturers;
END;
GO


IF OBJECT_ID('[dbo].[RandomizeCourseAnnouncement]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseAnnouncement];
GO
CREATE OR ALTER PROCEDURE RandomizeCourseAnnouncement
AS
BEGIN
    DECLARE @senderId INT;
    DECLARE @courseId INT;
    DECLARE @createdAt DATE;
    DECLARE @courseCreatedAt DATE;
    DECLARE @title NVARCHAR(64);
    DECLARE @content NVARCHAR(512);
    DECLARE @subtitle NVARCHAR(128);

    DECLARE ownedCourse_cursor CURSOR FOR
    SELECT ownerId, courseId
    FROM dbo.ownedCourse;

    DECLARE @EndDate DATE = GETDATE();

    OPEN ownedCourse_cursor;
    FETCH NEXT FROM ownedCourse_cursor INTO @senderId, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SELECT @subtitle = subtitle
            FROM dbo.course
            WHERE id = @courseId;

            SELECT @courseCreatedAt = createdAt
            FROM dbo.course
            WHERE id = @courseId;
            

            SET @createdAt = DATEADD(day, ABS(CHECKSUM(NEWID())) % (DATEDIFF(day, @courseCreatedAt, @EndDate) + 1), @courseCreatedAt);

            SET @title = N'Thông báo';
            SET @content = N'Chào mừng đến với lớp ' + @subtitle;
            INSERT INTO dbo.courseAnnouncement
                (senderId, courseId, createdAt, title, content)
            VALUES
                (@senderId, @courseId, @createdAt, @title, @content);
        END TRY

        BEGIN CATCH
            PRINT 'Error inserting record: ' + ERROR_MESSAGE();
        END CATCH;

        FETCH NEXT FROM ownedCourse_cursor INTO @senderId, @courseId;
    END

    CLOSE ownedCourse_cursor;
    DEALLOCATE ownedCourse_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomCourseSections]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomCourseSections];
GO

CREATE OR ALTER PROCEDURE RandomCourseSections
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sectionId SMALLINT = 1;
    DECLARE @courseId INT;
    DECLARE @title NVARCHAR(64);
    DECLARE @description NVARCHAR(512);
    DECLARE @type CHAR(1);
    DECLARE @pos SMALLINT;
    DECLARE @numSection SMALLINT;

    DECLARE course_cursor CURSOR FOR
        SELECT id
        FROM dbo.course;

    OPEN course_cursor;
    FETCH NEXT FROM course_cursor INTO @courseId;

    SET @numSection = FLOOR(RAND() * 4 + 1);
    SET @sectionId = 1;

    WHILE @@FETCH_STATUS = 0 AND @sectionId <= @numSection
    BEGIN
        SET @title = 'Course Section ' + CAST(@sectionId AS NVARCHAR(64));
        SET @description = 'Description for Course Section ' + CAST(@sectionId AS NVARCHAR(512));
        SET @type = (SELECT TOP 1 type FROM (VALUES ('M'), ('L'), ('E')) AS T(type) ORDER BY NEWID());
        SET @pos = FLOOR((RAND() * 1000 + 1));

        INSERT INTO dbo.courseSection
            (id, courseId, pos, title, description, type)
        VALUES
            (@sectionId, @courseId, @sectionId, @title, @description, @type);

        SET @sectionId = @sectionId + 1;
    
        IF @sectionId = @numSection + 1
        BEGIN
            FETCH NEXT FROM course_cursor INTO @courseId;
            SET @numSection = FLOOR(RAND() * 4 + 1);
            SET @sectionId = 1;
        END
    END

    CLOSE course_cursor;
    DEALLOCATE course_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomAndAssignNextCourseSections]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomAndAssignNextCourseSections];
GO

CREATE PROCEDURE RandomAndAssignNextCourseSections
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @courseId INT;
    DECLARE @sectionId INT = 1;
    DECLARE @title NVARCHAR(64);
    DECLARE @description NVARCHAR(512);
    DECLARE @type CHAR(1);
    DECLARE @nextSectionId INT;

    -- Cursor for existing courses
    DECLARE course_cursor CURSOR FOR
    SELECT id
    FROM dbo.course;

    OPEN course_cursor;
    FETCH NEXT FROM course_cursor INTO @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Set the values for the new course section
        SET @title = 'Course Section ' + CAST(@sectionId AS NVARCHAR(64));
        SET @description = 'Description for Course Section ' + CAST(@sectionId AS NVARCHAR(512));
        SET @type = (SELECT TOP 1 type FROM (VALUES ('M'), ('L'), ('E')) AS T(type) ORDER BY NEWID());

        -- Insert the new course section
        INSERT INTO dbo.courseSection
            (id, courseId, nextCourseSectionId, title, description, type)
        VALUES
            (@sectionId, @courseId, NULL, @title, @description, @type);

        -- Increment the section ID for the next insertion
        SET @sectionId = @sectionId + 1;

        FETCH NEXT FROM course_cursor INTO @courseId;
    END

    CLOSE course_cursor;
    DEALLOCATE course_cursor;

    -- Assign random nextCourseSectionId
    DECLARE section_cursor CURSOR FOR
    SELECT id, courseId
    FROM dbo.courseSection;

    OPEN section_cursor;
    FETCH NEXT FROM section_cursor INTO @sectionId, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Select a random next section within the same course
        SELECT TOP 1 @nextSectionId = id
        FROM dbo.courseSection
        WHERE courseId = @courseId AND id <> @sectionId
        ORDER BY NEWID();

        -- Update the course section with the random nextCourseSectionId
        UPDATE dbo.courseSection
        SET nextCourseSectionId = @nextSectionId
        WHERE id = @sectionId AND courseId = @courseId;

        FETCH NEXT FROM section_cursor INTO @sectionId, @courseId;
    END

    CLOSE section_cursor;
    DEALLOCATE section_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseLesson]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseLesson];
GO

CREATE PROCEDURE RandomizeCourseLesson
AS
BEGIN
    DECLARE @id INT;
    DECLARE @courseId INT;
    DECLARE @isFree BIT;
    DECLARE @durationInMinutes TINYINT;

    DECLARE course_cursor CURSOR FOR
    SELECT cs.id, cs.courseId
    FROM dbo.courseSection cs
        JOIN dbo.course c ON cs.courseId = c.id;

    OPEN course_cursor;
    FETCH NEXT FROM course_cursor INTO @id, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @isFree = CASE WHEN RAND() > 0.5 THEN 1 ELSE 0 END;
        SET @durationInMinutes = CAST(RAND() * 60 + 1 AS TINYINT);

        INSERT INTO dbo.courseLesson
            (id, courseId, isFree, durationInMinutes)
        VALUES
            (@id, @courseId, @isFree, @durationInMinutes);

        FETCH NEXT FROM course_cursor INTO @id, @courseId;
    END;

    CLOSE course_cursor;
    DEALLOCATE course_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseExercise]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseExercise];
GO

CREATE OR ALTER PROCEDURE RandomizeCourseExercise
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id INT;
    DECLARE @courseId INT;
    DECLARE @exerciseType CHAR(1);
    DECLARE @numEx INT;
    DECLARE @i INT;

    DECLARE course_section_cursor CURSOR FOR
    SELECT id, courseId
    FROM dbo.courseSection
    WHERE [type] IN ('E');

    OPEN course_section_cursor;
    FETCH NEXT FROM course_section_cursor INTO @id, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @exerciseType = (SELECT TOP 1 type FROM (VALUES ('E'), ('Q')) AS ExerciseTypes(type) ORDER BY NEWID());

        INSERT INTO dbo.courseExercise
            (id, courseId, type)
        VALUES
            (@id, @courseId, @exerciseType);

        FETCH NEXT FROM course_section_cursor INTO @id, @courseId;
    END;

    CLOSE course_section_cursor;
    DEALLOCATE course_section_cursor;
END;
GO


IF OBJECT_ID('[dbo].[RandomizeCourseChat]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseChat];
GO

CREATE PROCEDURE RandomizeCourseChat
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @courseId INT;
    DECLARE @chatId INT;

    DECLARE course_cursor CURSOR FOR
    SELECT id
    FROM dbo.course;

    OPEN course_cursor;

    FETCH NEXT FROM course_cursor INTO @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.chat (type)
        VALUES ('C');

        SET @chatId = SCOPE_IDENTITY();

        BEGIN TRY
            INSERT INTO dbo.courseChat
                (id, courseId)
            VALUES
                (@chatId, @courseId);
        END TRY
        BEGIN CATCH
            PRINT 'Skipping duplicate entry for courseId ' + CAST(@courseId AS NVARCHAR(10));
        END CATCH;

        FETCH NEXT FROM course_cursor INTO @courseId;
    END;

    CLOSE course_cursor;
    DEALLOCATE course_cursor;
END;
GO



IF OBJECT_ID('[dbo].[RandomizeCourseChatMember]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseChatMember];
GO

CREATE OR ALTER PROCEDURE RandomizeCourseChatMember
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @learnerId INT;
    DECLARE @courseId INT;

    DECLARE enrolledCourse_cursor CURSOR FOR
    SELECT learnerId, courseId
    FROM dbo.enrolledCourse;

    OPEN enrolledCourse_cursor;

    FETCH NEXT FROM enrolledCourse_cursor INTO @learnerId, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        INSERT INTO dbo.courseChatMember (userId, chatId)
        SELECT 
            @learnerId, 
            cc.id
        FROM 
            dbo.courseChat cc
        WHERE 
            @courseId = cc.courseId;
        

        FETCH NEXT FROM enrolledCourse_cursor INTO @learnerId, @courseId;
    END;

    CLOSE enrolledCourse_cursor;
    DEALLOCATE enrolledCourse_cursor;
END;
GO



IF OBJECT_ID('[dbo].[RandomizeMessage]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeMessage];
GO

CREATE OR ALTER PROCEDURE RandomizeMessage
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @counter INT = 0;
    DECLARE @num_records INT;
    DECLARE @max_records INT = 100000;
    DECLARE @i INT = 0;
    DECLARE @senderId INT;
    DECLARE @chatId INT;
    DECLARE @createdAt DATETIME;
    DECLARE @messageContent NVARCHAR(512);

    CREATE TABLE #RandomIds
    (
        id INT NOT NULL,
        CONSTRAINT PK_RandomIds PRIMARY KEY (id)
    );

    INSERT INTO #RandomIds
        (id)
    SELECT DISTINCT id
    FROM [dbo].[user]
    WHERE id IN (
                        SELECT id
        FROM [dbo].[lecturer]
    UNION
        SELECT id
        FROM [dbo].[learner]
    );

    DECLARE @StartDate DATE = '2020-01-01';
    DECLARE @EndDate DATE = GETDATE();

    SELECT TOP 1
        @chatId = id
    FROM [dbo].[chat]
    ORDER BY NEWID();
    
    SELECT TOP 1
        @senderId = id          
    FROM #RandomIds
    ORDER BY NEWID();

    SET @num_records = FLOOR(RAND() * 5 + 1);

    WHILE @counter < @max_records OR @i < @num_records
    BEGIN
            IF @i = @num_records
            BEGIN
                SELECT TOP 1
                    @chatId = id
                FROM [dbo].[chat]
                ORDER BY NEWID();
                
                SELECT TOP 1
                    @senderId = id          
                FROM #RandomIds
                ORDER BY NEWID();

                SET @num_records = FLOOR(RAND() * 5 + 1);
                SET @i = 0;
            END


            SET @messageContent = SUBSTRING(CONVERT(VARCHAR(50), NEWID()), 0, 9);
            
            SET @createdAt = DATEADD(day, ABS(CHECKSUM(NEWID())) % (DATEDIFF(day, @StartDate, @EndDate) + 1), @StartDate);

            INSERT INTO [dbo].[message] VALUES ( @senderId, @chatId, @createdAt, @messageContent);
            
            SET @counter = @counter + 1;
            SET @i = @i + 1;
    END;

    DROP TABLE #RandomIds;
END;
GO

CREATE OR ALTER PROCEDURE RandomizeNotification
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @counter INT = 0;
    DECLARE @max_records INT = 100000;
    DECLARE @senderId VARCHAR(256);
    DECLARE @receiverId VARCHAR(256);
    DECLARE @title NVARCHAR(64);
    DECLARE @content NVARCHAR(512);
    DECLARE @createdAt DATETIME = GETDATE();
    DECLARE @expiresAt DATE = DATEADD(DAY, 28, @createdAt);
    DECLARE @i INT = 0;
    DECLARE @num_records INT;

    CREATE TABLE #RandomIds
    (
        id INT NOT NULL,
        CONSTRAINT PK_RandomIds PRIMARY KEY (id)
    );

    INSERT INTO #RandomIds
        (id)
    SELECT DISTINCT id
    FROM [dbo].[user]
    WHERE id IN (
                        SELECT id
        FROM [dbo].[lecturer]
    UNION
        SELECT id
        FROM [dbo].[learner]
    );

    DECLARE @StartDate DATE = '2020-01-01';
    DECLARE @EndDate DATE = GETDATE();

    SELECT TOP 1
        @receiverId = id
    FROM #RandomIds
    ORDER BY NEWID();

    SELECT TOP 1
        @senderId = id
    FROM [dbo].[admin]
    ORDER BY NEWID();

    SET @num_records = FLOOR(RAND() * 5 + 1);

    WHILE @counter < @max_records OR @i < @num_records
    BEGIN 
            IF @i = @num_records
            BEGIN
                SELECT TOP 1
                    @receiverId = id
                FROM #RandomIds
                ORDER BY NEWID();

                SELECT TOP 1
                    @senderId = id
                FROM [dbo].[admin]
                ORDER BY NEWID();

                SET @num_records = FLOOR(RAND() * 5 + 1);
                SET @i = 0;
            END

            SET @content = N'Thông báo tin nhắn được gửi từ ' + @senderId;
            SET @title = N'Tin nhắn mới từ ' + @senderId;
            SET @createdAt = DATEADD(day, ABS(CHECKSUM(NEWID())) % (DATEDIFF(day, @StartDate, @EndDate) + 1), @StartDate);

            INSERT INTO dbo.notification
                (senderId, receiverId, createdAt, title, content)
            VALUES
                (@senderId, @receiverId, @createdAt, @title, @content);

            SET @counter = @counter + 1;
            SET @i = @i + 1;
    END;

    DROP TABLE #RandomIds;
END;
GO


IF OBJECT_ID('[dbo].[RandomizeCourseSectionProgress]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseSectionProgress];
GO

CREATE PROCEDURE RandomizeCourseSectionProgress
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @learnerEmail VARCHAR(256);
    DECLARE @courseId INT;
    DECLARE @courseSectionId INT;
    DECLARE @completionPercentage FLOAT;
    DECLARE @type CHAR(1);

    DECLARE enrolled_cursor CURSOR FOR
    SELECT learnerEmail, courseId
    FROM dbo.enrolledCourse;

    OPEN enrolled_cursor;

    FETCH NEXT FROM enrolled_cursor INTO @learnerEmail, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE courseSection_cursor CURSOR FOR
        SELECT id
        FROM dbo.courseSection
        WHERE courseId = @courseId;

        OPEN courseSection_cursor;

        FETCH NEXT FROM courseSection_cursor INTO @courseSectionId;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @completionPercentage = CAST(RAND(CHECKSUM(NEWID())) AS FLOAT);
            SET @type = CASE WHEN RAND(CHECKSUM(NEWID())) < 0.5 THEN 'S' ELSE 'E' END;

            BEGIN TRY
                INSERT INTO dbo.courseSectionProgress
                (learnerEmail, courseId, courseSectionId, completionPercentage, type)
                VALUES
                (@learnerEmail, @courseId, @courseSectionId, @completionPercentage, @type);
            END TRY
            BEGIN CATCH
                PRINT 'Skipping duplicate entry for learnerEmail ' + ISNULL(@learnerEmail, 'NULL') + ', courseId ' + CAST(@courseId AS NVARCHAR(10)) + ', courseSectionId ' + CAST(@courseSectionId AS NVARCHAR(10));
            END CATCH;

            FETCH NEXT FROM courseSection_cursor INTO @courseSectionId;
        END;

        CLOSE courseSection_cursor;
        DEALLOCATE courseSection_cursor;

        FETCH NEXT FROM enrolled_cursor INTO @learnerEmail, @courseId;
    END;

    CLOSE enrolled_cursor;
    DEALLOCATE enrolled_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseExerciseProgress]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseExerciseProgress];
GO

CREATE PROCEDURE RandomizeCourseExerciseProgress
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @learnerEmail VARCHAR(256);
    DECLARE @courseId INT;
    DECLARE @courseSectionId INT;
    DECLARE @savedTextSolution NVARCHAR(MAX);
    DECLARE @grade FLOAT;

    DECLARE progress_cursor CURSOR FOR
    SELECT learnerEmail, courseId, courseSectionId
    FROM dbo.courseSectionProgress;

    OPEN progress_cursor;

    FETCH NEXT FROM progress_cursor INTO @learnerEmail, @courseId, @courseSectionId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @savedTextSolution = 'Random solution text ' + CAST(NEWID() AS NVARCHAR(36));

        SET @grade = ROUND(RAND(CHECKSUM(NEWID())) * 10, 2);

        BEGIN TRY
            INSERT INTO dbo.courseExerciseProgress
            (learnerEmail, courseId, courseSectionId, savedTextSolution, grade)
        VALUES
            (@learnerEmail, @courseId, @courseSectionId, @savedTextSolution, @grade);
        END TRY
        BEGIN CATCH
            PRINT 'Skipping duplicate entry for learnerEmail ' + @learnerEmail + ', courseId ' + CAST(@courseId AS NVARCHAR(10)) + ', courseSectionId ' + CAST(@courseSectionId AS NVARCHAR(10));
        END CATCH;

        FETCH NEXT FROM progress_cursor INTO @learnerEmail, @courseId, @courseSectionId;
    END;

    CLOSE progress_cursor;
    DEALLOCATE progress_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeFileData]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeFileData];
GO

CREATE PROCEDURE RandomizeFileData @max_records INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id INT;
    DECLARE @path NVARCHAR(256);
    DECLARE @name NVARCHAR(128);
    DECLARE @counter INT = 1;

    WHILE @counter <= @max_records
    BEGIN
        SET @path = '/path/to/file' + CAST(@counter AS NVARCHAR(10)) + '.txt';
        SET @name = 'File ' + CAST(@counter AS NVARCHAR(10));

        BEGIN TRY
            INSERT INTO dbo.[file]
                (path, name)
            VALUES
                (@path, @name);
        END TRY
        BEGIN CATCH
            PRINT 'Error inserting record for file ' + CAST(@counter AS NVARCHAR(10));
        END CATCH;

        SET @counter = @counter + 1;
    END;
END;
GO


IF OBJECT_ID('[dbo].[RandomizeCourseSectionFile]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseSectionFile];
GO

CREATE OR ALTER PROCEDURE RandomizeCourseSectionFile
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fileId INT;
    DECLARE @courseId INT;
    DECLARE @sectionId INT;
    DECLARE @counter INT = 1;

    DECLARE courseSection_cursor CURSOR FOR
    SELECT id, courseId
    FROM dbo.[courseSection];

    OPEN courseSection_cursor;

    FETCH NEXT FROM courseSection_cursor INTO @sectionId, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.[file] (name, path)
            VALUES ('File ' + CAST(@counter AS NVARCHAR(10)), '/path/to/file' + CAST(@counter AS NVARCHAR(10)) + '.txt');
                
            SET @fileId = SCOPE_IDENTITY();
            SET @counter = @counter + 1;
            
            INSERT INTO dbo.courseSectionFile
            (id, courseSectionId, courseId)
            VALUES
            (@fileId, @sectionId, @courseId);
        END TRY
        BEGIN CATCH
            PRINT 'Skipping duplicate file ID ' + CAST(@fileId AS NVARCHAR(10));
        END CATCH;

        FETCH NEXT FROM courseSection_cursor INTO @sectionId, @courseId;
    END;

    CLOSE courseSection_cursor;
    DEALLOCATE courseSection_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseExerciseSolutionFile]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseExerciseSolutionFile];
GO

CREATE OR ALTER PROCEDURE RandomizeCourseExerciseSolutionFile
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fileId INT;
    DECLARE @courseExerciseId INT;
    DECLARE @courseId INT;
    DECLARE @counter INT;

    SELECT @counter = count(*) FROM [dbo].[file];

    DECLARE courseExercise_cursor CURSOR FOR
    SELECT id, courseId
    FROM dbo.[courseExercise];

    OPEN courseExercise_cursor;

    FETCH NEXT FROM courseExercise_cursor INTO @courseExerciseId, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.[file] (name, path)
            VALUES ('File ' + CAST(@counter AS NVARCHAR(10)), '/path/to/file' + CAST(@counter AS NVARCHAR(10)) + '.txt');
                
            SET @fileId = SCOPE_IDENTITY();
            SET @counter = @counter + 1;

            INSERT INTO dbo.courseExerciseSolutionFile
            (id, courseExerciseId, courseId)
        VALUES
            (@fileId, @courseExerciseId, @courseId);
        END TRY
        BEGIN CATCH
            PRINT 'Skipping duplicate file ID ' + CAST(@fileId AS NVARCHAR(10));
        END CATCH;

        FETCH NEXT FROM courseExercise_cursor INTO @courseExerciseId, @courseId;
    END;

    CLOSE courseExercise_cursor;
    DEALLOCATE courseExercise_cursor;
END;
GO


IF OBJECT_ID('[dbo].[RandomizeCourseQuiz]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseQuiz];
GO

CREATE PROCEDURE RandomizeCourseQuiz
AS
BEGIN
    DECLARE @id INT;
    DECLARE @courseId INT;
    DECLARE @durationInMinutes TINYINT;
    DECLARE exercise_cursor CURSOR FOR
    SELECT id, courseId
    FROM dbo.courseExercise;

    OPEN exercise_cursor;
    FETCH NEXT FROM exercise_cursor INTO @id, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @durationInMinutes = ABS(CHECKSUM(NEWID())) % 60 + 1;
        INSERT INTO dbo.courseQuiz
            (id, courseId, durationInMinutes)
        VALUES
            (@id, @courseId, @durationInMinutes);

        FETCH NEXT FROM exercise_cursor INTO @id, @courseId;
    END;

    CLOSE exercise_cursor;
    DEALLOCATE exercise_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseQuizQuestion]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseQuizQuestion];
GO

CREATE PROCEDURE RandomizeCourseQuizQuestion
AS
BEGIN
    DECLARE @id INT;
    DECLARE @courseQuizId INT;
    DECLARE @courseId INT;
    DECLARE @question NVARCHAR(512);
    DECLARE @correctAnswerIndex TINYINT;

    DECLARE @questionPool TABLE (question NVARCHAR(512));
    INSERT INTO @questionPool
        (question)
    VALUES
        ('What is the capital of France?'),
        ('Who wrote "To Kill a Mockingbird"?'),
        ('What is the powerhouse of the cell?'),
        ('What year did the Titanic sink?'),
        ('Who painted the Mona Lisa?');
    DECLARE quiz_cursor CURSOR FOR
    SELECT id, courseId
    FROM dbo.courseQuiz;

    OPEN quiz_cursor;
    FETCH NEXT FROM quiz_cursor INTO @courseQuizId, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @id = (SELECT COALESCE(MAX(id), 0) + 1
        FROM dbo.courseQuizQuestion);
        SET @correctAnswerIndex = ABS(CHECKSUM(NEWID())) % 4;
        SELECT TOP 1
            @question = question
        FROM @questionPool
        ORDER BY NEWID();
        INSERT INTO dbo.courseQuizQuestion
            (id, courseQuizId, courseId, question, correctAnswerIndex)
        VALUES
            (@id, @courseQuizId, @courseId, @question, @correctAnswerIndex);

        FETCH NEXT FROM quiz_cursor INTO @courseQuizId, @courseId;
    END;

    CLOSE quiz_cursor;
    DEALLOCATE quiz_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseQuizQuestionAnswer]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseQuizQuestionAnswer];
GO

CREATE PROCEDURE RandomizeCourseQuizQuestionAnswer
AS
BEGIN
    DECLARE @courseQuizQuestionId INT;
    DECLARE @courseQuizId INT;
    DECLARE @courseId INT;
    DECLARE @symbol CHAR(1);
    DECLARE @answer NVARCHAR(256);

    DECLARE question_cursor CURSOR FOR
    SELECT id, courseQuizId, courseId
    FROM dbo.courseQuizQuestion;

    OPEN question_cursor;
    FETCH NEXT FROM question_cursor INTO @courseQuizQuestionId, @courseQuizId, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @symbol = 'A';
        WHILE @symbol <= 'D'
        BEGIN
            SET @answer = CASE @symbol
                              WHEN 'A' THEN 'Option A answer'
                              WHEN 'B' THEN 'Option B answer'
                              WHEN 'C' THEN 'Option C answer'
                              WHEN 'D' THEN 'Option D answer'
                          END;

            INSERT INTO dbo.courseQuizQuestionAnswer
                (courseQuizQuestionId, courseQuizId, courseId, symbol, answer)
            VALUES
                (@courseQuizQuestionId, @courseQuizId, @courseId, @symbol, @answer);

            SET @symbol = CHAR(ASCII(@symbol) + 1);
        END;

        FETCH NEXT FROM question_cursor INTO @courseQuizQuestionId, @courseQuizId, @courseId;
    END;

    CLOSE question_cursor;
    DEALLOCATE question_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCoupon]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCoupon];
GO

CREATE PROCEDURE RandomizeCoupon
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @counter INT = 0;
    DECLARE @max_records INT = 10;
    DECLARE @code VARCHAR(16);
    DECLARE @spawnPercentage FLOAT;
    DECLARE @discountPercentage FLOAT;

    WHILE @counter < @max_records
    BEGIN
        SET @code = LEFT(CONVERT(VARCHAR(40), NEWID()), 16);

        SET @spawnPercentage = CAST(RAND() AS FLOAT);

        SET @discountPercentage = CAST(RAND() AS FLOAT);

        INSERT INTO dbo.coupon
            (code, spawnPercentage, discountPercentage)
        VALUES
            (@code, @spawnPercentage, @discountPercentage);

        SET @counter = @counter + 1;
    END;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeOwnedCoupon]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeOwnedCoupon];
GO

CREATE PROCEDURE RandomizeOwnedCoupon
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @couponId INT;
    DECLARE @ownerEmail VARCHAR(256);
    DECLARE @expirationDate DATE;

    DECLARE @max_records INT = 100000;
    DECLARE @counter INT = 0;

    DECLARE coupon_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT id
    FROM dbo.coupon;

    CREATE TABLE #RandomLearners
    (
        email VARCHAR(256) NOT NULL,
        CONSTRAINT PK_RandomLearners PRIMARY KEY (email)
    );

    INSERT INTO #RandomLearners
        (email)
    SELECT DISTINCT email
    FROM dbo.learner;

    OPEN coupon_cursor;

    FETCH NEXT FROM coupon_cursor INTO @couponId;

    WHILE @@FETCH_STATUS = 0 AND @counter < @max_records
    BEGIN
        SELECT TOP 1
            @ownerEmail = email
        FROM #RandomLearners
        ORDER BY NEWID();

        SET @expirationDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 365) + 1, GETDATE());

        print @ownerEmail
        print @couponId
        print @expirationDate;

        IF NOT EXISTS (
            SELECT 1
        FROM dbo.ownedCoupon
        WHERE ownerEmail = @ownerEmail AND couponId = @couponId
        )
        BEGIN
            INSERT INTO dbo.ownedCoupon
                (ownerEmail, couponId, expirationDate)
            VALUES
                (@ownerEmail, @couponId, @expirationDate);

            SET @counter = @counter + 1;
        END

        DELETE FROM #RandomLearners WHERE email = @ownerEmail;

        FETCH NEXT FROM coupon_cursor INTO @couponId;
    END;

    CLOSE coupon_cursor;
    DEALLOCATE coupon_cursor;
    DROP TABLE #RandomLearners;
END;
GO




IF OBJECT_ID('[dbo].[RandomizeTransactionData]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeTransactionData];
GO

CREATE PROCEDURE RandomizeTransactionData
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @max_records INT = 100000;
    DECLARE @counter INT = 0;

    CREATE TABLE #ValidCourseIds
    (
        courseId INT PRIMARY KEY
    );

    INSERT INTO #ValidCourseIds
        (courseId)
    SELECT id
    FROM dbo.course;

    WHILE @counter < @max_records
    BEGIN
        DECLARE @courseId INT;
        DECLARE @initiatorId INT;
        DECLARE @receiverId INT;
        DECLARE @paidAmount MONEY;
        DECLARE @taxPercentage FLOAT;
        DECLARE @transactionFee MONEY;
        DECLARE @discountPercentage FLOAT;
        DECLARE @netAmount MONEY;
        DECLARE @sharePercentage FLOAT;
        DECLARE @revenue MONEY;

        SELECT TOP 1
            @courseId = courseId
        FROM #ValidCourseIds
        ORDER BY NEWID();

        print @courseId

        SELECT TOP 1
            @initiatorId = learnerId
        FROM dbo.enrolledCourse
        WHERE courseId = @courseId
        ORDER BY NEWID();

        print @initiatorEmail

        SELECT TOP 1
            @receiverId = ownerId
        FROM dbo.ownedCourse
        WHERE courseId = @courseId
        ORDER BY NEWID();

        IF EXISTS (
                SELECT 1
        FROM dbo.ownedCoupon
        WHERE ownerId = @receiverId
            )
            BEGIN
            SELECT @discountPercentage = COALESCE((
                    SELECT discountPercentage
                    FROM dbo.coupon
                    WHERE id IN (
                        SELECT couponId
                        FROM dbo.ownedCoupon
                        WHERE ownerEmail = @receiverEmail
                    )
                ), 0);
        END
        ELSE
            BEGIN
            SET @discountPercentage = 0;
        END

        SET @sharePercentage = 1 - @discountPercentage;

        SET @paidAmount = CAST(ABS(CHECKSUM(NEWID())) % 100000 + 1000 AS MONEY);
        SET @taxPercentage = CAST(RAND() AS FLOAT);
        SET @transactionFee = CAST(ABS(CHECKSUM(NEWID())) % 10 AS MONEY);

        SET @netAmount = CASE
                            WHEN @paidAmount - @transactionFee - @taxPercentage * @paidAmount < 0
                            THEN 0 
                            ELSE @paidAmount - @transactionFee - @taxPercentage * @paidAmount
                        END;
        SET @revenue = @netAmount * @sharePercentage;

        INSERT INTO dbo.[transaction]
            (initiatorId, receiverId, courseId, createdAt, paidAmount, taxPercentage, transactionFee, sharePercentage, discountPercentage, netAmount, revenue)
        VALUES
            (@initiatorId, @receiverId, @courseId, GETDATE(), @paidAmount, @taxPercentage, @transactionFee, @sharePercentage, @discountPercentage, @netAmount, @revenue);

        SET @counter = @counter + 1;
    END;

    DROP TABLE #ValidCourseIds;
END;
GO

EXEC InsertCourseCategory;
exec RandomizeRegion;
exec RandomizeBankAccount;
-- -- Exec RandomizeCourseDescriptionDetail;
exec RandomizeEnrolledCourseByCourse;
-- -- exec RandomizeCourseReview;
exec RandomizeOwnedCourse;
exec RandomizeCourseAnnouncement;

exec RandomCourseSections;
-- -- exec RandomAndAssignNextCourseSections; -- nay chua fix 
-- -- exec RandomizeCourseLesson;
exec RandomizeCourseExercise;
-- -- exec RandomizeCourseSectionProgress;
-- exec RandomizeFileData 100000;

exec RandomizeCourseSectionFile;

-- -- exec RandomizeCourseExerciseProgress;
exec RandomizeCourseExerciseSolutionFile;

exec RandomizeCourseChat;
exec RandomizeCourseChatMember;
exec RandomizeMessage;
exec RandomizeNotification;
-- -- exec RandomizeCourseQuiz;
-- -- exec RandomizeCourseQuizQuestion;
-- -- exec RandomizeCourseQuizQuestionAnswer;

-- -- exec RandomizeCoupon;
-- -- exec RandomizeOwnedCoupon;

-- -- exec RandomizeTransactionData;
