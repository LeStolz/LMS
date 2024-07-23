USE [LMS]
GO

CREATE OR ALTER PROCEDURE searchCourse @title NVARCHAR(256)
AS
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	SELECT *
	FROM [dbo].[course]
	WHERE title LIKE '%'+ @title +'%'
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

INSERT INTO [dbo].[course] ([title], [subtitle], [status]) VALUES
('1', '1', 'C');
INSERT INTO [dbo].[course] ([title], [subtitle], [status]) VALUES
('2', '2', 'C');
INSERT INTO [dbo].[course] ([title], [subtitle], [status]) VALUES
('3', '3', 'C');