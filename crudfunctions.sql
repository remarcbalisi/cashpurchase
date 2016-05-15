create or replace function purchase_item(par_orno int, par_prodno int, par_cust_id int, par_qty int) returns text as
	$$
		declare local_response text; local_orno int;

		begin
			select into local_orno orno from items_purchased where orno = par_orno;

			if local_orno isnull then
				insert into items_purchased (orno, prodno, cust_id, qty) values (par_orno, par_prodno, par_cust_id, par_qty);
				local_response = 'Ok';

			else
				update product
					set qtyonhand = qtyonhand - par_qty
					where prodno = par_prodno;

				update purchase
					set amnt_due = (select amnt_due from purchase where orno = par_orno) + (par_qty * (select price from product where prodno = par_prodno))
					where orno = par_orno;

				update purchase
					set discount = (select sale_dis from product where prodno = par_prodno) * par_qty
					where orno = par_orno;

				update purchase
					set amnt_paid = (select amnt_paid from purchase where orno = par_orno) + ( ( (select price from product where prodno = par_prodno) * par_qty ) - ((select discount from purchase where orno=par_orno)/100) * (select price from product where prodno = par_prodno) )
					where orno = par_orno;
					local_response = 'Ok';
			end if;
			return local_response;
		end;
	$$
		language 'plpgsql';

create or replace function add_to_cart(par_orno int, par_prodno int, par_cust_id int, par_qty int) returns text as
	$$
		declare local_response text; local_orno int;

		begin
			select into local_orno orno from cart where orno = par_orno;

			if local_orno isnull then
				insert into cart (orno, cust_id) values (par_orno, par_cust_id);
				local_response = 'Ok';

			else

				update cart
					set amnt_due = (select amnt_due from cart where orno = par_orno) + (par_qty * (select price from product where prodno = par_prodno))
					where orno = par_orno;

				update cart
					set discount = (select discount from cart where orno = par_orno) + (select sale_dis from product where prodno = par_prodno) * par_qty
					where orno = par_orno;

				update cart
					set amnt_paid = (select amnt_paid from purchase where orno = par_orno) + ( ( ((select sale_dis from product where prodno=par_prodno)*par_qty) /100) * (par_qty * (select price from product where prodno = par_prodno)) )
					where orno = par_orno;
					local_response = 'Ok';
			end if;
			return local_response;
		end;
	$$
		language 'plpgsql';

create or replace function check_product_stock(in par_prodno int, out int, out int) returns setof record as
	$$
		select qtyonhand, stocklimit from product where prodno = par_prodno;
	$$
		language 'sql';

create or replace function add_transaction(par_amnt_due float, par_custno int, par_staffid int, par_amnt_paid float, par_discount float) returns int as
	$$
		declare local_response text; local_orno int;

		begin
			insert into purchase (ordate, amnt_due, custno, staffid, amnt_paid, discount) values ('now', par_amnt_due, par_custno, par_staffid, par_amnt_paid, par_discount);
			select into local_orno orno from purchase where orno = (SELECT currval(pg_get_serial_sequence('purchase','orno')));
			return local_orno;
		end;
	$$
		language 'plpgsql';

create or replace function get_transaction(in par_orno int, out int, out timestamp, out float, out int, out int, out float, out float) returns setof record as
	$$
		select orno, ordate, amnt_due, custno, staffid, amnt_paid, discount from purchase where orno = par_orno;
	$$
		language 'sql';

create or replace function get_customers(out int, out varchar, out varchar, out varchar) returns setof record as
	$$
		select custno, custname, address, phone from customer;
	$$
		language 'sql';

create or replace function get_staffs(out int, out varchar, out varchar, out varchar) returns setof record as
	$$
		select staffid, staffname, address, position from staff;
	$$
		language 'sql';

create or replace function get_products(out int, out text, out float, out int, out int, out int) returns setof record as
	$$
		select prodno, description, price, qtyonhand, stocklimit, sale_dis from product;
	$$
		language 'sql';

create or replace function add_products(par_description text, par_price float, par_qtyonhand int, par_stocklimit int, par_sale_dis int) returns text as
	$$ declare local_response text;
		begin
			insert into product (description, price, qtyonhand, stocklimit, sale_dis) values (par_description, par_price, par_qtyonhand, par_stocklimit, par_sale_dis);
				local_response = 'OK';
			return local_response;
		end;
	$$
		language 'plpgsql';
