require 'sequel'
require_relative 'movie'

if ARGV.length != 1 or ARGV[0] == '-h'
	puts "USAGE: ruby db_builder.rb <film info file>"
	puts "Builds a database out of movie data"
	exit 1
end

#	Constant strings
MOVIE_COLUMNS = "title, year, rated, poster, country, f_type"
GENRE_COLUMN = "genre"
DIRECTOR_COLUMN = "name"
ACTOR_COLUMN = "name"
GENRE_TABLE = "genres"
DIRECTOR_TABLE = "directors"
ACTOR_TABLE = "actors"

=begin
			Helper function to insert into singleton tables
			Edit each element to surround with quotes
			Add each element to respective column IFF not already in it
			Create proper relationships with the current movie
=end
def insert_single_value(value, table, column)
	value = "'#{value}'"
	DB.run("INSERT INTO #{table} (#{column}) VALUES (#{value})") if element_exists?(value, table, column) 
end

def element_exists?(value, table, column)
	DB["SELECT * FROM #{table} WHERE #{column} = #{value}"].count == 0
end

#	Open input file and database connection
#	sqlite3 and sequel gems required, as well as yum's sqlite3-devel
film_info = File.open(ARGV[0], 'r')
DB = Sequel.connect('sqlite://movies.db')

=begin
			Look at each line in the file and create a movie object
			Add an entry to movies, genres, actors, directors table
			Create a relational entry in is_genre, directed_by, acted_in tables
=end
film_info.each_line do |line|
	movie = Movie.build_from_data line

	movie_values = "'#{movie.title}', '#{movie.year}', '#{movie.rated}', '#{movie.poster}', '#{movie.country}', '#{movie.type}'"
	DB.run("INSERT INTO movies (#{MOVIE_COLUMNS}) VALUES (#{movie_values})") if element_exists?("'#{movie.title}'", "movies", "title")

	movie.genres.map{|genre| insert_single_value(genre, GENRE_TABLE, GENRE_COLUMN)}
	movie.directors.map{|director| insert_single_value(director, DIRECTOR_TABLE, DIRECTOR_COLUMN)}
	movie.actors.map{|actor| insert_single_value(actor, ACTOR_TABLE, ACTOR_COLUMN)}
end
