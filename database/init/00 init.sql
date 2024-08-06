-- Create the database
USE master
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'lms')
	DROP DATABASE lms
GO

CREATE DATABASE lms
GO

USE lms
GO

SET DATEFIRST 7
GO




-- Create the tables
IF OBJECT_ID('[dbo].[user]', 'U') IS NOT NULL
	DROP TABLE [dbo].[user]
GO

CREATE TABLE [dbo].[user]
(
	id INT IDENTITY(1, 1) NOT NULL,
	email VARCHAR(256) NOT NULL,
	password VARCHAR(128) NOT NULL,
	name NVARCHAR(128) NOT NULL,
	type CHAR(2) NOT NULL CHECK(type IN ('AD', 'LN', 'LT')),

	CONSTRAINT [User email format is invalid.] CHECK(email LIKE '%_@__%.__%'),
	CONSTRAINT [A user with this email already exists.] UNIQUE(email),
	CONSTRAINT [User password must be at least 5 characters long.] CHECK(LEN(password) > 4),
	CONSTRAINT [User name is required.] CHECK(LEN(name) > 0),

	CONSTRAINT [pk_user] PRIMARY KEY(id)
);
GO




CREATE FUNCTION [dbo].[isValidUser](@id INT, @type CHAR(2))
RETURNS BIT
AS
BEGIN
	IF (EXISTS(SELECT id FROM [dbo].[user] WHERE id = @id AND type = @type))
		RETURN 1

	RETURN 0
END
GO


IF OBJECT_ID('[dbo].[admin]', 'U') IS NOT NULL
	DROP TABLE [dbo].[admin]
GO

CREATE TABLE [dbo].[admin]
(
	id INT NOT NULL CHECK([dbo].[isValidUser](id, 'AD') = 1),

	CONSTRAINT [fk_admin_user] FOREIGN KEY(id) REFERENCES [dbo].[user](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_admin] PRIMARY KEY(id)
);
GO




IF OBJECT_ID('[dbo].[learner]', 'U') IS NOT NULL
	DROP TABLE [dbo].[learner]
GO

CREATE TABLE [dbo].[learner]
(
	id INT NOT NULL CHECK([dbo].[isValidUser](id, 'LN') = 1),

	CONSTRAINT [fk_learner_user] FOREIGN KEY(id) REFERENCES [dbo].[user](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_learner] PRIMARY KEY(id)
);
GO




IF OBJECT_ID('[dbo].[lecturer]', 'U') IS NOT NULL
	DROP TABLE [dbo].[lecturer]
GO

CREATE TABLE [dbo].[lecturer]
(
	id INT NOT NULL CHECK([dbo].[isValidUser](id, 'LT') = 1),
	dob DATE NOT NULL,
	gender CHAR(1) NOT NULL,
	homeAddress NVARCHAR(256) NOT NULL,
	workAddress NVARCHAR(256) NOT NULL,
	nationality CHAR(2) NOT NULL,
	phone CHAR(10) NOT NULL,
	introduction NVARCHAR(512) NOT NULL,
	annualIncome MONEY NOT NULL,
	academicRank CHAR(1) NOT NULL,
	academicDegree CHAR(1) NOT NULL,
	profileImage NVARCHAR(256) NOT NULL,
	status CHAR(1) NOT NULL,
	demandVerificationDate DATE NOT NULL,

	CONSTRAINT [Lecturer date of birth must be before today.] CHECK(dob <= GETDATE()),
	CONSTRAINT [Lecturer gender is required.] CHECK(gender IN ('M', 'F')),
	CONSTRAINT [Lecturer home address is required.] CHECK(LEN(homeAddress) > 0),
	CONSTRAINT [Lecturer work address is required.] CHECK(LEN(workAddress) > 0),
	CONSTRAINT [Lecturer nationality is required.] CHECK(LEN(nationality) = 2),
	CONSTRAINT [Lecturer phone format is invalid.] CHECK(ISNUMERIC(phone) = 1 AND LEN(phone) = 10),
	CONSTRAINT [Lecturer introduction is required.] CHECK(LEN(introduction) > 0),
	CONSTRAINT [Lecturer annual income must be non-negative.] CHECK(annualIncome >= 0),
	CONSTRAINT [Lecturer academic rank is required.] CHECK(academicRank IN ('A', 'B', 'C', 'D', 'E')),
	CONSTRAINT [Lecturer academic degree is required.] CHECK(academicDegree IN ('B', 'M', 'D')),
	CONSTRAINT [Lecturer profile image is required.] CHECK(LEN(profileImage) > 0),
	CONSTRAINT [Lecturer status is required.] CHECK(status IN ('R', 'P', 'V')),
	CONSTRAINT [Lecturer demand verification date must be before today.] CHECK(demandVerificationDate <= GETDATE()),

	CONSTRAINT [fk_lecturer_user] FOREIGN KEY(id) REFERENCES [dbo].[user](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_lecturer] PRIMARY KEY(id)
);
GO


IF OBJECT_ID('[dbo].[certificate]', 'U') IS NOT NULL
	DROP TABLE [dbo].[certificate]
GO

CREATE TABLE [dbo].[certificate]
(
	lecturerId INT NOT NULL,
	title NVARCHAR(128) NOT NULL,
	image NVARCHAR(256) NOT NULL,

	CONSTRAINT [Certificate title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [Certificate image is required.] CHECK(LEN(image) > 0),

	CONSTRAINT [fk_certificate_lecturer] FOREIGN KEY(lecturerId) REFERENCES [dbo].[lecturer](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_certificate] PRIMARY KEY(lecturerId, title)
);
GO


IF OBJECT_ID('[dbo].[workExperience]', 'U') IS NOT NULL
	DROP TABLE [dbo].[workExperience]
GO

CREATE TABLE [dbo].[workExperience]
(
	lecturerId INT NOT NULL,
	topic NVARCHAR(128) NOT NULL,
	role NVARCHAR(128) NOT NULL,
	organizationName NVARCHAR(128) NOT NULL,
	fromDate DATE NOT NULL,
	toDate DATE NOT NULL,

	CONSTRAINT [Work experience topic is required.] CHECK(LEN(topic) > 0),
	CONSTRAINT [Work experience role is required.] CHECK(LEN(role) > 0),
	CONSTRAINT [Work experience organization name is required.] CHECK(LEN(organizationName) > 0),
	CONSTRAINT [Work experience from date must be before to date.] CHECK(fromDate <= toDate),

	CONSTRAINT [fk_workExperience_lecturer] FOREIGN KEY(lecturerId) REFERENCES [dbo].[lecturer](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_workExperience] PRIMARY KEY(lecturerId, topic)
);
GO




IF OBJECT_ID('[dbo].[category]', 'U') IS NOT NULL
	DROP TABLE [dbo].[category]
GO

CREATE TABLE [dbo].[category]
(
	id SMALLINT IDENTITY(1, 1) NOT NULL,
	title NVARCHAR(64) NOT NULL,
	courseCount INT NOT NULL DEFAULT(0),
	learnerCount INT NOT NULL DEFAULT(0),
	rating FLOAT NOT NULL DEFAULT(0),
	monthlyRevenueGenerated MONEY NOT NULL DEFAULT(0),
	parentId SMALLINT DEFAULT(NULL),

	CONSTRAINT [category title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [A category with this title already exists.] UNIQUE(title),
	CONSTRAINT [A category cannot be its own parent.] CHECK(parentId <> id),
	CONSTRAINT [Category course count must be non-negative.] CHECK(courseCount >= 0),
	CONSTRAINT [Category learner count must be non-negative.] CHECK(learnerCount >= 0),
	CONSTRAINT [Category rating must be between 0 and 5.] CHECK(0 <= rating AND rating <= 5),
	CONSTRAINT [Category monthly revenue generated must be non-negative.] CHECK(monthlyRevenueGenerated >= 0),

	CONSTRAINT [fk_category_parent] FOREIGN KEY(parentId) REFERENCES [dbo].[category](id),
	CONSTRAINT [pk_category] PRIMARY KEY(id)
);
GO


IF OBJECT_ID('[dbo].[course]', 'U') IS NOT NULL
	DROP TABLE [dbo].[course]
GO

CREATE TABLE [dbo].[course]
(
	id INT IDENTITY(1, 1) NOT NULL,
	title NVARCHAR(64) NOT NULL,
	subtitle NVARCHAR(128) NOT NULL,
	description NVARCHAR(MAX),
	price MONEY,
	level CHAR(1),
	thumbnail NVARCHAR(256),
	advertisementVideo NVARCHAR(256),
	status CHAR(1) NOT NULL,
	createdAt DATE NOT NULL DEFAULT(GETDATE()),
	visitorCount INT NOT NULL DEFAULT(0),
	rating FLOAT NOT NULL DEFAULT(0),
	raterCount INT NOT NULL DEFAULT(0),
	learnerCount INT NOT NULL DEFAULT(0),
	lecturerCount TINYINT NOT NULL DEFAULT(1),
	minutesToComplete SMALLINT NOT NULL DEFAULT(0),
	updatedAt DATE NOT NULL DEFAULT(GETDATE()),
	monthlyRevenueGenerated MONEY NOT NULL DEFAULT(0),

	CONSTRAINT [Course title is required and must not be longer than 60.] CHECK(0 < LEN(title) AND LEN(title) <= 60),
	CONSTRAINT [A course with this title already exists.] UNIQUE(title),
	CONSTRAINT [Course subtitle is required and must not be longer than 120.] CHECK(0 < LEN(subtitle) AND LEN(subtitle) <= 120),
	CONSTRAINT [Course description is required.] CHECK(status = 'C' OR description IS NOT NULL AND LEN(description) > 0),
	CONSTRAINT [Course price must be non-negative.] CHECK(status = 'C' OR price IS NOT NULL AND price >= 0),
	CONSTRAINT [Course level is required.] CHECK(status = 'C' OR level IS NOT NULL AND level IN ('B', 'I', 'A')),
	CONSTRAINT [Course thumbnail is required.] CHECK(status = 'C' OR thumbnail IS NOT NULL AND LEN(thumbnail) > 0),
	CONSTRAINT [Course status is required.] CHECK(status IN ('C', 'R', 'P', 'V')),
	CONSTRAINT [Course creation date must be before today.] CHECK(createdAt <= GETDATE()),
	CONSTRAINT [Course visitor count must be non-negative.] CHECK(visitorCount >= 0),
	CONSTRAINT [Course rating must be between 0 and 5.] CHECK(0 <= rating AND rating <= 5),
	CONSTRAINT [Course rater count must be non-negative.] CHECK(raterCount >= 0),
	CONSTRAINT [Course learner count must be non-negative.] CHECK(learnerCount >= 0),
	CONSTRAINT [Course lecturer count must be non-negative.] CHECK(lecturerCount >= 0),
	CONSTRAINT [Course minutes to complete must be non-negative.] CHECK(minutesToComplete >= 0),
	CONSTRAINT [Course update date must be before today.] CHECK(updatedAt <= GETDATE()),
	CONSTRAINT [Course monthly revenue generated must be non-negative.] CHECK(monthlyRevenueGenerated >= 0),

	CONSTRAINT [pk_course] PRIMARY KEY(id)
);
GO


IF OBJECT_ID('[dbo].[courseCategory]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseCategory]
GO

CREATE TABLE [dbo].[courseCategory]
(
	courseId INT NOT NULL,
	categoryId SMALLINT NOT NULL,

	CONSTRAINT [fk_courseCategory_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_courseCategory_category] FOREIGN KEY(categoryId) REFERENCES [dbo].[category](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_courseCategory] PRIMARY KEY(courseId, categoryId)
);
GO


IF OBJECT_ID('[dbo].[courseDescriptionDetail]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseDescriptionDetail]
GO

CREATE TABLE [dbo].[courseDescriptionDetail]
(
	courseId INT NOT NULL,
	content NVARCHAR(128) NOT NULL,
	type CHAR(1) NOT NULL,

	CONSTRAINT [Course description detail type is required.]
		CHECK(type IN ('P', 'O', 'S', 'T', 'L')),
	CONSTRAINT [Course description detail content is required.] CHECK(LEN(content) > 0),

	CONSTRAINT [fk_courseDescriptionDetail_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_courseDescriptionDetail] PRIMARY KEY(courseId, content)
);
GO


IF OBJECT_ID('[dbo].[ownedCourse]', 'U') IS NOT NULL
	DROP TABLE [dbo].[ownedCourse]
GO

CREATE TABLE [dbo].[ownedCourse]
(
	ownerId INT NOT NULL,
	courseId INT NOT NULL,
	sharePercentage FLOAT NOT NULL,

	CONSTRAINT [Course share percentage must be non-negative.] CHECK(sharePercentage >= 0),

	CONSTRAINT [fk_ownedCourse_owner] FOREIGN KEY(ownerId) REFERENCES [dbo].[lecturer](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_ownedCourse_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_ownedCourse] PRIMARY KEY(ownerId, courseId),
);
GO


IF OBJECT_ID('[dbo].[monthlyCourseIncome]', 'U') IS NOT NULL
	DROP TABLE [dbo].[monthlyCourseIncome]
GO

CREATE TABLE [dbo].[monthlyCourseIncome]
(
	courseId INT NOT NULL,
	date DATE NOT NULL,
	income MONEY NOT NULL,

	CONSTRAINT [Monthly course income date must be before today.] CHECK(date <= GETDATE()),
	CONSTRAINT [Monthly course income date must be the first day of the month.]
		CHECK(date = DATEFROMPARTS(YEAR(date), MONTH(date), 1)),
	CONSTRAINT [Monthly course income must be non-negative.] CHECK(income >= 0),

	CONSTRAINT [fk_monthlyCourseIncome_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_monthlyCourseIncome] PRIMARY KEY(courseId, date)
);
GO


IF OBJECT_ID('[dbo].[courseAnnouncement]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseAnnouncement]
GO

CREATE TABLE [dbo].[courseAnnouncement]
(
	senderId INT,
	courseId INT NOT NULL,
	createdAt DATE NOT NULL DEFAULT GETDATE(),
	title NVARCHAR(64) NOT NULL,
	content NVARCHAR(512) NOT NULL,

	CONSTRAINT [Course announcement created at must be before today.] CHECK(createdAt <= GETDATE()),
	CONSTRAINT [Course announcement title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [Course announcement content is required.] CHECK(LEN(content) > 0),

	CONSTRAINT [fk_courseAnnouncement_sender] FOREIGN KEY(senderId) REFERENCES [dbo].[lecturer](id),
	CONSTRAINT [fk_courseAnnouncement_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_courseAnnouncement] PRIMARY KEY(courseId, createdAt)
);
GO


IF OBJECT_ID('[dbo].[courseReview]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseReview]
GO

CREATE TABLE [dbo].[courseReview]
(
	learnerId INT,
	courseId INT NOT NULL,
	createdAt DATETIME NOT NULL DEFAULT(GETDATE()),
	rating TINYINT NOT NULL,
	content NVARCHAR(512),

	CONSTRAINT [Course review created at must be before today.] CHECK(createdAt <= GETDATE()),
	CONSTRAINT [Course review rating must be between 1 and 5.] CHECK(rating BETWEEN 1 AND 5),

	CONSTRAINT [fk_courseReview_learner] FOREIGN KEY(learnerId) REFERENCES [dbo].[learner](id),
	CONSTRAINT [fk_courseReview_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_courseReview] PRIMARY KEY(learnerId, courseId, createdAt)
);
GO


IF OBJECT_ID('[dbo].[enrolledCourse]', 'U') IS NOT NULL
	DROP TABLE [dbo].[enrolledCourse]
GO

CREATE TABLE [dbo].[enrolledCourse]
(
	learnerId INT NOT NULL,
	courseId INT NOT NULL,
	status CHAR(1) NOT NULL,

	CONSTRAINT [Enrolled course status is required.] CHECK(status IN ('B', 'L', 'F')),

	CONSTRAINT [fk_enrolledCourse_learner] FOREIGN KEY(learnerId) REFERENCES [dbo].[learner](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_enrolledCourse_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_enrolledCourse] PRIMARY KEY(learnerId, courseId)
);
GO


IF OBJECT_ID('[dbo].[courseSection]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseSection]
GO

CREATE TABLE [dbo].[courseSection]
(
	id SMALLINT NOT NULL,
	courseId INT NOT NULL,
	nextCourseSectionId SMALLINT DEFAULT(NULL),
	title NVARCHAR(64) NOT NULL,
	description NVARCHAR(512) NOT NULL,
	type CHAR(1) NOT NULL CHECK(type IN ('M', 'L', 'E')),

	CONSTRAINT [Another course section already has the same next section id.] UNIQUE(nextCourseSectionId, courseId),
	CONSTRAINT [A course section cannot be its own next section.] CHECK(nextCourseSectionId <> id),
	CONSTRAINT [Course section title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [Course section description is required.] CHECK(LEN(description) > 0),

	CONSTRAINT [fk_courseSection_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_courseSection_nextSection]
		FOREIGN KEY(nextCourseSectionId, courseId) REFERENCES [dbo].[courseSection](id, courseId),

	CONSTRAINT [pk_courseSection] PRIMARY KEY(id, courseId)
);
GO




CREATE FUNCTION [dbo].[isValidSection](@id INT, @courseId INT, @type CHAR(1))
RETURNS BIT
AS
BEGIN
	IF (EXISTS(SELECT id FROM [dbo].[courseSection] WHERE id = @id AND courseId = @courseId AND type = @type))
		RETURN 1

	RETURN 0
END
GO


IF OBJECT_ID('[dbo].[courseLesson]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseLesson]
GO

CREATE TABLE [dbo].[courseLesson]
(
	id SMALLINT NOT NULL,
	courseId INT NOT NULL,
	isFree BIT NOT NULL DEFAULT 0,
	durationInMinutes TINYINT NOT NULL,

	CONSTRAINT [Course lesson must have a corresponding section.]
		CHECK([dbo].[isValidSection](id, courseId, 'L') = 1),

	CONSTRAINT [Course lesson duration must be between 1 and 60 minutes.]
		CHECK(1 <= durationInMinutes AND durationInMinutes <= 60),

	CONSTRAINT [fk_courseLesson_courseSection]
		FOREIGN KEY(id, courseId) REFERENCES [dbo].[courseSection](id, courseId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseLesson] PRIMARY KEY(id, courseId)
);
GO


IF OBJECT_ID('[dbo].[courseExercise]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseExercise]
GO

CREATE TABLE [dbo].[courseExercise]
(
	id SMALLINT NOT NULL,
	courseId INT NOT NULL,
	type CHAR(1) NOT NULL CHECK(type IN ('E', 'Q')),

	CONSTRAINT [Course exercise must have a corresponding section.]
		CHECK([dbo].[isValidSection](id, courseId, 'E') = 1),

	CONSTRAINT [fk_courseExercise_courseSection]
		FOREIGN KEY(id, courseId) REFERENCES [dbo].[courseSection](id, courseId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseExercise] PRIMARY KEY(id, courseId)
);
GO




CREATE FUNCTION [dbo].[isValidExercise](@id INT, @courseId INT, @type CHAR(1))
RETURNS BIT
AS
BEGIN
	IF (EXISTS(SELECT id FROM [dbo].[courseExercise] WHERE id = @id AND courseId = @courseId AND type = @type))
		RETURN 1

	RETURN 0
END
GO


IF OBJECT_ID('[dbo].[courseQuiz]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseQuiz]
GO

CREATE TABLE [dbo].[courseQuiz]
(
	id SMALLINT NOT NULL,
	courseId INT NOT NULL,
	durationInMinutes TINYINT NOT NULL,

	CONSTRAINT [Course quiz must have a corresponding exercise.]
		CHECK([dbo].[isValidExercise](id, courseId, 'Q') = 1),

	CONSTRAINT [Course quiz duration must be between 1 and 60 minutes.]
		CHECK(1 <= durationInMinutes AND durationInMinutes <= 60),

	CONSTRAINT [fk_courseQuiz_courseExercise]
		FOREIGN KEY(id, courseId) REFERENCES [dbo].[courseExercise](id, courseId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseQuiz] PRIMARY KEY(id, courseId)
);
GO


IF OBJECT_ID('[dbo].[courseQuizQuestion]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseQuizQuestion]
GO

CREATE TABLE [dbo].[courseQuizQuestion]
(
	id TINYINT NOT NULL,
	courseQuizId SMALLINT NOT NULL,
	courseId INT NOT NULL,
	question NVARCHAR(512) NOT NULL,
	correctAnswerSymbol CHAR(1) NOT NULL,

	CONSTRAINT [Course quiz question is required.] CHECK(LEN(question) > 0),

	CONSTRAINT [fk_courseQuizQuestion_courseQuiz]
		FOREIGN KEY(courseQuizId, courseId) REFERENCES [dbo].[courseQuiz](id, courseId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseQuizQuestion] PRIMARY KEY(id, courseQuizId, courseId)
);
GO


IF OBJECT_ID('[dbo].[courseQuizQuestionAnswer]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseQuizQuestionAnswer]
GO

CREATE TABLE [dbo].[courseQuizQuestionAnswer]
(
	courseQuizQuestionId TINYINT NOT NULL,
	courseQuizId SMALLINT NOT NULL,
	courseId INT NOT NULL,
	symbol CHAR(1) NOT NULL,
	answer NVARCHAR(256) NOT NULL,

	CONSTRAINT [Course quiz question answer symbol is required.] CHECK(LEN(symbol) = 1),
	CONSTRAINT [Course quiz answer is required.] CHECK(LEN(answer) > 0),

	CONSTRAINT [pk_courseQuizQuestionAnswer] PRIMARY KEY(symbol, courseQuizQuestionId, courseQuizId, courseId)
);
GO


ALTER TABLE [dbo].[courseQuizQuestion] ADD
	CONSTRAINT [fk_courseQuizQuestion_courseQuizQuestionAnswer]
		FOREIGN KEY(correctAnswerSymbol, id, courseQuizId, courseId)
		REFERENCES [dbo].[courseQuizQuestionAnswer](symbol, courseQuizQuestionId, courseQuizId, courseId)

ALTER TABLE [dbo].[courseQuizQuestionAnswer] ADD
	CONSTRAINT [fk_courseQuizQuestionAnswer_courseQuizQuestion]
		FOREIGN KEY(courseQuizQuestionId, courseQuizId, courseId)
		REFERENCES [dbo].[courseQuizQuestion](id, courseQuizId, courseId)
		ON DELETE CASCADE




IF OBJECT_ID('[dbo].[file]', 'U') IS NOT NULL
	DROP TABLE [dbo].[file]
GO

CREATE TABLE [dbo].[file]
(
	id INT IDENTITY(1, 1) NOT NULL,
	path NVARCHAR(256) NOT NULL,
	name NVARCHAR(128) NOT NULL,

	CONSTRAINT [File path is required.] CHECK(LEN(path) > 0),
	CONSTRAINT [File name is required.] CHECK(LEN(name) > 0),

	CONSTRAINT [pk_file] PRIMARY KEY(id)
);
GO


IF OBJECT_ID('[dbo].[courseSectionFile]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseSectionFile]
GO

CREATE TABLE [dbo].[courseSectionFile]
(
	id INT NOT NULL,
	courseSectionId SMALLINT NOT NULL,
	courseId INT NOT NULL,

	CONSTRAINT [fk_courseSectionFile_file] FOREIGN KEY(id) REFERENCES [dbo].[file](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_courseSectionFile_courseSection]
		FOREIGN KEY(courseSectionId, courseId) REFERENCES [dbo].[courseSection](id, courseId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseSectionFile] PRIMARY KEY(id)
);
GO


IF OBJECT_ID('[dbo].[courseExerciseSolutionFile]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseExerciseSolutionFile]
GO

CREATE TABLE [dbo].[courseExerciseSolutionFile]
(
	id INT NOT NULL,
	courseExerciseId SMALLINT NOT NULL,
	courseId INT NOT NULL,

	CONSTRAINT [fk_courseExerciseSolutionFile_file] FOREIGN KEY(id) REFERENCES [dbo].[file](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_courseExerciseSolutionFile_courseExercise]
		FOREIGN KEY(courseExerciseId, courseId) REFERENCES [dbo].[courseExercise](id, courseId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseExerciseSolutionFile] PRIMARY KEY(id)
);
GO




IF OBJECT_ID('[dbo].[courseSectionProgress]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseSectionProgress]
GO

CREATE TABLE [dbo].[courseSectionProgress]
(
	learnerId INT NOT NULL,
	courseId INT NOT NULL,
	courseSectionId SMALLINT NOT NULL,
	completionPercentage FLOAT NOT NULL DEFAULT 0,
	type CHAR(1) NOT NULL CHECK(type IN ('S', 'E')),

	CONSTRAINT [Course section completion percentage must be between 0 and 1.]
		CHECK(0 <= completionPercentage AND completionPercentage <= 1),

	CONSTRAINT [fk_courseSectionProgress_enrolledCourse]
		FOREIGN KEY(learnerId, courseId) REFERENCES [dbo].[enrolledCourse](learnerId, courseId)
		ON DELETE CASCADE,
	CONSTRAINT [fk_courseSectionProgress_courseSection]
		FOREIGN KEY(courseSectionId, courseId) REFERENCES [dbo].[courseSection](id, courseId),

	CONSTRAINT [pk_courseSectionProgress] PRIMARY KEY(learnerId, courseId, courseSectionId)
);
GO




CREATE FUNCTION [dbo].[isValidSectionProgress](
	@learnerId INT, @courseId INT, @courseSectionId INT, @type CHAR(1)
)
RETURNS BIT
AS
BEGIN
	IF (EXISTS(
		SELECT * FROM [dbo].[courseSectionProgress]
		WHERE learnerId = @learnerId AND courseId = @courseId AND courseSectionId = @courseSectionId AND type = @type
	))
		RETURN 1

	RETURN 0
END
GO

IF OBJECT_ID('[dbo].[courseExerciseProgress]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseExerciseProgress]
GO

CREATE TABLE [dbo].[courseExerciseProgress]
(
	learnerId INT NOT NULL,
	courseId INT NOT NULL,
	courseSectionId SMALLINT NOT NULL,
	savedTextSolution NVARCHAR(MAX) NOT NULL DEFAULT '',
	grade FLOAT,

	CONSTRAINT [Course exercise progress must have a corresponding course section progress.]
		CHECK([dbo].isValidSectionProgress(learnerId, courseId, courseSectionId, 'E') = 1),

	CONSTRAINT [Course exercise grade must be between 0 and 10.] CHECK(0 <= grade AND grade <= 10),

	CONSTRAINT [fk_courseExerciseProgress_courseSectionProgress] FOREIGN KEY(learnerId, courseId, courseSectionId)
		REFERENCES [dbo].[courseSectionProgress](learnerId, courseId, courseSectionId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseExerciseProgress] PRIMARY KEY(learnerId, courseId, courseSectionId)
);
GO




IF OBJECT_ID('[dbo].[chat]', 'U') IS NOT NULL
	DROP TABLE [dbo].[chat]
GO

CREATE TABLE [dbo].[chat]
(
	id INT IDENTITY(1, 1) NOT NULL,
	type CHAR(1) NOT NULL CHECK(type IN ('P', 'C')),

	CONSTRAINT [pk_chat] PRIMARY KEY(id)
);
GO




CREATE FUNCTION [dbo].[isValidChat](@id INT, @type CHAR(1))
RETURNS BIT
AS
BEGIN
	IF (EXISTS(SELECT id FROM [dbo].[chat] WHERE id = @id AND type = @type))
		RETURN 1

	RETURN 0
END
GO


IF OBJECT_ID('[dbo].[privateChat]', 'U') IS NOT NULL
	DROP TABLE [dbo].[privateChat]
GO

CREATE TABLE [dbo].[privateChat]
(
	id INT NOT NULL CHECK([dbo].[isValidChat](id, 'P') = 1),
	userId1 INT NOT NULL,
	userId2 INT NOT NULL,

	CONSTRAINT [The first id must be lexicographically smaller than the second id.] CHECK(userId1 < userId2),
	CONSTRAINT [A private chat between these two users already exists.] UNIQUE(userId1, userId2),

	CONSTRAINT [fk_privateChat_chat] FOREIGN KEY(id) REFERENCES [dbo].[chat](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_privateChat_user1] FOREIGN KEY(userId1) REFERENCES [dbo].[user](id),
	CONSTRAINT [fk_privateChat_user2] FOREIGN KEY(userId2) REFERENCES [dbo].[user](id),

	CONSTRAINT [pk_privateChat] PRIMARY KEY(id),
);
GO


IF OBJECT_ID('[dbo].[courseChat]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseChat]
GO

CREATE TABLE [dbo].[courseChat]
(
	id INT NOT NULL CHECK([dbo].[isValidChat](id, 'C') = 1),
	courseId INT NOT NULL,

	CONSTRAINT [fk_courseChat_chat] FOREIGN KEY(id) REFERENCES [dbo].[chat](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_courseChat_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_courseChat] PRIMARY KEY(id),
);
GO


IF OBJECT_ID('[dbo].[courseChatMember]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseChatMember]
GO

CREATE TABLE [dbo].[courseChatMember]
(
	userId INT NOT NULL,
	chatId INT NOT NULL,

	CONSTRAINT [fk_courseChatMember_user] FOREIGN KEY(userId) REFERENCES [dbo].[user](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_courseChatMember_chat] FOREIGN KEY(chatId) REFERENCES [dbo].[courseChat](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_courseChatMember] PRIMARY KEY(userId, chatId),
);
GO


IF OBJECT_ID('[dbo].[message]', 'U') IS NOT NULL
	DROP TABLE [dbo].[message]
GO

CREATE TABLE [dbo].[message]
(
	senderId INT NOT NULL,
	chatId INT NOT NULL,
	createdAt DATETIME NOT NULL DEFAULT GETDATE(),
	content NVARCHAR(512) NOT NULL,

	CONSTRAINT [Message content is required.] CHECK(LEN(content) > 0),

	CONSTRAINT [fk_message_user] FOREIGN KEY(senderId) REFERENCES [dbo].[user](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_message_chat] FOREIGN KEY(chatId) REFERENCES [dbo].[chat](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_message] PRIMARY KEY(senderId, chatId, createdAt),
);
GO




IF OBJECT_ID('[dbo].[notification]', 'U') IS NOT NULL
	DROP TABLE [dbo].[notification]
GO

CREATE TABLE [dbo].[notification]
(
	senderId INT NOT NULL,
	receiverId INT NOT NULL,
	createdAt DATE NOT NULL DEFAULT GETDATE(),
	title NVARCHAR(64) NOT NULL,
	content NVARCHAR(512) NOT NULL,
	expiresAt DATE NOT NULL DEFAULT GETDATE() + 4 * 7,

	CONSTRAINT [Notification title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [Notification content is required.] CHECK(LEN(content) > 0),
	CONSTRAINT [Notification expiration date must be after creation date.] CHECK(expiresAt > createdAt),

	CONSTRAINT [fk_notification_sender] FOREIGN KEY(senderId) REFERENCES [dbo].[admin](id),
	CONSTRAINT [fk_notification_receiver] FOREIGN KEY(receiverId) REFERENCES [dbo].[user](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_notification] PRIMARY KEY(senderId, receiverId, createdAt),
);
GO




IF OBJECT_ID('[dbo].[region]', 'U') IS NOT NULL
	DROP TABLE [dbo].[region]
GO

CREATE TABLE [dbo].[region]
(
	id INT IDENTITY(1, 1) NOT NULL,
	name VARCHAR(64) NOT NULL,
	CONSTRAINT [Region name is required.] CHECK(LEN(name) > 0),

	CONSTRAINT [pk_region] PRIMARY KEY(id),
);
GO


CREATE FUNCTION [dbo].[isBankAccountOwnerNotAdmin](@ownerId INT)
RETURNS BIT
AS
BEGIN
	IF (NOT EXISTS(SELECT id FROM [dbo].[admin] WHERE id = @ownerId))
		RETURN 1

	RETURN 0
END
GO

IF OBJECT_ID('[dbo].[bankAccount]', 'U') IS NOT NULL
	DROP TABLE [dbo].[bankAccount]
GO

CREATE TABLE [dbo].[bankAccount]
(
	ownerId INT NOT NULL,
	accountNumber VARCHAR(16) NOT NULL,
	goodThru DATE NOT NULL,
	cvc VARCHAR(3) NOT NULL,
	cardholderName VARCHAR(128) NOT NULL,
	regionId INT NOT NULL,
	zip VARCHAR(8) NOT NULL,
	inAppBalance MONEY NOT NULL DEFAULT 0,

	CONSTRAINT [Bank account owner cannot be an admin.] CHECK(
		[dbo].[isBankAccountOwnerNotAdmin](ownerId) = 1
	),
	CONSTRAINT [A bank account with this number already exists.] UNIQUE(accountNumber),
	CONSTRAINT [Bank account number must be 16 digits long.] CHECK(LEN(accountNumber) = 16),
	CONSTRAINT [Bank account good thru date must be after today.] CHECK(goodThru > GETDATE()),
	CONSTRAINT [Bank account CVC must be 3 digits long.] CHECK(LEN(cvc) = 3),
	CONSTRAINT [Bank account cardholder name is required.] CHECK(LEN(cardholderName) > 0),
	CONSTRAINT [Bank account zip code is required.] CHECK(LEN(zip) > 0),
	CONSTRAINT [Bank account balance must be non-negative.] CHECK(inAppBalance >= 0),

	CONSTRAINT [fk_bankAccount_user] FOREIGN KEY(ownerId) REFERENCES [dbo].[user](id)
	ON DELETE CASCADE,

	CONSTRAINT [fk_bankAccount_region] FOREIGN KEY(regionId) REFERENCES [dbo].[region](id),

	CONSTRAINT [pk_bankAccount] PRIMARY KEY(ownerId),
);
GO


IF OBJECT_ID('[dbo].[coupon]', 'U') IS NOT NULL
	DROP TABLE [dbo].[coupon]
GO

CREATE TABLE [dbo].[coupon]
(
	id SMALLINT IDENTITY(1, 1) NOT NULL,
	code VARCHAR(16) NOT NULL,
	spawnPercentage FLOAT NOT NULL,
	discountPercentage FLOAT NOT NULL,

	CONSTRAINT [Coupon code is required.] CHECK(LEN(code) > 0),
	CONSTRAINT [A coupon with this code already exists.] UNIQUE(code),
	CONSTRAINT [Coupon spawn percentage must be between 0 and 1.]
		CHECK(0 <= spawnPercentage AND spawnPercentage <= 1),
	CONSTRAINT [Coupon discount percentage must be between 0 and 1.]
		CHECK(0 <= discountPercentage AND discountPercentage <= 1),

	CONSTRAINT [pk_coupon] PRIMARY KEY(id),
);
GO


IF OBJECT_ID('[dbo].[ownedCoupon]', 'U') IS NOT NULL
	DROP TABLE [dbo].[ownedCoupon]
GO

CREATE TABLE [dbo].[ownedCoupon]
(
	ownerId INT NOT NULL,
	couponId SMALLINT NOT NULL,
	expirationDate DATE NOT NULL,

	CONSTRAINT [Coupon expiration date must be after today.] CHECK(expirationDate > GETDATE()),

	CONSTRAINT [fk_ownedCoupon_owner] FOREIGN KEY(ownerId) REFERENCES [dbo].[learner](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_ownedCoupon_coupon] FOREIGN KEY(couponId) REFERENCES [dbo].[coupon](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_ownedCoupon] PRIMARY KEY(ownerId, couponId),
);
GO


IF OBJECT_ID('[dbo].[transaction]', 'U') IS NOT NULL
	DROP TABLE [dbo].[transaction]
GO

CREATE TABLE [dbo].[transaction]
(
	initiatorId INT,
	receiverId INT,
	courseId INT,
	createdAt DATETIME NOT NULL DEFAULT GETDATE(),
	paidAmount MONEY NOT NULL,
	taxPercentage FLOAT NOT NULL,
	transactionFee MONEY NOT NULL,
	sharePercentage FLOAT NOT NULL,
	discountPercentage FLOAT NOT NULL,
	netAmount MONEY NOT NULL,
	revenue MONEY NOT NULL,

	CONSTRAINT [Transaction details cannot be all empty.]
		CHECK(initiatorId IS NOT NULL OR receiverId IS NOT NULL OR courseId IS NOT NULL),
	CONSTRAINT [Transaction creation date must be before today.] CHECK(createdAt <= GETDATE()),
	CONSTRAINT [Transaction tax percentage must be between 0 and 1.] CHECK(0 <= taxPercentage AND taxPercentage <= 1),
	CONSTRAINT [Transaction fee must be non-negative.] CHECK(transactionFee >= 0),
	CONSTRAINT [Transaction share percentage must be between 0 and 1.] CHECK(0 <= sharePercentage AND sharePercentage <= 1),
	CONSTRAINT [Transaction discount percentage must be between 0 and 1.] CHECK(0 <= discountPercentage AND discountPercentage <= 1),
	CONSTRAINT [Transaction net amount must be non-negative.] CHECK(netAmount >= 0),
	CONSTRAINT [Transaction revenue must be non-negative.] CHECK(revenue >= 0),

	CONSTRAINT [fk_transaction_initiator] FOREIGN KEY(initiatorId) REFERENCES [dbo].[learner](id),
	CONSTRAINT [fk_transaction_receiver] FOREIGN KEY(receiverId) REFERENCES [dbo].[lecturer](id),
	CONSTRAINT [fk_transaction_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id),

	CONSTRAINT [pk_transaction] PRIMARY KEY(initiatorId, receiverId, courseId, createdAt)
);
GO