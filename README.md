# Netflix movies and TV shows data analysis using SQL
![Alt text](Netflix_2015_logo.svg.png)

## Overview
The dataset contains information about 8,807 Netflix titles, including movies and TV shows. It includes attributes such as title, director, cast, country of origin, release year, date added to Netflix, rating, duration, genre (listed_in), and description. The dataset provides insights into Netflix's content library, allowing for an analysis of trends in content production and distribution.

## Objective
The objective of this project is to uncover patterns in content production, distribution, and audience preferences.
Key Goals:
1. Content Distribution Analysis
 - Compare the number of Movies vs. TV Shows on Netflix.
 - Identify the most common content ratings for different types of content.
 - Analyze content distribution by country and genre.

2. Trend Analysis
 - Track content additions over time, focusing on the last five years.
 - Identify the top-producing countries for Netflix content.
 - Determine the average number of content releases per year for Indian titles.

3. Deep Dive into Content Attributes
 - Find the longest movie available on Netflix.
 - List TV shows with more than five seasons.
 - Identify content that is missing director information.
 - Find actors with the highest number of appearances in Netflix content.

4. User Interest and Content Categorization
 - Analyze the popularity of documentaries on Netflix.
 - Categorize content based on keywords like "Kill" and "Violence" to label content as "Bold" or "Good".
 - Identify all movies or shows directed by specific directors or featuring certain actors like Salman Khan.

```SQL
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

### 1. Count the number of movies vs tv shows
```SQL
select type, count(1) as Cnt
from netflix
group by type
```

### 2. Find the most common rating for movies and tv shows
```SQL
select type, rating
from(
select type, rating, count(1),
Rank() over(partition by type order by count(1) desc) as Ranking
from netflix
group by type, rating) a
where Ranking = 1
```

### 3. List all the movies released in a specific year. e.g., 2020
```SQL
select type, title, release_year
from netflix
where type = 'Movie' AND release_year = 2020
```

### 4. Find the top 5 countries with the most content on netflix.
```SQL
select 
UNNEST(STRING_TO_ARRAY(country, ',')) as new_country
, count(title) as Top
from netflix
group by UNNEST(STRING_TO_ARRAY(country, ','))
order by count(title) desc
LIMIT 5
```

### 5. Identify the longest movie?
```SQL
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
```

### 6. Find content added in the last 5 years
```SQL
select *,
TO_DATE(date_added, 'Month DD, YYYY')
from netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= current_date - interval '5 Years'
```

### 7. Find all the movie/TV show by director 'Rajiv Chilaka'!
```SQL
with CTE as (
select *, UNNEST(STRING_TO_ARRAY(director, ',')) as New_director
from netflix)

select type, title, director
from CTE
where New_director = 'Rajiv Chilaka'
```

### 7.A Other way to find. -- In case first letter is small or last letter is small. using ILIKE we can get all records.
```SQL
select type, title, director
from netflix
where director ILIKE '%Rajiv Chilaka%'
```

### 8. List all TV shows with more than 5 Seasons
```SQL
select * -- This is how we converted, Cast(SPLIT_PART(duration, ' ', 1) as INTEGER) as New_duration
from netflix
where type = 'TV Show' and Cast(SPLIT_PART(duration, ' ', 1) as INTEGER) > 5
```

### 9. Count the number of content item in each genre
```SQL
select
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as New_listed_in, count(1) as No_of_content
from netflix
group by UNNEST(STRING_TO_ARRAY(listed_in, ','))
```

### 10. For each year what is the average number of content release by India on netflix. Return top 5 year with hightest avg content release.
```SQL
select extract(Year from date_added :: DATE) as Year, --UNNEST(STRING_TO_ARRAY(country, ',')) as New_country,
Count(1) as No_of_content, Round(Count(1):: numeric / (select count(1) from netflix where country ILIKE '%India%'):: numeric * 100, 2) as Average
from netflix
where country ILIKE '%India%'
group by extract(Year from date_added :: DATE)
order by Round(Count(1):: numeric / (select count(1) from netflix where country ILIKE '%India%'):: numeric * 100, 2) desc
LIMIT 5
```

### 11. List all the movies that are documentries.
```SQL
with CTE as (
select type, title,
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as Genre
from netflix
where type = 'Movie'
)

select *
from CTE
where Genre ILIKE '%documentaries%'
```

### 12. Find all content wothout a director.
```SQL
select *
from netflix
where director is null
```

### 13. Find how many movies actor Salman Khan appeared in last 10 years.
```SQL
with CTE as (
select count(show_id) as No_of_Movies, UNNEST(STRING_TO_ARRAY(casts, ',')) as Actors, release_year, title
from netflix
group by UNNEST(STRING_TO_ARRAY(casts, ',')), release_year, title
)
select *
from CTE
where Actors ILIKE '%Salman Khan%' AND release_year >= Extract(Year from Current_date) - 10
order by release_year
```

### 14. Find the top 10 actors who have appeared in the hightest number of movies produced in India
```SQL
Select count(show_id) as No_of_movies, UNNEST(STRING_TO_ARRAY(casts, ',')) as Top_Actors
from netflix
where country ILIKE '%India%'
Group by UNNEST(STRING_TO_ARRAY(casts, ','))
order by count(show_id) desc
Limit 10
```

### 15. Categorize the content based on the presence of the keywords 'Kill' and 'Violence' in the description field. Label content containing these keywords as 'Bold' and all other content as 'Good'. Count how many items fall into each category.
```SQL
with Category_table as (
select *, case when description ILIKE '%Kill%' or description ILIKE '%Violence%' then 'Bad_content' else 'Good_Content' end as Category
from netflix
)

select Category, count(1) as No_of_content
from category_table
group by category
```
