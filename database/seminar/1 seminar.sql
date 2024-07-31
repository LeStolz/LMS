USE [LMS]
GO

CREATE OR ALTER PROCEDURE searchCourse @title NVARCHAR(256)
WITH RECOMPILE
AS 
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	SELECT * 
	FROM [dbo].[course] c
	LEFT JOIN [dbo].[ownedCourse] oc on oc.courseId = c.id
	LEFT JOIN [dbo].[courseSection] cs on cs.courseId = c.id
	LEFT JOIN [dbo].[courseCategory] cc on cc.courseId = c.id
	WHERE c.title LIKE '%'+ @title +'%' OR c.subtitle LIKE '%'+ @title +'%'
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
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	
	IF NOT EXISTS (
		SELECT *
		FROM [dbo].[course]
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