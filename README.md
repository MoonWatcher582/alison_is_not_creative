T H E  M A G I C  C O M P A S S 

Ruby/Sinatra-based movie statistic platform for film investors trying to see if a new movie might be a good idea, based on previous films and audiences. 

Data scrapped from IMDb using OMDb (http://www.omdbapi.com), users are currently generated at random; all placed in a MySQL database using Ruby's Sequel library (http://sequel.jeremyevans.net/rdoc/files/doc/sql_rdoc.html). 



@TODO - Database
*	Scrape data from imdb (Eric - Completed)
*	Generate random names (Alison - Completed)
*	Add a random amount of random 'seen' movies to the fullnames file (update name generator)
*	Give each movie each person has seen a rating with trends built-in
*	Create a Schema.sql file (Eric - Completed)
*	Build the database given the 'users.txt' and 'film_info.txt' in a new Ruby script (Eric)

@TODO - Queries
*	View movies by country
	*	How many movies from X country have good ratings?
	*	Do coutry of users and country of movie affect rating (correlations)?
*	View director trends 
	*	Are movies better when certain directors work with certain actors?
	*	Are movies better when certain directors make movies of certain genres?
	*	Do director careers get better or worse with time?
*	View actor trends
	*	Do actor careers get better or worse with time?
	*	Do actors do better in certain roles (genres)?

@TODO - Website
*	Create a login system: store user/pass in db but hash pass 
*	Create a login page
*	Create a home page, recommends movies based on the user logged in 
*	Create a user page/user 
