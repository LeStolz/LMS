CREATE OR ALTER PROCEDURE RandomizeCourseSectionFileFixed
AS
BEGIN
    SET NOCOUNT ON;

    SET IDENTITY_INSERT [dbo].[courseSectionFileFixed] ON;

    INSERT INTO [dbo].[courseSectionFileFixed] (id, courseSectionId, courseId, path, name)
    SELECT 
        csf.id, 
        csf.courseSectionId, 
        csf.courseId, 
        f.path, 
        f.name
    FROM 
        [dbo].[courseSectionFile] csf
    JOIN 
        [dbo].[file] f ON csf.id = f.id;

    SET IDENTITY_INSERT [dbo].[courseSectionFileFixed] ON;
END;
GO


CREATE OR ALTER PROCEDURE RandomizeCourseReviewFixed
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[courseReviewFixed] (learnerId, courseId, createdAt, rating, content, email, name)
    SELECT 
        cr.learnerId, 
        cr.courseId, 
        cr.createdAt, 
        cr.rating, 
        cr.content, 
        u.email, 
        u.name
    FROM 
        [dbo].[user] u
    JOIN 
        [dbo].[courseReview] cr ON cr.learnerId = u.id;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[updateUserFixed]
	@id INT,
	@oldPassword VARCHAR(128),
	@password VARCHAR(128),
	@name NVARCHAR(128)
AS
BEGIN TRANSACTION
	SET XACT_ABORT ON
	SET NOCOUNT ON

	IF @oldPassword <> (SELECT password FROM [dbo].[user] WHERE id = @id)
	BEGIN;
		THROW 51000, 'Incorrect password.', 1;
	END

	UPDATE [dbo].[user]
	SET password = @password, name = @name
	WHERE id = @id

	UPDATE [dbo].[courseReviewFixed]
	SET name = @name, email = (SELECT email FROM [dbo].[user] WHERE id = @id)
	WHERE learnerId = @id
COMMIT TRANSACTION
GO

exec RandomizeCourseSectionFileFixed;
exec RandomizeCourseReviewFixed;
