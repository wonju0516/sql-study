-- 이걸 맨 처음에 쳐야 실행됨
SET search_path TO dvdrental;


-- order by - sorting results
select first_name, last_name, actor_id
from actor
order by actor_id desc;

-- where - filtering rows
select title, length
from dvdrental.film -- 테이블명 앞에 스키마 직접 명시
where length > 100
order by length desc;

SELECT title, length, rating
FROM dvdrental.film
WHERE length > 100 AND rating = 'G';

-- limit
SELECT title, length
FROM dvdrental.film
LIMIT 10;

SELECT title
FROM dvdrental.film
WHERE title 

-- distinct
SELECT DISTINCT(rental_rate)
FROM dvdrental.film

-- between
SELECT title, length
FROM dvdrental.film
WHERE length BETWEEN 50 AND 100;

SELECT title, length
FROM dvdrental.film
WHERE length >= 50 AND length <= 100;

-- in
SELECT title, rating
from dvdrental.film
WHERE rating IN('PG', 'G', 'PG-13');

-- LIKE
SELECT title, rating
from dvdrental.film
WHERE title like 'AC%';

-- ILIKE

SELECT title, rating
FROM dvdrental.film
WHERE title ilike '%egg%'


select *
from actor;
