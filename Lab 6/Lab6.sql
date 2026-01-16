-- Zad. 1

CREATE PROCEDURE lab_6_zad_1 (p_job_id IN jobs.job_id%TYPE, p_job_title IN jobs.job_title%TYPE)
AS
BEGIN
    INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
    VALUES (p_job_id, p_job_title, NULL, NULL);
    DBMS_OUTPUT.PUT_LINE('Dodano nowe stanowisko: '|| p_job_id || '-' ||p_job_title);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Ten Job_id już istnieje');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił nieznany błąd');
END;

BEGIN
    lab_6_zad_1('test_id', 'test_job_title');
END;

-- Zad. 2

CREATE PROCEDURE modify_job_title (
    p_job_id    IN jobs.job_id%TYPE,
    p_new_title IN jobs.job_title%TYPE
) AS
    e_no_update EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_update, -20001); 
BEGIN
    UPDATE jobs
    SET job_title = p_new_title
    WHERE job_id = p_job_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_no_update;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Zaktualizowano stanowisko: ' || p_job_id || 
                         ' → ' || p_new_title);

EXCEPTION
    WHEN e_no_update THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD (użyty wyjątek własny): brak aktualizacji dla job_id = ' 
                             || p_job_id);
        DBMS_OUTPUT.PUT_LINE('SQLCODE = ' || SQLCODE || ', SQLERRM = ' || SQLERRM);

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: SQLCODE = ' || SQLCODE || 
                             ' SQLERRM = ' || SQLERRM);
END;


BEGIN
    modify_job_title('IT_PROG', 'New Programmer Title');
END;

BEGIN
    modify_job_title('XXXXX', 'Test Title');
END;

BEGIN
    modify_job_title('XXXXX', 'Test Title');
END;

--Zad. 3

CREATE OR REPLACE PROCEDURE delete_job (
    p_job_id IN jobs.job_id%TYPE
) AS
    e_no_delete EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_delete, -20002);
BEGIN
    DELETE FROM jobs
    WHERE job_id = p_job_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_no_delete;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Usunięto rekord o ID: ' || p_job_id);

EXCEPTION
    WHEN e_no_delete THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: nie usunięto żadnego rekordu dla job_id = ' 
                             || p_job_id);
        DBMS_OUTPUT.PUT_LINE('SQLCODE = ' || SQLCODE || ', SQLERRM = ' || SQLERRM);

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: SQLCODE = ' || SQLCODE ||
                             ', SQLERRM = ' || SQLERRM);
END;

BEGIN
    delete_job('IT_PROG');
END;

BEGIN
    delete_job('XYZ123');
END;

--Zad. 4

CREATE OR REPLACE PROCEDURE get_employee_data (
    p_employee_id IN  employees.employee_id%TYPE,
    p_last_name   OUT employees.last_name%TYPE,
    p_salary      OUT employees.salary%TYPE
) AS
BEGIN
    SELECT last_name, salary
    INTO   p_last_name, p_salary
    FROM   employees
    WHERE  employee_id = p_employee_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_last_name := NULL;
        p_salary := NULL;
        DBMS_OUTPUT.PUT_LINE('Brak pracownika o ID: ' || p_employee_id);

    WHEN OTHERS THEN
        p_last_name := NULL;
        p_salary := NULL;
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;

DECLARE
    v_last_name employees.last_name%TYPE;
    v_salary    employees.salary%TYPE;
BEGIN
    get_employee_data(100, v_last_name, v_salary);

    DBMS_OUTPUT.PUT_LINE('Nazwisko: ' || v_last_name);
    DBMS_OUTPUT.PUT_LINE('Pensja:   ' || v_salary);
END;

--Zad. 5

CREATE OR REPLACE PROCEDURE add_employee (
    p_first_name  IN employees.first_name%TYPE,
    p_last_name   IN employees.last_name%TYPE,
    p_email       IN employees.email%TYPE,
    p_job_id      IN employees.job_id%TYPE,
    p_salary      IN employees.salary%TYPE
) AS
    e_salary_too_high EXCEPTION;
    v_new_id employees.employee_id%TYPE;
BEGIN
    IF p_salary > 20000 THEN
        RAISE e_salary_too_high;
    END IF;

    SELECT NVL(MAX(employee_id),0) + 1
    INTO v_new_id
    FROM employees;

    INSERT INTO employees (
        employee_id, first_name, last_name, email,
        hire_date, job_id, salary
    ) VALUES (
        v_new_id,
        p_first_name,
        p_last_name,
        p_email,
        SYSDATE,
        p_job_id,
        p_salary
    );

    DBMS_OUTPUT.PUT_LINE('Dodano pracownika, ID = ' || v_new_id);

EXCEPTION
    WHEN e_salary_too_high THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: wynagrodzenie > 20000');

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;


BEGIN
    add_employee(
        p_first_name => 'Jan',
        p_last_name  => 'Kowalski',
        p_email      => 'JKOWAL',
        p_job_id     => 'IT_PROG',
        p_salary     => 9000
    );
END;

--Zad. 6

CREATE OR REPLACE PROCEDURE avg_salary_by_manager (
    p_manager_id IN  employees.manager_id%TYPE,
    p_avg_salary OUT employees.salary%TYPE
) AS
BEGIN
    SELECT AVG(salary)
    INTO   p_avg_salary
    FROM   employees
    WHERE  manager_id = p_manager_id;

    IF p_avg_salary IS NULL THEN
        DBMS_OUTPUT.PUT_LINE(
            'Manager o ID ' || p_manager_id || ' nie ma podwładnych.'
        );
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_avg_salary := NULL;
        DBMS_OUTPUT.PUT_LINE('Brak danych dla managera ID: ' || p_manager_id);

    WHEN OTHERS THEN
        p_avg_salary := NULL;
        DBMS_OUTPUT.PUT_LINE(
            'Błąd: SQLCODE=' || SQLCODE || ' SQLERRM=' || SQLERRM
        );
END;

DECLARE
    v_avg_salary employees.salary%TYPE;
BEGIN
    avg_salary_by_manager(100, v_avg_salary);

    DBMS_OUTPUT.PUT_LINE(
        'Średnia pensja podwładnych: ' || NVL(v_avg_salary, 0)
    );
END;

--Zad. 7

CREATE OR REPLACE PROCEDURE raise_salary_by_department (
    p_department_id IN employees.department_id%TYPE,
    p_percent       IN NUMBER
) AS
    v_dep_count NUMBER;
    v_updated   NUMBER := 0;
    v_new_salary employees.salary%TYPE;
BEGIN
    SELECT COUNT(*)
    INTO v_dep_count
    FROM departments
    WHERE department_id = p_department_id;

    IF v_dep_count = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'Department ID ' || p_department_id || ' nie istnieje'
        );
    END IF;

    FOR emp IN (
        SELECT e.employee_id,
               e.salary,
               j.min_salary,
               j.max_salary
        FROM employees e
        JOIN jobs j ON e.job_id = j.job_id
        WHERE e.department_id = p_department_id
    ) LOOP

        v_new_salary := emp.salary * (1 + p_percent / 100);

        IF v_new_salary BETWEEN emp.min_salary AND emp.max_salary THEN
            UPDATE employees
            SET salary = v_new_salary
            WHERE employee_id = emp.employee_id;

            v_updated := v_updated + 1;
        END IF;
    END LOOP;

    IF v_updated = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'Departament istnieje, ale brak pracowników do aktualizacji'
        );
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Zaktualizowano ' || v_updated ||
            ' pracowników w departamencie ' || p_department_id
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'BŁĄD: SQLCODE=' || SQLCODE || ' SQLERRM=' || SQLERRM
        );
END;


BEGIN
    raise_salary_by_department(50, 10);
END;

BEGIN
    raise_salary_by_department(999, 10);
END;

-- Zad. 8

CREATE OR REPLACE PROCEDURE move_employee (
    p_employee_id       IN employees.employee_id%TYPE,
    p_new_department_id IN departments.department_id%TYPE
) AS
    e_employee_not_found EXCEPTION;

    v_dep_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_dep_count
    FROM departments
    WHERE department_id = p_new_department_id;

    IF v_dep_count = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20020,
            'Departament ID ' || p_new_department_id || ' nie istnieje'
        );
    END IF;

    UPDATE employees
    SET department_id = p_new_department_id
    WHERE employee_id = p_employee_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_employee_not_found;
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        'Pracownik ID ' || p_employee_id ||
        ' przeniesiony do departamentu ' || p_new_department_id
    );

EXCEPTION
    WHEN e_employee_not_found THEN
        DBMS_OUTPUT.PUT_LINE(
            'BŁĄD: Pracownik o ID ' || p_employee_id || ' nie istnieje'
        );

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'Inny błąd: SQLCODE=' || SQLCODE || ' SQLERRM=' || SQLERRM
        );
END;

BEGIN
    move_employee(101, 60);
END;

BEGIN
    move_employee(9999, 60);
END;


--Zad. 9

CREATE OR REPLACE PROCEDURE delete_department (
    p_department_id IN departments.department_id%TYPE
) AS
    v_emp_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_emp_count
    FROM employees
    WHERE department_id = p_department_id;

    IF v_emp_count > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20030,
            'Nie można usunąć departamentu ' || p_department_id ||
            ' – są przypisani pracownicy'
        );
    END IF;

    DELETE FROM departments
    WHERE department_id = p_department_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'Departament o ID ' || p_department_id || ' nie istnieje'
        );
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Departament o ID ' || p_department_id || ' został usunięty'
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'BŁĄD: SQLCODE=' || SQLCODE || ' SQLERRM=' || SQLERRM
        );
END;

BEGIN
    delete_department(50);
END;