-- Create database
CREATE DATABASE IF NOT EXISTS db-name###;

-- Use the database
USE db-name###;

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data (optional)
INSERT INTO messages (message) VALUES 
    ('Hello!'),
    ('Hello there!'),
    ('Welcome to the scalable web application!');

-- Create a database user (optional, for security)
CREATE USER 'your-username###'@'localhost' IDENTIFIED BY 'your-password###';
GRANT ALL PRIVILEGES ON db-name###.* TO 'your-username###'@'localhost';
FLUSH PRIVILEGES;
