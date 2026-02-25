-- =========================================================================
-- CÂU 1: THIẾT KẾ CƠ SỞ DỮ LIỆU (DDL)
-- =========================================================================
CREATE DATABASE IF NOT EXISTS BookStoreDB;
USE BookStoreDB;

-- Dọn dẹp bảng cũ nếu có (Nguyên tắc: Xóa con trước, cha sau)
DROP TABLE IF EXISTS BookOrder;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Category;

-- 1. Bảng Category (Thể loại)
CREATE TABLE Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

-- 2. Bảng Book (Sách)
CREATE TABLE Book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    status INT DEFAULT 1,
    publish_date DATE,
    price DECIMAL(15, 2),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- 3. Bảng BookOrder (Đơn hàng)
CREATE TABLE BookOrder (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    book_id INT,
    order_date DATE DEFAULT (CURRENT_DATE),
    delivery_date DATE,
    FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE
);

-- =========================================================================
-- CÂU 2: THAY ĐỔI CẤU TRÚC BẢNG (DDL)
-- =========================================================================
-- Thêm cột author_name vào bảng Book
ALTER TABLE Book 
ADD COLUMN author_name VARCHAR(100) NOT NULL;

-- Thay đổi kiểu dữ liệu cột customer_name trong bảng BookOrder
ALTER TABLE BookOrder 
MODIFY COLUMN customer_name VARCHAR(200);

-- Thêm ràng buộc CHECK cho ngày giao hàng
ALTER TABLE BookOrder 
ADD CONSTRAINT chk_delivery_date CHECK (delivery_date >= order_date);

-- =========================================================================
-- CÂU 3: THAO TÁC DỮ LIỆU (DML)
-- =========================================================================
-- 1. Thêm mới dữ liệu
INSERT INTO Category (category_id, category_name, description) VALUES
(1, 'IT & Tech', 'Sách lập trình'),
(2, 'Business', 'Sách kinh doanh'),
(3, 'Novel', 'Tiểu thuyết');

INSERT INTO Book (book_id, title, status, publish_date, price, category_id, author_name) VALUES
(1, 'Clean Code', 1, '2020-05-10', 500000, 1, 'Robert C. Martin'),
(2, 'Đắc Nhân Tâm', 0, '2018-08-20', 150000, 2, 'Dale Carnegie'),
(3, 'JavaScript Nâng cao', 1, '2023-01-15', 350000, 1, 'Kyle Simpson'),
(4, 'Nhà Giả Kim', 0, '2015-11-25', 120000, 3, 'Paulo Coelho');

INSERT INTO BookOrder (order_id, customer_name, book_id, order_date, delivery_date) VALUES
(101, 'Nguyen Hai Nam', 1, '2025-01-10', '2025-01-15'),
(102, 'Tran Bao Ngoc', 3, '2025-02-05', '2025-02-10'),
(103, 'Le Hoang Yen', 4, '2025-03-12', NULL);

-- 2. Cập nhật dữ liệu
-- Tăng giá 50.000 cho sách IT & Tech (category_id = 1)
UPDATE Book 
SET price = price + 50000 
WHERE category_id = 1;

-- Cập nhật ngày giao hàng thành '2025-12-31' cho đơn hàng trống
UPDATE BookOrder 
SET delivery_date = '2025-12-31' 
WHERE delivery_date IS NULL;

-- 3. Xóa dữ liệu
-- Xóa các đơn hàng có ngày đặt trước '2025-02-01'
DELETE FROM BookOrder 
WHERE order_date < '2025-02-01';

-- =========================================================================
-- CÂU 4: TRUY VẤN DỮ LIỆU NÂNG CAO
-- =========================================================================
-- 4.1. CASE & AS
SELECT 
    title, 
    author_name, 
    CASE 
        WHEN status = 1 THEN 'Còn hàng' 
        ELSE 'Hết hàng' 
    END AS status_name 
FROM Book;

-- 4.2. Hàm hệ thống (UPPER và tính khoảng cách năm)
SELECT 
    UPPER(title) AS uppercase_title, 
    (YEAR(CURRENT_DATE) - YEAR(publish_date)) AS years_since_publish 
FROM Book;

-- 4.3. INNER JOIN
SELECT 
    b.title, 
    b.price, 
    c.category_name 
FROM Book b
INNER JOIN Category c ON b.category_id = c.category_id;

-- 4.4. ORDER BY & LIMIT
SELECT * FROM Book 
ORDER BY price DESC 
LIMIT 2;

-- 4.5. GROUP BY & HAVING
SELECT 
    c.category_name,
    COUNT(b.book_id) AS total_books 
FROM Book b
INNER JOIN Category c ON b.category_id = c.category_id
GROUP BY c.category_name 
HAVING COUNT(b.book_id) >= 2;

-- 4.6. Scalar Subquery
SELECT * FROM Book 
WHERE price > (SELECT AVG(price) FROM Book);

-- 4.7. IN Operator Subquery
SELECT * FROM Book 
WHERE book_id IN (SELECT book_id FROM BookOrder);

-- 4.8. Correlated Subquery (Sách đắt nhất trong từng thể loại)
SELECT * FROM Book b1 
WHERE price = (
    SELECT MAX(price) 
    FROM Book b2 
    WHERE b1.category_id = b2.category_id
);