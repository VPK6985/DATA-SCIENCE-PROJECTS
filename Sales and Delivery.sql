### PART 1 - SALES AND DELIVERY 


create database sales_delivery;
use sales_delivery;
-- Question 1: Find the top 3 customers who have the maximum number of orders
select sum(order_quantity) as total_quantity,m.cust_id,customer_name from market_fact as m join cust_dimen as c on m.cust_id=c.cust_id
group by m.cust_id order by total_quantity desc limit 3;



-- Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select order_date,ship_date,abs(datediff(str_to_date(ship_date,'%d-%m-%Y'),str_to_date(order_date,'%d-%m-%Y'))) as DaysTakenForDelivery
 from orders_dimen as o join shipping_dimen as s
on o.order_id=s.order_id;


-- Question 3: Find the customer whose order took the maximum time to get delivered.
select order_date,ship_date,customer_name,abs(datediff(str_to_date(ship_date,'%d-%m-%Y'),str_to_date(order_date,'%d-%m-%Y'))) as DaysTakenForDelivery
from orders_dimen as o join shipping_dimen as s on o.order_id=s.order_id
join market_fact as m on o.ord_id=m.ord_id
join cust_dimen as c on c.cust_id=m.Cust_id
order by DaysTakenForDelivery desc limit 1;

-- Question 4: Retrieve total sales made by each product from the data (use Windows function)
select   distinct prod_id,sum(sales*order_quantity) over(partition by prod_id ) as sum_sales from market_fact;




-- Question 5: Retrieve the total profit made from each product from the data (use windows function)
select distinct m.prod_id,p.product_category,p.product_sub_category,sum(profit)  over(partition by prod_id) as total_profit 
from market_fact as m join prod_dimen as p on m.prod_id=p.prod_id
order by total_profit desc;


-- Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
select order_id, ord_id, str_to_date(order_date, '%d-%m-%Y') 
from orders_dimen 
where str_to_date(order_date, '%d-%m-%Y') between "2011-01-01" and "2011-01-31";
# There are 96 unique orders placed in january

select distinct cust_id from market_fact mf
join
(
select distinct ord_id from orders_dimen 
where str_to_date(order_date, '%d-%m-%Y') between "2011-01-01" and "2011-01-31"
) uniq
on uniq.ord_id=mf.ord_id;
# There are 99 unique customers shopped on january.

select distinct cust_id from market_fact mf
join
(
select distinct ord_id from orders_dimen 
where (ord_id in (select ord_id from orders_dimen where str_to_date(order_date, '%d-%m-%Y') between "2011-02-01" and "2011-02-28"))
) uniq
on uniq.ord_id=mf.ord_id;
# customers from feb




### PART 2 - RESSTAURANT DATASET 



create database p_restaurant;
use p_restaurant;

select * from chefmozaccepts;
select * from Chefmozcuisine;
select * from chefmozparking;
select * from geoplaces2;
select * from rating_final;
select * from usercuisine;
select * from userpayment;
select * from userprofile;

# Q1: We need to find out the total visits to all restaurants under all alcohol categories available.
/*
select placeID from geoplaces2 where alcohol not like '%No_alc%';
select Rcuisine from chefmozcuisine where placeID in (select placeID from geoplaces2 where alcohol not like '%No_alc%');
*/
select count(*) from usercuisine 
where Rcuisine in (select Rcuisine from chefmozcuisine where placeID in (select placeID from geoplaces2 where alcohol not like '%No_alc%'));


#Q2: Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.
select rf.placeID, alcohol, price, avg(rating) from geoplaces2 ge join rating_final rf on ge.placeID=rf.placeID where alcohol not like '%No_alc%'
group by rf.placeID, alcohol, price order by rf.placeID, price ;




#Q3: Let’s write a query to quantify that what are the parking availability as well in different alcohol categories 
# along with the total number of restaurants.
/*
select ge.placeID, name, alcohol, parking_lot from geoplaces2 ge join chefmozparking cp on ge.placeID=cp.placeID where alcohol not like '%No_alc%';
*/
select alcohol, parking_lot, count(name) no_of_restaurants from geoplaces2 ge join chefmozparking cp on ge.placeID=cp.placeID 
where alcohol not like '%No_alc%' group by alcohol, parking_lot order by alcohol;





#Q4: Also take out the percentage of different cuisine in each alcohol type.
/*
select Rcuisine from chefmozcuisine where placeID in (select placeID from geoplaces2 where alcohol not like '%No_alc%');

select alcohol, Rcuisine from chefmozcuisine cc join geoplaces2 ge on cc.placeID=ge.placeID 
where alcohol not like '%No_alc%' order by alcohol;

select alcohol, Rcuisine from chefmozcuisine cc join geoplaces2 ge on cc.placeID=ge.placeID 
where alcohol not like '%No_alc%' group by alcohol,Rcuisine order by alcohol;

select alcohol, Rcuisine, count(Rcuisine) , sum(count(Rcuisine)) over(partition by alcohol) total_cuisine
from chefmozcuisine cc join geoplaces2 ge on cc.placeID=ge.placeID 
where alcohol not like '%No_alc%' group by alcohol,Rcuisine order by alcohol;
*/
select alcohol, Rcuisine, count(Rcuisine), sum(count(Rcuisine)) over(partition by alcohol) total_cuisine, 
count(Rcuisine)/sum(count(Rcuisine)) over(partition by alcohol)*100 as percentage
from chefmozcuisine cc join geoplaces2 ge on cc.placeID=ge.placeID 
where alcohol not like '%No_alc%' group by alcohol,Rcuisine order by alcohol;


#Q5: let’s take out the average rating of each state.
/*
select distinct state
from rating_final rf join geoplaces2 ge on rf.placeID=ge.placeID;
*/
select state, avg(rating) average_rating
from rating_final rf join geoplaces2 ge on rf.placeID=ge.placeID where state not like "%?%" group by state order by avg(rating);


#Q6: 'Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest 
#rated by providing the summary on the basis of State, alcohol, and Cuisine.
select state, alcohol, Rcuisine
from chefmozcuisine cc join geoplaces2 ge on cc.placeID=ge.placeID 
where state like "%Tamaulipas%" group by state, alcohol, Rcuisine;


#Q7: Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of 
#cuisine, and also their budget level is low. We encourage you to give it a try by not using joins.
/*
select cc.placeID,name, Rcuisine
from chefmozcuisine cc join geoplaces2 ge on cc.placeID=ge.placeID 
where name like "%kfc%";
*/

select weight, food_rating, service_rating, Rcuisine, name
from userprofile up, rating_final rf, chefmozcuisine cc, geoplaces2 ge
where up.userID=rf.userID and rf.placeID=cc.placeID and cc.placeID=ge.placeID and (Rcuisine like "%mex%" or Rcuisine like "%ita%") and name like "%kfc%";



### PART 3  - TRIGGERS

create database triggers;
use triggers;

/*
https://www.geeksforgeeks.org/sql-trigger-student-database/

https://www.mysqltutorial.org/mysql-triggers/mysql-before-delete-trigger/
*/

create table Student_details
(
Student_id int, 
Student_name varchar(30), 
mail_id varchar(30), 
mobile_no int
);

create table Student_details_backup
(
Student_id int, 
Student_name varchar(30), 
mail_id varchar(30), 
mobile_no int
);

insert into Student_details values
(101,'jayanth','jayanth@gmail',9010),
(102,'pavan','pavan@gmail',9632),
(103,'ajay','ajay@gmail',3260),
(104,'Harsha','harsha@gmail',1096);

select * from Student_details;
select * from Student_details_backup;

delimiter $$
create trigger backup
before delete on Student_details for each row
begin
insert into Student_details_backup (Student_id, Student_name, mail_id, mobile_no)
value(OLD.Student_id, OLD.Student_name, OLD.mail_id, OLD.mobile_no);
END $$

delimiter ;

select * from Student_details;
select * from Student_details_backup;


delete from student_details where mail_id like "%harsha%";
select * from Student_details_backup;
select * from Student_details;

delete from student_details where mail_id like "%ajay%";
select * from Student_details_backup;
select * from Student_details;
