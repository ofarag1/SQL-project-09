-- 09-SQL HomeWork
-- 1a. Display the first and last names of all actors from the table actor.
USE sakila;
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

USE sakila;
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS 'actor_name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."  What is one query would you use to obtain this information?
USE sakila;
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
USE sakila;
SELECT * FROM actor WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
USE sakila;
SELECT * FROM actor WHERE last_name LIKE "%LI%" 
ORDER BY last_name ASC, first_name ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
USE sakila;
SELECT country_id,country FROM country 
WHERE country IN ('Afghanistan','Bangladesh','China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant).
USE sakila;
ALTER TABLE actor ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
USE sakila;
ALTER TABLE actor DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
USE sakila;
SELECT last_name, COUNT(*) AS 'last_name_number'
FROM actor 
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
-- https://stackoverflow.com/questions/301793/mysql-using-count-in-the-where-clause
USE sakila;
SELECT last_name, COUNT(*) AS 'last_name_number'
FROM actor 
GROUP BY last_name
HAVING last_name_number > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

USE sakila;
UPDATE actor 
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- output
USE sakila;
SELECT first_name,last_name 
FROM actor 
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS' ;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.

USE sakila;
UPDATE actor 
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- output
SELECT first_name,last_name 
FROM actor 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS' ;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
USE sakila;
select staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON address.address_id = staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

USE sakila;
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'august_2005_total_amount'
FROM staff
INNER JOIN payment ON staff.staff_id = payment.staff_id 
WHERE payment_date LIKE '%2005-08%'
GROUP BY staff.first_name, staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
USE sakila;
SELECT film.title, COUNT(film_actor.actor_id) AS 'number_of_actors'
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
USE sakila;
SELECT film.title, COUNT(inventory.film_id) AS 'no_of_copies'
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
USE sakila;
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS 'total_paid'
FROM customer
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.first_name, customer.last_name
ORDER by customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.  
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

USE sakila;
SELECT title FROM film
WHERE language_id IN
(
	select language_id
	from language
	WHERE name = 'English'
)
AND title LIKE 'K%' OR title like 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
USE sakila;
select first_name, last_name
from actor
WHERE actor_id in
	(
	select actor_id
    from film_actor
    WHERE film_id in
		(
			select film_id
            from film
            WHERE title = 'Alone Trip'
		)
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

USE sakila;
Select first_name,last_name,email 
FROM customer
inner JOIN address ON customer.address_id = address.address_id
inner JOIN city ON address.city_id = city.city_id
inner join country ON city.country_id = country.country_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
USE sakila;
Select title 
FROM film
inner JOIN film_category ON film.film_id = film_category.film_id
inner JOIN category ON film_category.category_id = category.category_id
WHERE name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

USE sakila;
SELECT film.title, COUNT(rental.rental_id) AS 'most_rented_movies'
FROM rental 
JOIN inventory on rental.inventory_id = inventory.inventory_id
JOIN film on film.film_id = inventory.film_id
GROUP BY film.title
ORDER BY 2 DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

USE sakila;
SELECT store.store_id, SUM(payment.amount) AS 'total_in_dollars' 
FROM payment 
JOIN staff on payment.staff_id = staff.staff_id
JOIN store on staff.store_id = store.store_id
GROUP BY 1;

-- 7g. Write a query to display for each store its store ID, city, and country.

USE sakila;
select store.store_id, city.city, country.country
from country
join city on country.country_id = city.country_id
join address on city.city_id = address.city_id
join store on address.address_id = store.address_id;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

USE sakila;
select category.name, SUM(payment.amount) AS 'gross_revenue'
from category
join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY 2 DESC limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

USE sakila;
CREATE VIEW top_5_gross_revenue AS 
select name, SUM(payment.amount) AS 'gross_revenue'
from category
join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY 2 DESC limit 5;

-- 8b. How would you display the view that you created in 8a?
USE sakila;
SELECT * from top_5_gross_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

USE sakila;
DROP VIEW top_5_gross_revenue;















			
















    




