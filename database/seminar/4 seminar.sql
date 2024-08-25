USE [LMS]
GO

CREATE OR ALTER PROCEDURE searchCourse @title NVARCHAR(256)
WITH RECOMPILE
AS 
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	DECLARE @str nvarchar(256)
	SET @str = @title + '*'

	SELECT * 
	FROM [dbo].[course] c
	LEFT JOIN [dbo].[ownedCourse] oc on oc.courseId = c.id
	LEFT JOIN [dbo].[courseSection] cs on cs.courseId = c.id
	LEFT JOIN [dbo].[courseCategory] cc on cc.courseId = c.id
	WHERE CONTAINS(c.title, @str) OR CONTAINS(c.subtitle, @str)
	ORDER BY c.rating

	CHECKPOINT;
	DBCC DROPCLEANBUFFERS;
COMMIT TRAN;
GO

CREATE OR ALTER PROCEDURE updateCourseSubtitle
	@subtitle NVARCHAR(256),
	@id INT
AS
BEGIN TRAN
	IF NOT EXISTS (
		SELECT *
		FROM [dbo].[course]
		WITH (UPDLOCK)
		WHERE id = @id
	)
	BEGIN;
		THROW 51000, 'Course does not exist.', 1;
	END;

	WAITFOR DELAY '00:00:01'

	UPDATE [dbo].[course]
	SET subtitle = @subtitle
	WHERE id LIKE @id
COMMIT TRAN;
GO
