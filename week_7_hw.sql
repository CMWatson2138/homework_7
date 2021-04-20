--1. Create a new column called “status” in the rental table that uses a case statement to indicate if a film was returned late, early, or on time. 
/*The query uses the rental duration compared to the difference between when a rental was returned and when it was taken out. Then a status is assigned to each transaction as early, late or on time*/
SELECT CASE WHEN rental_duration > date_part('day', return_date - rental_date) THEN 'early'
	WHEN rental_duration < date_part('day', return_date - rental_date) THEN 'late'
	ELSE 'on_time' END AS status,
	film.title
	FROM film
	INNER JOIN inventory
	USING (film_id)
	FULL JOIN rental
	USING (inventory_id)
	GROUP BY film.title, rental_duration, return_date, rental_date
	ORDER BY 2 DESC;

--2. Show the total payment amounts for people who live in Kansas City or Saint Louis. 
/* The payment needed comes from the payment table.  In order to get the associated city from the city table I joined through customer and address. All transactions were excluded besides those occuring in Kansas City and Saint Louis*/
SELECT SUM(amount), city
FROM payment p
LEFT JOIN customer c1
ON c1.customer_id=p.customer_id
LEFT JOIN address a
ON c1.address_id=a.address_id
LEFT JOIN city c2
ON c2.city_id=a.city_id
WHERE city='Kansas City' OR city='Saint Louis'
GROUP BY city

--3. How many film categories are in each category? Why do you think there is a table for category and a table for film category?
/*The table category allows us to easily view that there are 16 distinct categories and what they are. There are 1000 entries in the film categories.  Trying to determine how many distinct categories there are if the tables were one table would add layers of code.*/
SELECT COUNT(film_id), name
FROM film_category f
LEFT JOIN category c
ON c.category_id=f.category_id
GROUP BY name
/*69	"Family",
61	"Games"
66	"Animation"
57	"Classics"
68	"Documentary"
63	"New"
74	"Sports"
60	"Children"
51	"Music"
57	"Travel"
73	"Foreign"
62	"Drama"
56	"Horror"
64	"Action"
61	"Sci-Fi"
58	"Comedy"*/

--4. Show a roster for the staff that includes their email, address, city, and country (not ids)
/*In order to get all of the pieces of this information it is necessary to join the tables for staff, address, city and country*/
SELECT first_name, last_name, email, address, address2, city, country
FROM staff s
INNER JOIN address a
ON s.address_id=a.address_id
INNER JOIN city c1
ON a.city_id=c1.city_id
INNER JOIN country c2
ON c1.country_id=c2.country_id
/*"Mike"	"Hillyer"	"Mike.Hillyer@sakilastaff.com"	"23 Workhaven Lane"		"Lethbridge"	"Canada"
"Jon"	"Stephens"	"Jon.Stephens@sakilastaff.com"	"1411 Lillydale Drive"		"Woodridge"	"Australia"*/

--5. Show the film_id, title, and length for the movies that were returned from May 15 to 31, 2005
/*This query pulls the rental returns from the specified time period and applies the rentals identified  to the film table to pull  the film_id, title, and length*/
SELECT f.film_id, title, length
FROM film f
INNER JOIN inventory i
ON f.film_id=i.film_id
INNER JOIN rental r
ON i.inventory_id=r.inventory_id
WHERE return_date 
BETWEEN '2005-05-15' AND '2005-05-31'

--6. Write a subquery to show which movies are rented below the average price for all movies. 
/*A subquery in the where clause is used to filter only those films that have a rental rate lower than the calculated column of overall avg rate for all films*/
SELECT title, rental_rate, (SELECT ROUND(AVG(rental_rate),2) AS overall_avg_rental_rate from film)
FROM film
WHERE rental_rate < (SELECT ROUND(AVG(rental_rate),2) AS overall_avg_rental_rate from film)
GROUP BY title, rental_rate

--7. Write a join statement to show which moves are rented below the average price for all movies.

SELECT f1.title, f1.rental_rate, (SELECT ROUND(AVG(rental_rate),2) AS overall_avg_rental_rate from film)
FROM film f1
LEFT JOIN film f2
ON f1.rental_rate=f2.rental_rate
WHERE f1.rental_rate < (SELECT ROUND(AVG(rental_rate),2) AS overall_avg_rental_rate from film)
GROUP BY f1.title, f1.rental_rate

--8. Perform an explain plan on 6 and 7, and describe what you’re seeing and important ways they differ.
/* The important way that the explain plans differ is that the self join uses less time because the entire subquery doesn't need to be run seperately.*/ 
#6
1.	Aggregate
2.	Aggregate
3.	Seq Scan on film as film_1
4.	Aggregate
5.	Seq Scan on film as film_2
6.	Seq Scan on film as film
Filter: (rental_rate < $1)

#7
	#	Node
1.	Aggregate
2.	Aggregate
3.	Seq Scan on film as film
4.	Aggregate
5.	Seq Scan on film as film_1
6.	Hash Left Join
Hash Cond: (f1.rental_rate = f2.rental_rate)
7.	Seq Scan on film as f1
Filter: (rental_rate < $1)
8.	Hash
9.	Seq Scan on film as f2
--9. With a window function, write a query that shows the film, its duration, and what percentile the duration fits into. This may help https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank 
/*PERCENT_RANK calculates the percentage of film duration(kength) based upon the percentile*/
SELECT title, length, PERCENT_RANK()OVER(ORDER BY length)
FROM film

--10. In under 100 words, explain what the difference is between set-based and procedural programming. Be sure to specify which sql and python are. 
/*Procedural programming refers to programming like Python, Java, and similar in which the programmer tells the system what to do and how to do it.  
SQL is an example of set based programming in which the programmer tells the system the results they are looking for and the system figures out how 
to make it happen.   You specify the processed result you want from a set of data.*/


--Bonus:
--Find the relationship that is wrong in the data model. Explain why its wrong. 