use salemanagerment;

insert into 
salesman(Salesman_Number,Salesman_Name,Address,City,Pincode,Province,salary,sales_target,Target_Achieved,Phone)
values
('S007','Quang','Chanh My','Da Lat',700032,'Lam Dong',25000,90,95,'0900853487'),
('S008','Hoa','Hoa Phu','Thu Dau Mot',700051,'Binh Duong',13500,50,75,'0998213659');

insert into 
salesorder(Order_Number,Order_Date,Client_Number,Salesman_Number,Delivery_Status,Delivery_Date,Order_Status)
values
('O20015','2022-05-12','C108','S007','On Way', '2022-05-15','Successful'),
('O20016','2022-05-16','C109','S008','Ready to Ship',null,'In Process');

insert into 
salesorderdetails(Order_Number,Product_Number,Order_Quantity)
values
('O20015','P1008',15),
('O20015','P1007',10),
('O20016','P1007',20),
('O20016','P1003',5);

-- 1. Display the clients (name) who lives in same city.
select a.Client_Name from clients a inner join clients b 
on a.City = b.City and a.Client_Name <> b.Client_Name;
-- 2. Display city, the client names and salesman names who are lives in “Thu Dau Mot” city.
select Client_Name from clients where city = 'Thu Dau Mot'
union
select Salesman_Name from salesman where city = 'Thu Dau Mot';
-- 3. Display client name, client number, order number, salesman number, and product number for each
-- order.
select c.Client_Name,so.Client_Number,so.Salesman_Number,so.Order_Number,p.Product_Name from salesorder so
inner join clients c on c.Client_Number = so.Client_Number
inner join products p on p.Product_Number in (select Product_Number from salesorderdetails where Order_Number = so.Order_Number);
-- 4. Find each order (client_number, client_name, order_number) placed by each client.
select c.Client_Name,c.Client_Number,so.Order_Number from clients c left join salesorder so on c.Client_Number = so.Client_Number;
-- 5. Display the details of clients (client_number, client_name) and the number of orders which is paid by
-- them.
select count(*) as `number of orders`, c.Client_Number,c.Client_Name
from salesorder so  inner join  clients c
					on c.Client_Number = so.Client_Number
where Order_Status = 'Successful'
group by so.Client_Number;
-- 6. Display the details of clients (client_number, client_name) who have paid for more than 2 orders.
select count(*) as `number of orders`, c.Client_Number,c.Client_Name
from salesorder so  inner join  clients c
					on c.Client_Number = so.Client_Number 
where Order_Status = 'Successful'
group by so.Client_Number
having count(*) > 2;

-- 7. Display details of clients who have paid for more than 1 order in descending order of client_number.
select c.*
from salesorder so  inner join  clients c
					on c.Client_Number = so.Client_Number
where Order_Status = 'Successful'
group by so.Client_Number
having count(*) > 1
order by c.Client_Number desc;
-- 8. Find the salesman names who sells more than 20 products.
select s.Salesman_Name,rs.sum
from salesman s inner join (select so.Salesman_Number,sum(sod.Order_Quantity) as sum from salesorder so 
                left join salesorderdetails sod 
                on sod.Order_Number = so.Order_Number
                group by so.Salesman_Number) rs on s.salesman_number = rs.Salesman_Number
where rs.sum > 20;
-- 9. Display the client information (client_number, client_name) and order number of those clients who
-- have order status is cancelled.
select count(*) as `number of orders cancelled`, c.Client_Number,c.Client_Name
from salesorder so  inner join  clients c
					on c.Client_Number = so.Client_Number
where Order_Status = 'Cancelled'
group by so.Client_Number;
-- 10. Display client name, client number of clients C101 and count the number of orders which were
-- received “successful”.
select count(*) `as number of orders`, c.Client_Number,c.Client_Name
from salesorder so  inner join  clients c
					on c.Client_Number = so.Client_Number and c.Client_Number ='C101'
where Order_Status = 'Successful'
group by so.Client_Number;
-- 11. Count the number of clients orders placed for each product.
select rs.Product_Number, count(*) as client from (select distinct so.Client_Number,sod.Product_Number from salesorder so 
                right join salesorderdetails sod 
                on sod.Order_Number = so.Order_Number) rs
group by rs.Product_Number;
-- 12. Find product numbers that were ordered by more than two clients then order in descending by product
-- number.
select rs.Product_Number, count(*) as clients from (select distinct so.Client_Number,sod.Product_Number from salesorder so 
                right join salesorderdetails sod 
                on sod.Order_Number = so.Order_Number) rs
group by rs.Product_Number
having clients > 2
order by Product_Number desc;
-- b) Using nested query with operator (IN, EXISTS, ANY and ALL)
-- 13. Find the salesman’s names who is getting the second highest salary.
select Salesman_Name from salesman
where Salesman_Number not in (select Salesman_Number from salesman where Salary = (select max(salary) from salesman))
order by Salary desc
limit 1;
-- 14. Find the salesman’s names who is getting second lowest salary.
select Salesman_Name from salesman
where Salesman_Number not in (select Salesman_Number from salesman where Salary = (select min(salary) from salesman))
order by Salary
limit 1;
-- 15. Write a query to find the name and the salary of the salesman who have a higher salary than the
-- salesman whose salesman number is S001.
select Salesman_Name, Salary from salesman where salary > (select salary from salesman where Salesman_Number='S001');
-- 16. Write a query to find the name of all salesman who sold the product has number: P1002.
select s.Salesman_Name from salesman s where s.Salesman_Number = any (select so.Salesman_Number 
					from salesorder so inner join salesorderdetails sod 
					on so.Order_Number = sod.Order_Number
                    where sod.Product_Number = 'P1002');
-- 17. Find the name of the salesman who sold the product to client C108 with delivery status is “delivered”.
select s.Salesman_Name from salesman s where s.Salesman_Number = any (select so.Salesman_Number 
					from salesorder so inner join clients c 
					on so.Client_Number = c.Client_Number and so.Delivery_Status='Delivered'
                    where c.Client_Number = 'C108');
                    select * from salesorder;
-- 18. Display lists the ProductName in ANY records in the sale Order Details table has Order Quantity equal
-- to 5.
select p.Product_Name from products p 
where p.Product_Number in (select Product_Number from salesorderdetails sod where sod.Order_Quantity=5);
-- 19. Write a query to find the name and number of the salesman who sold pen or TV or laptop.
select distinct s.Salesman_Name,s.Salesman_Number from salesman s 
				inner join salesorder so on s.Salesman_Number = so.Salesman_Number
				inner join salesorderdetails sod on so.Order_Number = sod.Order_Number
                inner join products p on p.Product_Number = sod.Product_Number
                where p.Product_Name in('TV','laptop','pen');
-- 20. Lists the salesman’s name sold product with a product price less than 800 and Quantity_On_Hand
-- more than 50.
select distinct s.Salesman_Name from salesman s 
				inner join salesorder so on s.Salesman_Number = so.Salesman_Number
				inner join salesorderdetails sod on so.Order_Number = sod.Order_Number
                inner join products p on p.Product_Number = sod.Product_Number
                where p.Cost_Price < 800 and p.Quantity_On_Hand > 50;
-- 21. Write a query to find the name and salary of the salesman whose salary is greater than the average
-- salary.
select Salesman_Name salary from salesman
where salary > ( select avg(salary) from salesman );
-- 22. Write a query to find the name and Amount Paid of the clients whose amount paid is greater than the
-- average amount paid.
select Client_Name,Amount_Paid from clients where Amount_Paid > (select avg(Amount_Paid) from clients) ;
-- II. Additional excersice:
-- 23. Find the product price that was sold to Le Xuan.
select p.Sell_Price from products p 
					inner join salesorderdetails sod on sod.Product_Number = p.Product_Number
					inner join salesorder so on so.Order_Number = sod.Order_Number
                    inner join clients c on c.Client_Number = so.Client_Number
                    where c.Client_Name='Le Xuan';
-- 24. Determine the product name, client name and amount due that was delivered.
select c.Client_Name,p.Product_Name,c.Amount_Due from salesorder so 
				inner join clients c on c.Client_Number = so.Client_Number
                inner join salesorderdetails sod on so.Order_Number = sod.Order_Number
                inner join products p on p.Product_Number = sod.Product_Number
                where so.Delivery_Status='Delivered';
-- 25. Find the salesman’s name and their product name which is cancelled.
select s.Salesman_Number,p.Product_Name from salesorder so 
                inner join salesorderdetails sod on so.Order_Number = sod.Order_Number
                inner join salesman s on s.Salesman_Number = so.Salesman_Number
                inner join products p on p.Product_Number = sod.Product_Number
                where so.Order_Status='Cancelled';
-- 26. Find product names, prices and delivery status for those products purchased by Nguyen Thanh.
select p.Product_Name,p.Sell_Price,so.Delivery_Status from products p 
					inner join salesorderdetails sod on sod.Product_Number = p.Product_Number
					inner join salesorder so on so.Order_Number = sod.Order_Number
                    inner join clients c on c.Client_Number = so.Client_Number
                    where c.Client_Name='Le Xuan';
-- 27. Display the product name, sell price, salesperson name, delivery status, and order quantity information
-- for each customer.
select c.Client_Name,p.Product_Name,p.Sell_Price,s.Salesman_Name,so.Delivery_Status,sod.Order_Quantity from products p 
					inner join salesorderdetails sod on sod.Product_Number = p.Product_Number
					inner join salesorder so on so.Order_Number = sod.Order_Number
                    inner join salesman s on s.Salesman_Number = so.Salesman_Number
                    inner join clients c on c.Client_Number = so.Client_Number
                    order by c.Client_Name;
-- 28. Find the names, product names, and order dates of all sales staff whose product order status has been
-- successful but the items have not yet been delivered to the client.
select s.Salesman_Number,p.Product_Name,so.Order_Date from salesorder so 
                inner join salesorderdetails sod on so.Order_Number = sod.Order_Number
                inner join salesman s on s.Salesman_Number = so.Salesman_Number
                inner join products p on p.Product_Number = sod.Product_Number
                where so.Order_Status='Successful' and so.Delivery_Status <> 'Delivered';
-- 29. Find each clients’ product which in on the way.
select c.Client_Name,p.Product_Name from salesorder so 
				inner join clients c on c.Client_Number = so.Client_Number
                inner join salesorderdetails sod on so.Order_Number = sod.Order_Number
                inner join products p on p.Product_Number = sod.Product_Number
                where so.Delivery_Status='On Way';
-- 30. Find salary and the salesman’s names who is getting the highest salary.
select Salary,Salesman_Name from salesman
where Salesman_Number in (select Salesman_Number from salesman where Salary = (select max(salary) from salesman));
-- 31. Find salary and the salesman’s names who is getting second lowest salary.
select Salesman_Name from salesman
where Salesman_Number not in (select Salesman_Number from salesman where Salary = (select min(salary) from salesman))
order by Salary
limit 1;
-- 32. Display lists the ProductName in ANY records in the sale Order Details table has Order Quantity more
-- than 9.
select p.Product_Name,sod.order_quantity 
from products p inner join salesorderdetails sod on p.product_number = sod.product_number
where sod.order_quantity > 9;
-- 33. Find the name of the customer who ordered the same item multiple times.
select distinct c.client_name from clients c 
		inner join salesorder so on c.client_number = so.client_number
		inner join salesorderdetails sod on so.order_number = sod.order_number 
        group by c.client_name,sod.product_number
        having count(sod.product_number) > 1;
-- 34. Write a query to find the name, number and salary of the salemans who earns less than the average
-- salary and works in any of Thu Dau Mot city.
select Salesman_Name,Salesman_Number,Salary 
		from salesman where salary < (select avg(salary) from salesman) 
        and (city ='Thu Dau Mot' or province='Thu Dau Mot' ) ;
-- 35. Write a query to find the name, number and salary of the salemans who earn a salary that is higher than
-- the salary of all the salesman have (Order_status = ‘Cancelled’). Sort the results of the salary of the lowest to
-- highest.
select Salesman_Name,Salesman_Number,Salary 
		from salesman where salary > (select max(salary) from salesman s left join salesorder so on s.salesman_number = so.salesman_number 
			where so.Order_status = 'Cancelled')
		order by salary;

-- 36. Write a query to find the 4th maximum salary on the salesman’s table.
select * from salesman order by salary desc limit 4;
-- 37. Write a query to find the 3th minimum salary in the salesman’s table.
select * from salesman order by salary  limit 3;