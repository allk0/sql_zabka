DROP TABLE IF EXISTS Pickup;
DROP TABLE IF EXISTS Discount;
DROP TABLE IF EXISTS Discount_Level;
DROP TABLE IF EXISTS Shop_Open;
DROP TABLE IF EXISTS Package;
DROP TABLE IF EXISTS Shop;
DROP TABLE IF EXISTS User_info;
DROP VIEW IF EXISTS User_info_editable;

DROP DATABASE IF EXISTS zabka;
CREATE DATABASE zabka CHARACTER SET = utf8mb4 COLLATE = utf8mb4_polish_ci;

USE zabka;

ALTER DATABASE zabka CHARACTER SET = utf8mb4 COLLATE = utf8mb4_polish_ci;
CREATE TABLE User_info (
    user_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    mail VARCHAR(255) UNIQUE NOT NULL,
    phone_number BIGINT,
    city VARCHAR(255),
    street VARCHAR(255),
    post_code VARCHAR(20),
    location_range FLOAT,
    diet_type VARCHAR(255),
    gender VARCHAR(10),
    points INT DEFAULT 0,
    password_hash VARCHAR(255), 
    role VARCHAR(10)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_polish_ci;

CREATE TABLE Shop (
    shop_id INT PRIMARY KEY,
    city VARCHAR(255),
    street VARCHAR(255),
    post_code VARCHAR(20)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_polish_ci;

CREATE TABLE Package (
    package_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT,
    size VARCHAR(50),
    price INT,
    diet_type VARCHAR(255),
    order_status VARCHAR(50),
    pickup_day DATE,
    start_pickup_hours TIMESTAMP,
    end_pickup_hours TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_polish_ci;


CREATE TABLE Shop_Open (
    id INT PRIMARY KEY,
    shop_id INT,
    open_day INT CHECK(open_day BETWEEN 0 AND 6),
    start_hours TIME,
    end_hours TIME,
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_polish_ci;

CREATE TABLE Discount_Level (
    discount_level INT PRIMARY KEY,
    discount_name VARCHAR(255),
    discount_amount FLOAT,
    points INT
) CHARACTER SET utf8mb4 COLLATE utf8mb4_polish_ci;

CREATE TABLE Discount (
    discount_code INT PRIMARY KEY,
    discount_level INT,
    FOREIGN KEY (discount_level) REFERENCES Discount_Level(discount_level) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_polish_ci;

CREATE TABLE Pickup (
    pickup_code INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    shop_id INT,
    package_id INT,
    discount_code INT,
    rating INT CHECK(rating BETWEEN 1 AND 5),
    FOREIGN KEY (user_id) REFERENCES User_info(user_id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id) ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES Package(package_id) ON DELETE CASCADE,
    FOREIGN KEY (discount_code) REFERENCES Discount(discount_code) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_polish_ci;

/* INSERT DATA */
INSERT INTO User_info (user_id, name, surname, mail, phone_number, city, street, post_code, location_range, diet_type, gender, points, password_hash, role) VALUES
(1, 'Jan', 'Kowalski', 'jan.kowalski@o2.pl', 485012345, 'Warszawa', 'Marszalkowska 10', '00-001', 10.5, 'wegetarianska', 'male', 100, '4ef666357246a0fdc62fe6e38106354c351bc4fcc9dc0675a9f5c99660b64782', 'client'),
(2, 'Anna', 'Nowak', 'anna.nowak@wpl.pl', 485023456, 'Krakow', 'Dluga 5', '30-002', 15.2, 'miesna', 'female', 200, 'd0329a970f435e29ba5832431cafb979f9822be089700f5e6ca1a92353f12136', 'client'),
(3, 'Piotr', 'Wisniewski', 'piotr.wisniewski@gmail.com', 555666777, 'Gdansk', 'Grunwaldzka 5', '80-001', 8.0, 'bezglutenowa', 'male', 200, '7ee897b5572cfdd929f443065cb50f48ebae31de3d935b02f01e0bf54da608c5', 'client'),
(4, 'Katarzyna', 'Lis', 'katarzyna.lis@gmail.com', 444333222, 'Wroclaw', 'Swidnicka 22', '50-001', 12.0, 'miesna', 'female', 150, 'af4a8a15189b726063a7032a92546ab8bbb907c67e61167a21f678eeab4d53f9', 'client'),
(5, 'Michal', 'Cal', 'michal.cal@gmail.com', 444333122, 'Wrocław', 'Swidnicka 22', '50-001', 12.0, 'miesna', 'female', 150, '01cb73529cc450d00a5df3dd09d17015dda25ba8d20dd4f08ad2df28b8219d0c', 'manager');

REPLACE INTO Shop (shop_id, city, street, post_code) VALUES 
(1, 'Warszawa', 'Marszalkowska 10', '00-001'),
(2, 'Krakow', 'Florianska 20', '30-001'),
(3, 'Gdansk', 'Dluga 33', '80-001'),
(4, 'Wroclaw', 'Pilsudskiego 44', '50-001');


INSERT INTO Package (package_id, shop_id, size, price, diet_type, order_status, pickup_day, start_pickup_hours, end_pickup_hours) VALUES 
(1, 1, 'Mala', 25, 'miesna', 'Do odbioru', '2025-04-01', '2025-04-01 10:00:00', '2025-04-01 12:00:00'),
(2, 2, 'Duza', 50, 'weganska', 'Do odbioru', '2025-04-02', '2025-04-02 14:00:00', '2025-04-02 16:00:00'),
(3, 3, 'Srednia', 40, 'bezglutenowa', 'Do odbioru', '2025-04-03', '2025-04-03 12:00:00', '2025-04-03 14:00:00'),
(4, 4, 'Mala', 30, 'wegetarianska', 'W realizacji', '2025-04-04', '2025-04-04 09:00:00', '2025-04-04 11:00:00'),
(5, 3, 'Srednia', 40, 'bezglutenowa', 'Do odbioru', '2025-04-03', '2025-04-03 12:00:00', '2025-04-03 12:00:00');


INSERT INTO Shop_Open (id, shop_id, open_day, start_hours, end_hours) VALUES 
(1, 1, 1, '09:00:00', '18:00:00'),
(2, 2, 2, '10:00:00', '19:00:00'),
(3, 3, 3, '08:00:00', '17:00:00'),
(4, 4, 4, '11:00:00', '20:00:00');

INSERT INTO Discount_Level (discount_level, discount_name, discount_amount, points) VALUES 
(1, 'Brązowy', 5.0, 50),
(2, 'Srebrny', 10.0, 100),
(3, 'Złoty', 15.0, 200);

INSERT INTO Discount (discount_code, discount_level) VALUES 
(101, 1),
(102, 2),
(103, 3);

INSERT INTO Pickup (pickup_code, user_id, shop_id, package_id, discount_code, rating) VALUES 
(1001, 1, 1, 1, 101, 4),
(1002, 2, 2, 2, 102, 5),
(1003, 3, 3, 3, 103, 3);

DELIMITER $$
CREATE TRIGGER update_points_after_pickup
AFTER INSERT ON Pickup
FOR EACH ROW
BEGIN
    UPDATE User_info SET points = points + 10 WHERE user_id = NEW.user_id;
END $$
DELIMITER ;

INSERT INTO Pickup (pickup_code, user_id, shop_id, package_id, discount_code, rating) VALUES 
(1005, 3, 1, 4, 101, 5);

CREATE VIEW User_info_editable AS
SELECT user_id, name, surname, mail, phone_number, city, street, post_code, location_range, diet_type, gender 
FROM User_info;

DROP USER IF EXISTS 'manager'@'localhost';
DROP USER IF EXISTS 'client'@'localhost';
DROP USER IF EXISTS 'admin'@'localhost';



CREATE USER 'manager'@'localhost' IDENTIFIED BY 'password1';
GRANT INSERT, SELECT, UPDATE (size, price, diet_type, order_status, pickup_day, start_pickup_hours, end_pickup_hours) ON Package TO 'manager'@'localhost';
GRANT INSERT, SELECT, UPDATE(city, street, post_code) ON Shop TO 'manager'@'localhost';
GRANT INSERT, SELECT, UPDATE(open_day, start_hours, end_hours) ON Shop_Open TO 'manager'@'localhost';
GRANT SELECT ON User_info TO 'manager'@'localhost';
GRANT SELECT ON Pickup TO 'manager'@'localhost';

CREATE USER 'client'@'localhost' IDENTIFIED BY 'apppasswd';
GRANT SELECT ON package to 'client'@'localhost';
GRANT SELECT ON User_info TO 'client'@'localhost';
GRANT INSERT ON Pickup TO 'client'@'localhost';

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password3';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
