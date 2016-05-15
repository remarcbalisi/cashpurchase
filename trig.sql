-- NEW
-- Data type RECORD; variable holding the new database row for INSERT/UPDATE operations in row-level triggers. This variable is NULL in statement-level triggers and for DELETE operations.

-- OLD
-- Data type RECORD; variable holding the old database row for UPDATE/DELETE operations in row-level triggers. This variable is NULL in statement-level triggers and for INSERT operations.

-- TG_NAME
-- Data type name; variable that contains the name of the trigger actually fired.

-- TG_WHEN
-- Data type text; a string of BEFORE, AFTER, or INSTEAD OF, depending on the trigger's definition.

-- TG_LEVEL
-- Data type text; a string of either ROW or STATEMENT depending on the trigger's definition.

-- TG_OP
-- Data type text; a string of INSERT, UPDATE, DELETE, or TRUNCATE telling for which operation the trigger was fired.

-- TG_RELID
-- Data type oid; the object ID of the table that caused the trigger invocation.

-- TG_RELNAME
-- Data type name; the name of the table that caused the trigger invocation. This is now deprecated, and could disappear in a future release. Use TG_TABLE_NAME instead.

-- TG_TABLE_NAME
-- Data type name; the name of the table that caused the trigger invocation.

-- TG_TABLE_SCHEMA
-- Data type name; the name of the schema of the table that caused the trigger invocation.

-- TG_NARGS
-- Data type integer; the number of arguments given to the trigger procedure in the CREATE TRIGGER statement.

-- TG_ARGV[]
-- Data type array of text; the arguments from the CREATE TRIGGER statement. The index counts from 0. Invalid indexes (less than 0 or greater than or equal to tg_nargs) result in a null value.

-- ALTERING CONSTRAINS
--   ALTER TABLE purchase ALTER COLUMN discount type FLOAT;

-- SETTING VALUE
--	new.modification_time := now();
--**TOP NOTE --- DON'T MIND THIS ONE. THIS IS JUST A SOURCE CODE(cheat sheet).









-- problem: can't find out how to return text response from a trigger command.
-- case: when stockonhand reach stock limit
-- loc_res is defined but it's not being use(not returned) instead new is being returned.
create or replace function purchased() RETURNS trigger AS
	$$
	declare loc_res text; loc_stock int; loc_onhand int; loc_available int;
	BEGIN
		select into loc_stock stocklimit from product where prodno = new.prodno;
		select into loc_onhand qtyonhand from product where prodno = new.prodno;
		loc_available = loc_onhand - loc_stock;

		if loc_stock = loc_onhand or loc_available < new.qty or loc_onhand > loc_stock then
			insert into Withdrawal_request (staff_id) values ((select staffid from purchase where orno = new.orno));
			insert into Product_request (request_no, wh_prodno, qty_requested) values (( SELECT currval(pg_get_serial_sequence('Withdrawal_request','request_no')) ), new.prodno, 50);
		elsif tg_op = 'INSERT' THEN
			UPDATE product
					SET qtyonhand = qtyonhand - new.qty
					WHERE prodno = new.prodno;
			UPDATE purchase
					SET amnt_due = (select amnt_due from purchase where orno = new.orno) + (new.qty * (select price from product where prodno = new.prodno) )
					WHERE orno = new.orno;
			UPDATE purchase
					SET discount = (select sale_dis from product where prodno = new.prodno) * new.qty
					WHERE orno = new.orno;
			UPDATE purchase
					SET amnt_paid = (select amnt_due from purchase where orno = new.orno) - ( ((select discount from purchase where orno = new.orno)/100)*(select amnt_due from purchase where orno = new.orno) )
					WHERE orno = new.orno;
		else
			raise notice 'stockonhand reach the stock limit';
		END IF;
		return new;
	END
	$$ LANGUAGE 'plpgsql';

CREATE TRIGGER purchased_ins AFTER INSERT ON items_purchased FOR each ROW
EXECUTE PROCEDURE purchased();

create or replace function purchased() returns trigger as
	$$
		begin
			if tg_op = 'INSERT' then
				update product
					set qtyonhand = qtyonhand - new.qty
					where prodno = new.prodno;

				update purchase
					set amnt_due = (select amnt_due from purchase where orno = new.orno) + (new.qty * (select price from product where prodno = new.prodno))
					where orno = new.orno;

				update purchase
					set discount = (select sale_dis from product where prodno = new.prodno) * new.qty
					where orno = new.orno;

				update purchase
					set amnt_paid = (select amnt_paid from purchase where orno = new.orno) + ( ( (select price from product where prodno = new.prodno) * new.qty ) - ((select discount from purchase where orno=new.orno)/100) * (select price from product where prodno = new.prodno) )
					where orno = new.orno;
			end if;
			return new;
		end;
	$$
		LANGUAGE 'plpgsql';

create trigger purchase_ins AFTER insert on items_purchased FOR each ROW
EXECUTE PROCEDURE purchased();
-- create or replace function warehouse() returns trigger as
-- 	$$
-- 		declare loc_stock int; loc_onhand int; loc_onorder int; loc_available int;

-- 		BEGIN
-- 			select into loc_stock wh_stocklimit from Warehouse_product where wh_prodno = new.wh_prodno;
-- 			select into loc_onhand qty_onhand from Warehouse_product where wh_prodno = new.wh_prodno;
-- 			loc_available = loc_onhand - loc_stock;

-- 			if new.qty_requested > loc_available then
-- 				raise notice 'limited stock';

-- 			elsif tg_op = 'INSERT' then
-- 				UPDATE Warehouse_product
-- 					SET qtyonhand = qtyonhand - new.qty_requested
-- 					WHERE wh_prodno = new.wh_prodno;
-- 				UPDATE Warehouse_product
-- 						SET qty_onorder = new.qty_requested
-- 						WHERE orno = new.orno;

-- 			else
-- 			raise notice 'stockonhand reach the stock limit';

-- 			end if;
-- 			return new;
-- 		END
-- 	$$ LANGUAGE plpgsql;

-- CREATE TRIGGER warehouse_ins AFTER INSERT ON Product_request FOR each ROW
-- EXECUTE PROCEDURE warehouse();
