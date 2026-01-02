-- Create the database & tables:

CREATE DATABASE IF NOT EXISTS ecommerce_clean;
USE ecommerce_clean;
  
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    category VARCHAR(50),
    product_name VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);



-- Insert sample data:
INSERT INTO customers VALUES
(1, 'Amit Sharma', 'North'),
(2, 'Priya Das', 'South'),
(3, 'Rahul Mehta', 'East'),
(4, 'Sneha Kapoor', 'West'),
(5, 'Ravi Singh', 'North');
SELECT * from customers;

INSERT INTO products VALUES
(101, 'Electronics', 'Headphones', 1500),
(102, 'Electronics', 'Smartwatch', 5000),
(103, 'Home', 'Mixer Grinder', 3500),
(104, 'Fashion', 'Jacket', 2000),
(105, 'Home', 'Vacuum Cleaner', 8000);
SELECT * from products;

INSERT INTO orders VALUES
(1001, 1, 101, '2024-12-05', 2, 3000),
(1002, 2, 103, '2024-12-06', 1, 3500),
(1003, 3, 104, '2025-01-10', 3, 6000),
(1004, 4, 105, '2025-02-01', 1, 8000),
(1005, 5, 102, '2025-02-10', 2, 10000),
(1006, 1, 104, '2025-03-03', 1, 2000),
(1007, 3, 101, '2025-03-15', 1, 1500);
SELECT * from orders;

-- Classify customers by spending level (CASE statement):
SELECT 
    c.customer_name,
    SUM(o.total_amount) AS total_spent,
    CASE 
        WHEN SUM(o.total_amount) > 8000 THEN 'High Value'
        WHEN SUM(o.total_amount) BETWEEN 4000 AND 8000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_category
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

-- Find top products by revenue using window function (RANK):
SELECT 
    p.category,
    p.product_name,
    SUM(o.total_amount) AS total_sales,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(o.total_amount) DESC) AS category_rank
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.category, p.product_name;

-- Total revenue by product
SELECT 
    p.product_name,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Top 5 products
SELECT 
    p.product_name,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Bottom 5 products
SELECT 
    p.product_name,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue ASC
LIMIT 5;

-- Monthly revenue trend(USING YEAR() and MONTH() functions):
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

-- Compare region-wise average revenue with overall average (CTE + HAVING):
SELECT 
    c.region,
    AVG(o.total_amount) AS avg_revenue,
    MAX(overall.avg_all) AS overall_avg
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN (
    SELECT AVG(total_amount) AS avg_all FROM orders
) overall
GROUP BY c.region
HAVING AVG(o.total_amount) > MAX(overall.avg_all);

-- Find customers who ordered above-average priced products (subquery):
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.total_amount > (
    SELECT AVG(total_amount) FROM orders
);

-- Track repeat customers using COUNT + HAVING:
SELECT 
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 1;