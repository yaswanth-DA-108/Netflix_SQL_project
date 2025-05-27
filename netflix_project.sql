-- 7	104	208	771	123	19	4	8	10	79	250
create table netflix (
show_id varchar(10)	,
type varchar(10),
title varchar(110),
director varchar(210),
casts varchar(780),
country varchar(130),	
date_added varchar(20),
release_year int,
rating varchar(10),
duration varchar(10),
listed_in varchar(80),
description varchar(250));

select * from netflix;

select distinct type
from netflix;



/*1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!
11. List all movies that are documentaries
12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.   */

-- 1. Count the number of Movies vs TV Shows

select type,count(type) from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
select type,rating from
(select type,rating,count(rating) counts,
row_number() over(partition by type order by count(rating) desc) as ramk
from netflix
group by type,rating order by type desc) as sq 
where ramk=1;

-- 3. List all movies released in a specific year (e.g., 2020)
select title as movies_released_in_2020
from netflix
where type='Movie' and release_year=2020;

-- Find the top 5 countries with the most content on Netflix
select 
	unnest(string_to_array(country,',')) as new_country
	from netflix;

select unnest(string_to_array(country,',')) as new_country,count(*)
from netflix
group by 1
order by 2 desc
limit 5
;

-- 5. Identify the longest movie
select title,cast(replace(duration,' min','')as integer)as duration
from netflix
where type='Movie' and duration is not null
order by duration desc 
limit 1;

-- 6. Find content added in the last 5 years
select * from netflix;

update netflix
set date_added=to_date(date_added,'Month DD,YYYY');

select * from netflix
where to_date(date_added,'YYYY,MM,DD') >= current_date-interval '5 years';



-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select title as directed_by_Rajiv_Chilaka
from netflix
where director ilike '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons

with cte as(
select title,cast(split_part(duration,' ',1)as integer) as seasons
from netflix
where type='TV Show' 
order by 2 desc
)
select * from cte 
where seasons>5;


-- 9. Count the number of content items in each genre
select * from netflix;
select genre,count(*) as contents
from(
select *,unnest(string_to_array(listed_in,',')) as genre
from netflix
)as sq group by genre order by 2 desc;

-- 10.Find each year and the average numbers of content release in India on netflix. 
--     return top 5 year with highest avg content release!  

with cte1 as(
select split_part(date_added,'-',1)::int as ryear,count(*) as num_ from netflix
where country ilike '%India%'
group by ryear
)
select ryear,num_,round(((num_/(select sum(num_) from cte1))*100),2) as average_content
from cte1
order by 2 desc
limit 5;

-- 11. List all movies that are documentaries
select title from netflix
where listed_in ilike '%documentaries%' 
		and type='Movie';

-- 12. Find all content without a director
select * from netflix where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select extract(year from current_date-interval '10 years');
select date_part('year', current_date-interval '10 years');
select to_char( current_date-interval '10 years','yyyy')::int;

select count(*) as total_appearrences_of_salman_khan
from netflix 
where casts ilike '%salman khan%'
and release_year >= extract(year from current_date-interval '10 years');

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
with cte as(
select *,unnest(string_to_array(casts,',')) as actors from netflix
where country ilike '%India%' and type='Movie'
)
select actors,count(*) as appearences from cte
group by 1 order by 2 desc
limit 10
;


/*15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.   */

select catogery,count(*)
from(
select *,
case 
	when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
	else 'Good' end as catogery
from netflix
) as cato
group by catogery;






