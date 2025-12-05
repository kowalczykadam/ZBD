-- Zad. 1

DECLARE
    number_max NUMBER;
    new_number NUMBER;
    new_name departments.department_name%TYPE:= 'EDUCATION';
BEGIN
    SELECT MAX(department_id)
    INTO number_max
    FROM departments;
    
    dbms_output.put_line('number max = ' || number_max);
    
    new_number:= number_max + 10;
    
    INSERT INTO departments (department_id, department_name)
    VALUES (new_number, new_name);
    
    -- Zad. 2
    
    UPDATE departments
    SET location_id = '3000'   
    WHERE department_id = new_number;
END;


-- Zad. 3

CREATE TABLE nowa (
    kolumna VARCHAR2(50)
);

BEGIN
    FOR i IN 1..10 LOOP
        IF i NOT IN (4, 6) THEN
            INSERT INTO nowa (kolumna)
            VALUES (TO_CHAR(i));
        END IF;
    END LOOP;

    COMMIT;
END;

-- Zad. 4

DECLARE
    v_country countries%ROWTYPE;
BEGIN
    SELECT *
    INTO v_country
    FROM countries
    WHERE country_id = 'CA';

    DBMS_OUTPUT.PUT_LINE('Country name: ' || v_country.country_name);
    DBMS_OUTPUT.PUT_LINE('Region ID: ' || v_country.region_id);
END;

-- Zad. 5

DECLARE
    v_job   jobs%ROWTYPE;     
    v_count NUMBER := 0;      
BEGIN
    FOR rec IN (
        SELECT * FROM jobs
        WHERE LOWER(job_title) LIKE '%manager%'
    )
    LOOP
        v_job := rec; 

        UPDATE jobs
        SET min_salary = v_job.min_salary * 1.05
        WHERE job_id = v_job.job_id;

        v_count := v_count + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Liczba zaktualizowanych rekordów: ' || v_count);

    ROLLBACK;

    DBMS_OUTPUT.PUT_LINE('Zmiany zostały cofnięte.');
END;

-- Zad. 6

DECLARE
    v_job jobs%ROWTYPE;  
BEGIN
    SELECT *
    INTO v_job
    FROM jobs
    WHERE max_salary = (SELECT MAX(max_salary) FROM jobs);

    DBMS_OUTPUT.PUT_LINE('Job ID: ' || v_job.job_id);
    DBMS_OUTPUT.PUT_LINE('Job Title: ' || v_job.job_title);
    DBMS_OUTPUT.PUT_LINE('Min Salary: ' || v_job.min_salary);
    DBMS_OUTPUT.PUT_LINE('Max Salary: ' || v_job.max_salary);
END;

-- Zad. 7

DECLARE
    CURSOR c_countries(region_id_param NUMBER) IS
        SELECT country_id, country_name
        FROM   countries
        WHERE  region_id = region_id_param;

    v_country_id   countries.country_id%TYPE;
    v_country_name countries.country_name%TYPE;
    v_employee_count NUMBER;
BEGIN
    OPEN c_countries(1);

    LOOP
        FETCH c_countries INTO v_country_id, v_country_name;
        EXIT WHEN c_countries%NOTFOUND;

        SELECT COUNT(*)
        INTO v_employee_count
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id
        JOIN locations l ON d.location_id = l.location_id
        WHERE l.country_id = v_country_id;

        DBMS_OUTPUT.PUT_LINE(
              'Country: ' || v_country_name ||
              '   | Employees: ' || v_employee_count
        );
    END LOOP;

    CLOSE c_countries;
END;

-- Zad. 8

DECLARE
    CURSOR c_wyn IS
        SELECT salary, last_name
        FROM employees
        WHERE department_id = 50;

    v_salary    employees.salary%TYPE;
    v_last_name employees.last_name%TYPE;
BEGIN
    OPEN c_wyn;

    LOOP
        FETCH c_wyn INTO v_salary, v_last_name;
        EXIT WHEN c_wyn%NOTFOUND;

        IF v_salary > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(v_last_name || ' - nie dawać podwyżki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_last_name || ' - dać podwyżkę');
        END IF;
    END LOOP;

    CLOSE c_wyn;
END;

-- Zad. 9

DECLARE
    CURSOR c_prac (p_min_sal NUMBER, p_max_sal NUMBER, p_name_part VARCHAR2) IS
        SELECT salary, first_name, last_name
        FROM employees
        WHERE salary BETWEEN p_min_sal AND p_max_sal
        AND LOWER(first_name) LIKE '%' || LOWER(p_name_part) || '%';

    v_salary     employees.salary%TYPE;
    v_first_name employees.first_name%TYPE;
    v_last_name  employees.last_name%TYPE;
BEGIN

    -- a)
    DBMS_OUTPUT.PUT_LINE('Pracownicy 1000–5000 z imieniem zawierającym "a":');
    OPEN c_prac(1000, 5000, 'a');

    LOOP
        FETCH c_prac INTO v_salary, v_first_name, v_last_name;
        EXIT WHEN c_prac%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name ||
                             ' | Salary: ' || v_salary);
    END LOOP;

    CLOSE c_prac;

    -- b)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Pracownicy 5000–20000 z imieniem zawierającym "u":');
    OPEN c_prac(5000, 20000, 'u');

    LOOP
        FETCH c_prac INTO v_salary, v_first_name, v_last_name;
        EXIT WHEN c_prac%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name ||
                             ' | Salary: ' || v_salary);
    END LOOP;

    CLOSE c_prac;

END;

-- Zad. 10

CREATE TABLE statystyki_menedzerow (
    manager_id      NUMBER,
    liczba_podwladnych NUMBER,
    roznica_pensji  NUMBER
);

DECLARE
    CURSOR c_mgr IS
        SELECT manager_id
        FROM employees
        WHERE manager_id IS NOT NULL
        GROUP BY manager_id;

    v_mgr_id       employees.manager_id%TYPE;
    v_count        NUMBER;
    v_max_sal      NUMBER;
    v_min_sal      NUMBER;
BEGIN
    FOR rec IN c_mgr LOOP
        v_mgr_id := rec.manager_id;

        SELECT COUNT(*)
        INTO v_count
        FROM employees
        WHERE manager_id = v_mgr_id;

        SELECT MAX(salary), MIN(salary)
        INTO v_max_sal, v_min_sal
        FROM employees
        WHERE manager_id = v_mgr_id;

        INSERT INTO statystyki_menedzerow(manager_id, liczba_podwladnych, roznica_pensji)
        VALUES(v_mgr_id, v_count, v_max_sal - v_min_sal);
    END LOOP;

    COMMIT;
END;