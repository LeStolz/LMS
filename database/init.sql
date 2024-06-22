-- Create the database
USE master
GO

IF EXISTS (SELECT name
FROM sys.databases
WHERE name = N'lms')
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
	email VARCHAR(256) NOT NULL,
	password VARCHAR(128) NOT NULL,
	name NVARCHAR(128) NOT NULL,

	CONSTRAINT [User email format is invalid.] CHECK(email LIKE '%_@__%.__%'),
	CONSTRAINT [User password must be at least 5 characters long.] CHECK(LEN(password) > 4),
	CONSTRAINT [User name is required.] CHECK(LEN(name) > 0),

	CONSTRAINT [pk_user] PRIMARY KEY(email)
);
GO




IF OBJECT_ID('[dbo].[admin]', 'U') IS NOT NULL
	DROP TABLE [dbo].[admin]
GO

CREATE TABLE [dbo].[admin]
(
	email VARCHAR(256) NOT NULL,

	CONSTRAINT [fk_admin_user] FOREIGN KEY(email) REFERENCES [dbo].[user](email)
	ON DELETE CASCADE,
	CONSTRAINT [pk_admin] PRIMARY KEY(email)
);
GO




IF OBJECT_ID('[dbo].[learner]', 'U') IS NOT NULL
	DROP TABLE [dbo].[learner]
GO

CREATE TABLE [dbo].[learner]
(
	email VARCHAR(256) NOT NULL,

	CONSTRAINT [fk_learner_user] FOREIGN KEY(email) REFERENCES [dbo].[user](email)
	ON DELETE CASCADE,
	CONSTRAINT [pk_learner] PRIMARY KEY(email)
);
GO




IF OBJECT_ID('[dbo].[lecturer]', 'U') IS NOT NULL
	DROP TABLE [dbo].[lecturer]
GO

CREATE TABLE [dbo].[lecturer]
(
	email VARCHAR(256) NOT NULL,
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

	CONSTRAINT [fk_lecturer_user] FOREIGN KEY(email) REFERENCES [dbo].[user](email)
	ON DELETE CASCADE,
	CONSTRAINT [pk_lecturer] PRIMARY KEY(email)
);
GO


IF OBJECT_ID('[dbo].[certificate]', 'U') IS NOT NULL
	DROP TABLE [dbo].[certificate]
GO

CREATE TABLE [dbo].[certificate]
(
	lecturerEmail VARCHAR(256) NOT NULL,
	title NVARCHAR(128) NOT NULL,
	image NVARCHAR(256) NOT NULL,

	CONSTRAINT [Certificate title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [Certificate image is required.] CHECK(LEN(image) > 0),

	CONSTRAINT [fk_certificate_lecturer] FOREIGN KEY(lecturerEmail) REFERENCES [dbo].[lecturer](email)
	ON DELETE CASCADE,
	CONSTRAINT [pk_certificate] PRIMARY KEY(lecturerEmail, title)
);
GO


IF OBJECT_ID('[dbo].[workExperience]', 'U') IS NOT NULL
	DROP TABLE [dbo].[workExperience]
GO

CREATE TABLE [dbo].[workExperience]
(
	lecturerEmail VARCHAR(256) NOT NULL,
	topic NVARCHAR(128) NOT NULL,
	role NVARCHAR(128) NOT NULL,
	organizationName NVARCHAR(128) NOT NULL,
	fromDate DATE NOT NULL,
	toDate DATE NOT NULL,

	CONSTRAINT [Work experience topic is required.] CHECK(LEN(topic) > 0),
	CONSTRAINT [Work experience role is required.] CHECK(LEN(role) > 0),
	CONSTRAINT [Work experience organization name is required.] CHECK(LEN(organizationName) > 0),
	CONSTRAINT [Work experience from date must be before to date.] CHECK(fromDate <= toDate),

	CONSTRAINT [fk_workExperience_lecturer] FOREIGN KEY(lecturerEmail) REFERENCES [dbo].[lecturer](email)
	ON DELETE CASCADE,
	CONSTRAINT [pk_workExperience] PRIMARY KEY(lecturerEmail, topic)
);
GO




IF OBJECT_ID('[dbo].[category]', 'U') IS NOT NULL
	DROP TABLE [dbo].[category]
GO

CREATE TABLE [dbo].[category]
(
	id INT IDENTITY(1, 1) NOT NULL,
	title NVARCHAR(64) NOT NULL,
	courseCount INT NOT NULL DEFAULT(0),
	learnerCount INT NOT NULL DEFAULT(0),
	rating FLOAT NOT NULL DEFAULT(0),
	monthlyRevenueGenerated MONEY NOT NULL DEFAULT(0),
	parentId INT DEFAULT(NULL),

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
	description NVARCHAR(512) NOT NULL,
	price MONEY NOT NULL,
	level CHAR(1) NOT NULL,
	thumbnail NVARCHAR(256) NOT NULL,
	advertisementVideo NVARCHAR(256),
	status CHAR(1) NOT NULL,
	createdAt DATE NOT NULL DEFAULT(GETDATE()),
	visitorCount INT NOT NULL DEFAULT(0),
	rating FLOAT NOT NULL DEFAULT(0),
	raterCount INT NOT NULL DEFAULT(0),
	learnerCount INT NOT NULL DEFAULT(0),
	lecturerCount INT NOT NULL DEFAULT(0),
	minutesToComplete INT NOT NULL DEFAULT(0),
	updatedAt DATE NOT NULL DEFAULT(GETDATE()),
	monthlyRevenueGenerated MONEY NOT NULL DEFAULT(0),

	CONSTRAINT [Course title is required and must not be longer than 60.] CHECK(0 < LEN(title) AND LEN(title) <= 60),
	CONSTRAINT [A course with this title already exists.] UNIQUE(title),
	CONSTRAINT [Course subtitle is required and must not be longer than 120.] CHECK(0 < LEN(subtitle) AND LEN(subtitle) <= 120),
	CONSTRAINT [Course description is must be longer than 200.] CHECK(LEN(description) > 200),
	CONSTRAINT [Course price must be non-negative.] CHECK(price >= 0),
	CONSTRAINT [Course level is required.] CHECK(level IN ('B', 'I', 'A')),
	CONSTRAINT [Course thumbnail is required.] CHECK(LEN(thumbnail) > 0),
	CONSTRAINT [Course status is required.] CHECK(status IN ('R', 'P', 'V')),
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
	categoryId INT NOT NULL,

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
	type VARCHAR(16) NOT NULL,

	CONSTRAINT [Course description detail type is required.]
		CHECK(type IN ('PREREQUISITE', 'OBJECTIVE', 'SKILL', 'TARGET_USER', 'LANGUAGE')),
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
	ownerEmail VARCHAR(256) NOT NULL,
	courseId INT NOT NULL,
	sharePercentage FLOAT NOT NULL,

	CONSTRAINT [Course share percentage must be non-negative.] CHECK(sharePercentage >= 0),

	CONSTRAINT [fk_ownedCourse_owner] FOREIGN KEY(ownerEmail) REFERENCES [dbo].[lecturer](email)
	ON DELETE CASCADE,
	CONSTRAINT [fk_ownedCourse_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_ownedCourse] PRIMARY KEY(ownerEmail, courseId),
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
	senderEmail VARCHAR(256),
	courseId INT NOT NULL,
	createdAt DATE NOT NULL DEFAULT GETDATE(),
	title NVARCHAR(64) NOT NULL,
	content NVARCHAR(512) NOT NULL,

	CONSTRAINT [Course announcement created at must be before today.] CHECK(createdAt <= GETDATE()),
	CONSTRAINT [Course announcement title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [Course announcement content is required.] CHECK(LEN(content) > 0),

	CONSTRAINT [fk_courseAnnouncement_sender] FOREIGN KEY(senderEmail) REFERENCES [dbo].[lecturer](email),
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
	learnerEmail VARCHAR(256),
	courseId INT NOT NULL,
	createdAt DATETIME NOT NULL DEFAULT(GETDATE()),
	rating TINYINT NOT NULL,
	content NVARCHAR(512),

	CONSTRAINT [Course review created at must be before today.] CHECK(createdAt <= GETDATE()),
	CONSTRAINT [Course review rating must be between 1 and 5.] CHECK(rating BETWEEN 1 AND 5),

	CONSTRAINT [fk_courseReview_learner] FOREIGN KEY(learnerEmail) REFERENCES [dbo].[learner](email),
	CONSTRAINT [fk_courseReview_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_courseReview] PRIMARY KEY(learnerEmail, courseId, createdAt)
);
GO


IF OBJECT_ID('[dbo].[enrolledCourse]', 'U') IS NOT NULL
	DROP TABLE [dbo].[enrolledCourse]
GO

CREATE TABLE [dbo].[enrolledCourse]
(
	learnerEmail VARCHAR(256) NOT NULL,
	courseId INT NOT NULL,
	status CHAR(1) NOT NULL,

	CONSTRAINT [Enrolled course status is required.] CHECK(status IN ('B', 'L', 'F')),

	CONSTRAINT [fk_enrolledCourse_learner] FOREIGN KEY(learnerEmail) REFERENCES [dbo].[learner](email)
	ON DELETE CASCADE,
	CONSTRAINT [fk_enrolledCourse_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_enrolledCourse] PRIMARY KEY(learnerEmail, courseId)
);
GO


IF OBJECT_ID('[dbo].[courseSection]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseSection]
GO

CREATE TABLE [dbo].[courseSection]
(
	id INT NOT NULL,
	courseId INT NOT NULL,
	nextCourseSectionId INT DEFAULT(NULL),
	title NVARCHAR(64) NOT NULL,
	description NVARCHAR(512) NOT NULL,

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


IF OBJECT_ID('[dbo].[courseLesson]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseLesson]
GO

CREATE TABLE [dbo].[courseLesson]
(
	id INT NOT NULL,
	courseId INT NOT NULL,
	isFree BIT NOT NULL DEFAULT 0,
	durationInMinutes TINYINT NOT NULL,

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
	id INT NOT NULL,
	courseId INT NOT NULL,

	CONSTRAINT [fk_courseExercise_courseSection]
		FOREIGN KEY(id, courseId) REFERENCES [dbo].[courseSection](id, courseId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseExercise] PRIMARY KEY(id, courseId)
);
GO


IF OBJECT_ID('[dbo].[courseQuiz]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseQuiz]
GO

CREATE TABLE [dbo].[courseQuiz]
(
	id INT NOT NULL,
	courseId INT NOT NULL,
	durationInMinutes TINYINT NOT NULL,

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
	id INT NOT NULL,
	courseQuizId INT NOT NULL,
	courseId INT NOT NULL,
	question NVARCHAR(512) NOT NULL,
	correctAnswerIndex TINYINT NOT NULL,

	CONSTRAINT [Course quiz question is required.] CHECK(LEN(question) > 0),
	CONSTRAINT [Course quiz question's correct answer must be non-negative.] CHECK(correctAnswerIndex >= 0),

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
	courseQuizQuestionId INT NOT NULL,
	courseQuizId INT NOT NULL,
	courseId INT NOT NULL,
	symbol CHAR(1) NOT NULL,
	answer NVARCHAR(256) NOT NULL,

	CONSTRAINT [Course quiz question answer symbol is required.] CHECK(LEN(symbol) = 1),
	CONSTRAINT [Course quiz answer is required.] CHECK(LEN(answer) > 0),

	CONSTRAINT [fk_courseQuizQuestionAnswer_courseQuizQuestion]
		FOREIGN KEY(courseQuizQuestionId, courseQuizId, courseId)
		REFERENCES [dbo].[courseQuizQuestion](id, courseQuizId, courseId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseQuizQuestionAnswer] PRIMARY KEY(symbol, courseQuizQuestionId, courseQuizId, courseId)
);
GO




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
	courseSectionId INT NOT NULL,
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
	courseExerciseId INT NOT NULL,
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
	learnerEmail VARCHAR(256) NOT NULL,
	courseId INT NOT NULL,
	courseSectionId INT NOT NULL,
	completionPercentage FLOAT NOT NULL DEFAULT 0,

	CONSTRAINT [Course section completion percentage must be between 0 and 1.]
		CHECK(0 <= completionPercentage AND completionPercentage <= 1),

	CONSTRAINT [fk_courseSectionProgress_enrolledCourse]
		FOREIGN KEY(learnerEmail, courseId) REFERENCES [dbo].[enrolledCourse](learnerEmail, courseId)
		ON DELETE CASCADE,
	CONSTRAINT [fk_courseSectionProgress_courseSection]
		FOREIGN KEY(courseSectionId, courseId) REFERENCES [dbo].[courseSection](id, courseId),

	CONSTRAINT [pk_courseSectionProgress] PRIMARY KEY(learnerEmail, courseId, courseSectionId)
);
GO


IF OBJECT_ID('[dbo].[courseExerciseProgress]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseExerciseProgress]
GO

CREATE TABLE [dbo].[courseExerciseProgress]
(
	learnerEmail VARCHAR(256) NOT NULL,
	courseId INT NOT NULL,
	courseSectionId INT NOT NULL,
	savedTextSolution NVARCHAR(MAX) NOT NULL DEFAULT '',
	grade FLOAT,

	CONSTRAINT [Course exercise grade must be between 0 and 10.] CHECK(0 <= grade AND grade <= 10),

	CONSTRAINT [fk_courseExerciseProgress_courseSectionProgress] FOREIGN KEY(learnerEmail, courseId, courseSectionId)
		REFERENCES [dbo].[courseSectionProgress](learnerEmail, courseId, courseSectionId)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseExerciseProgress] PRIMARY KEY(learnerEmail, courseId, courseSectionId)
);
GO




IF OBJECT_ID('[dbo].[chat]', 'U') IS NOT NULL
	DROP TABLE [dbo].[chat]
GO

CREATE TABLE [dbo].[chat]
(
	id INT IDENTITY(1, 1) NOT NULL,

	CONSTRAINT [pk_chat] PRIMARY KEY(id)
);
GO


IF OBJECT_ID('[dbo].[privateChat]', 'U') IS NOT NULL
	DROP TABLE [dbo].[privateChat]
GO

CREATE TABLE [dbo].[privateChat]
(
	id INT NOT NULL,
	email1 VARCHAR(256) NOT NULL,
	email2 VARCHAR(256) NOT NULL,

	CONSTRAINT [The first email must be lexicographically smaller than the second email.] CHECK(email1 < email2),
	CONSTRAINT [A private chat between these two users already exists.] UNIQUE(email1, email2),

	CONSTRAINT [fk_privateChat_chat] FOREIGN KEY(id) REFERENCES [dbo].[chat](id)
	ON DELETE CASCADE,
	CONSTRAINT [fk_privateChat_user1] FOREIGN KEY(email1) REFERENCES [dbo].[user](email),
	CONSTRAINT [fk_privateChat_user2] FOREIGN KEY(email2) REFERENCES [dbo].[user](email),

	CONSTRAINT [pk_privateChat] PRIMARY KEY(id),
);
GO


IF OBJECT_ID('[dbo].[courseChat]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseChat]
GO

CREATE TABLE [dbo].[courseChat]
(
	id INT NOT NULL,
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
	userEmail VARCHAR(256) NOT NULL,
	chatId INT NOT NULL,

	CONSTRAINT [fk_courseChatMember_user] FOREIGN KEY(userEmail) REFERENCES [dbo].[user](email)
	ON DELETE CASCADE,
	CONSTRAINT [fk_courseChatMember_chat] FOREIGN KEY(chatId) REFERENCES [dbo].[courseChat](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_courseChatMember] PRIMARY KEY(userEmail, chatId),
);
GO


IF OBJECT_ID('[dbo].[message]', 'U') IS NOT NULL
	DROP TABLE [dbo].[message]
GO

CREATE TABLE [dbo].[message]
(
	senderEmail VARCHAR(256) NOT NULL,
	chatId INT NOT NULL,
	createdAt DATETIME NOT NULL DEFAULT GETDATE(),
	content NVARCHAR(512) NOT NULL,

	CONSTRAINT [Message content is required.] CHECK(LEN(content) > 0),

	CONSTRAINT [fk_message_user] FOREIGN KEY(senderEmail) REFERENCES [dbo].[user](email)
	ON DELETE CASCADE,
	CONSTRAINT [fk_message_chat] FOREIGN KEY(chatId) REFERENCES [dbo].[chat](id)
	ON DELETE CASCADE,
	CONSTRAINT [pk_message] PRIMARY KEY(senderEmail, chatId, createdAt),
);
GO




IF OBJECT_ID('[dbo].[notification]', 'U') IS NOT NULL
	DROP TABLE [dbo].[notification]
GO

CREATE TABLE [dbo].[notification]
(
	senderEmail VARCHAR(256) NOT NULL,
	receiverEmail VARCHAR(256) NOT NULL,
	createdAt DATE NOT NULL DEFAULT GETDATE(),
	title NVARCHAR(64) NOT NULL,
	content NVARCHAR(512) NOT NULL,
	expiresAt DATE NOT NULL DEFAULT GETDATE() + 4 * 7,

	CONSTRAINT [Notification title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [Notification content is required.] CHECK(LEN(content) > 0),
	CONSTRAINT [Notification expiration date must be after creation date.] CHECK(expiresAt > createdAt),

	CONSTRAINT [fk_notification_sender] FOREIGN KEY(senderEmail) REFERENCES [dbo].[admin](email),
	CONSTRAINT [fk_notification_receiver] FOREIGN KEY(receiverEmail) REFERENCES [dbo].[user](email)
	ON DELETE CASCADE,
	CONSTRAINT [pk_notification] PRIMARY KEY(senderEmail, receiverEmail, createdAt),
);
GO




CREATE FUNCTION [dbo].[isBankAccountOwnerNotAdmin](@ownerEmail VARCHAR(256))
RETURNS BIT
AS
BEGIN
	IF (NOT EXISTS(SELECT email FROM [dbo].[admin] WHERE email = @ownerEmail))
		RETURN 1

	RETURN 0
END
GO

IF OBJECT_ID('[dbo].[bankAccount]', 'U') IS NOT NULL
	DROP TABLE [dbo].[bankAccount]
GO

CREATE TABLE [dbo].[bankAccount]
(
	ownerEmail VARCHAR(256) NOT NULL,
	accountNumber VARCHAR(16) NOT NULL,
	goodThru DATE NOT NULL,
	cvc VARCHAR(3) NOT NULL,
	cardholderName VARCHAR(128) NOT NULL,
	region VARCHAR(64) NOT NULL,
	zip VARCHAR(16) NOT NULL,
	inAppBalance MONEY NOT NULL DEFAULT 0,

	CONSTRAINT [Bank account owner cannot be an admin.] CHECK(
		[dbo].[isBankAccountOwnerNotAdmin](ownerEmail) = 1
	),
	CONSTRAINT [Bank account number must be 16 digits long.] CHECK(LEN(accountNumber) = 16),
	CONSTRAINT [Bank account good thru date must be after today.] CHECK(goodThru > GETDATE()),
	CONSTRAINT [Bank account CVC must be 3 digits long.] CHECK(LEN(cvc) = 3),
	CONSTRAINT [Bank account cardholder name is required.] CHECK(LEN(cardholderName) > 0),
	CONSTRAINT [Bank account region is required.] CHECK(LEN(region) > 0),
	CONSTRAINT [Bank account zip code is required.] CHECK(LEN(zip) > 0),
	CONSTRAINT [Bank account balance must be non-negative.] CHECK(inAppBalance >= 0),

	CONSTRAINT [fk_bankAccount_user] FOREIGN KEY(ownerEmail) REFERENCES [dbo].[user](email)
	ON DELETE CASCADE,

	CONSTRAINT [pk_bankAccount] PRIMARY KEY(ownerEmail, accountNumber),
);
GO


IF OBJECT_ID('[dbo].[coupon]', 'U') IS NOT NULL
	DROP TABLE [dbo].[coupon]
GO

CREATE TABLE [dbo].[coupon]
(
	id INT IDENTITY(1, 1) NOT NULL,
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
	ownerEmail VARCHAR(256) NOT NULL,
	couponId INT NOT NULL,
	expirationDate DATE NOT NULL,

	CONSTRAINT [Coupon expiration date must be after today.] CHECK(expirationDate > GETDATE()),

	CONSTRAINT [fk_ownedCoupon_owner] FOREIGN KEY(ownerEmail) REFERENCES [dbo].[learner](email)
	ON DELETE CASCADE,
	CONSTRAINT [fk_ownedCoupon_coupon] FOREIGN KEY(couponId) REFERENCES [dbo].[coupon](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_ownedCoupon] PRIMARY KEY(ownerEmail, couponId),
);
GO


IF OBJECT_ID('[dbo].[transaction]', 'U') IS NOT NULL
	DROP TABLE [dbo].[transaction]
GO

CREATE TABLE [dbo].[transaction]
(
	initiatorEmail VARCHAR(256),
	receiverEmail VARCHAR(256),
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
		CHECK(initiatorEmail IS NOT NULL OR receiverEmail IS NOT NULL OR courseId IS NOT NULL),
	CONSTRAINT [Transaction creation date must be before today.] CHECK(createdAt <= GETDATE()),
	CONSTRAINT [Transaction tax percentage must be between 0 and 1.] CHECK(0 <= taxPercentage AND taxPercentage <= 1),
	CONSTRAINT [Transaction fee must be non-negative.] CHECK(transactionFee >= 0),
	CONSTRAINT [Transaction share percentage must be between 0 and 1.] CHECK(0 <= sharePercentage AND sharePercentage <= 1),
	CONSTRAINT [Transaction discount percentage must be between 0 and 1.] CHECK(0 <= discountPercentage AND discountPercentage <= 1),
	CONSTRAINT [Transaction net amount must be non-negative.] CHECK(netAmount >= 0),
	CONSTRAINT [Transaction revenue must be non-negative.] CHECK(revenue >= 0),

	CONSTRAINT [fk_transaction_initiator] FOREIGN KEY(initiatorEmail) REFERENCES [dbo].[learner](email),
	CONSTRAINT [fk_transaction_receiver] FOREIGN KEY(receiverEmail) REFERENCES [dbo].[lecturer](email),
	CONSTRAINT [fk_transaction_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id),

	CONSTRAINT [pk_transaction] PRIMARY KEY(initiatorEmail, receiverEmail, courseId, createdAt)
);
GO




-- Create the procedures
CREATE OR ALTER PROCEDURE [dbo].[selectUserByCred]
	@email VARCHAR(256),
	@password VARCHAR(128)
AS
BEGIN TRANSACTION
SET XACT_ABORT ON
SET NOCOUNT ON

IF @email IS NULL OR @password IS NULL
BEGIN;
	THROW 51000, 'Email and password are required.', 1;
END

SELECT *
FROM [dbo].[user]
WHERE email = @email AND password = @password
COMMIT TRANSACTION
GO




CREATE OR ALTER PROCEDURE [dbo].[insertUser]
	@email VARCHAR(256),
	@password VARCHAR(128),
	@name NVARCHAR(128)
AS
BEGIN TRANSACTION
SET XACT_ABORT ON
SET NOCOUNT ON

IF @email IS NULL OR @password IS NULL OR @name IS NULL
	BEGIN;
	THROW 51000, 'Email, password, and name are required.', 1;
END

INSERT INTO [dbo].[user]
VALUES(@email, @password, @name)

SELECT *
FROM [dbo].[user]
WHERE email = @email AND password = @password
COMMIT TRANSACTION
GO