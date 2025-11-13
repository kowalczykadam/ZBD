-- Zad. 1

CREATE VIEW v_wysokie_pensje AS
SELECT first_name, last_name, salary
FROM employees
WHERE salary > 6000;

SELECT * FROM v_wysokie_pensje;

-- Zad. 2

CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT first_name, last_name, salary
FROM employees
WHERE salary > 12000;

-- Zad. 3

DROP VIEW v_wysokie_pensje;

-- Zad. 4

CREATE VIEW v_employees_4 AS
SELECT e.employee_id, e.last_name, e.first_name
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE d.department_name = 'Finance';

SELECT * FROM v_employees_4;


--Zad. 5

CREATE VIEW v_employees AS
SELECT employee_id, first_name, last_name, salary, job_id, email, hire_date
FROM employees
WHERE salary BETWEEN 5000 AND 12000;

SELECT * FROM v_employees;

--Zad. 6

INSERT INTO v_employees (employee_id, first_name, last_name, salary, job_id, email, hire_date)
VALUES (1232, 'John', 'Database', 8000, 'IT_PROG', 'mail@mail', '2025-10-10');

UPDATE v_employees
SET first_name = 'Jane'
WHERE employee_id = 1232;

DELETE FROM v_employees WHERE employee_id = 1232;

--Zad. 7

CREATE VIEW v_departments AS
SELECT 
    d.department_id,
    d.department_name,
    COUNT(*) employees_count,
    ROUND(AVG(e.salary)) average_salary,
    MAX(e.salary) maximum_salary
FROM departments d
JOIN employees e
    ON d.department_id = e.department_id
Group by d.department_id, d.department_name
HAVING COUNT(*) > 3;

SELECT * FROM v_departments;

--Zad. 8

CREATE VIEW v_employees_8 AS
SELECT employee_id, first_name, last_name, salary, job_id, email, hire_date
FROM employees
WHERE salary BETWEEN 5000 AND 12000
WITH CHECK OPTION;

INSERT INTO v_employees_8 (employee_id, first_name, last_name, salary, job_id, email, hire_date)
VALUES (1232, 'John', 'Database', 8000, 'IT_PROG', 'mail@mail', '2025-10-10');

INSERT INTO v_employees_8 (employee_id, first_name, last_name, salary, job_id, email, hire_date)
VALUES (1232, 'John', 'Database', 18000, 'IT_PROG', 'mail@mail', '2025-10-10');

--Zad. 9

CREATE MATERIALIZED VIEW v_managerowie
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS manager_name,
       d.department_name
FROM employees e
JOIN departments d
    ON e.employee_id = d.manager_id;

SELECT * FROM v_managerowie;

--Zad. 10

CREATE VIEW v_najlepiej_oplacani AS
SELECT employee_id,
       first_name,
       last_name,
       salary,
       department_id
FROM (
    SELECT employee_id,
           first_name,
           last_name,
           salary,
           department_id,
           RANK() OVER (ORDER BY salary DESC) AS ranking
    FROM employees
)
WHERE ranking <= 10;

SELECT * FROM v_najlepiej_oplacani;