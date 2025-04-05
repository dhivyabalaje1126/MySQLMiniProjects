/* My analysis of the sakila database 

README!

Hello, my name is Dhivya and I'm going to analyze the sakila database that comes with the full installation of MySQL workbench. 
This is for my own purposes, to implement SQL functions and methods and randomly analyze stuff from thsi dataset. 
I've done this analysis with no particular aim or analysis in mind, so this is not a very systematic file/document. 

STUFF TO KNOW!
1. Database used: sakila.
   Please download this database in your DBMS and continue.
   I strongly recommend doing this hands-on. 
2. DBMS: MySQL. 
   If you are downloading this, feel free to change the things here according to your own DBMS. 
3. Table used from the 'sakila' databse: .

Disclaimers!
1. This is just for fun and learning.
2. I'm not an expert. I WILL make, and probably have made a few mistakes in some places and I may not have corrected them. 
   Proceed with caution.
3. The analyses I'm doing are based on the contents of the sakila database as of the year 2025 (when I installed this database). 
   These may not be in line with your timeline.
4. I am just proceeding based on the data and results I have, based on the contents of the sakila database.
5. My naming conventions for variables and tables are by default, long, and pertain to the way I proceeded with the data and
   my understanding of it only. 
6. I have used the techniques I know, nested CTEs, subqueries. and may not have explained my steps all the time. 
   Take your time to read, understand and experiment. There are so many ways different people can analyze the same data.
7. I've used both -- and the *\ ways to comment and my notes may be chaotic. Sorry about that if it confuses you.
8. I am only a beginner in SQL. I am also still learning. 

PERSONAL NOTE:
I'm doing this to learn SQL in the MySQL database. I used to be someone very afraid of SQL because of a traumtaic experience in a 
workplace environment where people said I couldn't code in SQL since I didn't know anything.
By doing this analysis, i'VE STARTED TO COME OUT OF MY FEAR!
So if you're facing something similar, let me tell you, JUST PRACTICE! SQL IS GREAT!
Try having fun with your datasets. Start simple and just keep going!
I hope this database analysis helps you learn something in some way. 

I'll let you get to it now! */

-- Accessing the sakila database in my workbench
use sakila;

-- How many tables are present in the database?
show tables; #23 tables are present in this database

-- * I used Reverse Engineer in the Database tab of MySQL Workbench to view the ER diagram
-- for the sakila database.
-- It's an extremely complex database with many relationships and information */

-- /* Short info about the sakila database (based on my understanding after reading through the documentation):
-- It was created to showcase the complex capabilities of MySQL, as opposed to the world database that has a few tables and only uses
-- certain functionalities. 
-- The sakila database has information about movie listings. the Sakila sample database is designed to represent a DVD rental store. 
-- The Sakila sample database still borrows film and actor names from the Dell sample database. */

select * from actor;
describe actor;
describe address;
describe category;
select * from category;
select * from film;
select * from film_actor;

-- I'm unable to understand the database by just doing this. I'm going to refer to the documentation of MySQL.
-- I suggest you do the same too. 

/* I am going to use Gemini to generate sample questions based on the sakila database for me to practice!
1.  List all the actors' first and last names */

describe actor;
select first_name, last_name from actor;

-- 2. Find the titles of all films in the "Comedy" category
describe category;
describe film;
describe film_category;
-- To answer this question, you need to join these 3 tables and use a cte
with filmcategory as
(
select c.category_id, c.name, f.film_id, f.title
from category c join film_category fc using(category_id)
join film f using(film_id)
)
select title from filmcategory where name = 'Comedy';

-- 3. How many customers are there?
show tables;
-- Either customer or customer_list gives us the answer we need
describe customer;
select count(*) from customer where active = 1;
-- I am going to consider only active customers for this answer

-- 4. List all the distinct ratings of films in the film table.
describe film;
select distinct(rating) from film;

-- 5.  Show the address and phone number for the store with store_id of 1.
show tables;
describe address;
describe store;
with adst as
(
select s.store_id, s.address_id, a.address, a.phone from store s join address a 
on a.address_id = s.address_id
)
select address, phone from adst where store_id = 1;

-- 6. Find the total number of rentals for each customer.
describe customer;
describe rental;
with customerrental as
(
select r.rental_id, r.rental_date, r.customer_id from 
rental r join customer c on c.customer_id = r.customer_id
)
select customer_id, count(rental_id) as RentedCount from customerrental
group by customer_id;

-- 7.List the films with the longest rental duration (rental_duration)
describe film;
with ranking as (
select title, rental_duration, 
dense_rank() over (order by rental_duration desc)
as DurationRank from film
)
select title from Ranking where DurationRank = 1;

-- 8. Find the average payment amount for each customer.
describe customer;
describe payment;
select p.customer_id, avg(p.amount)
from payment p join customer c on c.customer_id = p.customer_id
group by p.customer_id;

-- 9. List the actors who have appeared in the film "ACADEMY DINOSAUR"
describe actor; -- we need actor_id, first_name, last_name
describe film_actor; -- we need film_id
describe film; -- now we can join
-- I'm going to attempt to do this in a single query. 
select a.actor_id, a.first_name, a.last_name, f.title
from actor a join film_actor fa on fa.actor_id = a.actor_id
join film f on f.film_id = fa.film_id
where f.title = "ACADEMY DINOSAUR";

-- Show the city and country of each store
describe city; -- city_id, city,country_id
describe country; -- country_id, country
describe store; -- store_id, address_id
describe address; -- city_id
select s.store_id, c.city, co.country from
store s join address a using(address_id) join city c using(city_id) join country co using(country_id);

-- Find the customers who have rented more than 30 films
show tables;
describe customer; -- customer_id, first_name, last_name, store_id
describe rental; -- customer_id, rental_id
select c.customer_id, c.first_name, c.last_name, count(rental_id) as TimesRented
from customer c join rental r using(customer_id)
group by 1,2,3 having count(rental_id) > 30;

--  List the first and last names of customers who have made payments totaling more than $100.

select first_name, last_name, sum(amount)
from customer c join payment p using(customer_id)
group by 1,2 having sum(amount) > 100;

-- Find the titles of films that have an average rental duration greater than 5 days.
select title, round(avg(rental_duration),1) as Avg_Rental_Duration
from film group by 1 having Avg_Rental_Duration > 5;

-- Display the category name and the total number of films in each category
describe film_category;
describe category;
select c.category_id, c.name, count(fc.film_id) as FilmsinCategory
from category c join film_category fc using(category_id)
group by 1,2;

-- Find the email addresses of customers who have rented films with the rating "PG".
describe film; -- rating
describe customer; -- email, store_id, address_id
describe store; -- address_id
SELECT DISTINCT
    c.email, f.title, f.rating
FROM
    customer c
JOIN
    rental r ON c.customer_id = r.customer_id
JOIN
    inventory i ON r.inventory_id = i.inventory_id
JOIN
    film f ON i.film_id = f.film_id
WHERE
    f.rating = 'PG';
    
    --  List the actors who have appeared in more than 2 films. 
    -- Display the actor's first name, last name, and the number of films they've appeared in.
   describe actor; -- link with actor_id
   describe film_actor;
   select a.first_name, a.last_name, count(fa.film_id) as NumberofFilms
   from actor a join film_actor fa using(actor_id)
   group by 1,2 having count(fa.film_id) > 2;
    
-- Show the city names and the number of customers in each city.
describe city; -- city
describe customer; -- customer_id, address_id
describe address; -- city_id
select c.city, sum(cu.customer_id) as customerCount
from city c join address a using(city_id) join customer cu using(address_id)
group by c.city;

-- Find the titles of films that are available in inventory
-- at more than one store.
describe film; -- film_id
describe inventory;
select i.inventory_id, i.film_id, f.title, count(i.store_id) as instore
from inventory i join film f on i.film_id = f.film_id
group by 1,2,3 having count(i.store_id) > 1;

/* And that's a wrap. I was doing all this mostly for practice.
This database is highly complex and fun to work with. 
Generating the ER diagram for the sakila database shows how complex the relationships between the tables in the database are. 
I had fun with this and I was able to brush up on my SQL skills. I think I'll stop here for now. Tootles! */