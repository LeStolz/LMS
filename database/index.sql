--1
CREATE NONCLUSTERED INDEX IX_User_email
ON [dbo].[user] (email)
INCLUDE (id, password);

DROP INDEX IX_User_email ON [dbo].[user];

--2 -- searchCOURSE
CREATE UNIQUE NONCLUSTERED INDEX UIX_Course_title
ON [dbo].[course] (title)
INCLUDE ([subtitle], [description], [price], [level], [thumbnail], [advertisementVideo],
			[status], [createdAt], [visitorCount], [rating], [raterCount], 
			[learnerCount], [lecturerCount], [minutesToComplete], [updatedAt])

CREATE NONCLUSTERED INDEX IX_Course_learnerCount
ON [dbo].[Course] (learnerCount)

DROP INDEX IX_Course_learnerCount ON [dbo].[course];
DROP INDEX UIX_Course_title ON [dbo].[course];

--3 -- enrolledCourse
CREATE NONCLUSTERED INDEX UIX_OwnedCourse_courseId
ON [dbo].[ownedCourse] (courseId)

DROP INDEX UIX_OwnedCourse_courseId ON [dbo].[ownedCourse];

--4 --courseAnnoucement
CREATE NONCLUSTERED INDEX UIX_CourseAnnoucement_createdAt
ON [dbo].[courseAnnouncement] (createdAt)

DROP INDEX UIX_CourseAnnoucement_createdAt ON [dbo].[courseAnnouncement];


--5 -- selectCourseSection
CREATE NONCLUSTERED INDEX IX_CourseSectionFile_courseId_courseSectionId
ON [dbo].[courseSectionFile] (courseId, courseSectionId)

CREATE NONCLUSTERED INDEX IX_CourseExerciseSolutionFile_courseId_courseExerciseId
ON [dbo].[courseExerciseSolutionFile] (courseId, courseExerciseId)

DROP INDEX IX_CourseSectionFile_courseId_courseSectionId ON [dbo].[courseSectionFile];
DROP INDEX IX_CourseExerciseSolutionFile_courseId_courseExerciseId ON [dbo].[courseExerciseSolutionFile];


--7 -- selectCourse
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

------------------------------------------------------------------------------
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
ADD CONSTRAINT pk_courseSection PRIMARY KEY CLUSTERED (id, courseId);

ALTER TABLE courseSectionProgress
ADD	CONSTRAINT [fk_courseSectionProgress_courseSection]
		FOREIGN KEY(courseSectionId, courseId) REFERENCES [dbo].[courseSection](id, courseId);

ALTER TABLE courseExercise
ADD	CONSTRAINT [fk_courseExercise_courseSection]
		FOREIGN KEY(id, courseId) REFERENCES [dbo].[courseSection](id, courseId);

ALTER TABLE courseSectionFile
ADD	CONSTRAINT [fk_courseSectionFile_courseSection]
		FOREIGN KEY(courseSectionId, courseId) REFERENCES [dbo].[courseSection](id, courseId)

ALTER TABLE courseLesson
ADD CONSTRAINT [fk_courseLesson_courseSection]
		FOREIGN KEY(id, courseId) REFERENCES [dbo].[courseSection](id, courseId)
--
