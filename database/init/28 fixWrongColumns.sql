--Transaction
UPDATE [dbo].[course]
SET price = price / 1000
WHERE price > 100000;
GO

UPDATE [dbo].[course]
SET price = price / 100
WHERE price > 10000;
GO

UPDATE [dbo].[course]
SET price = price * 10
WHERE price > 10 AND price < 100;
GO

UPDATE [dbo].[transaction]
SET paidAmount = (SELECT price FROM [dbo].[course] c WHERE courseId = c.id);
GO

UPDATE [dbo].[transactionFixed]
SET paidAmount = (SELECT price FROM [dbo].[course] c WHERE courseId = c.id);
GO

--Course
--raterCount
UPDATE [dbo].[course]
SET raterCount = (SELECT COUNT(*) FROM [dbo].[courseReview] cr WHERE id = cr.courseId)

UPDATE [dbo].[course]
SET rating = ISNULL(
                (SELECT AVG(rating) 
                 FROM [dbo].[courseReview] cr 
                 WHERE [dbo].[course].id = cr.courseId), 0
             );
GO

--lecturerCount
UPDATE [dbo].[course]
SET lecturerCount = (SELECT COUNT(ownerId) FROM [dbo].[ownedCourse] own WHERE id = own.courseId)

--learnerCount
UPDATE [dbo].[course]
SET learnerCount = (SELECT COUNT(DISTINCT initiatorId) FROM [dbo].[transaction] trans WHERE id = trans.courseId)

--minutesToComplete
UPDATE [dbo].[course]
SET minutesToComplete = ISNULL((SELECT SUM(durationInMinutes) 
								FROM [dbo].[courseLesson] cl 
								WHERE [dbo].[course].id = cl.courseId), 0);

--Category
--monthlyCourseIncome
UPDATE [dbo].[category]
SET monthlyRevenueGenerated = (SELECT SUM(mci.income) FROM [dbo].[courseCategory] cc
							JOIN [dbo].[monthlyCourseIncome] mci ON cc.courseId = mci.courseId
							WHERE cc.categoryId = [dbo].[category].[id])

--courseCount
ALTER TABLE [dbo].[category]
DROP COLUMN [courseCount];

ALTER TABLE [dbo].[category] ADD courseCount AS [dbo].[getCategoryCourseCount](id)
GO

--learnerCount
ALTER TABLE [dbo].[category]
DROP COLUMN [learnerCount];

ALTER TABLE [dbo].[category] ADD learnerCount AS [dbo].[getCategoryLearnerCount](id)
GO

--rating
ALTER TABLE [dbo].[category]
DROP COLUMN [rating];

ALTER TABLE [dbo].[category] ADD rating AS [dbo].[getCategoryRating](id)
GO

--monthlyRevenueGenerated
ALTER TABLE [dbo].[category]
DROP COLUMN [monthlyRevenueGenerated];

ALTER TABLE [dbo].[category] ADD monthlyRevenueGenerated AS [dbo].[getCategoryMonthlyRevenueGenerated](id)
GO

