CREATE TABLE movies(
	id       INTEGER PRIMARY KEY AUTOINCREMENT,
	title    TEXT UNIQUE NOT NULL,
	year     SMALLINT NOT NULL,
	rated    TEXT NOT NULL,
	poster   TEXT NOT NULL,
	country  TEXT NOT NULL,
	f_type   TEXT NOT NULL
);

CREATE TABLE genres(
	id		INTEGER PRIMARY KEY AUTOINCREMENT,
	genre	TEXT UNIQUE NOT NULL
);

CREATE TABLE actors(
	id    INTEGER PRIMARY KEY AUTOINCREMENT,
	name  TEXT UNIQUE NOT NULL
);

CREATE TABLE directors(
	id    INTEGER PRIMARY KEY AUTOINCREMENT,
	name  TEXT UNIQUE NOT NULL
);

CREATE TABLE users(
	id             INTEGER PRIMARY KEY AUTOINCREMENT,
	name           TEXT NOT NULL,
	age				INTEGER NOT NULL,
	country        TEXT NOT NULL,
	login_name     TEXT UNIQUE NOT NULL,
	pass_hash      TEXT NOT NULL
);

CREATE TABLE is_genre(
	id			INTEGER PRIMARY KEY AUTOINCREMENT,
	film_id	INTEGER NOT NULL,
	genre_id	INTEGER NOT NULL,
	FOREIGN KEY(film_id) REFERENCES movies(id),
	FOREIGN KEY(genre_id) REFERENCES genres(id)
);

CREATE TABLE directed_by(
	id          INTEGER PRIMARY KEY AUTOINCREMENT,
	film_id     INTEGER NOT NULL,
	director_id INTEGER NOT NULL,
	FOREIGN KEY(film_id) REFERENCES movies(id),
	FOREIGN KEY(director_id) REFERENCES directors(id)
);

CREATE TABLE acted_in(
	id       INTEGER PRIMARY KEY AUTOINCREMENT,
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

CREATE TABLE movie_rating(
	id       INTEGER PRIMARY KEY AUTOINCREMENT,
	rating	NUMBER NOT NULL,
	user_id  INTEGER NOT NULL,
	film_id  INTEGER NOT NULL,
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(film_id) REFERENCES movies(id)
);
