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
        SET @accountNumber = CONVERT(VARCHAR(16), CONVERT(NUMERIC(16, 0), RAND() * 8999999999999999) + 1000000000000000);
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
CREATE OR ALTER PROCEDURE RandomizeCourseDescriptionDetail
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
                ('P'),
                ('O'),
                ('S'),
                ('T'),
                ('L')) AS T(type)
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
IF OBJECT_ID('[dbo].[RandomizeEnrolledCourse]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeEnrolledCourse];
GO

CREATE OR ALTER PROCEDURE RandomizeEnrolledCourse
AS
BEGIN
    DECLARE @learnerId VARCHAR(256);
    DECLARE @courseId INT;
    DECLARE @i INT = 0;
    DECLARE @numCourse INT;

    CREATE TABLE #CourseIds
    (
        id VARCHAR(256) NOT NULL,
        CONSTRAINT PK_CourseIds PRIMARY KEY (id)
    );

    INSERT INTO #CourseIds (id)
    SELECT id
    FROM dbo.course;
    
    SET @numCourse = FLOOR(RAND() * 3 + 2);

    DECLARE learner_cursor CURSOR FOR
    SELECT id
    FROM dbo.learner;

    OPEN learner_cursor;
    FETCH NEXT FROM learner_cursor INTO @learnerId;

    WHILE @@FETCH_STATUS = 0 AND @i < @numCourse
    BEGIN
        SELECT TOP 1 @courseId = id
        FROM #CourseIds
        ORDER BY NEWID();

        -- Insert into enrolledCourse table
        INSERT INTO dbo.enrolledCourse
            (learnerId, courseId)
        VALUES
            (@learnerId, @courseId);

        SET @i = @i + 1;

        IF @i >= @numCourse
        BEGIN
            FETCH NEXT FROM learner_cursor INTO @learnerId;
            SET @i = 0;
            SET @numCourse = FLOOR(RAND() * 3 + 2);
        END

    END

    CLOSE learner_cursor;
    DEALLOCATE learner_cursor;

    DROP TABLE #CourseIds;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseReview]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseReview];
GO
CREATE OR ALTER PROCEDURE RandomizeCourseReview
AS
BEGIN
    DECLARE @learnerId VARCHAR(256);
    DECLARE @courseId INT;
    DECLARE @courseCreatedAt DATE;
    DECLARE @reviewCreatedAt DATETIME;
    DECLARE @rating TINYINT;
    DECLARE @content NVARCHAR(512);
    DECLARE @EndDate DATE = GETDATE();

    DECLARE enrolledCourse_cursor CURSOR FOR
    SELECT learnerId, courseId
    FROM dbo.enrolledCourse;

    OPEN enrolledCourse_cursor;
    FETCH NEXT FROM enrolledCourse_cursor INTO @learnerId, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @courseCreatedAt = createdAt
        FROM dbo.course
        WHERE id = @courseId;

        SET @reviewCreatedAt = DATEADD(day, ABS(CHECKSUM(NEWID())) % (DATEDIFF(day, @courseCreatedAt, @EndDate) + 1), @courseCreatedAt);
        SET @rating = (SELECT FLOOR(RAND() * 5) + 1);
        SET @content = CASE 
                          WHEN @rating = 5 THEN 'Very Good'
                          WHEN @rating BETWEEN 2 AND 4 THEN 'Good'
                          WHEN @rating = 1 THEN 'Very bad'
                       END;

        BEGIN TRY
        INSERT INTO dbo.courseReview
            (learnerId, courseId, createdAt, rating, content)
        VALUES
            (@learnerId, @courseId, @reviewCreatedAt, @rating, @content);
        End TRY
        BEGIN CATCH
            RAISERROR('Rating: %d', 16, 1, @rating);
        END CATCH 
        FETCH NEXT FROM enrolledCourse_cursor INTO @learnerId, @courseId;
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
    DECLARE @remainingSharePercentage FLOAT;
    DECLARE @counter INT = 0;
    DECLARE @max INT = 200000;

    DECLARE course_cursor CURSOR FOR
    SELECT id
    FROM dbo.course;

    OPEN course_cursor;

    FETCH NEXT FROM course_cursor INTO @courseId;
    
    SET @numLecturer = FLOOR(RAND() * 3 + 1);

    WHILE @@FETCH_STATUS = 0 AND @counter < @max AND @i < @numLecturer
    BEGIN
        WHILE @i < @numLecturer
        BEGIN
            SET @ownerId = (SELECT TOP 1 id
            FROM dbo.lecturer
            ORDER BY NEWID());

            SET @remainingSharePercentage = 1 - 
                        (SELECT ISNULL(SUM(sharePercentage), 0) 
                         FROM [dbo].[ownedCourse] oc 
                         WHERE @courseId = oc.courseId);

            SET @sharePercentage = ROUND(RAND() * @remainingSharePercentage, 2);  

            INSERT INTO dbo.ownedCourse
                (ownerId, courseId, sharePercentage)
            VALUES
                (@ownerId, @courseId, @sharePercentage);
            
            SET @i = @i + 1;
            SET @counter = @counter + 1;
        END

        IF @i >= @numLecturer
        BEGIN
            FETCH NEXT FROM course_cursor INTO @courseId;
            SET @numLecturer = FLOOR(RAND() * 3 + 1);
            SET @i = 0;
        END
    END

    CLOSE course_cursor;
    DEALLOCATE course_cursor;
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
    DECLARE @count INT = 0;
    DECLARE @maxRecord INT = 250000;

    DECLARE course_cursor CURSOR FOR
        SELECT id
        FROM dbo.course;

    OPEN course_cursor;
    FETCH NEXT FROM course_cursor INTO @courseId;

    SET @numSection = FLOOR(RAND() * 5 + 1);
    SET @sectionId = 1;

    WHILE @@FETCH_STATUS = 0 AND @count < @maxRecord AND @sectionId <= @numSection
    BEGIN
        SET @title = 'Course Section ' + CAST(@sectionId AS NVARCHAR(64));
        SET @description = 'Description for Course Section ' + CAST(@sectionId AS NVARCHAR(512));
        SET @type = (SELECT TOP 1 type FROM (VALUES ('M'), ('L'), ('E')) AS T(type) ORDER BY NEWID());
        INSERT INTO dbo.courseSection
            (id, courseId, pos, title, description, type)
        VALUES
            (@sectionId, @courseId, @sectionId, @title, @description, @type);

        SET @sectionId = @sectionId + 1;
        SET @count = @count + 1;
    
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

IF OBJECT_ID('[dbo].[RandomizeCourseLesson]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseLesson];
GO

CREATE OR ALTER PROCEDURE RandomizeCourseLesson
AS
BEGIN
    DECLARE @id INT;
    DECLARE @courseId INT;
    DECLARE @isFree BIT;
    DECLARE @durationInMinutes TINYINT;

    DECLARE course_cursor CURSOR FOR
    SELECT cs.id, cs.courseId
    FROM dbo.courseSection cs
    WHERE cs.type = 'L';

    OPEN course_cursor;
    FETCH NEXT FROM course_cursor INTO @id, @courseId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @isFree = CASE WHEN RAND() > 0.5 THEN 1 ELSE 0 END;
        SET @durationInMinutes = CAST(RAND() * 55 + 5 AS TINYINT);

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

    DECLARE @StartDate DATE = '2021-01-01';
    DECLARE @EndDate DATE = GETDATE();

    SELECT TOP 1
        @chatId = id
    FROM [dbo].[chat]
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

                SET @num_records = FLOOR(RAND() * 5 + 1);
                SET @i = 0;
            END

            SELECT TOP 1
                @senderId = id          
            FROM #RandomIds
            ORDER BY NEWID();

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
    DECLARE @max_records INT = 120000;
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

    DECLARE @StartDate DATE = '2021-01-01';
    DECLARE @EndDate DATE = GETDATE();

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
                    @senderId = id
                FROM [dbo].[admin]
                ORDER BY NEWID();

                SET @num_records = FLOOR(RAND() * 5 + 1);
                SET @i = 0;
            END

            SELECT TOP 1
                @receiverId = id
            FROM #RandomIds
            ORDER BY NEWID();
            
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

    DECLARE @learnerId VARCHAR(256);
    DECLARE @courseId INT;
    DECLARE @courseSectionId INT;
    DECLARE @completionPercentage FLOAT;
    DECLARE @type CHAR(1);
    DECLARE @count INT = 0;
    DECLARE @numRecord INT = 120000;


    DECLARE enrolled_cursor CURSOR FOR
    SELECT learnerId, courseId
    FROM dbo.enrolledCourse;

    OPEN enrolled_cursor;

    FETCH NEXT FROM enrolled_cursor INTO @learnerId, @courseId;

    WHILE @@FETCH_STATUS = 0 AND @count < @numRecord
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
            SET @type = (SELECT TOP 1 type FROM 
                            (VALUES ('E'), ('E'), ('S')) AS T(type)
                            ORDER BY NEWID());

            BEGIN TRY
                INSERT INTO dbo.courseSectionProgress
                (learnerId, courseId, courseSectionId, completionPercentage, type)
                VALUES
                (@learnerId, @courseId, @courseSectionId, @completionPercentage, @type);
            END TRY
            BEGIN CATCH
                PRINT 'Skipping duplicate entry for learnerId ' + ISNULL(@learnerId, 'NULL') + ', courseId ' + CAST(@courseId AS NVARCHAR(10)) + ', courseSectionId ' + CAST(@courseSectionId AS NVARCHAR(10));
            END CATCH;

            SET @count = @count + 1;

            FETCH NEXT FROM courseSection_cursor INTO @courseSectionId;
        END;

        CLOSE courseSection_cursor;
        DEALLOCATE courseSection_cursor;

        FETCH NEXT FROM enrolled_cursor INTO @learnerId, @courseId;
    END;

    CLOSE enrolled_cursor;
    DEALLOCATE enrolled_cursor;
END;
GO

IF OBJECT_ID('[dbo].[RandomizeCourseExerciseProgress]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeCourseExerciseProgress];
GO

CREATE OR ALTER PROCEDURE RandomizeCourseExerciseProgress
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @learnerId VARCHAR(256);
    DECLARE @courseId INT;
    DECLARE @courseSectionId INT;
    DECLARE @savedTextSolution NVARCHAR(MAX);
    DECLARE @grade FLOAT;

    DECLARE progress_cursor CURSOR FOR
    SELECT learnerId, courseId, courseSectionId
    FROM dbo.courseSectionProgress
    WHERE type = 'E';

    OPEN progress_cursor;

    FETCH NEXT FROM progress_cursor INTO @learnerId, @courseId, @courseSectionId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @savedTextSolution = 'Random solution text ' + CAST(NEWID() AS NVARCHAR(36));

        SET @grade = ROUND(RAND(CHECKSUM(NEWID())) * 10, 2);

        INSERT INTO dbo.courseExerciseProgress
        (learnerId, courseId, courseSectionId, savedTextSolution, grade)
        VALUES
        (@learnerId, @courseId, @courseSectionId, @savedTextSolution, @grade);
           
        FETCH NEXT FROM progress_cursor INTO @learnerId, @courseId, @courseSectionId;
    END;

    CLOSE progress_cursor;
    DEALLOCATE progress_cursor;
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
    DECLARE @i INT = 0;
    DECLARE @numFile INT;

    DECLARE courseSection_cursor CURSOR FOR
    SELECT id, courseId
    FROM dbo.[courseSection];

    SET @numFile = FLOOR(RAND() * 2) + 1;

    OPEN courseSection_cursor;

    FETCH NEXT FROM courseSection_cursor INTO @sectionId, @courseId;

    WHILE @@FETCH_STATUS = 0 AND @i < @numFile
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

            SET @i = @i + 1;
        END TRY
        BEGIN CATCH
            PRINT 'Skipping duplicate file ID ' + CAST(@fileId AS NVARCHAR(10));
        END CATCH;

        IF @i = @numFile
        BEGIN
            SET @i = 0;
            SET @numFile = FLOOR(RAND() * 2) + 1;
            FETCH NEXT FROM courseSection_cursor INTO @sectionId, @courseId;
        END
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
    DECLARE @i INT = 0;
    DECLARE @numFile INT;


    SELECT @counter = count(*) FROM [dbo].[file];

    DECLARE courseExercise_cursor CURSOR FOR
    SELECT id, courseId
    FROM dbo.[courseExercise];

    SET @numFile = FLOOR(RAND() * 2) + 1;

    OPEN courseExercise_cursor;

    FETCH NEXT FROM courseExercise_cursor INTO @courseExerciseId, @courseId;

    WHILE @@FETCH_STATUS = 0 AND @i < @numFile
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

        SET @i = @i + 1;
        END TRY
        BEGIN CATCH
            PRINT 'Skipping duplicate file ID ' + CAST(@fileId AS NVARCHAR(10));
        END CATCH;

        IF @i = @numFile
        BEGIN
            SET @i = 0;
            SET @numFile = FLOOR(RAND() * 2) + 1;
            FETCH NEXT FROM courseExercise_cursor INTO @courseExerciseId, @courseId;
        END
    END;

    CLOSE courseExercise_cursor;
    DEALLOCATE courseExercise_cursor;
END;
GO


IF OBJECT_ID('[dbo].[RandomizeTransactionData]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[RandomizeTransactionData];
GO

CREATE OR ALTER PROCEDURE RandomizeTransactionData
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @max_records INT = 120000;
    DECLARE @counter INT = 0;
    DECLARE @courseId INT;
    DECLARE @initiatorId INT;
    DECLARE @paidAmount MONEY;
    DECLARE @discountPercentage FLOAT;
    DECLARE @sharePercentage FLOAT;
    DECLARE @createdAt DATETIME;
    DECLARE @StartDate DATE = '2021-01-01';
    DECLARE @EndDate DATE = GETDATE();

    DECLARE enrolledCourse_cursor CURSOR FOR
    SELECT learnerId, courseId
    FROM dbo.[enrolledCourse];

    OPEN enrolledCourse_cursor;

    FETCH NEXT FROM enrolledCourse_cursor INTO @initiatorId, @courseId;

    WHILE  @@FETCH_STATUS = 0 AND @counter < @max_records
    BEGIN
        SET @createdAt = DATEADD(day, ABS(CHECKSUM(NEWID())) % (DATEDIFF(day, @StartDate, @EndDate) + 1), @StartDate);
        SET @paidAmount = (SELECT price FROM [dbo].[course] WHERE id = @courseId)
        SET @discountPercentage = ROUND(RAND() * 1, 2);  


        INSERT INTO dbo.[transaction]
            (initiatorId, receiverId, courseId, paidAmount, taxPercentage, transactionFee, sharePercentage, discountPercentage, createdAt)
        SELECT @initiatorId, ownerId, @courseId, @paidAmount, 0.1, 10, sharePercentage, @discountPercentage, @createdAt
	    FROM [dbo].[ownedCourse]
	    WHERE courseId = @courseId


        SET @counter = @counter + 1;
        FETCH NEXT FROM enrolledCourse_cursor INTO @initiatorId, @courseId;
    END;

    CLOSE enrolledCourse_cursor;
    DEALLOCATE enrolledCourse_cursor;
END;
GO


EXEC InsertCourseCategory;

EXEC RandomizeBankAccount;
EXEC RandomizeCourseDescriptionDetail;
EXEC RandomizeEnrolledCourse;
EXEC RandomizeCourseReview;
EXEC RandomizeOwnedCourse;
EXEC RandomizeCourseAnnouncement;


EXEC RandomCourseSections;
EXEC RandomizeCourseLesson;
EXEC RandomizeCourseExercise;
EXEC RandomizeCourseSectionProgress;
EXEC RandomizeCourseExerciseProgress;


EXEC RandomizeCourseSectionFile;
EXEC RandomizeCourseExerciseSolutionFile;

EXEC RandomizeCourseChat;
EXEC RandomizeCourseChatMember;
EXEC RandomizeMessage;
EXEC RandomizeNotification;

EXEC RandomizeTransactionData;
