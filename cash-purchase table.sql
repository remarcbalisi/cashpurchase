create table customer(
	custno serial not null primary key,
	custname varchar(60),
	address varchar(250),
	phone varchar(50));

create table staff(
	staffid serial not null primary key,
	staffname varchar(60),
	address varchar(50),
	position varchar(50));

create table product(
	prodno serial not null primary key,
	description TEXT,
	price FLOAT,
	qtyonhand INT,
	stocklimit INT,
	sale_dis INT);

create table purchase(
	orno serial not null primary key,
	ordate TIMESTAMP,
	amnt_due FLOAT,
	custno INT not null references customer(custno),
	staffid INT not null references staff(staffid),
	amnt_paid FLOAT,
	discount FLOAT);

create table items_purchased(
	orno INT not null references purchase(orno),
	prodno INT not null references product(prodno),
	cust_id int references customer(custno),
	qty INT);


create table Withdrawal_request(
  request_no serial4 primary key,
  request_date timestamp,
  staff_id int8 references Staff(staffid)
);

create table Warehouse_product(
  wh_prodno serial4 primary key,
  description text,
  qty_onhand int,
  qty_onorder int,
  wh_stocklimit int,
  delivery_price int8,
  selling_price int8
);

create table Product_request(
  id serial8 primary key,
  request_no int4 references Withdrawal_request(request_no),
  wh_prodno int4 references Warehouse_product(wh_prodno),
  qty_requested int8,
  qty_released int8
);
	