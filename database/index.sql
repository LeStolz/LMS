--1
CREATE NONCLUSTERED INDEX IX_User_email_password
ON [dbo].[user] (email, password)
INCLUDE (id);

--2
CREATE UNIQUE NONCLUSTERED INDEX UIX_Course_title
ON [dbo].[course] (title)

--3
CREATE NONCLUSTERED INDEX UIX_CourseAnnoucement_createdAt
ON [dbo].[courseAnnouncement] (createdAt)

--4
CREATE NONCLUSTERED INDEX IX_CourseSectionFile_courseId_courseSectionId
ON [dbo].[courseSectionFile] (courseId, courseSectionId)

--5
CREATE NONCLUSTERED INDEX IX_CourseExerciseSolutionFile_courseId_courseExerciseId
ON [dbo].[courseExerciseSolutionFile] (courseId, courseExerciseId)


--6
CREATE NONCLUSTERED INDEX IX_CourseSection_courseId_id
ON [dbo].[courseSection] (courseId, id)