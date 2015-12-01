--What genres will do well in certain countries? (Country is intended audience)
SELECT g.genre, AVG(r.rating)
FROM movies m, movie_ratings r, genres g, is_genre ig, users u
WHERE u.country = ?
	AND m.id = r.film_id
	AND ig.genre_id = g.id
	AND m.id = ig.film_id
GROUP BY r.film_id
ORDER BY ig.genre_id;

--How many movies has a country produced that have good or bad ratings? (Country is producer)
SELECT c.name, c.a
FROM (
	SELECT m.name, AVG(r.rating) a
	FROM movies m, movie_ratings r
	WHERE m.country = ?
		AND m.id = r.film_id) c
WHERE c.a >= 3.5
ORDER BY c.a;

SELECT c.name, c.a
FROM ( 
	SELECT m.name, AVG(r.rating) a
	FROM movies m, movie_ratings r
	WHERE m.country = ?
		AND m.id = r.film_id) c
WHERE c.a < 3.5
ORDER BY c.a;

--Your country's movies are liked by what other country?
SELECT u.country, AVG(r.rating)
FROM movies m, movie_ratings r, users u
WHERE m.country = ?
	AND m.id = r.film_id
	AND r.user_id = u.id
GROUP BY u.country
ORDER BY u.country;

--Are movies better when certain directors work with certain actors?
--Are two movies where the director and actor work together better than the director's avg rating

--Are movies better when certain directors make movies of certain genres?
SELECT g.genre, AVG(r.rating) 
FROM movies m, movie_ratings r, directed_by d, is_genre ig, genres g
WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1)
	AND m.id = d.film_id
	AND m.id = r.film_id
	AND m.id = ig.film_id
	AND ig.genre_id = g.id
GROUP BY ig.genre_id
ORDER BY ig.genre_id;

--Do director careers get better or worse with time?
--ORDER BY defaults to ascending
--Graph the results and let the user decide???
SELECT m.name, m.year, AVG(r.rating) 
FROM movies m, movie_ratings r, directed_by b
WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1)
	AND m.id = d.film_id
	AND m.id = r.film_id
GROUP BY r.film_id
ORDER BY m.year;

--Do actor careers get better or worse by time?
SELECT m.name, m.year, AVG(r.rating) 
FROM movies m, movie_ratings r, acted_in a
WHERE a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1)
	AND m.id = a.film_id
	AND m.id = r.film_id
GROUP BY r.film_id
ORDER BY m.year;

--Do actors do better in certain genres?
SELECT g.genre, AVG(r.rating) 
FROM movies m, movie_ratings r, acted_in a, is_genre ig, genres g
WHERE a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1)
	AND m.id = a.film_id
	AND m.id = r.film_id
	AND m.id = ig.film_id
	AND ig.genre_id = g.id
GROUP BY ig.genre_id
ORDER BY ig.genre_id;

--Are actors received better in certain countries?
SELECT u.country, AVG(r.rating)
FROM movies m, movie_ratings r, acted_in a
WHERE a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1)
	AND m.id = a.film_id
	AND m.id = r.film_id
GROUP BY u.country
ORDER BY u.country;
