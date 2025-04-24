USE airport;

-- 2
SELECT CONCAT(e.first_name, ' ', e.last_name) AS name, e.phone, e.email, e.position 
FROM employees AS e 
JOIN departments AS d ON e.department_id = d.id
WHERE d.department_name = "pilots";

-- 3 
SELECT sp.year AS year, SUM(sp.amount) AS salary_payment_amount FROM salary_payments AS sp
GROUP BY year;

SELECT d.department_name, AVG(s.amount) AS avg_salary
FROM salary_payments AS s
JOIN employees AS e ON s.employee_id = e.id
JOIN departments AS d ON e.department_id = d.id
GROUP BY d.department_name;

-- 4
SELECT CONCAT(e.first_name, ' ', e.last_name) AS name, e.position, d.department_name
FROM employees AS e
INNER JOIN departments AS d ON e.department_id = d.id;

SELECT f.flight_number, a.registration_number, a.brand, a.model
FROM flights f
INNER JOIN airplanes a ON f.airplane_id = a.id;

-- 5
SELECT CONCAT(e.first_name, ' ', e.last_name) AS name, e.position, sp.amount
FROM employees AS e
LEFT OUTER JOIN salary_payments AS sp ON e.id = sp.employee_id;

SELECT e.first_name, e.last_name, sb.bus_number
FROM employees e
LEFT OUTER JOIN shuttle_buses sb ON e.id = sb.driver_id;

-- 6
SELECT CONCAT(e.first_name, ' ', e.last_name) AS name, e.position, sp.amount, d.department_name
FROM employees AS e
INNER JOIN salary_payments AS sp ON e.id = sp.employee_id
INNER JOIN departments AS d ON e.department_id = d.id
WHERE sp.amount > (
    SELECT AVG(amount)
    FROM salary_payments
    WHERE employee_id IN (
        SELECT id
        FROM employees
        WHERE department_id = e.department_id
    )
);

SELECT AVG(sp.amount) AS avg_amount FROM salary_payments AS sp;

SELECT first_name, last_name
FROM employees
WHERE id IN (
    SELECT employee_id
    FROM salary_payments
    WHERE amount = (SELECT MAX(amount) FROM salary_payments)
);

-- 7
SELECT d.department_name AS department, AVG(sp.amount) AS Avg_Salary FROM salary_payments AS sp
JOIN employees AS e ON sp.employee_id = e.id
JOIN departments AS d ON e.department_id = d.id
GROUP BY d.department_name;

SELECT f.flight_number, SUM(b.weight) AS total_baggage_weight
FROM flights AS f
JOIN tickets AS t ON f.id = t.flight_id
JOIN baggage AS b ON t.id = b.ticket_id
GROUP BY f.flight_number;

-- 8
DELIMITER $$

CREATE TRIGGER check_terminal_insert
BEFORE INSERT
ON gates
FOR EACH ROW
BEGIN
    IF NEW.terminal NOT IN ('T1', 'T2') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Terminal should be either T1 or T2!';
    END IF;
END$$

DELIMITER ;

SELECT * FROM gates;
DELETE FROM gates WHERE id = 3;

INSERT INTO gates (gate_number, terminal, status) VALUES 
('A2', 'T6', 'available');

--

DELIMITER $$
CREATE TRIGGER salary_payments_log_trigger AFTER DELETE ON salary_payments 
FOR EACH ROW 
	BEGIN
	INSERT INTO salarypayments_log 
    (operation,
	old_employee_id,
	new_employee_id,
	old_month,
	new_month,
	old_year,
	new_year,
	old_salaryAmount,
	new_salaryAmount,
	old_dateOfPayment,
	new_dateOfPayment,
	dateOfLog) VALUES ('DELETE', OLD.employee_id, NULL, OLD.month, NULL, OLD.year, NULL, OLD.amount, NULL, OLD.dateOfPayment, NULL, NOW()
    );
    END$$
DELIMITER ; 

SELECT * FROM salary_payments;

DROP TRIGGER salary_payments_log_trigger;

DELETE FROM salary_payments
WHERE id = 1;

SELECT * FROM salarypayments_log;

-- 9
-- proc 1
DELIMITER $$

CREATE PROCEDURE process_gates()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE gate_name VARCHAR(50);
    DECLARE cur CURSOR FOR
        SELECT gate_number FROM gates;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO gate_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT gate_name;
    END LOOP;
    CLOSE cur;
END $$

DELIMITER ;

CALL process_gates();


-- proc 2
DELIMITER $$

CREATE PROCEDURE CheckUnderpaidEmployees(
    IN dept_name ENUM("administration", "pilots", "flight attendants", "workers"),
    IN min_salary DECIMAL(10, 2)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE emp_id INT;
    DECLARE emp_fname VARCHAR(255);
    DECLARE emp_lname VARCHAR(255);
    DECLARE emp_min_salary DECIMAL(10, 2);

    DECLARE emp_cursor CURSOR FOR
        SELECT e.id, e.first_name, e.last_name
        FROM employees e
        JOIN departments d ON e.department_id = d.id
        WHERE d.department_name = dept_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS underpaid_employees;
    CREATE TEMPORARY TABLE underpaid_employees (
        employee_id INT,
        first_name VARCHAR(255),
        last_name VARCHAR(255),
        lowest_salary DECIMAL(10, 2)
    );

    OPEN emp_cursor;

    read_loop: LOOP
        FETCH emp_cursor INTO emp_id, emp_fname, emp_lname;
        IF done THEN 
            LEAVE read_loop;
        END IF;
        
        SELECT MIN(amount)
        INTO emp_min_salary
        FROM salary_payments
        WHERE employee_id = emp_id;
        
        IF emp_min_salary < min_salary THEN
            INSERT INTO underpaid_employees (employee_id, first_name, last_name, lowest_salary)
            VALUES (emp_id, emp_fname, emp_lname, emp_min_salary);
        END IF;
    END LOOP;

    CLOSE emp_cursor;

    SELECT * FROM underpaid_employees;
END$$

DELIMITER ;
CALL CheckUnderpaidEmployees('workers', 100000.00);




