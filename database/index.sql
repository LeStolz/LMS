--1
CREATE NONCLUSTERED INDEX IX_User_email_password
ON [dbo].[user] (email, password)
INCLUDE (id);

--2
CREATE UNIQUE NONCLUSTERED INDEX UIX_Course_title
ON [dbo].[course] (title)

CREATE NONCLUSTERED INDEX IX_Course_learnerCount
ON [dbo].[Course] (learnerCount)

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
ALTER TABLE courseSectionProgress
DROP CONSTRAINT fk_courseSectionProgress_courseSection;

ALTER TABLE courseExercise
DROP CONSTRAINT fk_courseExercise_courseSection;

ALTER TABLE courseSectionFile
DROP CONSTRAINT fk_courseSectionFile_courseSection;

ALTER TABLE courseLesson
DROP CONSTRAINT fk_courseLesson_courseSection;

ALTER TABLE courseSection
DROP CONSTRAINT pk_courseSection;

ALTER TABLE courseSection
ADD CONSTRAINT pk_courseSection PRIMARY KEY CLUSTERED (courseId, id);

ALTER TABLE courseSectionProgress
ADD	CONSTRAINT [fk_courseSectionProgress_courseSection]
		FOREIGN KEY(courseId, courseSectionId) REFERENCES [dbo].[courseSection](courseId, id);

ALTER TABLE courseExercise
ADD	CONSTRAINT [fk_courseExercise_courseSection]
		FOREIGN KEY(courseId, id) REFERENCES [dbo].[courseSection](courseId, id);

ALTER TABLE courseSectionFile
ADD	CONSTRAINT [fk_courseSectionFile_courseSection]
		FOREIGN KEY(courseId, courseSectionId) REFERENCES [dbo].[courseSection](courseId, id)

ALTER TABLE courseLesson
ADD CONSTRAINT [fk_courseLesson_courseSection]
		FOREIGN KEY(courseId, id) REFERENCES [dbo].[courseSection](courseId, id)
---