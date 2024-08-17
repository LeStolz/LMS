IF OBJECT_ID('[dbo].[courseSectionFileFixed]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseSectionFileFixed]
GO

CREATE TABLE [dbo].[courseSectionFileFixed]
(
    id INT IDENTITY(1, 1) NOT NULL,
	courseSectionId SMALLINT NOT NULL,
	courseId INT NOT NULL,
	path NVARCHAR(256) NOT NULL,
	name NVARCHAR(128) NOT NULL,

	CONSTRAINT [Fixed File path is required.] CHECK(LEN(path) > 0),
	CONSTRAINT [Fixed File name is required.] CHECK(LEN(name) > 0),

	CONSTRAINT [fk_courseSectionFileFixed_courseSection]
		FOREIGN KEY(courseId, courseSectionId) REFERENCES [dbo].[courseSection](courseId, id)
		ON DELETE CASCADE,

	CONSTRAINT [pk_courseSectionFileFixed] PRIMARY KEY(id)
);
GO


IF OBJECT_ID('[dbo].[courseReviewFixed]', 'U') IS NOT NULL
	DROP TABLE [dbo].[courseReviewFixed]
GO

CREATE TABLE [dbo].[courseReviewFixed]
(
	learnerId INT,
	courseId INT NOT NULL,
	createdAt DATETIME NOT NULL DEFAULT(GETDATE()),
	rating TINYINT NOT NULL,
	content NVARCHAR(512),
    email VARCHAR(256) NOT NULL,
    name NVARCHAR(128) NOT NULL,

    CONSTRAINT [Fixed User email format is invalid.] CHECK(email LIKE '%_@__%.__%'),
	CONSTRAINT [Fixed A user with this email already exists.] UNIQUE(email),
	CONSTRAINT [Fixed User name is required.] CHECK(LEN(name) > 0),

	CONSTRAINT [Fixed Course review created at must be before today.] CHECK(createdAt <= GETDATE()),
	CONSTRAINT [Fixed Course review rating must be between 1 and 5.] CHECK(rating BETWEEN 1 AND 5),

	CONSTRAINT [fk_courseReviewFixed_learner] FOREIGN KEY(learnerId) REFERENCES [dbo].[learner](id),
	CONSTRAINT [fk_courseReviewFixed_course] FOREIGN KEY(courseId) REFERENCES [dbo].[course](id)
	ON DELETE CASCADE,

	CONSTRAINT [pk_courseReviewFixed] PRIMARY KEY(learnerId, courseId, createdAt)
);
GO