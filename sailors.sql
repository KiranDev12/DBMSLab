-- SAILORS (sid, sname, rating, age)
-- BOAT(bid, bname, color)
-- RSERVERS (sid, bid, date)

create table if not exists sailors(
	sid int primary key,
	sname varchar(35) not null,
	rating float not null,
	age int not null
);

create table if not exists boat(
	bid int primary key,
	bname varchar(35) not null,
	color varchar(25) not null
);

create table if not exists reserves(
	sid int not null,
	bid int not null,
	sdate date not null,
	foreign key (sid) references sailors(sid) on delete cascade,
	foreign key (bid) references boat(bid) on delete cascade
);

insert into sailors values
(1,"Albert", 9.2, 40),
(2, "Nakul", 8.2, 49),
(3, "Darshan", 9.5, 18),
(4, "Astorm Gowda", 5, 68),
(5, "Armstormin", 6.7, 19);

insert into boat values
(101,"Boat_1", "Green"),
(102,"Boat_2", "Red"),
(103,"Boat_3", "Blue");

insert into reserves values
(1,103,"2023-01-01"),
(1,102,"2023-02-01"),
(2,101,"2023-02-05"),
(3,102,"2023-03-06"),
(5,103,"2023-03-06"),
(1,101,"2023-03-06");


-- Find the colours of boats reserved by Albert 
select color 
from Sailors s, Boat b, reserves r 
where s.sid=r.sid and b.bid=r.bid and s.sname="Albert";

-- Find all the sailor sids who have rating atleast 8 or reserved boat 103
(select sid from sailors
where sailors.rating>=8)
UNION
(select sid from reserves
where reserves.bid=103);

-- Find the names of the sailor who have not reserved a boat whose name contains the string "storm". Order the name in the ascending order
select s.sname
from sailors s
where s.sid not in 
(select s1.sid from sailors s1, reserves r1 where r1.sid=s1.sid and s1.sname like "%storm%")
and s.sname like "%storm%"
order by s.name ASC;

--Find the name of the sailors who have reserved all boats
select sname from sailors s where not exists
	(select * from boat b where not exists
		(select * from reserves r where r.sid=s.sid and b.bid=r.bid));

-- Find the name and age of the oldest sailor. 
select sname, age from sailors s where age in (select MAX(age) from sailors s);

-- For each boat which was reserved by atleast 2 sailors with age >= 40, find the bid and average age of such sailors
select b.bid, AVG(age) from sailors s, boat b, reserves r 
where r.sid=s.sid and r.bid=b.bid 
and s.age>=40 
group by bid having 2<=count(distinct r.sid);


-- Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.
create view reserved as
select distinct bname, color
from sailors s, boat b, reserves r
where s.sid=r.sid and b.bid=r.bid and s.rating=9.5;


-- A trigger that prevents boats from being deleted If they have active reservations.

DELIMITER //

CREATE TRIGGER CheckAndDelete
BEFORE DELETE ON boat
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM reserves WHERE reserves.bid = old.bid) THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Boat is reserved and cannot be deleted';
    END IF;
END;

//

DELIMITER ;