CREATE TABLE movies(
	id       INTEGER PRIMARY KEY,
	title    TEXT UNIQUE NOT NULL,
	year     SMALLINT NOT NULL,
	rated    TEXT NOT NULL,
	poster   TEXT NOT NULL,
	country  TEXT NOT NULL,
	genre    TEXT NOT NULL,
	f_type   TEXT NOT NULL
);

CREATE TABLE actors(
	id    INTEGER PRIMARY KEY,
	name  TEXT UNIQUE NOT NULL
);

CREATE TABLE directors(
	id    INTEGER PRIMARY KEY,
	name  TEXT UNIQUE NOT NULL
);

CREATE TABLE users(
	id             INTEGER PRIMARY KEY,
	name           TEXT NOT NULL,
	country        TEXT NOT NULL,
	favorite_genre TEXT,
	login_name     TEXT UNIQUE NOT NULL,
	pass_hash      TEXT NOT NULL
);

CREATE TABLE directed_by(
	id          INTEGER PRIMARY KEY,
	film_id     INTEGER NOT NULL,
	director_id INTEGER NOT NULL,
	FOREIGN KEY(film_id) REFERENCES movies(id),
	FOREIGN KEY(director_id) REFERENCES directors(id)
);

CREATE TABLE acted_in(
	id       INTEGER PRIMARY KEY,
	film_id  INTEGER NOT NULL,
	actor_id INTEGER NOT NULL,
	FOREIGN KEY(film_id) REFERENCES movies(id),
	FOREIGN KEY(actor_id) REFERENCES actors(id)
);

/*
 *	A View is a virtual table,
 *	used as an alias for the sql statement below.
 *	The relationship for worked_with can be
 *	easily be accessed from other tables.
 */
CREATE VIEW [worked_with] AS
	SELECT DISTINCT d.director_id, a.actor_id
		FROM directed_by d, acted_in a
		WHERE d.film_id = a.film_id;

CREATE TABLE likes_actor(
	id       INTEGER PRIMARY KEY,
	user_id  INTEGER NOT NULL,
	actor_id INTEGER NOT NULL,
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(actor_id) REFERENCES actor(id)
);

CREATE TABLE likes_director(
	id          INTEGER PRIMARY KEY,
	user_id     INTEGER NOT NULL,
	director_id INTEGER NOT NULL,
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(director_id) REFERENCES directors(id)
);

CREATE TABLE likes_movie(
	id       INTEGER PRIMARY KEY,
	user_id  INTEGER NOT NULL,
	film_id  INTEGER NOT NULL,
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(film_id) REFERENCES movies(id)
);
