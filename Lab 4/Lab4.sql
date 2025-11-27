CREATE TABLE Products 
AS
SELECT *
FROM HR.Products;

CREATE TABLE Sales
AS
SELECT *
FROM HR.Sales;


-- Zad. 1

SELECT first_name, last_name, salary, dense_rank() over (order by salary) as ranking
FROM employees;

-- Zad. 2

SELECT first_name, last_name,
sum(salary) over() as sum_salary
FROM employees;

-- Zad. 3

SELECT e.last_name,
       p.product_name,
       SUM(s.quantity * s.price) AS total_sales_value,
       RANK() OVER (ORDER BY SUM(s.quantity * s.price) DESC) AS sales_rank
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.last_name, p.product_name
ORDER BY total_sales_value DESC;

-- Zad. 4

SELECT 
    e.last_name,
    p.product_name,
    s.price,
    
    COUNT(*) OVER (
        PARTITION BY s.product_id, TRUNC(s.sale_date)
    ) AS transactions_that_day,
    
    SUM(s.quantity * s.price) OVER (
        PARTITION BY s.product_id, TRUNC(s.sale_date)
    ) AS total_paid_that_day,

    LAG(s.price) OVER (
        PARTITION BY s.product_id
        ORDER BY s.sale_date
    ) AS previous_price,

    LEAD(s.price) OVER (
        PARTITION BY s.product_id
        ORDER BY s.sale_date
    ) AS next_price

FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
ORDER BY s.sale_date, s.product_id, s.sale_id;

-- Zad. 5

SELECT 
    p.product_name,
    s.price,
    
    SUM(s.quantity * s.price) OVER (
        PARTITION BY s.product_id, TRUNC(s.sale_date, 'MM')
    ) AS monthly_total,

    SUM(s.quantity * s.price) OVER (
        PARTITION BY s.product_id, TRUNC(s.sale_date, 'MM')
        ORDER BY s.sale_date, s.sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS monthly_running_total

FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY s.product_id, TRUNC(s.sale_date, 'MM'), s.sale_date, s.sale_id;

-- Zad. 6

SELECT 
    p.product_name,
    p.product_category,
    s_2022.price AS price_2022,
    s_2023.price AS price_2023,
    (s_2023.price - s_2022.price) AS price_difference
FROM
    (SELECT 
         product_id,
         EXTRACT(MONTH FROM sale_date) AS month_num,
         EXTRACT(DAY FROM sale_date) AS day_num,
         price
     FROM sales
     WHERE EXTRACT(YEAR FROM sale_date) = 2022
    ) s_2022
JOIN
    (SELECT 
         product_id,
         EXTRACT(MONTH FROM sale_date) AS month_num,
         EXTRACT(DAY FROM sale_date) AS day_num,
         price
     FROM sales
     WHERE EXTRACT(YEAR FROM sale_date) = 2023
    ) s_2023
ON s_2022.product_id = s_2023.product_id
AND s_2022.month_num = s_2023.month_num
AND s_2022.day_num = s_2023.day_num
JOIN products p ON p.product_id = s_2022.product_id
ORDER BY p.product_name, s_2022.month_num, s_2022.day_num;

-- Zad. 7

SELECT
    p.product_category,
    p.product_name,
    s.price,
    MIN(s.price) OVER (
        PARTITION BY p.product_category) AS min_price_in_category,
    MAX(s.price) OVER (
        PARTITION BY p.product_category) AS max_price_in_category,
    (MIN(s.price) OVER (
        PARTITION BY p.product_category) -
    MAX(s.price) OVER (
        PARTITION BY p.product_category)) AS max_min_difference
FROM sales s
JOIN products p ON s.product_id = p.product_id;

-- Zad. 8

SELECT
    p.product_name,
    s.sale_date,
    s.price,

    AVG(s.price) OVER (
        PARTITION BY s.product_id
        ORDER BY s.sale_date
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS moving_avg_3
FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY p.product_name, s.sale_date;

-- Zad. 9

SELECT
    p.product_name,
    p.product_category,
    s.price,

    RANK() OVER (
        PARTITION BY p.product_category
        ORDER BY s.price
    ) AS price_rank,

    ROW_NUMBER() OVER (
        PARTITION BY p.product_category
        ORDER BY s.price
    ) AS price_rownum,

    DENSE_RANK() OVER (
        PARTITION BY p.product_category
        ORDER BY s.price
    ) AS price_dense_rank

FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY p.product_category, s.price, p.product_name;

-- Zad. 10

SELECT
    e.last_name,
    p.product_name,
    s.sale_date,
    s.quantity,
    s.price,
    (s.price * s.quantity) AS order_value,

    -- Wartość rosnąca sprzedaży dla danego pracownika wg dat
    SUM(s.price * s.quantity) OVER (
        PARTITION BY s.employee_id
        ORDER BY s.sale_date, s.sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_employee_sales,

    -- Globalny ranking wartości zamówienia
    RANK() OVER (
        ORDER BY (s.price * s.quantity) DESC
    ) AS global_order_rank

FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
ORDER BY e.last_name, s.sale_date, s.sale_id;

-- Zad. 11

SELECT DISTINCT
       e.first_name,
       e.last_name,
       e.job_id
FROM employees e
JOIN sales s
     ON e.employee_id = s.employee_id;