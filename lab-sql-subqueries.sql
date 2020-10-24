# Lab | SQL Subqueries
# In this lab, you will be using the Sakila database of movie rentals.
# Instructions
#  1.  How many copies of the film Hunchback Impossible exist in the inventory system?
#  2.  List all films longer than the average.
#  3.  Use subqueries to display all actors who appear in the film Alone Trip.
#  4.  Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
#  5.  Get name and email from customers from Canada using subqueries. Do the same with joins.
#  6.  Which are films starred by the most prolific actor?
#  7.  Films rented by most profitable customer.
#  8.  Customers who spent more than the average.
use sakila;
########################################################
#  1.  How many copies of the film Hunchback Impossible exist in the inventory system?
# Child
select film_id from film
where title = 'Hunchback Impossible';
# Parent
select film_id, count(inventory_id) as num_copies from inventory
where film_id = (select film_id from film
where title = 'Hunchback Impossible');
########################################################
#  2.  List all films longer than the average.
select film_id, title, length from film;
select avg(length) from film;
select film_id, title, length from film
where length > (select avg(length) from film)
order by length ASC;
########################################################
#  3.  Use subqueries to display all actors who appear in the film Alone Trip.
select film_id, title from film
where title ='Alone trip';

select actor_id, film_id from film_actor 
where film_id = (select film_id from film
where title ='Alone trip');

select f_a.actor_id, a.first_name, a.last_name, f_a.film_id from film_actor as f_a
join actor as a on a.actor_id = f_a.actor_id
where film_id = (select film_id from film
where title ='Alone trip');

########################################################
#  4.  Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select * from category;

select category_id from category 
where name = 'Family';

select * from film_category 
where category_id = (select category_id from category 
where name = 'Family');

select f.film_id, f.title, f_a.category_id from film_category as f_a
join film as f on f.film_id = f_a.film_id
where category_id = (select category_id from category 
where name = 'Family');

########################################################
#  5.  Get name and email from customers from Canada using subqueries. Do the same with joins.
# with subqueries
select country_id from country
where country = 'canada';

select city_id, city, country_id from city 
where country_id = (select country_id from country
where country = 'canada');

select * from address 
where city_id IN (select city_id from city 
where country_id = (select country_id from country
where country = 'canada'));

select customer_id, first_name, last_name, email from customer
where address_id in (select address_id from address 
where city_id IN (select city_id from city 
where country_id = (select country_id from country
where country = 'canada')));

# with joins
select cust.customer_id, cust.first_name, cust.last_name, cust.email, coun.country from customer as cust
join address as a on a.address_id = cust.address_id
join city as c on c.city_id=a.city_id
join country as coun on c.country_id = coun.country_id
where coun.country = 'Canada';

#########################################################
#  6.  Which are films starred by the most prolific actor?
select actor_id, count(film_id) as 'num_movies' from film_actor
group by actor_id
order by num_movies DESC;

select * from (
select actor_id, count(film_id) as 'num_movies' from film_actor
group by actor_id
order by num_movies DESC
) as sub1
Limit 1;

select actor_id from (
select actor_id, count(film_id) as 'num_movies' from film_actor
group by actor_id
order by num_movies DESC
) as sub1
Limit 1;

select * from film_actor
where actor_id = (select actor_id from (
select actor_id, count(film_id) as 'num_movies' from film_actor
group by actor_id
order by num_movies DESC
) as sub1
Limit 1);

select film_id from film_actor
where actor_id = (select actor_id from (
select actor_id, count(film_id) as 'num_movies' from film_actor
group by actor_id
order by num_movies DESC
) as sub1
Limit 1);

select film_id, title from film 
where film_id IN (
select film_id from film_actor
where actor_id = (select actor_id from (
select actor_id, count(film_id) as 'num_movies' from film_actor
group by actor_id
order by num_movies DESC
) as sub1
Limit 1));

########################################################
#  7.  Films rented by most profitable customer.
select customer_id, amount from payment
group by customer_id;

# Most profitable customer
select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
join payment as p on p.rental_id = r.rental_id
group by r.customer_id
order by money_spent DESC
Limit 1;
select customer_id from(
	select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
	join payment as p on p.rental_id = r.rental_id
	group by r.customer_id
	order by money_spent DESC
	Limit 1) as sub1;

select * from rental 
where customer_id = (select customer_id from(
	select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
	join payment as p on p.rental_id = r.rental_id
	group by r.customer_id
	order by money_spent DESC
	Limit 1) as sub1);

select r.customer_id, r.inventory_id, i.film_id from rental as r
join inventory as i on i.inventory_id = r.inventory_id
where customer_id = (select customer_id from(
	select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
	join payment as p on p.rental_id = r.rental_id
	group by r.customer_id
	order by money_spent DESC
	Limit 1) as sub1)
    ;

select r.customer_id, i.film_id, f.title from rental as r
join inventory as i on i.inventory_id = r.inventory_id
join film as f on f.film_id = i.film_id
where customer_id = (select customer_id from(
	select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
	join payment as p on p.rental_id = r.rental_id
	group by r.customer_id
	order by money_spent DESC
	Limit 1) as sub1)
group by film_id;

select r.customer_id, i.film_id from rental as r
join inventory as i on i.inventory_id = r.inventory_id
where customer_id = (select customer_id from(
	select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
	join payment as p on p.rental_id = r.rental_id
	group by r.customer_id
	order by money_spent DESC
	Limit 1) as sub1)
group by film_id;

select customer_id, money_spent from (
	select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
join payment as p on p.rental_id = r.rental_id
group by r.customer_id
order by money_spent DESC) as sub1;

########################################################
#  8.  Customers who spent more than the average.
# let's calculate the average amount spent 
select r.customer_id, count(r.rental_id) as 'num_rentals', sum(amount) as 'money_spent' from rental as r
join payment as p on p.rental_id = r.rental_id
group by customer_id;

select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
join payment as p on p.rental_id = r.rental_id
group by r.customer_id
order by money_spent DESC;

select avg(money_spent) from (
	select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
	join payment as p on p.rental_id = r.rental_id
	group by r.customer_id) as sub1;
    
select r.customer_id, count(r.rental_id) as 'num_rentals', sum(amount) as 'money_spent' from rental as r
join payment as p on p.rental_id = r.rental_id
group by customer_id
having money_spent > (
	select avg(money_spent) from (
	select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
	join payment as p on p.rental_id = r.rental_id
	group by r.customer_id) as sub1)    
order by money_spent;

select r.customer_id, c.first_name, c.last_name, count(r.rental_id) as 'num_rentals', sum(amount) as 'money_spent' from rental as r
join payment as p on p.rental_id = r.rental_id
join customer as c on p.customer_id = c.customer_id
group by customer_id
having money_spent > (
	select avg(money_spent) from (
	select r.customer_id, sum(p.amount) as 'money_spent' from rental as r
	join payment as p on p.rental_id = r.rental_id
	group by r.customer_id) as sub1)    
order by money_spent DESC;
