-- PERSON (driver id#: string, name: string, address: string)
-- CAR (regno: string, model: string, year: int)
-- ACCIDENT (report_ number: int, acc_date: date, location: string)
-- OWNS (driver id#: string, regno: string)

CREATE TABLE IF NOT EXISTS person (
driver_id VARCHAR(255) primary key,
driver_name TEXT NOT NULL,
address TEXT NOT NULL,
);

CREATE TABLE IF NOT EXISTS car (
reg_no VARCHAR(255) primary key,
model TEXT NOT NULL,
c_year INTEGER,
);

CREATE TABLE IF NOT EXISTS accident (
report_no INTEGER primary key,
accident_date DATE,
location TEXT,
);

CREATE TABLE IF NOT EXISTS owns (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS participated (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
report_no INTEGER NOT NULL,
damage_amount FLOAT NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

INSERT INTO person VALUES
("D111", "Driver_1", "Kuvempunagar, Mysuru"),
("D222", "Smith", "JP Nagar, Mysuru"),
("D333", "Driver_3", "Udaygiri, Mysuru"),
("D444", "Driver_4", "Rajivnagar, Mysuru"),
("D555", "Driver_5", "Vijayanagar, Mysore");

INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2020),
("KA-20-BC-5674", "Mazda", 2017),
("KA-21-AC-5473", "Alto", 2015),
("KA-21-BD-4728", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

INSERT INTO accident VALUES
(43627, "2020-04-05", "Nazarbad, Mysuru"),
(56345, "2019-12-16", "Gokulam, Mysuru"),
(63744, "2020-05-14", "Vijaynagar, Mysuru"),
(54634, "2019-08-30", "Kuvempunagar, Mysuru"),
(65738, "2021-01-21", "JSS Layout, Mysuru"),
(66666, "2021-01-21", "JSS Layout, Mysuru");

INSERT INTO owns VALUES
("D111", "KA-20-AB-4223"),
("D222", "KA-20-BC-5674"),
("D333", "KA-21-AC-5473"),
("D444", "KA-21-BD-4728"),
("D222", "KA-09-MA-1234");

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 43627, 20000),
("D222", "KA-20-BC-5674", 56345, 49500),
("D333", "KA-21-AC-5473", 63744, 15000),
("D444", "KA-21-BD-4728", 54634, 5000),
("D222", "KA-09-MA-1234", 65738, 25000);

-- Find the total number of people who owned cars that were involved in accidents in 2021. 
select count(*) as totalPeople from person per, participated p, accident a 
where per.driver_id=p.driver_id and p.report_no=a.report_no and a.accident_date>"2021-01-01";

-- Find the number of accidents in which the cars belonging to “Smith” were involved. 
SELECT COUNT(DISTINCT a.report_no)
FROM accident a, participated ptd, person p
where a.report_no = ptd.report_no and p.driver_id = ptd.driver_id 
and p.driver_name = "Smith";

-- Add a new accident to the database; assume any values for required attributes.
insert into accident values(45562, "2024-04-05", "Mandya");

-- Delete the Mazda belonging to “Smith”.
delete from car
where model="Mazda" and reg_no in
(select car.reg_no from person p, owns o where p.driver_id=o.driver_id and o.reg_no=car.reg_no and p.driver_name="Smith");

--Update the damage amount for the car with license number “KA09MA1234” in the accident with report. 
update participated set damage_amount=10000 where reg_no="KA-09-MA-1234";

-- A view that shows models and year of cars that are involved in accident.
create view CarsInAccident as
select distinct model, c_year
from car c, participated p
where c.reg_no=p.reg_no;

-- A trigger that prevents a driver from participating in more than 3 accidents in a given year

DELIMITER //

CREATE TRIGGER PreventParticipation
BEFORE INSERT ON participated
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM participated WHERE driver_id = NEW.driver_id) >= 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver has already participated in 2 accidents';
    END IF;
END;

//

DELIMITER ;
