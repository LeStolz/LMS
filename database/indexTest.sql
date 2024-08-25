--IDX1
DECLARE @email VARCHAR(256);
DECLARE @password VARCHAR(256);
DECLARE @middleId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user]) / 2);

SELECT @email = email, @password = password
FROM [dbo].[user]
WHERE id = @middleId;

EXEC selectUserByCred @email, @password

--IDX2 --DCP2
EXEC searchCourses 'the', null, 0, null, null, null, null, 'L'

--IDX3
DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2);
DECLARE @courseId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[course]) / 2);
EXEC enrollInCourse @learnerId, @courseId, null;

DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2) + 1;
DECLARE @courseId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[course]) / 2);
EXEC enrollInCourse @learnerId, @courseId, null;

--IDX4
EXEC searchCourseAnnouncement 0

EXEC searchCourseAnnouncement 0

--IDX5 -- DCP1
DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2);
DECLARE @courseId INT = (SELECT TOP 1 (courseId) FROM enrolledCourse WHERE @learnerId = learnerId);

EXEC selectCourseSection 1, @courseId, @learnerId

--IDX6
DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2);
DECLARE @courseId INT = (SELECT TOP 1 (courseId) FROM enrolledCourse WHERE @learnerId = learnerId);

EXEC selectCourseSection 1, @courseId, @learnerId

--IDX7
DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2);
DECLARE @courseId INT = (SELECT TOP 1 (courseId) FROM enrolledCourse WHERE @learnerId = learnerId);

EXEC selectCourse @courseId, 1, 1, 1, 1, 1, @learnerId