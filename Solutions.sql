Schema
	
```sql
Create table Netflix
(
	show_id	varchar (6),
	type varchar (10),
	title varchar (150),
	director varchar (210),
	casts varchar (1000),
	country varchar (150),
	date_added varchar (50),
	release_year Int,
	rating varchar (10),
	duration varchar (15),
	listed_in varchar (100),
	description varchar (300)
);
```

- 1. Count the number of movies vs tv shows

select type, count(1) as Cnt
from netflix
group by type

-- 2. Find the most common rating for movies and tv shows

select type, rating
from(
select type, rating, count(1),
Rank() over(partition by type order by count(1) desc) as Ranking
from netflix
group by type, rating) a
where Ranking = 1

--3. List all the movies released in a specific year. e.g., 2020


select type, title, release_year
from netflix
where type = 'Movie' AND release_year = 2020

--4. Find the top 5 countries with the most content on netflix.

select 
UNNEST(STRING_TO_ARRAY(country, ',')) as new_country
, count(title) as Top
from netflix
group by UNNEST(STRING_TO_ARRAY(country, ','))
order by count(title) desc
LIMIT 5


--5. Identify the longest movie?

with cte as
(select type,
	title,
	cast(split_part(duration,' ',1) as INTEGER) as duration
from netflix
where type='Movie')
select type, title,duration
from cte
where duration=(select max(duration)
from cte);

--6. Find content added in the last 5 years

select *,
TO_DATE(date_added, 'Month DD, YYYY')
from netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= current_date - interval '5 Years'

--7. Find all the movie/TV show by director 'Rajiv Chilaka'!

with CTE as (
select *, UNNEST(STRING_TO_ARRAY(director, ',')) as New_director
from netflix)

select type, title, director
from CTE
where New_director = 'Rajiv Chilaka'

Other way to find. -- In case first letter is small or last letter is small. using ILIKE we can get all records.

select type, title, director
from netflix
where director ILIKE '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 Seasons

select * -- This is how we converted, Cast(SPLIT_PART(duration, ' ', 1) as INTEGER) as New_duration
from netflix
where type = 'TV Show' and Cast(SPLIT_PART(duration, ' ', 1) as INTEGER) > 5

--9. Count the number of content item in each genre

select
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as New_listed_in, count(1) as No_of_content
from netflix
group by UNNEST(STRING_TO_ARRAY(listed_in, ','))

--10. For each year what is the average number of content release by India on netflix. Return top 5 year with hightest avg content release.


select extract(Year from date_added :: DATE) as Year, --UNNEST(STRING_TO_ARRAY(country, ',')) as New_country,
Count(1) as No_of_content, Round(Count(1):: numeric / (select count(1) from netflix where country ILIKE '%India%'):: numeric * 100, 2) as Average
from netflix
where country ILIKE '%India%'
group by extract(Year from date_added :: DATE)
order by Round(Count(1):: numeric / (select count(1) from netflix where country ILIKE '%India%'):: numeric * 100, 2) desc
LIMIT 5

--used this as sub query 
--select count(1)
--from netflix
--where country ILIKE '%India%'

--11. List all the movies that are documentries.
--"Docuseries" 829

with CTE as (
select type, title,
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as Genre
from netflix
where type = 'Movie'
)

select *
from CTE
where Genre ILIKE '%documentaries%'

--12. Find all content wothout a director.

select *
from netflix
where director is null

--13. Find how many movies actor Salman Khan appeared in last 10 years.

with CTE as (
select count(show_id) as No_of_Movies, UNNEST(STRING_TO_ARRAY(casts, ',')) as Actors, release_year, title
from netflix
group by UNNEST(STRING_TO_ARRAY(casts, ',')), release_year, title
)
select *
from CTE
where Actors ILIKE '%Salman Khan%' AND release_year >= Extract(Year from Current_date) - 10
order by release_year


--14. Find the top 10 actors who have appeared in the hightest number of movies produced in India

Select count(show_id) as No_of_movies, UNNEST(STRING_TO_ARRAY(casts, ',')) as Top_Actors
from netflix
where country ILIKE '%India%'
Group by UNNEST(STRING_TO_ARRAY(casts, ','))
order by count(show_id) desc
Limit 10


--15. Categorize the content based on the presence of the keywords 'Kill' and 'Violence' in the description field. 
--Label content containing these keywords as 'Bold' and all other content as 'Good'. Count how many items fall into each category.

with Category_table as (
select *, case when description ILIKE '%Kill%' or description ILIKE '%Violence%' then 'Bad_content' else 'Good_Content' end as Category
from netflix
)

select Category, count(1) as No_of_content
from category_table
group by category





