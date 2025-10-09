CREATE TABLE Jobs (
    job_id int,
    job_title varchar(255),
    min_salary int,
    max_salary int,
    PRIMARY KEY (job_id)
);

CREATE TABLE Job_History (
    employee_id int,
    start_date date,
    end_date date,
    job_id int,
    department_id int,
    CONSTRAINT PK_Job_History PRIMARY KEY (employee_id, start_date)
);

CREATE TABLE Departments (
    department_id int NOT NULL,
    department_name varchar(255),
    manager_id int,
    location_id int,
    PRIMARY KEY (department_id)
);

CREATE TABLE Employees (
    employee_id int,
    first_name varchar(255),
    last_name varchar(255),
    email varchar(255),
    phone_number int,
    hire_date date,
    job_id int,
    salary int,
    commission_pct float,
    manager_id int,
    department_id int,
    PRIMARY KEY (employee_id)
);

CREATE TABLE Regions (
    region_id int,
    region_name varchar(255),
    PRIMARY KEY (region_id)
);

CREATE TABLE Countries (
    country_id int,
    country_name varchar(255),
    region_id int,
    PRIMARY KEY (country_id),
    CONSTRAINT FK_CountryRegion FOREIGN KEY (region_id)
    REFERENCES Regions(region_id)
);

CREATE TABLE Locations (
    location_id int,
    street_address varchar(255),
    postal_code varchar(255),
    city varchar(255),
    country_id int,
    PRIMARY KEY (location_id),
    CONSTRAINT FK_LocationCountry FOREIGN KEY (country_id)
    REFERENCES Countries(country_id)
);

ALTER TABLE Locations
ADD state_province varchar(255);


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
    
ALTER TABLE Jobs
ADD CHECK (max_salary>=min_salary + 2000); 
    
INSERT INTO Jobs (job_id, job_title, min_salary, max_salary)
VALUES (1, 'Manager', 2000, 5000);

INSERT INTO Jobs (job_id, job_title, min_salary, max_salary)
VALUES (2, 'IT', 1500, 4000);

INSERT INTO Jobs (job_id, job_title, min_salary, max_salary)
VALUES (3, 'Tech_support', 1400, 3800);

INSERT INTO Jobs (job_id, job_title, min_salary, max_salary)
VALUES (4, 'Retail', 1000, 3000);

INSERT INTO Jobs (job_id, job_title, min_salary, max_salary)
VALUES (5, 'Janitor', 1200, 9200);


INSERT INTO Employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id)
VALUES (1, 'John', 'Johnson', 'Johnson@mail', '123321123', '2021-10-10', 1, 3000, 23, 1);

INSERT INTO Employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id)
VALUES (2, 'Karl', 'Fairfield', 'Fairfield@mail', '231324512', '2022-11-05', 2, 4000, 12, 2);

INSERT INTO Employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id)
VALUES (3, 'Dwight', 'Morell', 'Morell@mail', '765136842', '2020-05-12', 3, 3400, 32, 3);

INSERT INTO Employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id)
VALUES (4, 'Felix', 'King', 'King@mail', '572975126', '2022-04-03', 4, 1500, 15, 1);

UPDATE Employees
SET manager_id = 1
WHERE employee_id = 2;

UPDATE Employees
SET manager_id = 1
WHERE employee_id = 3;

UPDATE Jobs
SET max_salary = max_salary + 500
WHERE LOWER(job_title) LIKE '%b%'
   OR LOWER(job_title) LIKE '%s%';

DELETE FROM Jobs WHERE max_salary > 9000;

DROP TABLE Job_History;

show recyclebin;

flashback table "BIN$vw/HOURfTFmvtlWXoG/0UQ==$0" to before drop;
