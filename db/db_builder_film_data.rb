require 'mysql2'
require 'sequel'
require 'yaml'

if ARGV.length != 4 or ARGV[0] == '-h'
	puts "USAGE: ruby db_builder.rb <film info file> <genre relation file> <director relation file> <actor relation file>"
	puts "Builds a database out of movie data"
	exit 1
end

#	Constant strings
MOVIE_COLUMNS = "title, year, rated, poster, country, f_type"
MOVIE_TABLE = "movies"

GENRE_NAME = "genre"
GENRE_TABLE = "genres"
GENRE_RELATION = "is_genre"
GENRE_ID = "genre_id"

DIRECTOR_NAME = "name"
DIRECTOR_TABLE = "directors"
DIRECTOR_RELATION = "directed_by"
DIRECTOR_ID = "director_id"

ACTOR_NAME = "name"
ACTOR_TABLE = "actors"
ACTOR_RELATION = "acted_in"
ACTOR_ID = "actor_id"

=begin
			Helper function to insert into singleton tables
			Edit each element to surround with quotes
			Add each element to respective column IFF not already in it
			Create proper relationships with the current movie
=end
def insert_value(value, table, column)
	DB.run "INSERT INTO #{table} (#{column}) VALUES (#{value})" if not element_exists? value, table, column
end

=begin
			Checks the number of rows returned by a SQL query to see if an element exists
			Query just SELECTS values in the sepecified column equal to the one passed in at the specified table
=end
def element_exists?(value, table, column)
	DB["SELECT * FROM #{table} WHERE #{column} = #{value.chomp}"].count > 0
end

=begin
			Helper function to insert relationship pairings
			Will insert the non-movie relationship into the specified table iff it is not already present
			Runs a query to create an entry in the relationship table
=end
def insert_relationship(file_desc, table, r_table, column, foreign_key)
	file_desc.each_line do |line|
		relation = line.chomp.split(',')
		insert_value("'#{relation[1]}'", table, column)
		DB.run "INSERT INTO #{r_table} (film_id, #{foreign_key}) VALUES ( (SELECT m.id FROM #{MOVIE_TABLE} m WHERE m.title = '#{relation[0]}'), (SELECT f.id FROM #{table} f WHERE f.#{column} = '#{relation[1]}') )"
	end
end

=begin
	Open database connection
	sqlite3 and sequel gems required, as well as yum's sqlite3-devel
=end
yamlfile = YAML.load(open('../website/config/database.yml'))
DB = Sequel.connect(database: yamlfile[:database], user: yamlfile[:username], password: yamlfile[:password], host: yamlfile[:host], port: yamlfile[:host], adapter: 'mysql2') 

#	Look at each line in the file and insert movie into database 
puts "Parsing and inserting from #{ARGV[0]}"
File.open(ARGV[0], 'r') do |film_info|
	film_info.each_line.with_index do |line, idx|
		movie = line.chomp.split(',')
		unless movie.length >= 6
			puts "#{ARGV[0]}:#{idx}: Data malformed!"
			return
		end
		movie_values = "'#{movie[0]}', '#{movie[1]}', '#{movie[2]}', '#{movie[4]}', '#{movie[3]}', '#{movie[5]}'"
		DB.run "INSERT INTO #{MOVIE_TABLE} (#{MOVIE_COLUMNS}) VALUES (#{movie_values})" if not element_exists? "'#{movie[0]}'", MOVIE_TABLE, "title"
	end
end

#	for each of these, add entry to the relational table
puts "Parsing and inserting from #{ARGV[1]}"
File.open(ARGV[1], 'r') do |genre_data|
	insert_relationship genre_data, GENRE_TABLE, GENRE_RELATION, GENRE_NAME, GENRE_ID
end

puts "Parsing and inserting from #{ARGV[2]}"
File.open(ARGV[2], 'r') do |director_data|
	insert_relationship director_data, DIRECTOR_TABLE, DIRECTOR_RELATION, DIRECTOR_NAME, DIRECTOR_ID
end

puts "Parsing and inserting from #{ARGV[3]}"
File.open(ARGV[3], 'r') do |actor_data|
	insert_relationship actor_data, ACTOR_TABLE, ACTOR_RELATION, ACTOR_NAME, ACTOR_ID
end
