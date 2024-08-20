--IDX1
DECLARE @email VARCHAR(256);
DECLARE @password VARCHAR(256);

-- Tính toán id ở giữa phạm vi MAX(id) và MIN(id)
DECLARE @middleId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user]) / 2);

-- Lấy email và password từ user có id = @middleId
SELECT @email = email, @password = password
FROM [dbo].[user]
WHERE id = @middleId;

EXEC selectUserByCred @email, @password


--IDX2
EXEC searchCourses '[5]', null, 0, null, null, null, null, null

--IDX3
DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2) + 3;
DECLARE @courseId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[course]) / 2);
EXEC enrollInCourse @learnerId, @courseId, null;

DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%learner%') / 2) + 4;
DECLARE @courseId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[course]) / 2);
EXEC enrollInCourse @learnerId, @courseId, null;


--IDX4
EXEC searchCourseAnnouncement 0

EXEC searchCourseAnnouncement 0

--IDX5
DECLARE @learnerId INT = FLOOR((SELECT MAX(id) + MIN(id) FROM [dbo].[user] where email like '%lecturer%') / 2);
DECLARE @courseId INT = (SELECT TOP 1 (courseId) FROM ownedCourse WHERE @learnerId = ownerId);

EXEC selectCourseSection 1, @courseId, @learnerId