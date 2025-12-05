-- Create a sample database
CREATE DATABASE SampleDB;
GO

USE SampleDB;
GO

-- Create a sample table
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Insert sample data
INSERT INTO Users (Username, Email) VALUES 
    ('admin', 'admin@example.com'),
    ('user1', 'user1@example.com');
GO

PRINT 'Database initialization completed successfully!';
GO
