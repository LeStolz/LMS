-- DCP1
CREATE OR ALTER PROCEDURE [dbo].[selectCourseSectionFixed]
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
			SELECT csf.id, csf.path, csf.name
			FROM [dbo].[courseSectionFileFixed] csf
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
--Before
DECLARE @StartTime DATETIME2, @EndTime DATETIME2;
SET @StartTime = SYSDATETIME();

DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2);
DECLARE @courseId INT = (SELECT TOP 1 (courseId) FROM enrolledCourse WHERE @learnerId = learnerId);
EXEC selectCourseSection 1, @courseId, @learnerId

SET @EndTime = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecTimeInMsBeforeDcp;
GO
--After
DECLARE @StartTime DATETIME2, @EndTime DATETIME2;
SET @StartTime = SYSDATETIME();

DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2);
DECLARE @courseId INT = (SELECT TOP 1 (courseId) FROM enrolledCourse WHERE @learnerId = learnerId);
EXEC selectCourseSectionFixed 1, @courseId, @learnerId

SET @EndTime = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecTimeInMsAfterDcp;
GO
--DCP2
CREATE OR ALTER PROCEDURE [dbo].[selectCourseFixed]
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
			SELECT *
			FROM [dbo].[courseReviewFixed] cr
			WHERE @withReviews = 1 AND cr.courseId = co.id
			FOR JSON PATH, INCLUDE_NULL_VALUES
		) as reviews
	FROM [dbo].[course] co
	WHERE co.id = @id
COMMIT TRANSACTION
GO

--Before
DECLARE @StartTime DATETIME2, @EndTime DATETIME2;
SET @StartTime = SYSDATETIME();

DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2);
DECLARE @courseId INT = (SELECT TOP 1 (courseId) FROM enrolledCourse WHERE @learnerId = learnerId);
EXEC selectCourse @courseId, 1, 1, 1, 1, 1, @learnerId

SET @EndTime = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecTimeInMsAfterDcp;
GO

--After
DECLARE @StartTime DATETIME2, @EndTime DATETIME2;
SET @StartTime = SYSDATETIME();

DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2);
DECLARE @courseId INT = (SELECT TOP 1 (courseId) FROM enrolledCourse WHERE @learnerId = learnerId);
EXEC selectCourseFixed @courseId, 1, 1, 1, 1, 1, @learnerId

SET @EndTime = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecTimeInMsBeforeDcp;
GO