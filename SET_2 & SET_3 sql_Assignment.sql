use assignment;
#QUE 1. select all employees in department 10 whose salary is greater than 3000. [table: employee]

select* from employee;
select* from employee where deptno = 10 and salary>3000;

---------------------------------------------------------------------------

#Ques 2. The grading of students based on the marks they have obtained is done as follows:
-- 2.a How many students have graduated with first class?

select*from students;

select count(*)marks from students
where marks>50 and marks<60;

-- 2b. How many students have obtained distinction? [table: students]

select count(*)marks
from students
where marks>80 and marks<100;

------------------------------------------------------------------------------------------------------

#Ques 3. Get a list of city names from station with even ID numbers only. 
-- Exclude duplicates from your answer.[table: station]

select*from station;
SELECT	 distinct name, id 
from city where mod(id,2) =0;

-------------------------------------------------------------------------------------------------------------------------------------------------
#Ques 4. Find the difference between the total number of city entries in the table and the number of distinct city entries in the table. 
-- In other words, if N is the number of city entries in station, and N1 is the number of distinct city names in station, write a query to find the value of N-N1 from station.

select count(*) - count(distinct(city))
from station;

-------------------------------------------------------------------------------------------------------------------------------------------------
##Ques 5.a Query the list of CITY names starting with vowels (i.e., a, e, i, o, or u) from STATION. Your result cannot contain duplicates. [Hint: Use RIGHT() / LEFT() methods ]

select distinct city
from station
where left(city,1) in ('A','E','I','O','U');

-- 5.b Query the list of CITY names from STATION which have vowels (i.e., a, e, i, o, and u) as both their first and last characters. Your result cannot contain duplicates.

select distinct city
from station
where left(city,1) in ('A','E','I','O','U')
AND 	right(city,1) in('A','E','I','O','U');

-- 5.c Query the list of CITY names from STATION that do not start with vowels. Your result cannot contain duplicates.

select distinct city
from station
where left(city,1) not in ('A','E','I','O','U');

-- 5.d Query the list of CITY names from STATION that either do not start with vowels or do not end with vowels. Your result cannot contain duplicates. [table: station]

select distinct city
from station
where left(city,1) not in ('A','E','I','O','U')
AND 	right(city,1) not in('A','E','I','O','U');

------------------------------------------------------------------------------------------------------------------------------------------------------------
#Ques 6. Write a query that prints a list of employee names having a salary greater than $2000 per month who have been employed for less than 36 months. Sort your result by descending order of salary. [table: emp]

select*from emp;

SELECT CONCAT(FIRST_NAME,'',LAST_NAME) AS EMPLOYEE,
       CONCAT (SALARY,'$') AS 'SALARY($)',
       HIRE_DATE,
       TIMESTAMPDIFF(MONTH,HIRE_DATE,CURDATE()) AS 'TOTAL_MONTHS_JOINED'
FROM EMP
WHERE SALARY > 2000
HAVING TOTAL_MONTHS_JOINED < 36
ORDER BY SALARY DESC;

-----------------------------------------------------------------------------------------------------------------------------------------------------------
#Ques 7. How much money does the company spend every month on salaries for each department? [table: employee]

SELECT * FROM employee;

select deptno, sum(salary) from employee group by deptno;

-----------------------------------------------------------------------------------------------------------------------------------

#Ques 8 How many cities in the CITY table have a Population larger than 100000. [table: city]

select count(district) from city where population>100000;
------------------------------------------------------------------------------------------------------------------------
#Ques 9. What is the total population of California? [table: city]
select sum(population) from city
where district="california";
-------------------------------------------------------------------------------------------------------------------------------------
#Ques 10. What is the average population of the districts in each country? 

select countrycode, avg(population) from city group by countrycode;
---------------------------------------------------------------------------------------------------------------------------------------

#Ques 11. Find the ordernumber, status, customernumber, customername and comments for all orders that are ‘Disputed=  [table: orders, customers]

SELECT 
    orders.orderNumber,
    orders.status,
    orders.customerNumber,
    customers.customerName,
    orders.comments
FROM
    orders
        INNER JOIN
    customers ON orders.customerNumber = customers.customerNumber where orders.status='Disputed';
    
    ---------------------------------------------------------------------------------------------------------
    ###########################SET-3 SQL ASSIGNMENT########################
    
    -- 1. Write a stored procedure that accepts the month and year as inputs and prints the ordernumber, orderdate and status of the orders placed in that month
    
     DELIMITER //
 create procedure status_order(IN order_month varchar(50) , IN order_year varchar(50))
 BEGIN
  Select orderDate , orders.status from orders where month(orderDate) = month(str_to_date(order_month , '%b')) and year(orderdate) = order_year ;
 END //
 
call status_order('Dec',2003);

-- 2. Write a stored procedure to insert a record into the cancellations table for all cancelled orders.

CREATE TABLE cancellations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    comments TEXT,
    ordernumber INT,
    customernumber INT,
    FOREIGN KEY (customernumber)
        REFERENCES customers (customernumber),
    FOREIGN KEY (ordernumber)
        REFERENCES orders (ordernumber)
); 

DELIMITER //
create procedure orders_cancelled()
BEGIN
insert into cancellations (ordernumber, customernumber ,comments) select ordernumber , customernumber , status from orders where status='cancelled';
END //


CALL orders_cancelled();

-- 3. a. Write function that takes the customernumber as input and returns the purchase_status based on the following criteria . [table:Payments]

DELIMITER $$
CREATE FUNCTION purchase_status(amount DECIMAL(10,2)) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
	DECLARE purchase_status VARCHAR(20);
    
    IF amount > 50000 THEN
		SET purchase_status = 'PLATINUM';
        
    ELSEIF (amount >= 25000 AND amount < 50000) THEN
        SET purchase_status = 'GOLD';
        
    ELSEIF amount < 25000 THEN
        SET purchase_status = 'SILVER';
        
    END IF;
	
	RETURN (purchase_status);
END$$

-- 3.b Write a query that displays customerNumber, customername and purchase_status from customers table.


alter table payments add foreign key (customernumber) references customers(customernumber);

desc payments;

select p.customernumber, customername , 
(CASE
        WHEN amount < 25000 THEN 'Silver'
        WHEN amount <= 50000 THEN 'Gold'
        WHEN amount > 50000 THEN 'Platinum'
    END)AS purchase_status from payments as p inner join customers as c on p.customernumber=c.customernumber;
    
    -- 4. Replicate the functionality of 'on delete cascade' and 'on update cascade' using triggers on movies and rentals tables. Note: Both tables - movies and rentals - don't have primary or foreign keys. Use only triggers to implement the above.
    
DELIMITER $$

CREATE TRIGGER after_movies_update
AFTER UPDATE
ON movies FOR EACH ROW
BEGIN
IF OLD.id <> new.id THEN
        INSERT INTO rentals(memid,first_name, last_name, movieid)
        VALUES(old.id, new.id);
    END IF;
    END$$
    
    DROP TRIGGER after_movies_update;
    
update rentals 
set movieid = 21
where memid = 6;

update rentals 
set movieid = 23
where memid = 7;

select * from rentals;


DELIMITER //
CREATE TRIGGER after_movies_delete
AFTER DELETE
ON movies FOR EACH ROW
BEGIN
delete from rentals
where movieid = old.id;
END //


DROP TRIGGER after_movies_delete;


UPDATE rentals
SET movieid = old.id

-- 5. Select the first name of the employee who gets the third highest salary. [table: employee]


SELECT 
    fname
FROM
    employee e1
WHERE
    2 = (SELECT 
            COUNT(DISTINCT salary)
        FROM
            employee e2
        WHERE
            e2.salary > e1.salary); 
            
-- 6. Assign a rank to each employee  based on their salary. The person having the highest salary has rank 1. [table: employee]
          
select *, rank() over (order by salary desc) as 'rank' from employee;
    
