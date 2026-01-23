CREATE DATABASE IF NOT EXISTS momo_db;
USE momo_db;


CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(20),
    email VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS transactionsCategory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);


CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    amount DECIMAL(10,2) NOT NULL,
    transactionDate DATETIME NOT NULL,
    status VARCHAR(50) NOT NULL,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES transactionsCategory(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS userTransaction (
    user_id INT NOT NULL,
    transactionId INT NOT NULL,
    PRIMARY KEY (user_id, transactionId),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (transactionId) REFERENCES transactions(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS systemLog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    logTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    message TEXT NOT NULL,
    severity VARCHAR(50) NOT NULL,
    transactionId INT,
    FOREIGN KEY (transactionId) REFERENCES transactions(id) ON DELETE SET NULL
);





