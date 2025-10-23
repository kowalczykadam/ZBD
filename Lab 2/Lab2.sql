DROP TABLE Countries CASCADE constraints;
DROP TABLE Departments CASCADE constraints;
DROP TABLE Employees CASCADE constraints;
DROP TABLE Job_history CASCADE constraints;
DROP TABLE Jobs CASCADE constraints;
DROP TABLE Locations CASCADE constraints;
DROP TABLE Regions CASCADE constraints;

CREATE TABLE Regions 
AS
SELECT *
FROM HR.Regions;

CREATE TABLE Locations 
AS
SELECT *
FROM HR.Locations;

CREATE TABLE Jobs
AS
SELECT *
FROM HR.Jobs;

CREATE TABLE Job_History 
AS
SELECT *
FROM HR.Job_History;

CREATE TABLE Employees 
AS
SELECT *
FROM HR.Employees;

CREATE TABLE Departments 
AS
SELECT *
FROM HR.Departments;

CREATE TABLE Countries 
AS
SELECT *
FROM HR.Countries;

CREATE TABLE Job_Grades 
AS
SELECT *
FROM HR.Job_Grades;

ALTER TABLE Jobs
ADD PRIMARY KEY (job_id);

ALTER TABLE Job_History
ADD CONSTRAINT PK_Job_History PRIMARY KEY (employee_id, start_date);

ALTER TABLE Departments 
ADD CONSTRAINT FK_LocationDepartment FOREIGN KEY (location_id)
    REFERENCES Locations(location_id);
    
ALTER TABLE Departments
ADD PRIMARY KEY (department_id);

ALTER TABLE Employees
ADD PRIMARY KEY (employee_id);

ALTER TABLE Regions
ADD PRIMARY KEY (region_id);

ALTER TABLE Countries
ADD PRIMARY KEY (country_id);

ALTER TABLE Locations
ADD PRIMARY KEY (location_id);

ALTER TABLE Countries 
ADD CONSTRAINT FK_CountryRegion FOREIGN KEY (region_id)
    REFERENCES Regions(region_id);
    
ALTER TABLE Locations 
ADD CONSTRAINT FK_LocationCountry FOREIGN KEY (country_id)
    REFERENCES Countries(country_id);
    
ALTER TABLE Departments 
ADD CONSTRAINT FK_LocationDepartment FOREIGN KEY (location_id)
    REFERENCES Locations(location_id);
ALTER TABLE Departments
ADD CONSTRAINT FK_ManagerDepartment FOREIGN KEY (manager_id)
    REFERENCES Employees(employee_id);

ALTER TABLE Job_History
    ADD CONSTRAINT FK_HistoryEmployee FOREIGN KEY (employee_id)
    REFERENCES Employees(employee_id);
ALTER TABLE Job_History
    ADD CONSTRAINT FK_HistoryDepartment FOREIGN KEY (department_id)
    REFERENCES Departments(department_id);
    
ALTER TABLE Employees
    ADD CONSTRAINT FK_EmployeesJob FOREIGN KEY (job_id)
    REFERENCES Jobs(job_id);
ALTER TABLE Employees
    ADD CONSTRAINT FK_EmployeesDepartment FOREIGN KEY (department_id)
    REFERENCES Departments(department_id);
ALTER TABLE Employees
    ADD CONSTRAINT FK_EmployeesManager FOREIGN KEY (manager_id)
    REFERENCES Employees(employee_id);

-- Zad.1

select last_name, salary as wynagrodzenie
from Employees
where (department_id = 20 OR department_id = 50) AND (salary >= 2000 AND salary <= 7000)
order by last_name;

-- Zad. 2

select hire_date, last_name, &user_input_2 as kol
from Employees
where (manager_id IS NOT NULL) AND (hire_date >= DATE '2005-01-01' AND hire_date < DATE '2006-01-01')
order by kol;

-- Zad. 3

select CONCAT(first_name, last_name) as Employee, salary, phone_number
from Employees
where last_name LIKE '__%e%' AND LOWER(first_name) LIKE LOWER ('%&user_input_3%')
order by Employee DESC, salary;

-- Zad. 4

SELECT 
    first_name || ' ' || last_name AS pracownik,
    ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS liczba_miesiecy,
    CASE 
        WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) <= 150 THEN salary * 0.10
        WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) > 150 
             AND ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) < 200 THEN salary * 0.20
        ELSE salary * 0.30
    END AS wysokosc_dodatku
FROM employees
ORDER BY liczba_miesiecy;

-- Zad. 5

SELECT  e.first_name,
        e.last_name,
        e.department_id,
        (SELECT MIN(el.salary) FROM employees el
        WHERE e.department_id = el.department_id) department_min_salary,
        e.salary,
        (SELECT ROUND(SUM(el.salary)) FROM employees el
        WHERE e.department_id = el.department_id) sum_of_salary,
        (SELECT ROUND(AVG(el.salary)) FROM employees el
        WHERE e.department_id = el.department_id) average_salary
FROM employees e
WHERE (SELECT MIN(el.salary) FROM employees el
        WHERE e.department_id = el.department_id) >= 5000;

-- Zad. 6

SELECT 
    e.last_name,
    e.department_id,
    d.department_name,
    e.job_id
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN locations l
    ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

-- Zad. 7

SELECT 
    e.first_name || ' ' || e.last_name AS coworker_name,
    j.first_name || ' ' || j.last_name AS jennifer_name
FROM employees e
JOIN employees j
    ON e.department_id = j.department_id    
   AND j.first_name = 'Jennifer'
ORDER BY e.department_id, e.last_name;

-- Zad. 8

SELECT d.department_id,
       d.department_name
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
WHERE e.employee_id IS NULL
ORDER BY d.department_id;

-- Zad. 9

SELECT 
    e.first_name,
    e.last_name,
    e.job_id,
    d.department_name,
    e.salary,
    CASE 
        WHEN e.salary <= 2999 THEN 'A'
        WHEN e.salary >= 3000
             AND e.salary <= 4999 THEN 'B'
        WHEN e.salary >= 5000
             AND e.salary <= 7999 THEN 'C'
        WHEN e.salary >= 8000
             AND e.salary <= 9999 THEN 'D'
        WHEN e.salary >= 10000
             AND e.salary <= 14999 THEN 'E'
        WHEN e.salary >= 15000
             AND e.salary <= 200999 THEN 'F'
    END AS grade
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id;

-- Zad. 10

SELECT  e.first_name,
        e.last_name,
        e.salary,
        (SELECT ROUND(AVG(el.salary)) FROM employees el) average_salary
FROM employees e
WHERE (SELECT ROUND(AVG(el.salary)) FROM employees el) <= e.salary
ORDER BY e.salary DESC;

-- Zad. 11

SELECT 
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
JOIN employees j
    ON e.department_id = j.department_id    
   AND j.last_name LIKE LOWER ('%u%');
   
-- Zad. 12

SELECT  e.first_name,
        e.last_name,
        ROUND (MONTHS_BETWEEN( '2025-10-17', e.hire_date )) time_hired,
        (SELECT ROUND(AVG(MONTHS_BETWEEN( '2025-10-17', el.hire_date ))) FROM employees el ) average_time_hired
FROM employees e
WHERE ROUND (MONTHS_BETWEEN( '2025-10-17', e.hire_date )) >= (SELECT ROUND(AVG(MONTHS_BETWEEN( '2025-10-17', el.hire_date ))) FROM employees el );

-- Zad. 13

SELECT 
    d.department_name,
    (SELECT ROUND(AVG(el.salary)) FROM employees el
    WHERE e.department_id = el.department_id) number_of_employees,
    (SELECT ROUND(AVG(el.salary)) FROM employees el
    WHERE e.department_id = el.department_id) average_salary,
    e.salary
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id;