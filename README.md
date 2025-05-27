# Netflix_SQL_project
## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.
## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

- ## Note
Before Creating database or Table it is best practice to take a quick look at dataset and calculate maximum length of text fields/coloums so that we can define the length of fields appropriately.

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
select type,rating from
(select type,rating,count(rating) counts,
row_number() over(partition by type order by count(rating) desc) as ramk
from netflix
group by type,rating order by type desc) as sq 
where ramk=1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select title as movies_released_in_2020
from netflix
where type='Movie' and release_year=2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
select unnest(string_to_array(country,',')) as new_country,count(*)
from netflix
group by 1
order by 2 desc
limit 5
;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
select title,cast(replace(duration,' min','')as integer)as duration
from netflix
where type='Movie' and duration is not null
order by duration desc 
limit 1;
```

**Objective:** Find the movie with the longest duration.


### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select title as directed_by_Rajiv_Chilaka
from netflix
where director ilike '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
with cte as(
select title,cast(split_part(duration,' ',1)as integer) as seasons
from netflix
where type='TV Show' 
order by 2 desc
)
select * from cte 
where seasons>5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
select genre,count(*) as contents
from(
select *,unnest(string_to_array(listed_in,',')) as genre
from netflix
)as sq group by genre order by 2 desc;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
with cte1 as(
select split_part(date_added,'-',1)::int as ryear,count(*) as num_ from netflix
where country ilike '%India%'
group by ryear
)
select ryear,num_,round(((num_/(select sum(num_) from cte1))*100),2) as average_content
from cte1
order by 2 desc
limit 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select title
from netflix
where listed_in ilike '%documentaries%' 
		and type='Movie';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select * from netflix
where director is null;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select count(*) as total_appearrences_of_salman_khan
from netflix 
where casts ilike '%salman khan%'
and release_year >= extract(year from current_date-interval '10 years');
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
with cte as(
select *,unnest(string_to_array(casts,',')) as actors from netflix
where country ilike '%India%' and type='Movie'
)
select actors,count(*) as appearences from cte
group by 1 order by 2 desc
limit 10
;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
select catogery,count(*)
from(
select *,
case 
	when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
	else 'Good' end as catogery
from netflix
) as cato
group by catogery;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.


## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Yaswanth Balaji

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!




