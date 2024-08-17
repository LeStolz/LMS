--User
ALTER TABLE [dbo].[User] DROP CONSTRAINT [pk_user];
ALTER TABLE [dbo].[User] DROP CONSTRAINT [A user with this email already exists.];
ALTER TABLE [dbo].[User] DROP CONSTRAINT [User email format is invalid.];
ALTER TABLE [dbo].[User] DROP CONSTRAINT [User password must be at least 5 characters long.];
ALTER TABLE [dbo].[User] DROP CONSTRAINT [User name is required.];


CREATE PARTITION FUNCTION pf_UserId(int)
AS RANGE LEFT FOR VALUES (20000, 40000, 60000, 80000, 100000);

CREATE PARTITION SCHEME ps_UserId
AS PARTITION pf_UserId
TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY]);


CREATE CLUSTERED INDEX IX_User_Id
ON [dbo].[User] (id)
ON ps_UserId(id);


ALTER TABLE [dbo].[User]
ADD CONSTRAINT [pk_user] PRIMARY KEY CLUSTERED (id) ON ps_UserId(id);

ALTER TABLE [dbo].[User]
ADD CONSTRAINT [A user with this email already exists.] UNIQUE(email);

ALTER TABLE [dbo].[User]
ADD CONSTRAINT [User email format is invalid.] CHECK(email LIKE '%_@__%.__%');

ALTER TABLE [dbo].[User]
ADD CONSTRAINT [User password must be at least 5 characters long.] CHECK(LEN(password) > 4);

ALTER TABLE [dbo].[User]
ADD CONSTRAINT [User name is required.] CHECK(LEN(name) > 0);

--bankAccount
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [pk_bankAccount];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [A bank account with this number already exists.];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [Bank account owner cannot be an admin.];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [Bank account number must be 16 digits long.];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [Bank account good thru date must be after today.];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [Bank account CVC must be 3 digits long.];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [Bank account cardholder name is required.];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [Bank account zip code is required.];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [Bank account balance must be non-negative.];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [fk_bankAccount_user];
ALTER TABLE [dbo].[bankAccount] DROP CONSTRAINT [fk_bankAccount_region];


CREATE PARTITION FUNCTION pf_ownerIdRange(int)
AS RANGE LEFT FOR VALUES (1000000, 2000000, 3000000, 4000000, 5000000);

CREATE PARTITION SCHEME ps_ownerId
AS PARTITION pf_ownerIdRange
TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY]);


CREATE CLUSTERED INDEX IX_BankAccount_ownerId
ON [dbo].[BankAccount] (ownerId)
ON ps_ownerId (ownerId);

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [pk_BankAccount] PRIMARY KEY CLUSTERED (ownerId) ON ps_ownerId(ownerId);

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [A bank account with this number already exists.] UNIQUE(accountNumber);

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [Bank account owner cannot be an admin.] CHECK([dbo].[isBankAccountOwnerNotAdmin](ownerId) = 1);

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [Bank account number must be 16 digits long.] CHECK(LEN(accountNumber) = 16);

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [Bank account good thru date must be after today.] CHECK(goodThru > GETDATE());

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [Bank account CVC must be 3 digits long.] CHECK(LEN(cvc) = 3);

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [Bank account cardholder name is required.] CHECK(LEN(cardholderName) > 0);

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [Bank account zip code is required.] CHECK(LEN(zip) > 0);

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [Bank account balance must be non-negative.] CHECK(inAppBalance >= 0);

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [fk_BankAccount_user] FOREIGN KEY(ownerId) REFERENCES [dbo].[user](id) ON DELETE CASCADE;

ALTER TABLE [dbo].[BankAccount]
ADD CONSTRAINT [fk_BankAccount_region] FOREIGN KEY(regionId) REFERENCES [dbo].[region](id);


--transaction
ALTER TABLE [dbo].[transaction]
DROP CONSTRAINT [Transaction details cannot be all empty.];

ALTER TABLE [dbo].[transaction]
DROP CONSTRAINT [Transaction creation date must be before today.];

ALTER TABLE [dbo].[transaction]
DROP CONSTRAINT [Transaction tax percentage must be between 0 and 1.];

ALTER TABLE [dbo].[transaction]
DROP CONSTRAINT [Transaction fee must be non-negative.];

ALTER TABLE [dbo].[transaction]
DROP CONSTRAINT [Transaction share percentage must be between 0 and 1.];

ALTER TABLE [dbo].[transaction]
DROP CONSTRAINT [Transaction discount percentage must be between 0 and 1.];


CREATE PARTITION FUNCTION pf_createdAtRange(datetime)
AS RANGE LEFT FOR VALUES (
    '2023-01-01', '2023-02-01', '2023-03-01', '2023-04-01', '2023-05-01', '2023-06-01', 
    '2023-07-01', '2023-08-01', '2023-09-01', '2023-10-01', '2023-11-01', '2023-12-01',
    '2024-01-01', '2024-02-01', '2024-03-01', '2024-04-01', '2024-05-01', '2024-06-01'
);


CREATE PARTITION SCHEME ps_createdAt
AS PARTITION pf_createdAtRange
TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], 
    [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY],
    [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY]);



CREATE CLUSTERED INDEX IX_Transaction_createdAt
ON [dbo].[transaction] (createdAt)
ON ps_createdAt (createdAt);



ALTER TABLE [dbo].[transaction]
ADD CONSTRAINT [Transaction details cannot be all empty.]
CHECK(initiatorId IS NOT NULL OR receiverId IS NOT NULL OR courseId IS NOT NULL);

ALTER TABLE [dbo].[transaction]
ADD CONSTRAINT [Transaction creation date must be before today.] 
CHECK(createdAt <= GETDATE());

ALTER TABLE [dbo].[transaction]
ADD CONSTRAINT [Transaction tax percentage must be between 0 and 1.] 
CHECK(0 <= taxPercentage AND taxPercentage <= 1);

ALTER TABLE [dbo].[transaction]
ADD CONSTRAINT [Transaction fee must be non-negative.] 
CHECK(transactionFee >= 0);

ALTER TABLE [dbo].[transaction]
ADD CONSTRAINT [Transaction share percentage must be between 0 and 1.] 
CHECK(0 <= sharePercentage AND sharePercentage <= 1);

ALTER TABLE [dbo].[transaction]
ADD CONSTRAINT [Transaction discount percentage must be between 0 and 1.] 
CHECK(0 <= discountPercentage AND discountPercentage <= 1);

ALTER TABLE [dbo].[transaction]
ADD CONSTRAINT [fk_transaction_initiator] 
FOREIGN KEY(initiatorId) REFERENCES [dbo].[learner](id);

ALTER TABLE [dbo].[transaction]
ADD CONSTRAINT [fk_transaction_receiver] 
FOREIGN KEY(receiverId) REFERENCES [dbo].[lecturer](id);

ALTER TABLE [dbo].[transaction]
ADD CONSTRAINT [fk_transaction_course] 
FOREIGN KEY(courseId) REFERENCES [dbo].[course](id);


--courseAnnoucement
ALTER TABLE [dbo].[courseAnnouncement]
DROP CONSTRAINT [Course announcement created at must be before today.];

ALTER TABLE [dbo].[courseAnnouncement]
DROP CONSTRAINT [Course announcement title is required.];

ALTER TABLE [dbo].[courseAnnouncement]
DROP CONSTRAINT [Course announcement content is required.];

ALTER TABLE [dbo].[courseAnnouncement]
DROP CONSTRAINT [fk_courseAnnouncement_sender];

ALTER TABLE [dbo].[courseAnnouncement]
DROP CONSTRAINT [fk_courseAnnouncement_course];

ALTER TABLE [dbo].[courseAnnouncement]
DROP CONSTRAINT [pk_courseAnnouncement];


CREATE PARTITION FUNCTION pf_createdAtRange(date)
AS RANGE LEFT FOR VALUES (
    '2020-01-01', '2021-01-01', '2022-01-01', '2023-01-01', '2024-01-01'
);


CREATE PARTITION SCHEME ps_createdAt
AS PARTITION pf_createdAtRange
TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY]);


CREATE CLUSTERED INDEX IX_courseAnnouncement_createdAt
ON [dbo].[courseAnnouncement] (createdAt)
ON ps_createdAt (createdAt);


ALTER TABLE [dbo].[courseAnnouncement]
ADD CONSTRAINT [Course announcement created at must be before today.] 
CHECK(createdAt <= GETDATE());

ALTER TABLE [dbo].[courseAnnouncement]
ADD CONSTRAINT [Course announcement title is required.] 
CHECK(LEN(title) > 0);

ALTER TABLE [dbo].[courseAnnouncement]
ADD CONSTRAINT [Course announcement content is required.] 
CHECK(LEN(content) > 0);

ALTER TABLE [dbo].[courseAnnouncement]
ADD CONSTRAINT [fk_courseAnnouncement_sender] 
FOREIGN KEY(senderId) REFERENCES [dbo].[lecturer](id);

ALTER TABLE [dbo].[courseAnnouncement]
ADD CONSTRAINT [fk_courseAnnouncement_course] 
FOREIGN KEY(courseId) REFERENCES [dbo].[course](id) ON DELETE CASCADE;

ALTER TABLE [dbo].[courseAnnouncement]
ADD CONSTRAINT [pk_courseAnnouncement] 
PRIMARY KEY (courseId, createdAt);

