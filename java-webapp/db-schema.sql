-- Create database
CREATE DATABASE IF NOT EXISTS webapp_db;
-- Use the database
USE webapp_db;

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
CREATE USER 'webapp_user'@'*' IDENTIFIED BY 'pasword';
GRANT ALL PRIVILEGES ON webapp_db.* TO 'webapp_user'@'*';
FLUSH PRIVILEGES;
