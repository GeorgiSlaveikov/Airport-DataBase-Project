DROP DATABASE IF EXISTS airport;
CREATE DATABASE airport;
USE airport;

CREATE TABLE departments (
	id INT PRIMARY KEY AUTO_INCREMENT,
    manager_id INT DEFAULT NULL,
    department_name ENUM("administration", "pilots", "flight attendants", "workers")
)Engine = Innodb;

CREATE TABLE employees (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    egn VARCHAR(10) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    position ENUM("manager", "admin", "pilot", "flight attendant", "worker"),
    department_id INT NOT NULL,
    CONSTRAINT FOREIGN KEY (department_id) 
		REFERENCES departments(id)
)Engine = Innodb;


ALTER TABLE departments
ADD CONSTRAINT fk_manager
FOREIGN KEY (manager_id) REFERENCES Employees(id)
    ON DELETE SET NULL;

CREATE TABLE salary_payments (
	id INT PRIMARY KEY AUTO_INCREMENT,
    amount DECIMAL(10, 2) NOT NULL,
    month INT NOT NULL,
    year YEAR NOT NULL,
    employee_id INT NOT NULL,
    dateOfPayment DATETIME NOT NULL,
    CONSTRAINT FOREIGN KEY(employee_id) 
		REFERENCES employees(id)
)Engine = Innodb;

CREATE TABLE airplanes (
	id INT PRIMARY KEY AUTO_INCREMENT,
	registration_number VARCHAR(100) NOT NULL UNIQUE,
    brand VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    manifacture_date DATE NOT NULL,
    manifacture_year INT NOT NULL,
    passenger_capacity INT NOT NULL,
    flight_hours INT NOT NULL,
    weight DECIMAL(10, 2) NOT NULL
)Engine = Innodb;

CREATE TABLE maintenance(
	id INT PRIMARY KEY AUTO_INCREMENT,
    maintenance_date DATE NOT NULL, 
	maintenance_year INT NOT NULL,
    description TEXT,
    cost DECIMAL(10, 2) NOT NULL,
    airplane_id INT NOT NULL,
    CONSTRAINT FOREIGN KEY(airplane_id) 
		REFERENCES airplanes(id)
)Engine = Innodb;

CREATE TABLE flights (
	id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(255) NOT NULL UNIQUE,
    origin VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    departure_datetime DATETIME NOT NULL, 
    arrival_datetime DATETIME NOT NULL,
    flight_status ENUM ("departed", "landed", "on air", "boarding"),
    airplane_id INT NOT NULL,
    CONSTRAINT FOREIGN KEY (airplane_id) 
		REFERENCES airplanes(id)
)Engine = Innodb;

CREATE TABLE flight_employee (
    flight_id INT NOT NULL, 
    employee_id INT NOT NULL, 
    PRIMARY KEY(flight_id,employee_id),
    CONSTRAINT FOREIGN KEY(flight_id) 
		REFERENCES flights(id),
	CONSTRAINT FOREIGN KEY(employee_id) 
		REFERENCES employees(id)
)Engine = Innodb;

CREATE TABLE passengers (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    passport_number VARCHAR(20) NOT NULL UNIQUE,
    nationality VARCHAR(100) NOT NULL,
    birthdate DATE
)Engine = Innodb;

CREATE TABLE tickets (
	id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    class ENUM("economy", "business", "first") NOT NULL,
    CONSTRAINT FOREIGN KEY (passenger_id) 
		REFERENCES passengers(id),
    CONSTRAINT FOREIGN KEY (flight_id) 
		REFERENCES flights(id)
)Engine = Innodb;

CREATE TABLE baggage (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    weight DECIMAL(10, 2) NOT NULL,
    type ENUM('checked', 'carry-on') NOT NULL,
    status ENUM('loaded', 'in transit', 'lost') DEFAULT 'in transit',
	CONSTRAINT FOREIGN KEY (ticket_id) 
		REFERENCES tickets(id)
)Engine = Innodb;

CREATE TABLE gates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    gate_number VARCHAR(10) NOT NULL UNIQUE,
    terminal VARCHAR(10) NOT NULL,
    status ENUM('available', 'occupied', 'maintenance') DEFAULT 'available'
)Engine = Innodb;

CREATE TABLE boarding_passes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    gate_id INT NOT NULL,
    boarding_time DATETIME NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    CONSTRAINT FOREIGN KEY (ticket_id) 
        REFERENCES tickets(id),
    CONSTRAINT FOREIGN KEY (gate_id) 
        REFERENCES gates(id)
)Engine = Innodb;

CREATE TABLE runways (
    id INT PRIMARY KEY AUTO_INCREMENT,
    runway_code VARCHAR(10) NOT NULL UNIQUE,
    length_meters INT NOT NULL,
    status ENUM('active', 'inactive', 'under maintenance') DEFAULT 'active'
)Engine = Innodb;

CREATE TABLE takeoffs_landings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    runway_id INT NOT NULL,
    event_type ENUM('takeoff', 'landing') NOT NULL,
    event_time DATETIME NOT NULL,
    CONSTRAINT FOREIGN KEY (flight_id) 
        REFERENCES flights(id),
    CONSTRAINT FOREIGN KEY (runway_id) 
        REFERENCES runways(id)
)Engine = Innodb;

CREATE TABLE shuttle_buses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    bus_number VARCHAR(20) NOT NULL UNIQUE,
    capacity INT NOT NULL,
    status ENUM('available', 'in use', 'maintenance') DEFAULT 'available',
    driver_id INT DEFAULT NULL,
    assigned_flight_id INT DEFAULT NULL,
    CONSTRAINT FOREIGN KEY (driver_id)
        REFERENCES employees(id)
        ON DELETE SET NULL,
    CONSTRAINT FOREIGN KEY (assigned_flight_id)
        REFERENCES flights(id)
        ON DELETE SET NULL
)Engine = Innodb;

create table salarypayments_log(
id INT PRIMARY KEY AUTO_INCREMENT,
operation ENUM('INSERT','UPDATE','DELETE') not null,
old_salaryAmount DECIMAL,
new_salaryAmount DECIMAL,
old_month INT,
new_month INT,
old_year INT,
new_year INT,
old_employee_id INT,
new_employee_id INT,
old_dateOfPayment DATETIME,
new_dateOfPayment DATETIME,
dateOfLog DATETIME
)Engine = Innodb;

INSERT INTO departments (department_name) VALUES 
('administration'),
('pilots'),
('flight attendants'),
('workers');

INSERT INTO employees (first_name, last_name, egn, phone, email, position, department_id) VALUES 
('Ivan', 'Marinov', '1234567890', '123-456-7890', 'ivan@airport.com', 'manager', 1),
('Stoyan', 'Georgiev', '2345678901', '234-567-8901', 'stoyan@airport.com', 'admin', 1),
('Martin', 'Petrov', '3456789012', '345-678-9012', 'martin@airport.com', 'pilot', 2),
('Ivana', 'Kirilova', '4567890123', '456-789-0123', 'ivana@airport.com', 'flight attendant', 3),
('Radina', 'Mirovska', '5678901234', '567-890-1234', 'radina@airport.com', 'worker', 4);

UPDATE departments SET manager_id = 1 WHERE id = 1; 
UPDATE departments SET manager_id = 3 WHERE id = 2;
UPDATE departments SET manager_id = 4 WHERE id = 3; 
UPDATE departments SET manager_id = 5 WHERE id = 4;

INSERT INTO salary_payments (amount, month, year, employee_id, dateOfPayment) VALUES
(4000.00, 2, 2025, 5, '2025-02-28'),
(5200.00, 4, 2025, 1, '2025-04-01'),
(3600.00, 2, 2025, 2, '2025-02-28'),
(6100.00, 3, 2025, 3, '2025-03-31'),
(3300.00, 3, 2025, 4, '2025-03-31');

INSERT INTO airplanes (registration_number, brand, model, manifacture_date, 
manifacture_year, passenger_capacity, flight_hours, weight) VALUES 
('N123AA', 'Boeing', '737', '2015-06-15', 2015, 180, 12000, 41000.50),
('N456BB', 'Airbus', 'A320', '2018-09-23', 2018, 150, 8500, 42000.75);

INSERT INTO maintenance (maintenance_date, maintenance_year, description, 
cost, airplane_id) VALUES 
('2024-12-01', 2024, 'Routine engine check', 5000.00, 1),
('2025-01-15', 2025, 'Hydraulic system replacement', 12000.00, 2);

INSERT INTO flights (flight_number, origin, destination, departure_datetime, arrival_datetime, 
flight_status, airplane_id) VALUES 
('AA101', 'New York', 'London', '2025-04-20 14:30:00', '2025-04-21 02:00:00', 'boarding', 1),
('BA202', 'Los Angeles', 'Paris', '2025-04-22 09:00:00', '2025-04-22 20:00:00', 'boarding', 2);

INSERT INTO flight_employee (flight_id, employee_id) VALUES 
(1, 3),
(1, 4),
(2, 3),
(2, 5);

INSERT INTO passengers (first_name, last_name, passport_number, nationality, birthdate) VALUES 
('Tom', 'Hanks', 'M12345678', 'USA', '1960-07-09'),
('Marina', 'Georgieva', 'B98765432', 'BUL', '1997-04-15');

INSERT INTO tickets (ticket_number, passenger_id, flight_id, seat_number, price, class) VALUES 
('TK001', 1, 1, '12A', 1200.00, 'business'),
('TK002', 2, 2, '15B', 950.00, 'economy');

INSERT INTO baggage (ticket_id, weight, type, status) VALUES 
(1, 23.5, 'checked', 'loaded'),
(2, 7.8, 'carry-on', 'in transit');

INSERT INTO gates (gate_number, terminal, status) VALUES 
('A1', 'T1', 'available'),
('B2', 'T2', 'occupied');

INSERT INTO boarding_passes (ticket_id, gate_id, boarding_time, seat_number) VALUES 
(1, 1, '2025-04-20 13:45:00', '12A'),
(2, 2, '2025-04-22 08:15:00', '15B');

INSERT INTO runways (runway_code, length_meters, status) VALUES 
('RW1', 3500, 'active'),
('RW2', 4000, 'active');

INSERT INTO takeoffs_landings (flight_id, runway_id, event_type, event_time) VALUES 
(1, 1, 'takeoff', '2025-04-20 14:40:00'),
(2, 2, 'takeoff', '2025-04-22 09:15:00');

INSERT INTO shuttle_buses (bus_number, capacity, status, driver_id, assigned_flight_id) VALUES 
('BUS001', 50, 'in use', 5, 1),
('BUS002', 40, 'available', NULL, NULL);





