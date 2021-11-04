--------------------TP 3 : Procédures, Fonctions et Déclencheurs--------------------
----------------------------------SEDDOUKI  FAOUZI----------------------------------
----------------------------------       GI-2     ----------------------------------

------Partie 1 : Procédures

---Question 1:
SET SERVEROUTPUT ON;
DECLARE
    v_location_id WAREHOUSES.LOCATION_ID%type;
    v_warehouse_name WAREHOUSES.warehouse_name%type;
    PROCEDURE AddWarhouse(v_warehs_nm IN WAREHOUSES.warehouse_name%type, v_loc_id IN number) IS
BEGIN
    INSERT INTO WAREHOUSES(warehouse_name ,location_id)
    VALUES (v_warehs_nm, v_loc_id);
END;
BEGIN
    v_location_id := 23;
    v_warehouse_name := 'Faouzi';
    AddWarhouse(v_warehouse_name, v_location_id);
    dbms_output.put_line('Ajout avec succés !');
END;

---Question 2:
SET SERVEROUTPUT ON;
DECLARE
    v_warehouse_id WAREHOUSES.WAREHOUSE_ID%type;
    v_warehouse_name WAREHOUSES.WAREHOUSE_NAME%type;
    v_location_id WAREHOUSES.LOCATION_ID%type;
    PROCEDURE UpdateWarehouse (v_wid IN WAREHOUSES.WAREHOUSE_ID%type, v_wnm IN WAREHOUSES.WAREHOUSE_NAME%type, v_lid IN WAREHOUSES.LOCATION_ID%type) IS
    BEGIN
        UPDATE WAREHOUSES
        SET WAREHOUSE_ID = v_wid, WAREHOUSE_NAME = v_wnm WHERE LOCATION_ID = v_lid;
    END;
BEGIN
    v_warehouse_id := '&v_warehouse_id';
    v_warehouse_name := '&v_warehouse_name';
    v_location_id := '&v_location_id';
    UpdateWarehouse(v_warehouse_id, v_warehouse_name , v_location_id);
END;

---Question 3:
SET SERVEROUTPUT ON;
DECLARE
    v_warehouse_id WAREHOUSES.WAREHOUSE_ID%type;
    PROCEDURE DeleteWarehouse (v_wid IN WAREHOUSES.WAREHOUSE_ID%type) IS
    BEGIN
        DELETE FROM WAREHOUSES
        WHERE WAREHOUSE_ID = v_wid;
    END;
BEGIN
    v_warehouse_id := '&v_warehouse_id';
    DeleteWarehouse(v_warehouse_id);
    dbms_output.put_line('Delete avec succés !');
END;

---Question 4:
SET SERVEROUTPUT ON;
DECLARE
    v_location_id WAREHOUSES.LOCATION_ID%type;
    PROCEDURE WarehousLocation (v_lid IN WAREHOUSES.LOCATION_ID%type) IS
    CURSOR searchwarhouses IS 
    SELECT WAREHOUSE_NAME FROM WAREHOUSES WHERE LOCATION_ID = v_lid;
    name_warehouse WAREHOUSES.WAREHOUSE_NAME%type;
    BEGIN
        OPEN searchwarhouses;
        LOOP
            FETCH searchwarhouses INTO name_warehouse;
            EXIT WHEN searchwarhouses%NOTFOUND;
            dbms_output.put_line('Warehouse name :' || name_warehouse);
        END LOOP;
        CLOSE searchwarhouses;
    END;
BEGIN
    v_location_id := '&v_location_id';
    dbms_output.put_line('Pour ' || v_location_id || ' :');
    WarehousLocation(v_location_id);
END;

---Question 5:
SET SERVEROUTPUT ON;
DECLARE
    v_employee_id ORDERS.SALESMAN_ID%type;
    PROCEDURE empCA (v_eid IN ORDERS.SALESMAN_ID%type) IS
    TYPE r_emp_variables IS RECORD 
    (
        emp_id ORDERS.SALESMAN_ID%type,
        order_id ORDERS.ORDER_ID%type,
        ca_order ORDER_ITEMS.UNIT_PRICE%type
     );
     r_emp r_emp_variables;
    CURSOR c_emp IS 
        SELECT SALESMAN_ID, ORDERS.ORDER_ID, SUM(QUANTITY * UNIT_PRICE) 
        FROM ORDERS JOIN ORDER_ITEMS 
        ON ORDERS.ORDER_ID = ORDER_ITEMS.ORDER_ID 
        WHERE SALESMAN_ID =  v_eid
        GROUP BY SALESMAN_ID, ORDERS.ORDER_ID;
    ca_total NUMBER(10,2) := 0;
    BEGIN
        OPEN c_emp;
        LOOP
            FETCH c_emp INTO r_emp;
            EXIT WHEN c_emp%NOTFOUND;
            ca_total := ca_total + r_emp.ca_order;
        END LOOP;
        CLOSE c_emp;
        dbms_output.put_line(ca_total);
    END;
BEGIN
    v_employee_id := '&v_employee_id';
    dbms_output.put_line('Pour ' || v_employee_id || ' son CA est :');
    empCA(v_employee_id);
END;

------Partie 2 : Fonctions

---Question 1:
DECLARE
    v_id_customer CUSTOMERS.CUSTOMER_ID%type;
    prx_ttl number := 0;
    FUNCTION PrixTotal (id_cstmr IN CUSTOMERS.CUSTOMER_ID%type)
    RETURN number
    IS
    v_total number := 0;
    v_prix ORDER_ITEMS.UNIT_PRICE%type;
    v_order_id CUSTOMERS.CUSTOMER_ID%type;
    CURSOR c_customer IS SELECT ORDER_ID FROM ORDERS WHERE CUSTOMER_ID = id_cstmr;
    CURSOR c_prix IS SELECT QUANTITY * UNIT_PRICE FROM ORDER_ITEMS WHERE ORDER_ID = v_order_id;
    BEGIN 
        OPEN c_customer;
        LOOP
            FETCH c_customer INTO v_order_id;
            EXIT WHEN c_customer%NOTFOUND;
                OPEN c_prix;
                LOOP
                    FETCH c_prix INTO v_prix;
                    EXIT WHEN c_prix%NOTFOUND;
                    v_total := v_total + v_prix;
                END LOOP;
                CLOSE c_prix;
        END LOOP;
        CLOSE c_customer;
    RETURN v_total;
    END PrixTotal;
BEGIN
    v_id_customer := '&v_id_customer';
    prx_ttl := PrixTotal(v_id_customer);
    dbms_output.put_line('Le prix total des commandes du client ' || v_id_customer || ' est : ' || prx_ttl);
END;

--Question 2:
DECLARE
    nmbr_ttl number := 0;
    FUNCTION Pending_Orders
    RETURN number
    IS
    nmbr number;
    BEGIN
     SELECT COUNT(ORDER_ID) INTO nmbr FROM ORDERS WHERE STATUS = 'Pending';
    RETURN nmbr;
    END Pending_Orders;
BEGIN
    nmbr_ttl := Pending_Orders();
    dbms_output.put_line('Le nombre total des commandes qui ont un statut Pending est : ' || nmbr_ttl);
END;


------Partie 3 : Déclencheurs

---Question 1:
create or replace TRIGGER q1 
AFTER INSERT ON ORDERS 
FOR EACH ROW
begin

dbms_output.put_line('Order Informations : order id : ' || :NEW.ORDER_ID);
dbms_output.put_line('customer id : ' || :NEW.CUSTOMER_ID);
dbms_output.put_line('status : ' || :NEW.STATUS);
dbms_output.put_line('salseman id : ' || :NEW.SALESMAN_ID);
dbms_output.put_line('order date : ' || :NEW.ORDER_DATE);
end ;

---Question 2:
create or replace TRIGGER A1 
AFTER UPDATE ON INVENTORIES 
FOR EACH ROW
WHEN (NEW.QUANTITY < 10)
begin
dbms_output.put_line('Alerte de stocke');
end ;


---Question 3:
create or replace TRIGGER A2 
BEFORE UPDATE ON CUSTOMERS
FOR EACH ROW
DECLARE
    jr number := EXTRACT(DAY FROM SYSDATE);
begin
     if(jr >= 28 and jr <= 30) THEN 
     dbms_output.put_line('Modification Interdit :( ' || jr);
     :NEW.CREDIT_LIMIT := :OLD.CREDIT_LIMIT;
     END IF;
end ;

---Question 4:
create or replace TRIGGER A3 
BEFORE INSERT ON EMPLOYEES
FOR EACH ROW
DECLARE
PROCEDURE interdit IS
BEGIN
raise_application_error(-20710,'Ajout Interdit');
END;
begin
     if(:NEW.HIRE_DATE > SYSDATE) THEN 
     interdit();
     END IF;
end ;