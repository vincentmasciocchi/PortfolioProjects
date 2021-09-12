/***************************************************/
/*Exploratory Analysis of Sakila DB  */
/***************************************************/

/* Email Campaigns for customers of Store 2 - First, Last name and Email address of customers from Store 2*/
SELECT first_name, last_name, email
FROM customer;

/* movies with rental rate of 0.99$* and how many movies are in each rental rate categories*/
SELECT COUNT(*) AS 99_Cent_Films
FROM film
WHERE rental_rate = .99;

SELECT rental_rate, COUNT(*) AS Total_Number_Of_Movies
FROM film
GROUP BY rental_rate;

/*Which rating do we have the most films in?*/
SELECT rating, COUNT(*) AS Titles_In_Rating_Category
FROM film
GROUP BY rating
ORDER BY COUNT(*) DESC
LIMIT 1;

/*Which rating is most prevalant in each store?*/
SELECT I.Store_id, F.Rating, COUNT(F.Rating) AS Total
FROM film AS F 
JOIN inventory AS I ON F.film_id = I.film_id
GROUP BY F.Rating, I.Store_id
ORDER BY Total DESC, Store_ID DESC
LIMIT 2;

/*We want to mail the customers about the upcoming promotion*/
SELECT C.customer_id, C.first_name, C.last_name, A.address, A.district, A.postal_code
FROM customer AS C
JOIN address AS A ON C.address_id = A.address_id;

/* List of films by Film Name, Category, Language*/
SELECT FC.film_id, F.title, C.category_name AS category, L.language_name AS 'language'
FROM film_category AS FC
JOIN category AS C ON FC.category_id = C.category_id
JOIN film AS F ON FC.film_id = F.film_id
JOIN language_table AS L ON F.language_id = L.language_id
ORDER BY FC.film_id;

/* How many times each movie has been rented out? */
SELECT F.film_id, F.title, COUNT(R.rental_id) AS total_number_of_rents
FROM film AS F
JOIN inventory AS I ON F.film_id = I.film_id
JOIN rental AS R ON I.inventory_id = R.inventory_id
GROUP BY F.title
ORDER BY 3 DESC;

/*Revenue per Movie */
SELECT F.film_id, F.title, COUNT(R.rental_id) * F.rental_rate as revenue_per_movie
FROM film AS F
JOIN inventory AS I ON F.film_id = I.film_id
JOIN rental AS R ON I.inventory_id = R.inventory_id
GROUP BY F.title
ORDER BY 3 DESC;

/* Customer with the greatest spend so that we can send him/her rewards or debate points*/
SELECT C.customer_id, C.first_name, C.last_name, SUM(P.amount) AS total_spend
FROM payment AS P
JOIN customer AS C ON C.customer_id = P.customer_id
GROUP BY C.customer_id
ORDER BY total_spend DESC;

/* What Store has historically brought the most revenue */
SELECT S.store_id, SUM(P.amount) AS revenue
FROM store AS S
JOIN inventory AS I ON S.store_id = I.store_id
JOIN rental AS R ON I.inventory_id = R.inventory_id
JOIN payment AS P ON R.rental_id = P.rental_id
GROUP BY S.store_id
ORDER BY revenue DESC;

/*How many rentals we have for each month*/
SELECT DATE_FORMAT(rental_date, '%M') AS rental_month, COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY rental_month
ORDER BY total_rentals DESC;

/* For each movie, when was the first time and last time it was rented out? */
SELECT F.film_id, F.title, DATE_FORMAT(MIN(rental_date) , "%M " "%d " "%Y") AS first_rental_date, DATE_FORMAT(MAX(rental_date) , "%M " "%d " "%Y") as last_rental_date
FROM film AS F
JOIN inventory AS I ON F.film_id = I.film_id
JOIN rental AS R ON I.inventory_id = R.inventory_id
GROUP BY F.film_id;

/* Revenue Per Month */
SELECT DATE_FORMAT(R.rental_date, '%M') AS rental_month, SUM(P.amount) AS revenue
FROM payment AS P
JOIN rental AS R ON P.rental_id = R.rental_id
GROUP BY rental_month
ORDER BY revenue DESC;

/* How many distint Renters per month, Total Renters per Month, Average Rents per Customer*/
SELECT DATE_FORMAT(rental_date, '%M') AS rental_month,
	COUNT(rental_id) AS total_rentals,
	COUNT(DISTINCT customer_id) AS total_distinct_renters,
    (COUNT(rental_id)/COUNT(DISTINCT customer_id)) AS average_rents_per_customer
FROM rental
GROUP BY rental_month
ORDER BY average_rents_per_customer DESC;

/*Number of Distinct Film Rented Each Month */
SELECT I.film_id, F.title, DATE_FORMAT(R.rental_date, '%Y-%m') AS rental_month, 
	COUNT(i.film_id) AS total_number_of_rentals
FROM rental R
JOIN inventory I ON R.inventory_id = I.inventory_id
JOIN film F ON F.film_id = I.film_id
GROUP BY I.film_id, rental_month
ORDER BY I.film_id ASC, rental_month ASC;

/* Number of Rentals in Comedy , Sports and Family */
SELECT C.category_name, COUNT(R.rental_id) AS total_rentals
FROM film_category AS FC
JOIN category AS C ON FC.category_id = C.category_id
JOIN film AS F ON FC.film_id = F.film_id
JOIN inventory I ON FC.film_id = I.film_id
JOIN rental AS R ON I.inventory_id = R.inventory_id
WHERE C.category_name IN ("Comedy", "Sports", "Family")
GROUP BY C.category_name
ORDER BY total_rentals DESC;

/*Customers that have rented atleast 3 times*/
SELECT C.customer_id, CONCAT(first_name, ' ', last_name) AS full_name, COUNT(R.rental_id) AS total_rents
FROM rental AS R
JOIN customer AS C ON R.customer_id = C.customer_id
GROUP BY full_name
HAVING total_rents >= 3
ORDER BY customer_id ASC;

/*How much revenue has one single store made over PG13 and R rated films*/
SELECT I.store_id, F.rating, SUM(P.amount)
FROM payment AS P
JOIN rental AS R ON P.rental_id = R.rental_id
JOIN inventory AS I ON R.inventory_id = I.inventory_id
JOIN film AS F ON I.film_id = F.film_id
WHERE F.rating IN ("PG-13", "R")
GROUP BY I.store_id, F.rating
ORDER BY I.store_id;

/* Active User  where active = 1*/
DROP TEMPORARY TABLE IF EXISTS tbl_active_users;
CREATE TEMPORARY TABLE tbl_active_users(
SELECT C.*, A.phone
FROM customer C
JOIN address A ON A.address_id = C.address_id
WHERE C.active = 1);

/* Reward Users : who has rented at least 30 times*/
DROP TEMPORARY TABLE IF EXISTS tbl_rewards_user;
CREATE TEMPORARY TABLE tbl_rewards_user(
SELECT R.customer_id, COUNT(R.customer_id) AS total_rents, max(R.rental_date) AS last_rental_date
FROM rental R
GROUP BY 1
HAVING COUNT(R.customer_id) >= 30);
