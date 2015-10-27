T H E  M A G I C  C O M P A S S 

Ruby/Sinatra-based movie statistic platform for film investors trying to see if a new movie might be a good idea, based on previous films and audiences. 

Data scrapped from IMDb using OMDb (http://www.omdbapi.com), users are currently generated at random; all placed in a MySQL database using Ruby's Sequel library (http://sequel.jeremyevans.net/rdoc/files/doc/sql_rdoc.html). 



@TODO - Database
*	Scrape data from imdb (Eric - Completed)
*	Generate random names (Alison - Completed)
*	Add a random amount of random 'seen' movies to the fullnames file (update name generator) (Alison - Complete)
*	Give each movie each person has seen a rating with trends built-in (Alison)
*	Create a Schema.sql file (Eric - Completed)
*	Build the database given the 'film_info.txt' in a new Ruby script (Eric - Completed)
*	Build the database given the 'users.txt' in a new Ruby script (Alison)

@TODO - Queries
*	View movies by country
	*	What genres do well in certain countries?
	*	How many movies has a country produced that have good ratings, vs bad movies? (see if your audience is world-wide, which coutries produce good movies?) (percentage)
	*	What country's movies are liked by what country (correlations)? (if your audience does not reflect your movie, the movie will flop)
*	View director trends 
	*	Are movies better when certain directors work with certain actors? (if so, for your movie, good) (must have more than one pairing)
	*	Are movies better when certain directors make movies of certain genres? (if so, for your movie, good)
	*	Do director careers get better or worse with time? (if this director no longer makes good movies, well, oh no)
*	View actor trends
	*	Do actor careers get better or worse with time?
	*	Do actors do better in certain roles (genres)?
	*	Do actors do better in certain countries? (sum of fans/country, if this actor does well in X but target audience is Y, bad)
*	Movie by rating?

@TODO - Website
*	Create a login system: store user/pass in db but hash pass 
*	Create a login page
*	Create a home page, recommends movies based on the user logged in 
*	Create a user page/user 
