CREATE TABLE movies(
	id       INTEGER PRIMARY KEY AUTO_INCREMENT,
	title    VARCHAR(255) UNIQUE NOT NULL,
	year     SMALLINT NOT NULL,
	rated    VARCHAR(10) NOT NULL,
	poster   VARCHAR(255) NOT NULL,
	country  VARCHAR(100) NOT NULL,
	f_type   VARCHAR(100) NOT NULL
);

CREATE TABLE genres(
	id		INTEGER PRIMARY KEY AUTO_INCREMENT,
	genre	VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE actors(
	id    INTEGER PRIMARY KEY AUTO_INCREMENT,
	name  VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE directors(
	id    INTEGER PRIMARY KEY AUTO_INCREMENT,
	name  VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE users(
	id             INTEGER PRIMARY KEY AUTO_INCREMENT,
	name           VARCHAR(255) NOT NULL,
	age				INTEGER NOT NULL,
	country        VARCHAR(100) NOT NULL,
	login_name     VARCHAR(255) UNIQUE NOT NULL,
	pass_hash      VARCHAR(255) NOT NULL
);

CREATE TABLE is_genre(
	id			INTEGER PRIMARY KEY AUTO_INCREMENT,
	film_id	INTEGER NOT NULL,
	genre_id	INTEGER NOT NULL,
	FOREIGN KEY(film_id) REFERENCES movies(id),
	FOREIGN KEY(genre_id) REFERENCES genres(id)
);

CREATE TABLE directed_by(
	id          INTEGER PRIMARY KEY AUTO_INCREMENT,
	film_id     INTEGER NOT NULL,
	director_id INTEGER NOT NULL,
	FOREIGN KEY(film_id) REFERENCES movies(id),
	FOREIGN KEY(director_id) REFERENCES directors(id)
);

CREATE TABLE acted_in(
	id       INTEGER PRIMARY KEY AUTO_INCREMENT,
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
	id       INTEGER PRIMARY KEY AUTO_INCREMENT,
	rating	NUMBER NOT NULL,
	user_id  INTEGER NOT NULL,
	film_id  INTEGER NOT NULL,
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(film_id) REFERENCES movies(id)
);
