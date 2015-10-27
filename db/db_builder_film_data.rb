require 'sequel'

if ARGV.length != 4 or ARGV[0] == '-h'
	puts "USAGE: ruby db_builder.rb <film info file> <genre relation file> <director relation file> <actor relation file>"
	puts "Builds a database out of movie data"
	exit 1
end

#	Constant strings
MOVIE_COLUMNS = "title, year, rated, poster, country, f_type"
GENRE_COLUMN = "genre"
DIRECTOR_COLUMN = "name"
ACTOR_COLUMN = "name"
MOVIE_TABLE = "movies"
GENRE_TABLE = "genres"
DIRECTOR_TABLE = "directors"
ACTOR_TABLE = "actors"

=begin
			Helper function to insert into singleton tables
			Edit each element to surround with quotes
			Add each element to respective column IFF not already in it
			Create proper relationships with the current movie
=end

def insert_value(value, table, column)
	DB.run("INSERT INTO #{table} (#{column}) VALUES (#{value})") if not element_exists?(value, table, column)
end

def element_exists?(value, table, column)
	DB["SELECT * FROM #{table} WHERE #{column} = #{value.chomp}"].count > 0
end

#	Open input files and database connection
#	sqlite3 and sequel gems required, as well as yum's sqlite3-devel
DB = Sequel.connect('sqlite://movies.db')
film_info = File.open(ARGV[0], 'r')
genre_data = File.open(ARGV[1], 'r')
director_data = File.open(ARGV[2], 'r')
actor_data = File.open(ARGV[3], 'r')

=begin
			Look at each line in the file and insert movie into database 
=end
puts "Parsing and inserting from #{ARGV[0]}"
film_info.each_line do |line|
	movie = line.chomp.split(',')
	movie_values = "'#{movie[0]}', '#{movie[1]}', '#{movie[2]}', '#{movie[4]}', '#{movie[3]}', '#{movie[5]}'"
	DB.run("INSERT INTO movies (#{MOVIE_COLUMNS}) VALUES (#{movie_values})") if not element_exists?("'#{movie[0]}'", "movies", "title")
end

#	for each of these, add entry to the relational table
puts "Parsing and inserting from #{ARGV[1]}"
genre_data.each_line do |line|
	genre = line.chomp.split(',')
	insert_value("'#{genre[1]}'", GENRE_TABLE, GENRE_COLUMN)
	DB.run("INSERT INTO is_genre (film_id, genre_id) VALUES ( (SELECT m.id FROM movies m WHERE m.title = '#{genre[0]}'), (SELECT g.id FROM genres g WHERE g.genre = '#{genre[1]}') )")
end

puts "Parsing and inserting from #{ARGV[2]}"
director_data.each_line do |line|
	puts "Working on tuple: #{line}"
	director = line.chomp.split(',')
	insert_value("'#{director[1]}'", DIRECTOR_TABLE, DIRECTOR_COLUMN)
	DB.run("INSERT INTO directed_by (film_id, director_id) VALUES ( (SELECT m.id FROM movies m WHERE m.title = '#{director[0]}'), (SELECT d.id FROM directors d WHERE d.name = '#{director[1]}') )")
end

puts "Parsing and inserting from #{ARGV[3]}"
actor_data.each_line do |line|
	puts "Working on tuple: #{line}"
	actor = line.chomp.split(',')
	insert_value("'#{actor[1]}'", ACTOR_TABLE, ACTOR_COLUMN)
	DB.run("INSERT INTO acted_in (film_id, actor_id) VALUES ( (SELECT m.id FROM movies m WHERE m.title = '#{actor[0]}'), (SELECT a.id FROM actors a WHERE a.name = '#{actor[1]}') )")
end

puts "Cleaning up..."
film_info.close
genre_data.close
director_data.close
actor_data.close
