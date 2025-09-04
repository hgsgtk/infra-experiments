CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    price DECIMAL(8, 2)
);

CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    product_id INT,
    quantity INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_product_id (product_id)
);

-- Sample Data
INSERT INTO users (name, email, created_at)
SELECT
    CONCAT('user', seq), CONCAT('user', seq, '@example.com'), NOW()
FROM (
    SELECT @rownum := @rownum + 1 AS seq
    FROM information_schema.columns, (SELECT @rownum := 0) r LIMIT 100000
) t;

INSERT INTO products (name, price)
SELECT
  CONCAT('product', seq), ROUND(RAND()*100+1,2)
FROM (
    SELECT @rownum := @rownum + 1 AS seq
    FROM information_schema.columns, (SELECT @rownum := 0) r LIMIT 100000
) t;

INSERT INTO orders (user_id, product_id, quantity, order_date)
SELECT
  FLOOR(1 + (RAND() * 99999)), FLOOR(1 + (RAND() * 99999)), FLOOR(1 + (RAND() * 10)), NOW()
FROM (
    SELECT @rownum := @rownum + 1 AS seq
    FROM information_schema.columns, (SELECT @rownum := 0) r LIMIT 100000
) t;
