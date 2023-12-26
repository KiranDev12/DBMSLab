-- Customer (Cust#:int, cname: string, city: string)
-- Order (order#:int, odate: date, cust#: int, order-amt: int)
-- Order-item (order#:int, Item#: int, qty: int)
-- Item (item#:int, unitprice: int)
-- Shipment (order#:int, warehouse#: int, ship-date: date)
-- Warehouse (warehouse#:int, city: string)

create table if not exists Customers (
	cust_id int primary key,
	cname varchar(35) not null,
	city varchar(35) not null
);

create table if not exists Orders (
	order_id int primary key,
	odate date not null,
	cust_id int,
	order_amt int not null,
	foreign key (cust_id) references Customers(cust_id) on delete cascade
);

create table if not exists Items (
	item_id  int primary key,
	unitprice int not null
);

create table if not exists OrderItems (
	order_id int not null,
	item_id int not null,
	qty int not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (item_id) references Items(item_id) on delete cascade
);

create table if not exists Warehouses (
	warehouse_id int primary key,
	city varchar(35) not null
);

create table if not exists Shipments (
	order_id int not null,
	warehouse_id int not null,
	ship_date date not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (warehouse_id) references Warehouses(warehouse_id) on delete cascade
);

INSERT INTO Customers VALUES
(0001, "Customer_1", "Mysuru"),
(0002, "Customer_2", "Bengaluru"),
(0003, "Kumar", "Mumbai"),
(0004, "Customer_4", "Dehli"),
(0005, "Customer_5", "Bengaluru");

INSERT INTO Orders VALUES
(001, "2020-01-14", 0001, 2000),
(002, "2021-04-13", 0002, 500),
(003, "2019-10-02", 0003, 2500),
(004, "2019-05-12", 0005, 1000),
(005, "2020-12-23", 0004, 1200);

INSERT INTO Items VALUES
(0001, 400),
(0002, 200),
(0003, 1000),
(0004, 100),
(0005, 500);

INSERT INTO Warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

INSERT INTO OrderItems VALUES 
(001, 0001, 5),
(002, 0005, 1),
(003, 0005, 5),
(004, 0003, 1),
(005, 0004, 12);

INSERT INTO Shipments VALUES
(001, 0002, "2020-01-16"),
(002, 0001, "2021-04-14"),
(003, 0004, "2019-10-07"),
(004, 0003, "2019-05-16"),
(005, 0005, "2020-12-23");


-- List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
select o.order_id, s.ship_date from Orders o, Shipments s, Warehouses w where o.order_id=s.order_id and s.warehouse_id=w.warehouse_id and w.warehouse_id=0002;


-- List the Warehouse information from which the Customer named "Kumar" was supplied his 
-- orders. Produce a listing of Order#, Warehouse#. 
select o.order_id, w.warehouse_id from Orders o, Warehouses w, Customers c, Shipments s where o.order_id=s.order_id and o.cust_id=c.cust_id and s.warehouse_id=w.warehouse_id and c.cname="Kumar";


-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total 
-- number of orders by the customer and the last column is the average order amount for that 
-- customer. (Use aggregate functions) 
select cname, COUNT(distinct order_id) as NumberOfOrder, AVG(order_amt) as AvgOfOrders
from Customers c, Orders o
where o.cust_id=o.cust_id group by cname; 


-- Delete all orders for customer named "Kumar".
delete from Orders where cust_id = (select cust_id from Customers where cname like "%Kumar%");

-- Find the item with max unit price 
select * from Items where unitprice = (select MAX(unitprice) from Items);

-- A trigger that updates order_amout based on quantity and unitprice of order_item
DELIMITER $$

CREATE TRIGGER UpdateOrderAmt
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET order_amt = new.qty * (SELECT unitprice FROM Items WHERE item_id = new.item_id)
    WHERE Orders.order_id = new.order_id;
END;

$$
DELIMITER ;

-- Create a view to display orderID and shipment date of all orders shipped from a warehouse 5. 
create view warehouse5 as 
select o.order_id, s.ship_date from Orders o, Shipments s, Warehouses w where o.order_id=s.order_id and s.warehouse_id=w.warehouse_id and w.warehouse_id=0005;
