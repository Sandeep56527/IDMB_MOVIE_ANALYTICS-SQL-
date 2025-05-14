-- Segment 1: Database - Tables, Columns, Relationships.
# Q1- What are the different tables in the database and how are they connected to each other in the database?
/*
 Ans. The database contains the following tables:

1. movie: This table stores information about movies. It has a primary key `id` and columns such as `title`, `year`, `date_published`, `duration`, `country`, `worlwide_gross_income`, `languages`, and `production_company`.
2. genre: This table represents the genres of movies. It has a composite primary key `(movie_id, genre)` and contains the movie ID and genre for each movie.
3. director_mapping: This table maps movies to directors. It has a composite primary key `(movie_id, name_id)` and contains the movie ID and director name for each movie.
4. role_mapping: This table maps movies to actors/actresses and their roles. It has a composite primary key `(movie_id, name_id)` and contains the movie ID, actor/actress name, and role category for each movie.
5. names: This table stores information about people involved in movies, such as actors, actresses, and directors. It has a primary key `id` and columns like `name`, `height`, `date_of_birth`, and `known_for_movies`.
6. ratings: This table contains ratings information for movies. It has a primary key `movie_id` and columns such as `avg_rating`, `total_votes`, and `median_rating`.
These tables are connected to each other using foreign keys. 
The `movie_id` column in the genre, director_mapping, and role_mapping tables references the `id` column in the movie table. 
The `name_id` column in the director_mapping and role_mapping tables references the `id` column in the names table. 
These relationships allow for the association of movies with genres, directors, and actors/actresses.
*/

# Q2-Find the total number of rows in each table of the schema.
SELECT table_name,
       table_rows
FROM   information_schema.TABLES
WHERE  table_schema = 'imdb';

#Q3- Identify which columns in the movie table have null values.
describe movies;
 SELECT 'ID',
       COUNT(*) AS null_cnt
FROM   movies
WHERE  id IS NULL
UNION
SELECT 'Title',
       COUNT(*) AS null_cnt
FROM   movies
WHERE  title IS NULL
UNION
SELECT 'Year',
       COUNT(*) AS null_cnt
FROM   movies
WHERE  YEAR IS NULL
UNION
SELECT 'Date_Published',
       COUNT(*) AS null_cnt
FROM   movies
WHERE  date_published IS NULL
UNION
SELECT 'Movie',
       COUNT(*) AS null_cnt
	
FROM   movies
WHERE  duration IS NULL
UNION
SELECT 'Country',
       COUNT(*) AS null_cnt
FROM  movies
WHERE  country IS NULL
UNION
SELECT 'worldwide_gross_income',
       COUNT(*) AS null_cnt
FROM   movies
WHERE  worlwide_gross_income IS NULL
UNION
SELECT 'Languages',
       COUNT(*) AS null_cnt
FROM   movies
WHERE  languages IS NULL
UNION
SELECT 'Production_company',
       COUNT(*) AS null_cnt
FROM   movies
WHERE  production_company IS NULL; 

-- Segment 2: Movie Release Trends.
#Q1- Determine the total number of movies released each year and analyse the month-wise trend.
 #number of movies in each years
SELECT Year,
       COUNT(title) AS 'number_of_movies' 
FROM  movies
GROUP  BY year;

 #no. for movies in each months
SELECT MONTH(date_published) AS month_num,
       COUNT(title) AS number_of_movies 
FROM  movies
GROUP  BY MONTH(date_published)
ORDER  BY  month_num; 

#Q2- Calculate the number of movies produced in the USA or India in the year 2019.
SELECT COUNT(*) AS mov_cnt
FROM movies
WHERE (country = 'USA' OR country = 'India') 
    AND year = 2019;

-- Segment 3: Production Statistics and Genre Analysis.
#Q1- Retrieve the unique list of genres present in the dataset.
SELECT DISTINCT genre
FROM genre;

#Q2- Identify the genre with the highest number of movies produced overall.
SELECT g.genre,
	COUNT(m.title) AS no_of_movies
FROM   movies m
INNER JOIN genre g ON g.movie_id= m.ID
GROUP  BY g.genre
ORDER  BY COUNT(m.title) DESC
LIMIT  1;  

#Q3- Determine the count of movies that belong to only one genre.
WITH cte
	AS (SELECT m.id,Count(g.genre) 
	FROM   movies m 
	INNER JOIN genre g ON g.movie_id = m.id
	GROUP  BY id
	HAVING Count(g.genre) = 1)
SELECT Count(id) AS movie_count
FROM   cte;

#Q4- Calculate the average duration of movies in each genre.
SELECT ROUND(AVG(duration),2) as avg_mov_dur, genre
FROM movies m
INNER JOIN genre g ON m.id = g.movie_id
GROUP BY genre
ORDER BY avg_mov_dur DESC;

#Q5-Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
WITH ranking
	AS (SELECT genre,
		Count(movie_id) AS 'mov_cnt',
		RANK()OVER(ORDER BY Count(movie_id) DESC) AS gen_rnk
	FROM genre
         GROUP BY genre)
SELECT *
FROM ranking
WHERE genre = 'thriller'; 

-- Segment 4: Ratings Analysis and Crew Members.
#Q1- Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
SELECT 
	MIN(avg_rating) AS min_avg_rating,
	MAX(avg_rating) AS max_avg_rating,
	MIN(total_votes) AS min_total_votes,
	MAX(total_votes) AS max_total_votes,
	MIN(median_rating) AS min_median_rating,
	MAX(median_rating) AS max_median_rating
FROM rating;
 
#Q2- Identify the top 10 movies based on average rating.
SELECT title, 
	   avg_rating,
       RANK() OVER(ORDER BY avg_rating DESC) AS mov_rnk
FROM rating r       
INNER JOIN movies m ON r.movie_id= m.id
ORDER BY avg_rating DESC
LIMIT 10;

#Q3- Summarise the ratings table based on movie counts by median ratings.
SELECT median_rating,
       COUNT(movie_id) AS mov_cnt
FROM rating
GROUP BY median_rating
ORDER BY mov_cnt DESC;

#Q4- Identify the production house that has produced the most number of hit movies (average rating > 8).
WITH cte AS (
    SELECT production_company,
           COUNT(*) AS mov_cnt,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_com_rnk
    FROM movies m
    INNER JOIN rating r ON m.id = r.movie_id
    WHERE avg_rating > 8
    GROUP BY production_company
)

SELECT production_company,
	   mov_cnt,
       prod_com_rnk
FROM cte
WHERE prod_com_rnk= 1;   

#Q5- Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.
WITH cte AS (
	SELECT genre,
		   id,
           date_published,
           country
	FROM rating r
	INNER JOIN genre g ON r.movie_id = g.movie_id
	INNER JOIN movies m ON g.movie_id = m.ID
	WHERE  total_votes > 1000                                    
	AND MONTH(date_published) = 3
	AND YEAR(date_published) = 2017
	AND m.country IN ( 'USA' ))
SELECT genre,
       Count(id) AS mov_cnt
FROM  cte
GROUP  BY genre
ORDER  BY mov_cnt DESC;

#Q6- Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.
SELECT title,
       avg_rating,
       genre
FROM genre g
INNER JOIN rating r ON g.movie_id = r.movie_id
INNER JOIN movies m ON g.movie_id= m.id
WHERE  avg_rating > 8
       AND title LIKE 'The%'      
ORDER  BY avg_rating DESC; 

-- Segment 5: Crew Analysis
#Q1- Identify the columns in the names table that have null values.
SELECT COUNT(*) - COUNT(id)               AS id_nulls,
       COUNT(*) - COUNT(name)             AS name_nulls,
       COUNT(*) - COUNT(height)           AS height_nulls,
       COUNT(*) - COUNT(date_of_birth)    AS date_of_birth_nulls,
       COUNT(*) - COUNT(known_for_movies) AS known_for_movies_nulls
FROM   names; 

#Q2- Determine the top three directors in the top three genres with movies having an average rating > 8.
select * from
(select g.genre,
       n.name,
       r.avg_rating,
	   row_number() over(order by avg_rating desc)  as rnk
from names n
inner join director_mapping dm on n.id=dm.name_id
inner join movies m on dm.movie_id=m.id                        
inner join genre g on m.id=g.movie_id
inner join rating r on m.id=r.movie_id
where  avg_rating > 8) temp
where rnk <4 ;

#Q3- Find the top two actors whose movies have a median rating >= 8.
SELECT n.name AS actor_name,
	   median_rating AS average_median_rating
FROM names n
INNER JOIN role_mapping rm ON n.id = rm.name_id
INNER JOIN rating r ON rm.movie_id = r.movie_id
WHERE category = 'actor'
AND median_rating >=8
ORDER BY average_median_rating DESC
LIMIT 2;

#Q4- Identify the top three production houses based on the number of votes received by their movies.
SELECT m.production_company,
	   SUM(r.total_votes) AS vote_count,
	   DENSE_RANK() OVER(ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rnk
FROM movies m
INNER JOIN rating r ON m.id = r.movie_id
GROUP BY m.production_company
LIMIT 3;

#Q5- Rank actors based on their average ratings in Indian movies released in India.
WITH actors
AS
  (
	SELECT n.name AS actor_name ,
		   SUM(r.total_votes) AS total_votes,
		   COUNT(n.name) AS movie_count,
		   ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) AS actor_avg_rating
	FROM names n
	INNER JOIN role_mapping rm ON n.id = rm.name_id
	INNER JOIN movies m ON rm.movie_id = m.id
	INNER JOIN rating r ON m.id = r.movie_id
	WHERE m.country REGEXP 'india'
	AND rm.category = 'actor'
	GROUP BY n.name
	HAVING movie_count >= 5)
  SELECT   *,
           DENSE_RANK() OVER ( ORDER BY actor_avg_rating DESC, total_votes DESC) AS act_rnk
  FROM actors;

 #Q6- Identify the top five actresses in Hindi movies released in India based on their average ratings.     
SELECT name AS actress_name,
	   dense_rank() over(order by avg_rating desc) as rnk
FROM role_mapping rm
INNER JOIN rating r ON rm.movie_id=r.movie_id 
INNER JOIN movies m ON r.movie_id=m.id
INNER JOIN names n ON rm.name_id=n.id
WHERE 
	country="india" AND category="actress" AND languages ="hindi"
LIMIT 5;
  
  -- Segment 6: Broader Understanding of Data
  #Q1--	Classify thriller movies based on average ratings into different categories.
  SELECT 
	   m.title AS movie_title,
       avg_rating,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         WHEN avg_rating < 5 THEN 'Flop movies'
       END   AS 'avg_rating_category'
FROM genre g
       INNER JOIN rating r ON g.movie_id = r.movie_id
       INNER JOIN movies m ON r.movie_id = m.id
WHERE genre = 'thriller'; 

#Q2 Analyse the genre-wise running total and moving average of the average movie duration.
WITH GENRE AS 
		(SELECT GENRE,
		    ROUND(AVG(m.duration), 2) AS avg_duration,
			SUM(AVG(m.duration)) OVER (ORDER BY g.genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
			AVG(AVG(m.duration)) OVER (ORDER BY g.genre ROWS UNBOUNDED PRECEDING) AS running_avg_duration
         FROM movies m
		 INNER JOIN genre g ON m.ID = g.movie_id
         GROUP  BY GENRE)
SELECT genre,
       avg_duration,
       ROUND(running_total_duration, 2) AS running_total_duration,
       ROUND(running_avg_duration, 2) AS running_avg_duration
FROM   GENRE;

#Q3-  Identify the five highest-grossing movies of each year that belong to the top three genres.
WITH genre_top_3 AS
(
    SELECT genre, COUNT(movie_id) AS movie_count
    FROM genre GROUP BY genre
    ORDER BY movie_count DESC
    LIMIT 3
),
base_table AS
(
   SELECT a.*,b.genre, REPLACE(worlwide_gross_income,'$ ','') AS new_gross_income
   FROM movies a
   INNER JOIN genre b
   ON a.id = b.movie_id
   WHERE genre IN (SELECT genre FROM genre_top_3)
)
SELECT * FROM
(
   SELECT genre, YEAR , title, worlwide_gross_income,
   DENSE_RANK() OVER (PARTITION BY genre, YEAR ORDER BY new_gross_income DESC) AS movie_rank
   FROM base_table
)t
WHERE movie_rank <= 5
ORDER BY genre, YEAR, movie_rank; 
 
#Q4- Determine the top two production houses that have produced the highest number of hits among multilingual movies.
SELECT production_company,
	   COUNT(production_company) AS movie_count ,
	   DENSE_RANK() OVER(ORDER BY COUNT(production_company) DESC) AS prod_comp_rank
FROM movies 
WHERE languages REGEXP ','
GROUP BY production_company
LIMIT 2;

#Q5- Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.
SELECT name AS actress_name,
           SUM(total_votes) AS total_votes,
           COUNT(name) AS movie_count,
           ROUND(SUM(avg_rating * total_votes)/SUM(total_votes),2) AS actress_avg_rating,
           ROW_NUMBER() OVER (ORDER BY COUNT(name) DESC) AS actress_rank
FROM genre g
INNER JOIN movies m ON g.movie_id = m.id
INNER JOIN rating r ON m.id = r.movie_id
INNER JOIN role_mapping rm ON r.movie_id = rm.movie_id
INNER JOIN names n ON rm.name_id = n.id
WHERE avg_rating>8
AND genre = 'drama'
AND category= 'actress'
GROUP BY name
LIMIT 3;

#Q6- Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.
WITH director_movie_count AS (
    SELECT dm.name_id, nm.name, COUNT(*) AS movie_count
    FROM director_mapping dm
    INNER JOIN names nm ON dm.name_id = nm.id
    GROUP BY dm.name_id, nm.name
),
director_average_duration AS (
    SELECT dm.name_id, AVG(m.duration) AS average_duration
    FROM director_mapping dm
    INNER JOIN movies m ON dm.movie_id = m.id
    GROUP BY dm.name_id
),
director_total_ratings AS (
    SELECT dm.name_id, SUM(r.total_votes) AS total_votes
    FROM director_mapping dm
    INNER JOIN rating r ON dm.movie_id = r.movie_id
    GROUP BY dm.name_id
),
ranked_directors AS (
    SELECT dmc.name_id, dmc.name, dmc.movie_count, ad.average_duration, tr.total_votes,
           ROW_NUMBER() OVER (ORDER BY dmc.movie_count DESC) AS `rank`
    FROM director_movie_count dmc
    LEFT JOIN director_average_duration ad ON dmc.name_id = ad.name_id
    LEFT JOIN director_total_ratings tr ON dmc.name_id = tr.name_id
)
SELECT name, movie_count, average_duration, total_votes
FROM ranked_directors
WHERE `rank` <= 9;

-- 2nd option

SELECT nm.name, COUNT(*) AS movie_count, AVG(m.duration) AS average_duration, SUM(r.total_votes) AS total_votes
FROM director_mapping dm
INNER JOIN names nm ON dm.name_id = nm.id
INNER JOIN movies m ON dm.movie_id = m.id
INNER JOIN rating r ON dm.movie_id = r.movie_id
GROUP BY dm.name_id, nm.name
ORDER BY movie_count DESC
LIMIT 9;
-- Segment 7: Recommendations
#Q1- Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.
/* 
Ans: Based on the Analysis of the IMBd Movies, the recommendations for the types of content Bolly Movies should focus on producing is:-

          1. The 'Triller' genre has caught the highest attention and interest amongst the audience as the amount of 'Thriller' movies watched is good,
	         so the Bollywood movie production houses should keep their interest towards producing more 'Thriller' genre movies. 
       
          2. The 'Drama' genre has gained the overall average highest IMDb rating by the audience, so the Bollywood movies production houses 
             should focus more on producing quality content movies in the 'Drama' genre as they have been doing.
       
          3. The Bollywood movie production houses should also focus on producing good quality movies in other genres as well for the 
             growth of the bollywood movie industry.
*/